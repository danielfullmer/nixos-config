{ pkgs }:

let
  zsh-autosuggestions = pkgs.fetchFromGitHub {
    owner = "tarruda";
    repo = "zsh-autosuggestions";
    rev = "87facd9b85630f288433aa0a20a963cffc612ee5";
    sha256 = "0rkdcswqm5wlwrmb7vhj6099a8lsrw01zlzb5pj75pk24j22p4df";
  };
  zsh-completions = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-completions";
    rev = "69e89c5e4a1eae49325314df3718f0c734536e2a";
    sha256 = "1j2kgdlh8fykc8kghyd7as2m5j4hm71jqd660d0hf2dvy8svv35s";
  };
  zsh-syntax-highlighting = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-syntax-highlighting";
    rev = "e8af14fe1f6f1b60062b67d8a70daabd9df6a8be";
    sha256 = "1jkkwyk06k1hqk854bd5q39dkmmlfda4sp5xcd3ww404wyi7kpwp";
  };
in
''
if [[ "$TERM" == "xterm" && "$COLORTERM" == "gnome-terminal" ]]; then
	export TERM=xterm-256color
fi

bindkey -e # Use emacs keys

fpath=("${zsh-completions}/src" $fpath)
autoload -U compinit && compinit
source "${zsh-autosuggestions}/zsh-autosuggestions.zsh"
source "${zsh-syntax-highlighting}/zsh-syntax-highlighting.zsh"

source "${pkgs.base16}/shell/base16-tomorrow.dark.sh"

source "${./zshrc.prompt}"
''
