{ config, lib, pkgs, ... }:

{
  # Import all core module components
  imports = [
    ./nix.nix
    ./boot.nix
    ./networking.nix
  ];
  
  # Provide a simplified interface to enable all core modules at once
  options.modules.core = {
    enable = lib.mkEnableOption "Enable all core modules";
  };
  
  # When modules.core.enable is true, enable all sub-modules
  config = lib.mkIf config.modules.core.enable {
    modules.core = {
      nix.enable = true;
      boot.enable = true;
      networking.enable = true;
    };
  };
}
