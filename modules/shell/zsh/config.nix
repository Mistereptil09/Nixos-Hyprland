{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.zsh;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.user.name} = { ... }: {
      programs.zsh = {
        enable = true;
        
        # History configuration
        history = {
          size = cfg.historySize;
          save = cfg.historySize;
          ignoreDups = true;
          share = true;
          path = "$HOME/.zsh_history";
        };
        
        # Directory navigation
        autocd = cfg.autocd;
        
        # Key bindings
        defaultKeymap = cfg.defaultKeymap;
        
        # Enable auto-suggestions and syntax highlighting
        enableAutosuggestions = cfg.autoSuggestions;
        enableSyntaxHighlighting = cfg.syntaxHighlighting;
        
        # Add prompt if starship is not enabled
        initExtra = lib.optionalString (!config.modules.shell.starship.enable) ''
          # Basic prompt configuration if starship is not enabled
          autoload -U colors && colors
          PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
        '' + ''
          # Better directory navigation
          setopt auto_pushd
          setopt pushd_ignore_dups
          setopt pushdminus
          
          # Additional useful options
          setopt extended_history
          setopt hist_expire_dups_first
          setopt hist_ignore_space
          setopt inc_append_history
          setopt complete_aliases
          
          # User customizations
          ${cfg.initExtra}
        '';
        
        # Recommended plugins
        plugins = cfg.plugins;
        
        # Standard aliases
        shellAliases = {
          ll = "ls -la";
          la = "ls -a";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          md = "mkdir -p";
          tree = "ls -R | grep \":$\" | sed -e 's/://' -e 's/[^-][^\\/]*\\//--/g' -e 's/^/   /' -e 's/-/|/'";
        };
        
        # Load completions better
        completionInit = ''
          # Better completion configuration
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive matching
          zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
          zstyle ':completion:*' menu select
          zstyle ':completion:*' verbose yes
          
          # Group matches and descriptions
          zstyle ':completion:*' group-name '''
          zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
          
          # Cache completions for better performance
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path "$HOME/.cache/zsh/.zcompcache"
        '';
      };
      
      # Optional: Custom zsh directory for configs
      home.file.".zsh" = {
        recursive = true;
        source = ../../assets/zsh;
        target = ".zsh";
      };
    };
  };
}
