{ config, lib, ... }:

{
  options.theme = {
    colors = lib.mkOption {
      type = lib.types.attrs;
      default = {
        primary = "#5294e2";
        secondary = "#5cb85c";
        background = "#383c4a";
        foreground = "#d3dae3";
        alert = "#d23c3d";
      };
      description = "Color scheme for the system";
    };
    
    fonts = lib.mkOption {
      type = lib.types.attrs;
      default = {
        monospace = "JetBrainsMono Nerd Font";
        sans = "Noto Sans";
        serif = "Noto Serif";
        sizes = {
          small = 10;
          normal = 12;
          large = 14;
        };
      };
      description = "Font configuration";
    };
  };
}
