;;; init.el --- Complete Emacs IDE Configuration with Evil Mode
;;; Commentary:
;; A comprehensive Emacs configuration for multi-language development
;; Uses Elpaca package manager and Evil mode for Vim keybindings
;;
;; IMPORTANT: Create ~/.config/emacs/early-init.el with:
;; (setq package-enable-at-startup nil)
;;
;; Save this as ~/.config/emacs/init.el

;;; Code:

;; ============================================================================
;; ELPACA PACKAGE MANAGER BOOTSTRAP
;; ============================================================================

(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))
(elpaca elpaca-use-package (elpaca-use-package-mode))
(elpaca-wait)
(setq elpaca-use-package-by-default t)

;; ============================================================================
;; BASIC EMACS SETTINGS & FONT CONFIGURATION
;; ============================================================================

;; FONT SIZE CONFIGURATION (200 = 20pt)
(defvar my/font-size 200 "Base font size for all text in Emacs (1/10 pt units).")

;; Default fonts
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height my/font-size)
(set-face-attribute 'fixed-pitch nil :font "JetBrainsMono Nerd Font" :height my/font-size)
(set-face-attribute 'variable-pitch nil :font "JetBrainsMono Nerd Font" :height my/font-size)

(when (member "Symbols Nerd Font" (font-family-list))
  (set-fontset-font t 'symbol "Symbols Nerd Font" nil 'prepend))
(when (member "Apple Color Emoji" (font-family-list))
  (set-fontset-font t 'emoji "Apple Color Emoji" nil 'prepend))

;; UI Improvements
(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(setq visible-bell t)

;; Line numbers
(column-number-mode)
(global-display-line-numbers-mode t)
(dolist (mode '(org-mode-hook term-mode-hook shell-mode-hook eshell-mode-hook treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Better defaults
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq make-backup-files nil)
(setq auto-save-default nil)
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; Fix for duplicate item ID warnings
(setq warning-suppress-types '((emacs) (lsp-mode)))

;; Supress Warning Popup
(setq ring-bell-function 'ignore)

;; Ctrl-h/j/k/l for window navigation
(global-set-key (kbd "C-h") 'evil-window-left)
(global-set-key (kbd "C-j") 'evil-window-down)
(global-set-key (kbd "C-k") 'evil-window-up)
(global-set-key (kbd "C-l") 'evil-window-right)

;; ============================================================================
;; DASHBOARD
;; ============================================================================

(use-package nerd-icons
  :ensure t
  :custom (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p)
  :config (setq all-the-icons-scale-factor (/ my/font-size 100.0)))

(use-package dashboard
  :ensure t
  :after all-the-icons
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  ;; Explicitly define items to avoid LSP/auto-detection conflicts
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
                          (bookmarks . 5)))
  (setq dashboard-banner-logo-title "Welcome to Emacs")
  (setq dashboard-footer-messages '("Happy coding!")))

;; ============================================================================
;; EVIL MODE
;; ============================================================================

(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :ensure t
  :after evil
  :config (evil-collection-init))

(use-package evil-commentary
  :ensure t
  :after evil
  :config (evil-commentary-mode))

(use-package evil-surround
  :ensure t
  :after evil
  :config (global-evil-surround-mode 1))

;; ============================================================================
;; GENERAL.EL
;; ============================================================================

(use-package general
  :ensure t
  :demand t
  :config
  (general-evil-setup t)
  (general-create-definer my/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  ;; Matches your Zed keymap request
  (my/leader-keys
    ;; File operations
    "f"  '(:ignore t :which-key "files")
    "ff" '(counsel-find-file :which-key "find file")
    "fP" '(dired :which-key "open project") ; Added back as requested
    "fp" '(projectile-switch-project :which-key "recent project")
    "fg" '(projectile-ripgrep :which-key "grep in project")
    "fb" '(counsel-switch-buffer :which-key "switch buffer")
    "fs" '(save-buffer :which-key "save file")

    ;; Panel & dock toggles
    "e"  '(:ignore t :which-key "explorer")
    "ee" '(treemacs :which-key "toggle file tree")
    "tt" '(vterm :which-key "toggle terminal")
    "td" '(lsp-ui-doc-mode :which-key "toggle diagnostics")

    ;; Git panel
    "g"  '(:ignore t :which-key "git")
    "gg" '(magit-status :which-key "git status")
    "gc" '(magit-commit :which-key "git commit")
    "gP" '(magit-pull :which-key "git pull")
    "gp" '(magit-push :which-key "git push")
    "gb" '(magit-branch :which-key "git branch")

    ;; LSP & Code
    "l"  '(:ignore t :which-key "lsp")
    "ll" '(lsp-ui-imenu :which-key "lsp menu")
    "la" '(lsp-execute-code-action :which-key "code action")
    "r"  '(:ignore t :which-key "rename")
    "rr" '(lsp-rename :which-key "rename")
    "s"  '(imenu :which-key "symbol outline")
    "S"  '(lsp-ivy-workspace-symbol :which-key "workspace symbols")

    ;; Debugger (DAP)
    "d"  '(:ignore t :which-key "debugger/delete")
    "db" '(kill-this-buffer :which-key "delete buffer")
    "ds" '(dap-debug :which-key "start debugging")
    "dS" '(dap-disconnect :which-key "stop debugging")
    "dr" '(dap-debug-restart :which-key "restart debugging")
    "dc" '(dap-continue :which-key "continue")
    "di" '(dap-step-in :which-key "step in")
    "do" '(dap-step-out :which-key "step out")
    "dO" '(dap-next :which-key "step over")
    "dt" '(dap-breakpoint-toggle :which-key "toggle breakpoint")

    ;; Other
    "SPC" '(evil-search-highlight-persist-remove-all :which-key "clear search"))

  (general-define-key
   :states 'normal
   :keymaps 'override
   "K" 'lsp-ui-doc-glance
   "gd" 'lsp-find-definition
   "gD" 'evil-window-vsplit
   "gr" 'lsp-find-references))

;; ============================================================================
;; COMPLETION: IVY / COUNSEL / SWIPER
;; ============================================================================

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ;; ZED-STYLE TAB CYCLING CONFIGURATION
         ;; TAB cycles down, Shift-TAB cycles up
         ("TAB" . ivy-next-line)
         ("<backtab>" . ivy-previous-line)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("TAB" . ivy-next-line)
         ("<backtab>" . ivy-previous-line))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :init (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)))

;; ============================================================================
;; COMPLETION: COMPANY
;; ============================================================================

(use-package company
  :after lsp-mode
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
         ;; ZED-STYLE TAB CYCLING CONFIGURATION
         ("TAB" . company-select-next)
         ("<tab>" . company-select-next)
         ("<backtab>" . company-select-previous)
         ("S-TAB" . company-select-previous)
         ("RET" . company-complete-selection))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0)
  (company-selection-wrap-around t))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; ============================================================================
;; PROJECT MANAGEMENT
;; ============================================================================

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap ("C-c p" . projectile-command-map))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(setq projectile-project-search-path '("~/Code/"))

;; ============================================================================
;; LSP & DAP (Language Server & Debug Adapter)
;; ============================================================================

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t)

  ;; --------------------------------------------------------------------------
  ;; META PYREFLY CONFIGURATION (Python)
  ;; --------------------------------------------------------------------------
  ;; Registers the 'pyrefly' client. Ensure 'pyrefly' binary is in your PATH.
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("pyrefly" "lsp"))
                    :major-modes '(python-mode python-ts-mode)
                    :server-id 'pyrefly
                    :priority 10 ;; Set high priority to prefer it over pylsp/pyright
                    :download-server-fn (lambda (_client callback error-callback _update?)
                                          (funcall callback))))
  :custom
  (lsp-idle-delay 0.1)
  (lsp-completion-provider :capf)
  (lsp-headerline-breadcrumb-enable t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom)
  (lsp-ui-sideline-show-hover t))

(use-package lsp-ivy :after lsp)
(use-package lsp-treemacs :after lsp)

;; DAP MODE (Debug Adapter Protocol)
(use-package dap-mode
  :ensure t
  :after lsp-mode
  :config
  (dap-auto-configure-mode)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (require 'dap-node)
  (require 'dap-chrome)
  (require 'dap-lldb)
  (require 'dap-gdb-lldb)
  (require 'dap-python)
  (require 'dap-go)
  (require 'dap-netcore))

;; ============================================================================
;; LANGUAGE SUPPORT
;; ============================================================================

;; --- Python (Pyrefly) ---
(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :config
  (setq python-shell-interpreter "python3")
  (require 'dap-python))

;; --- JS / TS (Node/Chrome) ---
(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred))
(use-package js2-mode
  :mode "\\.js\\'"
  :hook (js2-mode . lsp-deferred)
  :config (dap-register-debug-template "Node::Attach"
            (list :type "node" :request "attach" :name "Node::Attach")))

;; --- Go (Golang) ---
(use-package go-mode
  :mode "\\.go\\'"
  :hook (go-mode . lsp-deferred)
  :config
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t)
  (require 'dap-go))

;; --- Rust (Rustic) ---
;; Better than standard rust-mode
(use-package rustic
  :ensure t
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  (setq rustic-format-on-save t)
  (setq rustic-lsp-client 'lsp-mode))

;; --- C / C++ (Clangd) ---
;; Requires 'clangd' installed system-wide
(add-hook 'c-mode-hook 'lsp-deferred)
(add-hook 'c++-mode-hook 'lsp-deferred)

;; --- Dart / Flutter ---
(use-package dart-mode
  :ensure t
  :hook (dart-mode . lsp-deferred)
  :custom
  (dart-format-on-save t))

(use-package lsp-dart
  :ensure t
  :hook (dart-mode . lsp)
  :config
  ;; Enable flutter widget guides (like in VS Code)
  (setq lsp-dart-flutter-widget-guides t))

;; --- Zig ---
(use-package zig-mode
  :ensure t
  :hook (zig-mode . lsp-deferred)
  :config
  ;; Ensure 'zls' is in your PATH
  (setq lsp-zig-zls-executable "zls"))

;; --- C# (Omnisharp/Csharp-ls) ---
(use-package csharp-mode
  :ensure t
  :hook (csharp-mode . lsp-deferred))

;; --- F# ---
(use-package fsharp-mode
  :ensure t
  :hook (fsharp-mode . lsp-deferred)
  :config
  ;; Requires 'fsautocomplete'
  (setq inferior-fsharp-program "dotnet fsi --readline-"))

;; --- Assembly (x86_64 / Aarch64) ---
(use-package nasm-mode
  :ensure t
  :mode "\\.nasm\\'" "\\.asm\\'")

;; Generic ASM LSP (asm-lsp)
;; Install server via: cargo install asm-lsp
(use-package lsp-mode
  :config
  (add-to-list 'lsp-language-id-configuration '(nasm-mode . "asm"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection "asm-lsp")
                    :major-modes '(nasm-mode asm-mode)
                    :server-id 'asm-lsp)))

;; --- Configuration Files (JSON/TOML/INI/Elisp) ---
(use-package json-mode :mode "\\.json\\'")
(use-package toml-mode :mode "\\.toml\\'")
;; Generic conf-mode for INI, or specific package
(use-package ini-mode
  :ensure t
  :mode "\\.ini\\'" "\\.conf\\'")

;; Elisp support is built-in but can be enhanced
(use-package elisp-autofmt
  :ensure t
  :commands (elisp-autofmt-mode lsp-elisp-autofmt-mode)
  :hook (emacs-lisp-mode . elisp-autofmt-mode))

;; ============================================================================
;; TREEMACS & THEMES
;; ============================================================================

(use-package treemacs
  :config
  (setq treemacs-width 45)
  (setq treemacs-text-scale (/ my/font-size 10)))

(use-package treemacs-nerd-icons
  :config (treemacs-load-theme "nerd-icons"))

(use-package doom-themes
  :config
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 30)))

(use-package which-key
  :init (which-key-mode)
  :config
  (set-face-attribute 'which-key-local-map-description-face nil :height (/ my/font-size 100.0)))

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

(load-theme 'soft-focus-light t)

;; ============================================================================
;; PERFORMANCE & FINAL
;; ============================================================================

(setq gc-cons-threshold (* 100 1024 1024))
(setq read-process-output-max (* 1024 1024))

;;; init.el ends here
