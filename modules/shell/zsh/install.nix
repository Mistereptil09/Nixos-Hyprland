{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.zsh;
in {
  config = lib.mkIf cfg.enable {
    # System-level ZSH setup
    programs.zsh = {
      enable = true;
      
      # Include additional completions
      enableCompletion = true;
      
      # System-wide zshrc additions
      interactiveShellInit = ''
        # System-wide ZSH configuration
        export HISTSIZE=${toString cfg.historySize}
        export SAVEHIST=${toString cfg.historySize}
        
        # Basic setup
        setopt HIST_IGNORE_DUPS
        setopt HIST_FIND_NO_DUPS
        setopt HIST_REDUCE_BLANKS
      '';
      
      # Load plugins at system level
      syntaxHighlighting.enable = cfg.syntaxHighlighting;
      autosuggestions.enable = cfg.autoSuggestions;
    };
    
    # Ensure ZSH is installed with additional tools
    environment.systemPackages = with pkgs; [
      zsh
      zsh-completions
    ] ++ lib.optionals cfg.syntaxHighlighting [ zsh-syntax-highlighting ]
      ++ lib.optionals cfg.autoSuggestions [ zsh-autosuggestions ];
  };
}
