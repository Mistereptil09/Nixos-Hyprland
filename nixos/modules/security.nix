{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnupg             # OpenPGP implementation for encryption, signing and key management
    keepassxc         # Password manager with browser integration and YubiKey support
    yubikey-manager   # Tool for configuring and using YubiKey devices
    age               # Modern file encryption tool, simpler alternative to GPG
    cryptsetup        # Disk encryption utility supporting LUKS for full disk encryption
  ];
  
  # Enable Yubikey support
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
}
