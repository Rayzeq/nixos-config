{ lib, ... }: {
  mangohud = {
    enable = true;

    enableSessionWide = true;
    settings = [
      {
        legacy_layout = false;
        table_columns = 2;
        pci_dev = "0:07:00.0";
        position = "middle-left";
        round_corners = 10;
        font_size = 20;
        blacklist = "";
      }
      {
        text_color = "FFFFFF";
        gpu_color = "2E9762";
        cpu_color = "2E97CB";
        frametime_color = "FFFFFF";
        background_color = "000000";
        background_alpha = 0.6;
      }
      {
        gpu_stats = true;
        gpu_text = "GPU";
        gpu_load_change = true;
        gpu_load_value = [ "50" "90" ];
        gpu_load_color = [ "FFFFFF" "FFAA7F" "CC0000" ];
      }
      {
        cpu_stats = true;
        cpu_text = "CPU";
        cpu_load_change = true;
        cpu_load_value = [ "50" "90" ];
        cpu_load_color = [ "FFFFFF" "FFAA7F" "CC0000" ];
      }
      {
        fps = true;
        fps_color_change = true;
        fps_value = [ "30" "60" ];
        fps_color = [ "B22222" "FDFD09" "39F900" ];
      }
      { frame_timing = true; }
    ];
  };
}
