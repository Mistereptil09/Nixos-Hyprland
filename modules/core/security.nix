{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.security;
in {
  options.modules.core.security = {
    enable = lib.mkEnableOption "Enable security configuration";
    
    sudo = {
      enable = lib.mkEnableOption "Enable sudo";
      
      wheelNeedsPassword = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether wheel group needs a password for sudo";
      };
      
      wheelOnlyCommand = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Limit wheel group to certain commands";
      };
    };
    
    doas = {
      enable = lib.mkEnableOption "Enable doas";
    };
    
    pam = {
      enableFingerprintAuth = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable fingerprint authentication";
      };
    };
    
    firewall = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable firewall";
      };
      
      allowPing = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Allow ping";
      };
      
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [];
        description = "Allowed TCP ports";
      };
      
      allowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [];
        description = "Allowed UDP ports";
      };
    };
    
    polkit.enable = lib.mkEnableOption "Enable polkit authentication agent";
    
    ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable SSH server";
      };
      
      permitRootLogin = lib.mkOption {
        type = lib.types.enum ["yes" "no" "prohibit-password" "without-password" "forced-commands-only"];
        default = "no";
        description = "Whether to allow root login";
      };
      
      passwordAuthentication = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to allow password authentication";
      };
    };

    physicalSecurity = {
      lockScreen = {
        enable = lib.mkEnableOption "Enable automatic screen locking";
        timeout = lib.mkOption {
          type = lib.types.int;
          default = 300;
          description = "Timeout in seconds before locking the screen";
        };
        lockCommand = lib.mkOption {
          type = lib.types.str;
          default = "${pkgs.swaylock}/bin/swaylock -f";
          description = "Command to run to lock the screen";
        };
      };
    };
    
    harden = {
      enable = lib.mkEnableOption "Enable system hardening";
      
      kernel = lib.mkEnableOption "Harden kernel parameters";
      
      restrictSUIDPrograms = lib.mkEnableOption "Restrict SUID programs";
      
      hideProcFiles = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Hide sensitive files in /proc";
      };
    };
    
    apparmor = {
      enable = lib.mkEnableOption "Enable AppArmor";
      
      enforcing = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enforce AppArmor profiles";
      };
    };
    
    auditd = {
      enable = lib.mkEnableOption "Enable auditd";
      
      rules = lib.mkOption {
        type = lib.types.lines;
        default = ''
          # Log authentication events
          -w /etc/shadow -p wa -k auth
          -w /etc/passwd -p wa -k auth
          -w /etc/group -p wa -k auth
          -w /etc/gshadow -p wa -k auth
          
          # Log unsuccessful authorization attempts
          -a always,exit -F arch=b64 -S open -F exit=-EACCES -k access
          -a always,exit -F arch=b64 -S open -F exit=-EPERM -k access
        '';
        description = "Auditd rules";
      };
    };
    
    rkhunter = {
      enable = lib.mkEnableOption "Enable rootkit hunter";
      
      checkFrequency = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        description = "How often to run rootkit checks";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Sudo configuration
    security.sudo = lib.mkIf cfg.sudo.enable {
      enable = true;
      wheelNeedsPassword = cfg.sudo.wheelNeedsPassword;
      extraRules = lib.optionals (cfg.sudo.wheelOnlyCommand != null) [
        {
          groups = ["wheel"];
          commands = [
            {
              command = cfg.sudo.wheelOnlyCommand;
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
    
    # Doas configuration
    security.doas = lib.mkIf cfg.doas.enable {
      enable = true;
      extraRules = [
        {
          groups = ["wheel"];
          persist = true;
          keepEnv = true;
        }
      ];
    };
    
    # Fingerprint authentication
    services.fprintd.enable = cfg.pam.enableFingerprintAuth;
    security.pam.services.login.fprintAuth = cfg.pam.enableFingerprintAuth;
    security.pam.services.xscreensaver.fprintAuth = cfg.pam.enableFingerprintAuth;
    
    # Firewall configuration
    networking.firewall = {
      enable = cfg.firewall.enable;
      allowPing = cfg.firewall.allowPing;
      allowedTCPPorts = cfg.firewall.allowedTCPPorts;
      allowedUDPPorts = cfg.firewall.allowedUDPPorts;
    };
    
    # Polkit authentication agent
    security.polkit.enable = cfg.polkit.enable;
    
    # SSH server configuration
    services.openssh = lib.mkIf cfg.ssh.enable {
      enable = true;
      settings = {
        PermitRootLogin = cfg.ssh.permitRootLogin;
        PasswordAuthentication = cfg.ssh.passwordAuthentication;
        X11Forwarding = false;
        KbdInteractiveAuthentication = false;
      };
    };

    # Screen locking
    services.xserver.xautolock = lib.mkIf cfg.physicalSecurity.lockScreen.enable {
      enable = true;
      time = cfg.physicalSecurity.lockScreen.timeout / 60;
      locker = cfg.physicalSecurity.lockScreen.lockCommand;
    };
    
    # System hardening
    security.protectKernelImage = lib.mkIf cfg.harden.kernel true;
    boot.kernel.sysctl = lib.mkIf cfg.harden.kernel {
      # Restrict kernel pointer access
      "kernel.kptr_restrict" = 2;
      # Restrict access to kernel logs
      "kernel.dmesg_restrict" = 1;
      # Restrict kernel sysrq functionality
      "kernel.sysrq" = 0;
      # Protect against SMAP bypass
      "vm.mmap_min_addr" = 65536;
      # Protect against ptrace-based process inspection
      "kernel.yama.ptrace_scope" = 1;
      # Randomize memory space layout
      "kernel.randomize_va_space" = 2;
    };
    
    # Hide sensitive /proc files
    security.hideProcessInformation = cfg.harden.hideProcFiles;
    
    # Restrict SUID binaries
    security.allowSimultaneousMultithreading = !cfg.harden.restrictSUIDPrograms;
    
    # AppArmor configuration
    security.apparmor = lib.mkIf cfg.apparmor.enable {
      enable = true;
      killUnconfinedProcesses = cfg.apparmor.enforcing;
      packages = [ pkgs.apparmor-profiles ];
    };
    
    # Auditd configuration
    security.auditd.enable = cfg.auditd.enable;
    security.audit.rules = lib.mkIf cfg.auditd.enable cfg.auditd.rules;
    
    # Rootkit hunter
    services.rkhunter = lib.mkIf cfg.rkhunter.enable {
      enable = true;
      timer = cfg.rkhunter.checkFrequency;
    };
    
    # Add security tools to system packages
    environment.systemPackages = with pkgs; [
      openssl
      gnupg
      pinentry
      lsof
    ] 
    ++ lib.optional cfg.apparmor.enable apparmor-utils
    ++ lib.optional cfg.rkhunter.enable rkhunter;
  };
}
