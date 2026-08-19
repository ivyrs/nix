;; Basic settings
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; Treat "y"/"n" as valid answers to yes/no prompts
(defalias 'yes-or-no-p 'y-or-n-p)

;; Use UTF-8 everywhere
(set-charset-priority 'unicode)
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

;; Indentation
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; Sync $PATH from the shell (matters for GUI-launched Emacs, e.g. from niri)
(use-package exec-path-from-shell
  :init
  (exec-path-from-shell-initialize))

;; Fill column ruler at 80 chars
(setq-default fill-column 80)
(global-display-fill-column-indicator-mode 1)

;; Keep backup files out of the working directory
(setq backup-directory-alist '(("." . "~/.saves")))

;; Font configuration
(set-face-attribute 'default nil :font "Aporetic Sans" :height 120)
(set-face-attribute 'fixed-pitch nil :font "Aporetic Sans Mono")
(set-face-attribute 'variable-pitch nil :font "Aporetic Sans")

;; Enable line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Use-package setup
(require 'use-package)
(setq use-package-always-ensure t)

;; Evil mode (Vim keybindings)
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1))

;; Evil bindings for magit, dashboard, and other built-in/third-party modes
(use-package evil-collection
  :after evil
  :demand
  :config
  (evil-collection-init))

;; Vim-style comment toggling ("gc")
(use-package evil-nerd-commenter
  :general
  (general-nvmap
    "gc" 'evilnc-comment-operator))

;; Which-key
(use-package which-key
  :init
  (setq which-key-idle-delay 0.5) ; Open after .5s instead of 1s
  :config
  (which-key-mode))

;; General.el: SPC as a Vim-style leader key
(use-package general
  :demand
  :config
  (general-evil-setup)

  ;; eval-and-compile: general-create-definer expands to a `defmacro'
  ;; at runtime; without this, byte-compiling default.el (see
  ;; epkgs.trivialBuild in home-manager's emacs.nix) never sees
  ;; leader-keys as a macro, so every later `(leader-keys ...)` call
  ;; -- including the ones right below -- gets compiled as a plain
  ;; function call and fails at load time with "Invalid function:
  ;; leader-keys".
  (eval-and-compile
    (general-create-definer leader-keys
      :states '(normal insert visual emacs)
      :keymaps 'override
      :prefix "SPC"
      :global-prefix "C-SPC"))

  (leader-keys
    "x" '(execute-extended-command :which-key "execute command")
    "r" '(restart-emacs :which-key "restart emacs")
    "i" '((lambda () (interactive) (find-file user-init-file)) :which-key "open init file")

    ;; Buffer
    "b" '(:ignore t :which-key "buffer")
    ;; Don't show an error because SPC b ESC is undefined, just abort
    "b <escape>" '(keyboard-escape-quit :which-key t)
    "b d" 'kill-current-buffer))

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
(use-package nerd-icons
  :config
  ;; Ensure nerd-icons is loaded (fonts should be installed via nix)
  (require 'nerd-icons))

(use-package dashboard
  :after nerd-icons
  :config
  (setq dashboard-banner-logo-title nil)
  ;; Custom ASCII art banner
  ;; Options: 'official, 'logo, 1-3 (built-in ASCII), or path to file
  ;; e.g. "~/.config/emacs/banner.txt" or (expand-file-name "banner.txt" user-emacs-directory)
  (setq dashboard-startup-banner 1) ;; Built-in text banner
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
(use-package nyan-mode
  :init (nyan-mode))

;; Projectile for project management
(use-package projectile
  :general
  (leader-keys
    :states 'normal
    "SPC" '(projectile-find-file :which-key "find file")

    ;; Buffers
    "b b" '(projectile-switch-to-buffer :which-key "switch buffer")

    ;; Projects
    "p" '(:ignore t :which-key "projects")
    "p <escape>" '(keyboard-escape-quit :which-key t)
    "p p" '(projectile-switch-project :which-key "switch project")
    "p a" '(projectile-add-known-project :which-key "add project")
    "p r" '(projectile-remove-known-project :which-key "remove project"))
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; Ivy for fuzzy completion
(use-package ivy
  :config
  (ivy-mode))

;; Company mode for completion
(use-package company
  :config
  (global-company-mode))

;; Magit for Git
(use-package magit
  :bind ("C-x g" . magit-status)
  :general
  (leader-keys
    "g" '(:ignore t :which-key "git")
    "g <escape>" '(keyboard-escape-quit :which-key t)
    "g g" '(magit-status :which-key "status")
    "g l" '(magit-log :which-key "log"))
  (general-nmap
    "<escape>" #'transient-quit-one))

;; Highlight uncommitted changes in the gutter
(use-package diff-hl
  :init
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  :config
  (global-diff-hl-mode))

;; Terminal
(use-package vterm)
(use-package vterm-toggle
  :general
  (leader-keys
    "'" '(vterm-toggle :which-key "terminal")))

;; Tree-sitter major mode remapping (grammars come from Nix, see
;; extraPackages -- treesit-auto must not try to compile them itself,
;; since there's no C toolchain on PATH and the nix store is read-only)
(use-package treesit-auto
  :custom
  (treesit-auto-install nil)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; Eglot (built-in LSP client)
(use-package emacs
  :hook (rust-mode . eglot-ensure)
  :hook (typescript-mode . eglot-ensure)
  :hook (astro-ts-mode . eglot-ensure)
  :general
  (leader-keys
    "l" '(:ignore t :which-key "lsp")
    "l <escape>" '(keyboard-escape-quit :which-key t)
    "l r" '(eglot-rename :which-key "rename")
    "l a" '(eglot-code-actions :which-key "code actions")))

;; Astro mode
;;
;; astro-ts-mode's own package autoloads try to register themselves in
;; auto-mode-alist gated on (treesit-ready-p 'astro), but that runs during
;; package-activate-all -- before treesit.el has been loaded by anything
;; else -- so it errors with (void-function treesit-ready-p) and silently
;; never registers. Declaring :mode here explicitly is what actually makes
;; .astro files open in astro-ts-mode.
(use-package astro-ts-mode
  :mode "\\.astro\\'")

;; Markdown mode
(use-package markdown-mode
  :config
  (setq markdown-fontify-code-blocks-natively t))

;; Rust mode
(use-package rust-mode
  :general
  (leader-keys
    "m" '(:ignore t :which-key "mode")
    "m <escape>" '(keyboard-escape-quit :which-key t)
    "m b" '(rust-compile :which-key "build")
    "m r" '(rust-run :which-key "run")
    "m t" '(rust-test :which-key "test")
    "m k" '(rust-check :which-key "check")
    "m c" '(rust-run-clippy :which-key "clippy")))

;; Ripgrep-backed search
(use-package rg
  :general
  (leader-keys
    "f" '(rg-menu :which-key "find")))

;; Reduce GC-induced pauses
(use-package gcmh
  :demand
  :config
  (gcmh-mode 1))

;; ESC quits everything, Vim-style
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
