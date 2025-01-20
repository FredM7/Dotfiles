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
