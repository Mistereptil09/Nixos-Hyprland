{ config, lib, ... }:

{
  options.theme = {
    colors = lib.mkOption {
      type = lib.types.attrs;
      default = {
        primary = "#5294e2";
        background = "#383c4a";
        foreground = "#d3dae3";
      };
      description = "Color scheme for the system";
    };
    
    fonts = lib.mkOption {
      type = lib.types.attrs;
      default = {
        monospace = "Monospace";
        sans = "Noto Sans";
        serif = "Noto Serif";
        sizes = {
          normal = 11;
        };
      };
      description = "Font configuration";
    };
  };
}
