{inputs, ...}: {
  den.aspects.emacs.homeManager = {pkgs, ...}: {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk; # Pure GTK build for better Wayland support
      extraPackages = epkgs: with epkgs; [
        # Essential packages
        use-package
        evil                    # Vim keybindings
        which-key              # Keybind help
        
        # UI improvements
        catppuccin-theme
        doom-themes
        doom-modeline
        all-the-icons
        dashboard
        nerd-icons  # Modern icon set for dashboard
        
        # Navigation and completion
        ivy
        counsel
        swiper
        company
        projectile  # Project management for dashboard
        
        # Git integration
        magit
        
        # Language support
        lsp-mode
        lsp-ui
        flycheck
        
        # Programming languages
        rust-mode
        typescript-mode
        nix-mode
        markdown-mode
        
        # Org mode enhancements
        org-bullets
        org-roam
      ];
      
      # Optional: Add custom Emacs Lisp configuration
      extraConfig = ''
        ;; Basic settings
        (setq inhibit-startup-message t)
        (tool-bar-mode -1)
        (menu-bar-mode -1)
        (scroll-bar-mode -1)
        
        ;; Font configuration
        (set-face-attribute 'default nil :font "Aporetic Sans (mono)" :height 110)
        (set-face-attribute 'fixed-pitch nil :font "Aporetic Sans (mono)")
        (set-face-attribute 'variable-pitch nil :font "Aporetic Sans (mono)")
        
        ;; Enable line numbers
        (global-display-line-numbers-mode 1)
        
        ;; Use-package setup
        (require 'use-package)
        (setq use-package-always-ensure t)
        
        ;; Evil mode (Vim keybindings)
        (use-package evil
          :init
          (setq evil-want-integration t)
          (setq evil-want-keybinding nil)
          :config
          (evil-mode 1))
        
        ;; Which-key
        (use-package which-key
          :config
          (which-key-mode))
        
        ;; Theme - check for noctalia first, then fall back to Catppuccin
        (use-package catppuccin-theme)
        (use-package doom-themes)
        
        ;; Add noctalia theme directories to load path if they exist
        ;; Noctalia outputs to themes/noctalia-theme.el in the first existing config dir
        (dolist (dir '("~/.config/doom/themes"
                       "~/.config/emacs/themes"
                       "~/.emacs.d/themes"))
          (when (file-directory-p (expand-file-name dir))
            (add-to-list 'custom-theme-load-path (expand-file-name dir))))
        
        ;; Try to load noctalia theme first, fall back to Catppuccin
        (condition-case nil
            (load-theme 'noctalia :no-confirm)
          (error (load-theme 'catppuccin :no-confirm)))
        
        ;; Auto-reload theme when noctalia regenerates it
        (defun reload-noctalia-theme ()
          "Reload the noctalia theme."
          (interactive)
          (when (custom-theme-enabled-p 'noctalia)
            (disable-theme 'noctalia)
            (condition-case nil
                (load-theme 'noctalia :no-confirm)
              (error (message "Failed to reload noctalia theme")))))
        
        ;; Watch noctalia theme file for changes and reload automatically
        (when (require 'filenotify nil t)
          (let ((theme-paths '("~/.config/doom/themes/noctalia-theme.el"
                               "~/.config/emacs/themes/noctalia-theme.el"
                               "~/.emacs.d/themes/noctalia-theme.el")))
            (dolist (path theme-paths)
              (when (file-exists-p (expand-file-name path))
                (file-notify-add-watch
                 (expand-file-name path)
                 '(change)
                 (lambda (event)
                   (when (eq (nth 1 event) 'changed)
                     (run-with-timer 0.5 nil #'reload-noctalia-theme))))))))
        
        ;; Dashboard - clean minimal splash screen
        (use-package nerd-icons)
        
        (use-package dashboard
          :after nerd-icons
          :config
          (setq dashboard-banner-logo-title nil)
          (setq dashboard-startup-banner nil) ;; No logo
          (setq dashboard-center-content t)
          (setq dashboard-show-shortcuts nil)
          (setq dashboard-items '((recents  . 5)
                                  (projects . 5)))
          (setq dashboard-set-heading-icons t)
          (setq dashboard-set-file-icons t)
          (setq dashboard-icon-type 'nerd-icons)
          (setq dashboard-set-navigator nil)
          (setq dashboard-set-footer nil)
          (setq dashboard-page-separator "\n\n")
          (dashboard-setup-startup-hook))
        
        ;; Modeline
        (use-package doom-modeline
          :init (doom-modeline-mode 1))
        
        ;; Projectile for project management
        (use-package projectile
          :config
          (projectile-mode +1)
          (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))
        
        ;; Company mode for completion
        (use-package company
          :config
          (global-company-mode))
        
        ;; Magit for Git
        (use-package magit
          :bind ("C-x g" . magit-status))
      '';
    };
  };
}