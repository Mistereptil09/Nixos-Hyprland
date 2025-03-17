{ config, lib, pkgs, ... }:

{
  imports = [
    ./fzf.nix
    ./direnv.nix
    ./zoxide.nix
  ];

  options.modules.shell.utilities = {
    enable = lib.mkEnableOption "Enable common shell utilities";
    
    modern-unix = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install modern replacements for classic Unix commands";
    };
  };

  config = lib.mkIf config.modules.shell.utilities.enable {
    # System-wide packages for utilities
    environment.systemPackages = with pkgs; lib.mkIf config.modules.shell.utilities.modern-unix [
      bat     # Better cat replacement
      eza     # Better ls replacement
      fd      # Better find replacement
      ripgrep # Better grep replacement
      du-dust # Better du replacement
      jq      # JSON processor
      bottom  # Better top replacement
      yazi    # Terminal file manager
    ];
    
    # User-level configuration
    home-manager.users.${config.user.name} = { ... }: lib.mkIf config.modules.shell.utilities.modern-unix {
      # Set up aliases for modern utilities
      home.shellAliases = {
        cat = "bat";
        ls = "eza";
        ll = "eza -la";
        find = "fd";
        grep = "rg";
        du = "dust";
        top = "btm";
      };
    };
  };
}
