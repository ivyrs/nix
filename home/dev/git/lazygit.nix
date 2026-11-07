{ lib, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = lib.mkDefault {
      os.editPreset = "nvim";

      git.pagers = [
        {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        }
      ];

      gui = {
        showRandomTip = false;
      };
    };
  };
}
