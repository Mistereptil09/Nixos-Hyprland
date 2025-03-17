{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.networking;
in {
  options.modules.core.networking = {
    enable = lib.mkEnableOption "Enable networking configuration";
    
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "Machine hostname";
    };
    
    useNetworkManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use NetworkManager for network configuration";
    };
    
    useDHCP = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use DHCP for network configuration";
    };
    
    interfaces = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          useDHCP = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Use DHCP for this interface";
          };
          ipv4.addresses = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                address = lib.mkOption {
                  type = lib.types.str;
                  description = "IPv4 address";
                };
                prefixLength = lib.mkOption {
                  type = lib.types.int;
                  default = 24;
                  description = "Prefix length for IPv4 address";
                };
              };
            });
            default = [];
            description = "Static IPv4 addresses";
          };
        };
      });
      default = {};
      description = "Network interface configuration";
      example = {
        enp3s0 = {
          useDHCP = false;
          ipv4.addresses = [{
            address = "192.168.1.2";
            prefixLength = 24;
          }];
        };
      };
    };
    
    defaultGateway = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default gateway";
    };
    
    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["1.1.1.1" "8.8.8.8"];
      description = "DNS nameservers";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      hostName = cfg.hostName;
      
      # Network management
      networkmanager.enable = cfg.useNetworkManager;
      useDHCP = cfg.useDHCP;
      
      # Static interface configuration
      interfaces = lib.mapAttrs (name: interfaceCfg: {
        useDHCP = interfaceCfg.useDHCP;
        ipv4.addresses = interfaceCfg.ipv4.addresses;
      }) cfg.interfaces;
      
      # Default gateway and nameservers
      defaultGateway = cfg.defaultGateway;
      nameservers = cfg.nameservers;
    };
    
    # Add NetworkManager to system packages if enabled
    environment.systemPackages = lib.optionals cfg.useNetworkManager [ 
      pkgs.networkmanagerapplet
    ];
    
    # Add user to networkmanager group if needed
    users.users.${config.user.name} = lib.optionalAttrs cfg.useNetworkManager {
      extraGroups = [ "networkmanager" ];
    };
  };
}
