{ pkgs }:

let
  zsh-autosuggestions = pkgs.fetchFromGitHub {
    owner = "tarruda";
    repo = "zsh-autosuggestions";
    rev = "fedc22e9bbd046867860e772d7d6787f5dae9d4c";
    sha256 = "0mnwyz4byvckrslzqfng5c0cx8ka0y12zcy52kb7amg3l07jrls4";
  };
  zsh-completions = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-completions";
    rev = "44e821b7032bcaea90cbdaa724e94b8e3e98ddd1";
    sha256 = "0s9y4v8cgpjsipxfaaxsmcbkc6g0kndhwm64aj7bffnz88jkh55v";
  };
  zsh-syntax-highlighting = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-syntax-highlighting";
    rev = "9396ad5c5f9cc40f461e59fe1c5fd2cb70d9b723";
    sha256 = "0mx6q52ixcv8yvgjy2nxfv1qd08mk8gn3s7pjr9ixv3rqf7mqm6n";
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
