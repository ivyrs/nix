{ lib, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = lib.mkDefault {
      os.editPreset = "nvim";

      git.diffRenderers = [
        {
          colorArg = "always";
          command = "delta --dark --paging=never";
        }
      ];

      gui = {
        showRandomTip = false;
      };
    };
  };
}
