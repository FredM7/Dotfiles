if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting
    fastfetch
end

# Set up NVM for Fish
function nvm
  bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
end
set -x NVM_DIR ~/.nvm
nvm use default --silent

# Set up Flutter
set PATH /home/fred/.flutter/flutter/bin $PATH

# pnpm
set -gx PNPM_HOME "/home/fred/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/fred/.gcloud/path.fish.inc' ]; . '/home/fred/.gcloud/path.fish.inc'; end

# opencode
fish_add_path /home/fred/.opencode/bin


# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<

# Hermes Agent — ensure ~/.local/bin is on PATH
fish_add_path "$HOME/.local/bin"
