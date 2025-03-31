{ config, lib, pkgs, currentUsername ? "antonio", ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.${currentUsername} = {
      # Wofi configuration
      home.file.".config/wofi/style.css".text = ''
        window {
          margin: 5px;
          border: 2px solid #8be9fd;
          background-color: #282a36;
          border-radius: 15px;
        }
        
        #input {
          margin: 5px;
          border: none;
          color: #f8f8f2;
          background-color: #44475a;
          border-radius: 10px;
        }
        
        #inner-box {
          margin: 5px;
          border: none;
          background-color: #282a36;
          border-radius: 10px;
        }
        
        #outer-box {
          margin: 5px;
          border: none;
          background-color: #282a36;
          border-radius: 10px;
        }
        
        #scroll {
          margin: 5px;
          border: none;
        }
        
        #text {
          margin: 5px;
          border: none;
          color: #f8f8f2;
        }
        
        #entry:selected {
          background-color: #44475a;
          border-radius: 10px;
        }
      '';
      
      home.file.".config/wofi/config".text = ''
        show=drun
        width=400
        height=500
        always_parse_args=true
        show_all=true
        print_command=true
        insensitive=true
        prompt=Search...
      '';
    };
  };
}
