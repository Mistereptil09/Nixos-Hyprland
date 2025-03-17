{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.tmux;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.user.name} = { ... }: {
      programs.tmux = {
        enable = true;
        
        # Basic configuration
        keyMode = cfg.keyMode;
        prefix = "C-${cfg.shortcut}";
        terminal = cfg.terminal;
        historyLimit = cfg.historyLimit;
        
        # Common tmux settings
        sensibleOnTop = true;
        escapeTime = 0;
        baseIndex = 1;
        
        extraConfig = ''
          # Enable mouse support
          set -g mouse on
          
          # Use 24-bit color
          set -sa terminal-features ',*:RGB'
          
          # Support for focus events
          set -g focus-events on
          
          ${cfg.extraConfig}
        '';
      };
      
      # Bash integration
      programs.bash = lib.mkIf cfg.enableBashIntegration {
        enable = true;
        initExtra = ''
          # Tmux Bash integration
          if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
            # Add tmux helper aliases
            alias tn="tmux new -s"
            alias ta="tmux attach -t"
            alias tl="tmux list-sessions"
            alias tk="tmux kill-session -t"
          fi
        '';
      };
      
      # Zsh integration
      programs.zsh = lib.mkIf cfg.enableZshIntegration {
        enable = true;
        initExtra = ''
          # Tmux Zsh integration
          if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
            # Add tmux helper aliases
            alias tn="tmux new -s"
            alias ta="tmux attach -t"
            alias tl="tmux list-sessions"
            alias tk="tmux kill-session -t"
          fi
        '';
      };
      
      # Fish integration
      programs.fish = lib.mkIf cfg.enableFishIntegration {
        enable = true;
        interactiveShellInit = ''
          # Tmux Fish integration
          if command -v tmux &>/dev/null; and not set -q TMUX
            # Add tmux helper functions for fish
            alias tn="tmux new -s"
            alias ta="tmux attach -t"
            alias tl="tmux list-sessions"
            alias tk="tmux kill-session -t"
          end
        '';
        
        # Fish-specific shell functions for tmux
        functions = {
          # Example fish function for creating or attaching to a tmux session
          tms = ''
            # Usage: tms [session name]
            # If session name is provided, attaches to it or creates it
            # If no name provided, lists existing sessions or creates 'main'
            if test -z "$argv[1]"
              if tmux has-session 2>/dev/null
                tmux list-sessions
              else
                tmux new -s main
              end
            else
              tmux new -A -s "$argv[1]"
            end
          '';
        };
      };
    };
  };
}
