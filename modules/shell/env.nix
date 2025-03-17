{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.env;
in {
  options.modules.shell.env = {
    enable = lib.mkEnableOption "Enable common environment settings";
    
    variables = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Environment variables to set globally";
      example = {
        EDITOR = "nvim";
        VISUAL = "code";
        LANG = "en_US.UTF-8";
      };
    };
    
    path = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Directories to add to PATH";
      example = [ "$HOME/.local/bin" "$HOME/.cargo/bin" ];
    };
    
    shellAliases = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Shell aliases to set across all shells";
      example = {
        g = "git";
        dc = "docker-compose";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # System-wide environment variables
    environment.variables = cfg.variables;
    
    # Update system PATH
    environment.extraInit = lib.concatMapStrings (p: ''
      export PATH="${p}:$PATH"
    '') cfg.path;
    
    # User-level environment settings
    home-manager.users.${config.user.name} = { ... }: {
      # User environment variables
      home.sessionVariables = cfg.variables;
      
      # User PATH extension
      home.sessionPath = cfg.path;
      
      # Shell aliases
      home.shellAliases = cfg.shellAliases;
    };
  };
}
