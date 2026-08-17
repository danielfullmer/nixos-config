# Runs :checkhealth against the configured Neovim (pkgs/overlays.nix)
# and fails if any check reports an error.
#
# A plain derivation rather than a VM test: it runs the same wrapper
# (full config, all plugins) in the build sandbox, where the
# nvim-treesitter check (~200 prebuilt grammars) takes ~25s instead of
# the ~5-10 minutes it takes on the VM's 9p-backed store.
#
# The build environment mirrors the tools the health checks probe for
# that exist on the user's system: git (nvim-treesitter check), curl
# (the pynvim version check in vim.provider, filtered below), a UTF-8
# locale (vim.health), and a writable $HOME.  The sandbox default
# (/homeless-shelter) is
# unwritable, and vim/lsp/log.lua runs vim.fn.mkdir on stdpath('log') at
# load time: with a bad $HOME that throws at startup, marks vim.lsp as
# failed, and every later require('vim.lsp')/require('lspconfig.util')
# (including inside the health checks) dies with "loop or previous error
# loading module".  It also fails the shada check.
{ pkgs }:
let
  vimPkgs = pkgs.appendOverlays (import ../pkgs/overlays.nix);
in
vimPkgs.runCommand "vim-checkhealth" {
  nativeBuildInputs = [
    vimPkgs.neovim
    # The system config ships no C compiler; provide one so the
    # nvim-treesitter check doesn't fail on the missing `cc` executable.
    pkgs.stdenv.cc
    pkgs.git
    pkgs.curl
  ];
}
''
  export HOME="$TMPDIR"
  export LC_ALL=C.UTF-8

  # The sandbox does not pre-create $out (structured-attrs protocol);
  # create it so the :w! below can write the report into it.
  mkdir -p "$out"

  vim --headless -c 'checkhealth' -c "w! $out/health.txt" -c 'qa!' > run.log 2>&1 \
    || {
      echo "vim failed while running :checkhealth; its messages:" >&2
      cat run.log >&2
      exit 1
    }

  # Keep a copy in the build directory: with --keep-failed the $out
  # contents are rolled back, but this survives for inspection.  Not
  # fatal: if the write failed, the gate below reports it properly.
  cp "$out/health.txt" health-copy.txt 2>/dev/null || :

  # A failed :w! (e.g. E212) does not make vim exit non-zero, so check
  # run.log for vim error messages before trusting the report (a plugin
  # crash while loading or while running one of its checks, "E5113:
  # Argument error", "Error executing vimEnter Autocmds").  All gates
  # below are explicit: a bare command failing under `bash -e` exits
  # silently, with no build log at all.
  if grep -nE 'E[0-9]{3}:|Error executing' run.log; then
    echo "vim checkhealth: vim emitted error messages:" >&2
    cat run.log >&2
    exit 1
  fi
  if [ ! -s "$out/health.txt" ]; then
    echo "vim checkhealth: health report was not written" >&2
    cat run.log >&2
    exit 1
  fi
  if ! grep -q 'nvim-treesitter:' "$out/health.txt"; then
    echo "vim checkhealth: report is missing the nvim-treesitter section" >&2
    exit 1
  fi

  # One check inherently cannot run here: the Python 3 provider sub-check
  # queries PyPI (https://pypi.org/pypi/pynvim) for the latest pynvim
  # version, and the build sandbox has no network access, so it always
  # reports "ERROR HTTP request failed: ... curl error ... : 6"
  # (CURLE_COULDNT_RESOLVE_HOST) regardless of config health.  It is the
  # only such error in the report; drop its two detail lines and the
  # affected section summary line before gating.  A *real* vim.provider
  # error (e.g. "pynvim is not installed") still reports its own detail
  # line and still fails the gate.  Nothing else is exempted.
  sed -e '/Could not contact PyPI/d' \
    -e '/HTTP request failed/d' \
    -e '/^vim\.provider:.*❌/d' \
    "$out/health.txt" > health-filtered.txt

  # Fail if any check reports an error.  Match both the current report
  # format (section status "1 ❌", detail lines "- ❌ ERROR ...") and the
  # older one ("1 [ERROR]").  -A3 includes the continuation lines (e.g.
  # exception text) in the failure output.
  if grep -nA3 -E '❌|\[ERROR\]' health-filtered.txt; then
    echo "vim checkhealth: errors reported (lines above)" >&2
    echo "vim's messages:" >&2
    cat run.log >&2
    exit 1
  fi

  echo "vim checkhealth: no errors found"
''
