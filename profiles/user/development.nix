{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  
  config = {
    # Development packages
    home.packages = with pkgs; [
      # Languages and runtimes
      python3
      nodejs
      rustup
      go
      
      # Build tools
      cmake
      gnumake
      gcc
      
      # Development tools
      vscode
      insomnia # API client
      docker-compose
      
      # Git tools
      gitui
      gh # GitHub CLI
      git-absorb
    ];
    
    # Git configuration
    programs.git = {
      enable = true;
      userName = lib.mkDefault "Developer";
      userEmail = lib.mkDefault "dev@example.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };
    
    # VSCode configuration
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        ms-python.python
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb
        eamodio.gitlens
        tamasfe.even-better-toml
      ];
      userSettings = {
        "editor.fontFamily" = "${config.theme.fonts.monospace}";
        "editor.formatOnSave" = true;
        "editor.renderWhitespace" = "boundary";
        "telemetry.telemetryLevel" = "off";
        "workbench.colorTheme" = "Tokyo Night";
      };
    };
    
    # Neovim configuration (basic setup)
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
