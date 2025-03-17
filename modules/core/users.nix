{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.users;
in {
  options.modules.core.users = {
    enable = lib.mkEnableOption "Enable user configuration";
    
    primaryUser = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            example = "alice";
            description = "Primary user name";
          };
          
          description = lib.mkOption {
            type = lib.types.str;
            default = "Primary User";
            description = "User description";
          };
          
          initialPassword = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Initial password (not recommended for production)";
          };
          
          isNormalUser = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether the user is a normal user";
          };
          
          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = ["wheel" "video" "audio" "networkmanager" "input" "render"];
            description = "Extra groups for the user";
          };
          
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "User-specific packages";
          };
          
          hashedPassword = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "User's hashed password";
          };
          
          uid = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "User ID";
          };
          
          openssh.authorizedKeys.keys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "SSH public keys for the user";
          };
        };
      };
    };
    
    extraUsers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          description = lib.mkOption {
            type = lib.types.str;
            default = "User";
            description = "User description";
          };
          
          isNormalUser = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether the user is a normal user";
          };
          
          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Extra groups for the user";
          };
          
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "User-specific packages";
          };
          
          hashedPassword = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "User's hashed password";
          };
        };
      });
      default = {};
      description = "Additional users";
    };
    
    defaultUserShell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bash;
      description = "Default shell for users";
      example = "pkgs.zsh";
    };
    
    autoLoginUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "User to automatically log in to the console";
    };
  };

  config = lib.mkIf cfg.enable {
    # Set up the primary user
    users.users.${cfg.primaryUser.name} = {
      inherit (cfg.primaryUser) isNormalUser description extraGroups packages;
      initialPassword = cfg.primaryUser.initialPassword;
      hashedPassword = cfg.primaryUser.hashedPassword;
      uid = cfg.primaryUser.uid;
      shell = config.modules.shell.${config.modules.shell.defaultShell}.enable or false
        ? pkgs.${config.modules.shell.defaultShell}
        : cfg.defaultUserShell;
      openssh.authorizedKeys.keys = cfg.primaryUser.openssh.authorizedKeys.keys;
    };
    
    # Set the user option used throughout the configuration
    user = {
      name = cfg.primaryUser.name;
      description = cfg.primaryUser.description;
    };
    
    # Set up any extra users
    users.users = lib.mapAttrs (name: userCfg: {
      inherit (userCfg) isNormalUser description extraGroups packages hashedPassword;
      shell = cfg.defaultUserShell;
    }) cfg.extraUsers;
    
    # Configure auto-login if enabled
    services.getty.autologinUser = cfg.autoLoginUser;
  };
}
