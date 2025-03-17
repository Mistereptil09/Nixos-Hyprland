{ config, lib, pkgs, ... }:

{
  imports = [
    ./install.nix
    ./config.nix
  ];

  options.modules.shell.starship = {
    enable = lib.mkEnableOption "Enable Starship shell prompt";
    
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
    
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Starship configuration settings";
      example = {
        add_newline = true;
        format = "$all";
        scan_timeout = 10;
      };
    };
    
    preset = lib.mkOption {
      type = lib.types.enum [ "plain" "nerd-font" "tokyo-night" "pastel" "minimal" "none" ];
      default = "nerd-font";
      description = "Predefined style preset to use";
    };
  };
}
