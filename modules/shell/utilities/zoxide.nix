{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.utilities.zoxide;
in {
  options.modules.shell.utilities.zoxide = {
    enable = lib.mkEnableOption "Enable zoxide for smarter directory navigation";
    
    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Bash integration";
    };
    
    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Zsh integration";
    };
    
    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Fish integration";
    };
    
    options = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Options to pass to zoxide init";
      example = ["--cmd cd" "--hook pwd"];
    };
  };

  config = lib.mkIf cfg.enable {
    # System-level packages
    environment.systemPackages = with pkgs; [
      zoxide
    ];
    
    # User-level configuration
    home-manager.users.${config.user.name} = { ... }: {
      programs.zoxide = {
        enable = true;
        enableBashIntegration = cfg.enableBashIntegration; 
        enableZshIntegration = cfg.enableZshIntegration;
        enableFishIntegration = cfg.enableFishIntegration;
        options = cfg.options;
      };
    };
  };
}
