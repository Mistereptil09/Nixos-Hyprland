{ config, lib, pkgs, ... }:

{
  # Import all core modules
  imports = [
    ./networking.nix
    ./hardware.nix
    ./users.nix
    ./boot.nix
    ./nix.nix
    ./security.nix
    ./system.nix
  ];

  # Core module common options
  options.modules.core = {
    # Enable all core modules by default
    enable = lib.mkEnableOption "Enable all core modules";
  };
  
  # Common core configuration
  config = {
    # Enable all core submodules when core is enabled
    modules.core = lib.mkIf config.modules.core.enable {
      networking.enable = lib.mkDefault true;
      hardware.enable = lib.mkDefault true;
      users.enable = lib.mkDefault true;
      boot.enable = lib.mkDefault true;
      nix.enable = lib.mkDefault true;
      security.enable = lib.mkDefault true;
      system.enable = lib.mkDefault true;
    };
  };
}
