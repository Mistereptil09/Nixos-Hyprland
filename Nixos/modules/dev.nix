{ config, lib, pkgs, ... }:

{
  # Development tooling
  environment.systemPackages = with pkgs; [
    # Editors and IDEs
    vscode              # Visual Studio Code - versatile code editor with extensions
    jetbrains.idea-community # IntelliJ IDEA - Java/Kotlin IDE (community edition)
    neovim              # Modern, improved version of Vim
    
    # Version control
    gh                  # GitHub's official command line tool
    gitui               # Terminal-based UI for Git with keyboard-centric controls
    delta               # Syntax-highlighting pager for git
    
    # Languages and runtimes
    nodejs              # JavaScript/TypeScript runtime environment
    python3             # Python programming language interpreter and standard library
    rustup              # Rust toolchain installer and version management
    # ...other language runtimes...
    
    # Build tools
    gnumake             # GNU Make - build automation tool
    cmake               # Cross-platform build system generator
    gcc                 # GNU Compiler Collection - standard C/C++ compiler
    
    # Docker
    docker              # Containerization platform
    docker-compose      # Multi-container Docker applications tool
    
    # Terminal utilities
    tmux                # Terminal multiplexer for session management
    fzf                 # Command-line fuzzy finder
    ripgrep             # Fast grep alternative written in Rust
    bat                 # Cat clone with syntax highlighting
    fd                  # Fast and user-friendly alternative to 'find'
    exa                 # Modern replacement for ls command
    
    # Documentation
    zeal                # Offline documentation browser for developers
  ];

  # Docker service
  virtualisation.docker.enable = true;
  users.users.YOUR_USERNAME.extraGroups = [ "docker" ];
  
  # VSCode server for remote development
  # services.code-server = {
  #   enable = true;
  #   host = "127.0.0.1";
  #   port = 8080;
  # };
  
  # PostgreSQL database
  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_14;
  #   enableTCPIP = true;
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     local all all trust
  #     host all all 127.0.0.1/32 trust
  #     host all all ::1/128 trust
  #   '';
  # };
}