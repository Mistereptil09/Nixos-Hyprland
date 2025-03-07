{
  # All available modules (using clearer naming)
  all = [
    "desktop-system"     # System-level desktop integration (Hyprland, display manager)
    "desktop-user"       # User-level desktop configuration  
    "apps"               # User applications
    "gaming-system"      # System-level gaming support (drivers, kernel tweaks) 
    "gaming-user"        # User-level gaming applications
    "dev"                # Development tools
    "media"              # Media creation and consumption
    "security"           # Security tools and services
    "virtualization"     # Virtualization support
    "system-utils"       # System-level utilities
    "user-utils"         # User-level utilities
  ];

  # Strictly system-level modules (services, drivers, system configs)
  system = [
    "desktop-system"     # Core Hyprland system integration
    "gaming-system"      # Gaming drivers and system optimizations
    "security"           # System security features
    "virtualization"     # VM and container support
    "system-utils"       # System utilities
  ];

  # Strictly user-level modules (applications, user preferences)
  user = [
    "desktop-user"       # User-specific desktop settings
    "apps"               # User applications
    "gaming-user"        # Gaming software without system integration
    "dev"                # Development tools
    "media"              # Media tools
    "user-utils"         # User utilities
  ];

  # Module dependencies
  dependencies = {
    "desktop-user" = ["desktop-system"];
    "gaming-user" = ["gaming-system"];
    "dev" = ["virtualization"];
  };
}
