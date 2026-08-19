{inputs, ...}: {
  den.aspects.emacs.homeManager = {pkgs, ...}: {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk; # Pure GTK build for better Wayland support
      extraPackages = epkgs:
        with epkgs; [
          # Essential packages
          use-package
          evil # Vim keybindings
          evil-collection # Evil bindings for magit, dashboard, etc.
          evil-nerd-commenter # Vim-style comment toggling (gc)
          which-key # Keybind help
          general # SPC leader-key keybinding definitions
          restart-emacs # Backs the SPC r "restart emacs" binding
          exec-path-from-shell # Sync $PATH from the shell for GUI-launched Emacs

          # UI improvements
          catppuccin-theme
          doom-themes
          doom-modeline
          all-the-icons
          dashboard
          nerd-icons # Modern icon set for dashboard
          nyan-mode

          # Navigation and completion
          ivy
          counsel
          swiper
          company
          projectile # Project management for dashboard

          # Git integration
          magit
          diff-hl # Highlight uncommitted changes in the gutter

          # Terminal
          vterm
          vterm-toggle

          # Language support (eglot is built in; treesit-auto manages major-mode
          # remapping; grammars themselves come prebuilt from nixpkgs below,
          # since treesit-auto's own compile-on-demand needs a C toolchain
          # and a writable install dir, neither of which exist here)
          treesit-auto
          (treesit-grammars.with-grammars (grammars:
            with grammars; [
              tree-sitter-javascript
              tree-sitter-typescript
              tree-sitter-tsx
              tree-sitter-astro
              tree-sitter-css # astro-ts-mode embeds this for <style> blocks
            ]))

          # Programming languages
          rust-mode
          typescript-mode
          astro-ts-mode # Astro framework support
          nix-mode
          markdown-mode

          # Search
          rg

          # Org mode enhancements
          org-bullets
          org-roam

          # Performance
          gcmh
        ];

      extraConfig = builtins.readFile ./init.el;
    };
  };
}
