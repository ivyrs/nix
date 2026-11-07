{ pkgs, ... }:

{
  imports = [
    ./format.nix
    ./git.nix
    ./lsp.nix
    ./ux.nix
  ];

  vim = {
    viAlias = true;
    vimAlias = true;

    options = {
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;
      expandtab = true;
    };

    treesitter.enable = true;
    languages.enableTreesitter = true;

    autocomplete.blink-cmp.enable = true;
    autopairs.nvim-autopairs.enable = true;
    comments.comment-nvim.enable = true;

    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
      transparent = true;
    };

    extraPlugins = {
      vim-sleuth = {
        package = pkgs.vimPlugins.vim-sleuth;
      };
    };
  };
}
