{ config, lib, pkgs, ... }:

{
  # Development tools
  home.packages = with pkgs; [
    # Editors and IDEs
    vscode
    neovim
    
    # Version control
    gh
    gitui
    delta
    
    # Languages and runtimes
    nodejs
    python3
    rustup
    
    # Build tools
    gnumake
    cmake
    gcc
    
    # Terminal utilities
    tmux
    fzf
    ripgrep
    bat
    fd
    exa
  ];
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    delta.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
  
  # VSCode configuration
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      ms-python.python
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      jnoortheen.nix-ide
    ];
    userSettings = {
      "editor.fontFamily" = "'JetBrains Mono', 'monospace'";
      "editor.fontSize" = 14;
      "editor.lineNumbers" = "relative";
      "workbench.colorTheme" = "Monokai";
    };
  };
  
  # Neovim configuration
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };
}
