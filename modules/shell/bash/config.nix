{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.bash;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.user.name} = { ... }: {
      programs.bash = {
        enable = true;
        historySize = cfg.historySize;
        historyControl = cfg.historyControl;
        historyIgnore = cfg.historyIgnore;
        shellOptions = cfg.shellOptions;
        
        # Enable bash completions
        enableCompletion = true;
        
        # Add bash-specific prompt if starship is not enabled
        initExtra = lib.optionalString (!config.modules.shell.starship.enable) ''
          # Set up a nice prompt if starship is not enabled
          PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        '' + cfg.extraConfig;
        
        # User's bash profile
        profileExtra = ''
          # Source global definitions
          if [ -f /etc/bashrc ]; then
              . /etc/bashrc
          fi

          # User specific environment
          if ! [[ "$PATH" =~ "$HOME/.local/bin" ]]; then
              PATH="$HOME/.local/bin:$PATH"
          fi
          export PATH
        '';
      };
    };
  };
}
