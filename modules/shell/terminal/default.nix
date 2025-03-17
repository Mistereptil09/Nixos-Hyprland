{ config, lib, pkgs, ... }:

{
  imports = [
    ./kitty.nix
    ./alacritty.nix
    ./foot.nix
  ];

  options.modules.shell.terminal = {
    default = lib.mkOption {
      type = lib.types.enum [ "kitty" "alacritty" "foot" "none" ];
      default = "kitty";
      description = "Default terminal emulator to use";
    };
    
    font = {
      family = lib.mkOption {
        type = lib.types.str;
        default = config.theme.fonts.monospace;
        description = "Font family for terminal";
      };
      
      size = lib.mkOption {
        type = lib.types.int;
        default = config.theme.fonts.sizes.normal;
        description = "Font size for terminal";
      };
    };
    
    opacity = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Background opacity (0.0 to 1.0)";
    };
    
    scrollback = lib.mkOption {
      type = lib.types.int;
      default = 10000;
      description = "Lines of scrollback history";
    };
  };
  
  config = {
    # Enable the selected terminal
    modules.shell.terminal = {
      kitty.enable = (config.modules.shell.terminal.default == "kitty");
      alacritty.enable = (config.modules.shell.terminal.default == "alacritty");
      foot.enable = (config.modules.shell.terminal.default == "foot");
    };
    
    # Set standard TERM environment variable
    home-manager.users.${config.user.name} = lib.mkIf (config.modules.shell.terminal.default != "none") { 
      home.sessionVariables.TERMINAL = config.modules.shell.terminal.default;
    };
  };
}
