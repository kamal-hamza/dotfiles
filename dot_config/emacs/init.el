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

;; Bootstrap Elpaca - a modern, fast package manager for Emacs
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

;; Install use-package support for Elpaca
;; This allows us to use the familiar use-package syntax with Elpaca
(elpaca elpaca-use-package
  (elpaca-use-package-mode))

;; Block until current queue processed - important for packages used immediately
(elpaca-wait)

;; IMPORTANT: Set this so :ensure t works with use-package
(setq elpaca-use-package-by-default t)

;; ============================================================================
;; DASHBOARD (Welcome Screen)
;; ============================================================================

;; All-the-icons for beautiful icons (required by dashboard and doom-modeline)
;; IMPORTANT: After first install, run: M-x nerd-icons-install-fonts
(use-package nerd-icons
  :ensure t
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p)
  :custom
  (all-the-icons-scale-factor 1.2))     ; Make icons slightly larger

(use-package dashboard
  :ensure t
  :after all-the-icons
  :config
  ;; Dashboard provides a beautiful welcome screen with recent files, projects, etc.
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)  ; Use Emacs logo
  (setq dashboard-center-content t)      ; Center the content
  (setq dashboard-set-heading-icons t)   ; Show icons for headings
  (setq dashboard-set-file-icons t)      ; Show icons for files
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
                          (agenda . 5)
                          (bookmarks . 5)))
  (setq dashboard-banner-logo-title "Welcome to Emacs - Happy Hacking!")
  (setq dashboard-set-navigator t)       ; Show navigation buttons
  (setq dashboard-set-init-info t)       ; Show init time
  (setq dashboard-footer-messages '("Happy coding!"
                                    "May the force be with you!"
                                    "Live long and prosper!"
                                    "The power of Emacs compels you!"))
  ;; Dashboard with custom footer
  (setq dashboard-footer-icon (all-the-icons-octicon "dashboard"
                                                       :height 1.1
                                                       :v-adjust -0.05
                                                       :face 'font-lock-keyword-face)))

;; ============================================================================
;; BASIC EMACS SETTINGS
;; ============================================================================

;; UI Improvements
(setq inhibit-startup-message t)        ; Disable startup screen
(scroll-bar-mode -1)                    ; Disable visible scrollbar
(tool-bar-mode -1)                      ; Disable the toolbar
(tooltip-mode -1)                       ; Disable tooltips
(set-fringe-mode 10)                    ; Add breathing room
(menu-bar-mode -1)                      ; Disable the menu bar
(setq visible-bell t)                   ; Visual bell instead of beep

;; Line numbers
(column-number-mode)                    ; Show column number in mode line
(global-display-line-numbers-mode t)    ; Enable line numbers globally
(dolist (mode '(org-mode-hook           ; Disable line numbers for some modes
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Font configuration - Using Nerd Font for icons and symbols
;; Install a Nerd Font from: https://www.nerdfonts.com/
;; Popular options: JetBrainsMono Nerd Font, FiraCode Nerd Font, Hack Nerd Font
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 140)
(set-face-attribute 'fixed-pitch nil :font "JetBrainsMono Nerd Font" :height 140)
(set-face-attribute 'variable-pitch nil :font "JetBrainsMono Nerd Font" :height 140)

;; Set fallback fonts for symbols and emojis
(when (member "Symbols Nerd Font" (font-family-list))
  (set-fontset-font t 'symbol "Symbols Nerd Font" nil 'prepend))
(when (member "Apple Color Emoji" (font-family-list))
  (set-fontset-font t 'emoji "Apple Color Emoji" nil 'prepend))

;; Improve scrolling
(setq scroll-conservatively 101)        ; Smooth scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-follow-mouse 't)

;; Better defaults
(setq-default indent-tabs-mode nil)     ; Use spaces instead of tabs
(setq-default tab-width 4)              ; Tab width of 4
(setq make-backup-files nil)            ; No backup files
(setq auto-save-default nil)            ; No auto-save
(delete-selection-mode 1)               ; Replace selection when typing
(global-auto-revert-mode 1)             ; Auto-reload files changed on disk
(setq global-auto-revert-non-file-buffers t)  ; Also for Dired and others

;; Ctrl-h/j/k/l for window navigation (like Zed)
(global-set-key (kbd "C-h") 'evil-window-left)
(global-set-key (kbd "C-j") 'evil-window-down)
(global-set-key (kbd "C-k") 'evil-window-up)
(global-set-key (kbd "C-l") 'evil-window-right)

;; ============================================================================
;; EVIL MODE (Vim Emulation)
;; ============================================================================

(use-package evil
  :ensure t
  :demand t
  :init
  ;; Evil provides comprehensive Vim emulation
  (setq evil-want-integration t)        ; Enable Evil integration with other packages
  (setq evil-want-keybinding nil)       ; Required by evil-collection
  (setq evil-want-C-u-scroll t)         ; C-u scrolls up like in Vim
  (setq evil-want-C-i-jump t)           ; C-i jumps forward
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)    ; Use Emacs 28+ undo-redo system
  :config
  (evil-mode 1)
  ;; Use visual line motions outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; Set initial states for various modes
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  ;; Evil-collection provides Evil bindings for many Emacs modes
  (evil-collection-init))

(use-package evil-commentary
  :ensure t
  :after evil
  :config
  ;; Evil-commentary provides easy commenting (gcc to comment line)
  (evil-commentary-mode))

(use-package evil-surround
  :ensure t
  :after evil
  :config
  ;; Evil-surround provides commands to add/change/delete surrounding pairs
  ;; Example: cs"' changes "hello" to 'hello'
  (global-evil-surround-mode 1))

;; ============================================================================
;; GENERAL.EL (Better Keybinding Management with Evil)
;; ============================================================================

(use-package general
  :ensure t
  :demand t
  :config
  ;; General provides a more convenient way to define keybindings
  (general-evil-setup t)

  ;; Define a leader key (Space in normal mode)
  (general-create-definer my/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  ;; Leader key bindings (matching Zed workflow)
  (my/leader-keys
    ;; File operations
    "f"  '(:ignore t :which-key "files")
    "ff" '(counsel-find-file :which-key "find file")
    "fp" '(projectile-switch-project :which-key "open recent project")
    "fP" '((lambda () (interactive)
             (let ((dir (read-directory-name "Open directory as project: ")))
               (projectile-add-known-project dir)
               (projectile-switch-project-by-name dir))) :which-key "open any directory")
    "fg" '(projectile-ripgrep :which-key "grep in project")
    "fb" '(counsel-switch-buffer :which-key "switch buffer")
    "fr" '(counsel-recentf :which-key "recent files")
    "fs" '(save-buffer :which-key "save file")
    "fd" '(dired :which-key "open directory")

    ;; Panel & dock toggles
    "e"  '(:ignore t :which-key "explorer")
    "ee" '(treemacs :which-key "toggle file tree")

    ;; Git panel
    "g"  '(:ignore t :which-key "git")
    "gg" '(magit-status :which-key "git status")
    "gc" '(magit-commit :which-key "git commit")
    "gP" '(magit-pull :which-key "git pull")
    "gp" '(magit-push :which-key "git push")
    "gb" '(magit-branch :which-key "git branch")
    "ga" '(magit-stage-file :which-key "git add")
    "gA" '(magit-stage-modified :which-key "git stage all")
    "gu" '(magit-unstage-all :which-key "git unstage all")
    "gh" '(:ignore t :which-key "git hunk")
    "ghd" '(magit-diff :which-key "git diff")
    "gl" '(magit-log :which-key "git log")

    ;; Terminal
    "t"  '(:ignore t :which-key "terminal/toggle")
    "tt" '(vterm :which-key "toggle terminal")
    "td" '(lsp-ui-doc-mode :which-key "toggle diagnostics")
    "tn" '(display-line-numbers-mode :which-key "toggle line numbers")
    "tr" '((lambda () (interactive)
             (if (eq display-line-numbers-type 'relative)
                 (setq display-line-numbers-type t)
               (setq display-line-numbers-type 'relative))
             (display-line-numbers-mode)) :which-key "toggle relative numbers")

    ;; Delete/close
    "d"  '(:ignore t :which-key "delete/close")
    "db" '(kill-this-buffer :which-key "delete buffer")
    "dw" '(delete-window :which-key "delete window")

    ;; LSP
    "l"  '(:ignore t :which-key "lsp")
    "ll" '(lsp-ui-imenu :which-key "lsp menu")
    "lr" '(lsp-rename :which-key "rename")
    "lf" '(lsp-format-buffer :which-key "format buffer")
    "la" '(lsp-execute-code-action :which-key "code action")

    ;; Code actions
    "c"  '(:ignore t :which-key "code")
    "cc" '(lsp-execute-code-action :which-key "code actions")
    "cr" '(lsp-rename :which-key "rename")

    ;; Rename/replace
    "r"  '(:ignore t :which-key "rename/replace")
    "rr" '(lsp-rename :which-key "rename")
    "rR" '(evil-multiedit-match-all :which-key "select all matches")

    ;; Symbols
    "s" '(imenu :which-key "symbol outline")
    "S" '(lsp-ivy-workspace-symbol :which-key "workspace symbols")

    ;; Project
    "p"  '(:ignore t :which-key "project")
    "pp" '(projectile-switch-project :which-key "switch project")
    "pf" '(projectile-find-file :which-key "find file in project")
    "ps" '(projectile-ripgrep :which-key "search in project")
    "pc" '(projectile-compile-project :which-key "compile project")
    "pd" '(projectile-dired :which-key "open project root")
    "pa" '((lambda () (interactive)
             (let ((dir (read-directory-name "Add project directory: ")))
               (projectile-add-known-project dir)
               (message "Added %s to known projects" dir))) :which-key "add directory as project")

    ;; Buffer
    "b"  '(:ignore t :which-key "buffers")
    "bb" '(counsel-switch-buffer :which-key "switch buffer")
    "bd" '(kill-this-buffer :which-key "delete buffer")
    "bn" '(next-buffer :which-key "next buffer")
    "bp" '(previous-buffer :which-key "previous buffer")

    ;; Window
    "w"  '(:ignore t :which-key "window")
    "wh" '(evil-window-left :which-key "window left")
    "wj" '(evil-window-down :which-key "window down")
    "wk" '(evil-window-up :which-key "window up")
    "wl" '(evil-window-right :which-key "window right")
    "ws" '(evil-window-split :which-key "split horizontal")
    "wv" '(evil-window-vsplit :which-key "split vertical")
    "wd" '(evil-window-delete :which-key "delete window")
    "wm" '(delete-other-windows :which-key "maximize window")

    ;; Open
    "o"  '(:ignore t :which-key "open")
    "ot" '(vterm :which-key "terminal")
    "oe" '(treemacs :which-key "file tree")
    "od" '((lambda () (interactive) (dashboard-refresh-buffer)) :which-key "dashboard")

    ;; Jump
    "j"  '(:ignore t :which-key "jump")
    "jj" '(avy-goto-char-2 :which-key "jump to char")
    "jw" '(avy-goto-word-1 :which-key "jump to word")
    "jl" '(avy-goto-line :which-key "jump to line")

    ;; Other
    "u"  '(undo-tree-visualize :which-key "undo tree")
    "SPC" '(evil-search-highlight-persist-remove-all :which-key "clear search"))

  ;; Additional keybindings in normal mode (like Zed)
  (general-define-key
   :states 'normal
   :keymaps 'override
   "K" 'lsp-ui-doc-glance        ; Hover docs (like Shift-K in Zed)
   "gd" 'lsp-find-definition      ; Go to definition
   "gD" 'evil-window-vsplit       ; Go to definition split
   "gt" 'lsp-find-type-definition ; Go to type definition
   "gT" '(lambda () (interactive) ; Go to type definition split
           (evil-window-vsplit)
           (lsp-find-type-definition))
   "gr" 'lsp-find-references)     ; Go to references

  ;; Visual mode keybindings
  (general-define-key
   :states 'visual
   :keymaps 'override
   "J" 'evil-next-line
   "K" 'evil-previous-line))

;; ============================================================================
;; THEME
;; ============================================================================

(use-package doom-themes
  :config
  ;; Doom themes are modern, popular themes with good syntax highlighting
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)              ; Load doom-one theme
  (doom-themes-org-config))             ; Configure org-mode

;; ============================================================================
;; MODELINE
;; ============================================================================

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  ;; Doom modeline provides a beautiful, informative status line
  ((doom-modeline-height 30)            ; Increased from 25
   (doom-modeline-bar-width 4)          ; Increased from 3
   (doom-modeline-icon t)
   (doom-modeline-major-mode-icon t)
   (doom-modeline-major-mode-color-icon t)
   (doom-modeline-buffer-file-name-style 'truncate-upto-project)
   (doom-modeline-buffer-state-icon t)
   (doom-modeline-buffer-modification-icon t)
   (doom-modeline-lsp t)
   (doom-modeline-github t)
   (doom-modeline-modal-icon t)))

;; ============================================================================
;; WHICH-KEY
;; ============================================================================

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  ;; Which-key shows available keybindings in a popup
  (setq which-key-idle-delay 0.3)
  (setq which-key-popup-type 'side-window)
  (setq which-key-side-window-max-height 0.5)
  (setq which-key-side-window-max-width 0.5)
  ;; Increase font size for which-key
  (set-face-attribute 'which-key-local-map-description-face nil :height 1.1))

;; ============================================================================
;; IVY/COUNSEL/SWIPER (Completion Framework)
;; ============================================================================

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)               ; Better search
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  ;; Ivy is a completion framework for Emacs (alternative to Helm)
  (ivy-mode 1))

(use-package ivy-rich
  :init
  ;; Ivy-rich adds extra information to ivy completions
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)          ; Enhanced M-x with search
         ("C-x b" . counsel-ibuffer)    ; Better buffer switching
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

(use-package swiper)                    ; Better isearch

;; ============================================================================
;; HELPFUL (Better Help Pages)
;; ============================================================================

(use-package helpful
  :custom
  ;; Helpful provides better help buffers with more information
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; ============================================================================
;; PROJECTILE (Project Management)
;; ============================================================================

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; Projectile provides project-aware commands for navigation and management
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-action #'projectile-dired)
  ;; Automatically discover projects in search paths
  (setq projectile-track-known-projects-automatically t)
  ;; Save known projects to file
  (setq projectile-known-projects-file
        (expand-file-name "projectile-bookmarks.eld" user-emacs-directory)))

(use-package counsel-projectile
  :config (counsel-projectile-mode))    ; Integrate projectile with counsel

;; ============================================================================
;; MAGIT (Git Integration)
;; ============================================================================

(use-package transient
  :ensure t)

(use-package magit
  :ensure t
  :after transient
  :custom
  ;; Magit is the best Git interface for Emacs
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Note: evil-magit is deprecated, evil-collection handles Magit bindings

;; ============================================================================
;; LSP-MODE (Language Server Protocol)
;; ============================================================================

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  ;; LSP provides IDE-like features: completion, navigation, refactoring
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t)
  :custom
  ;; Performance tuning
  (lsp-idle-delay 0.1)                  ; Reduce delay for LSP actions
  (lsp-log-io nil)                      ; Disable logging for performance
  (lsp-completion-provider :capf)       ; Use completion-at-point
  (lsp-headerline-breadcrumb-enable t)  ; Show breadcrumb navigation
  (lsp-modeline-code-actions-enable t)  ; Show code actions in modeline
  (lsp-modeline-diagnostics-enable t)   ; Show diagnostics in modeline
  (lsp-signature-auto-activate t)       ; Show function signatures
  (lsp-signature-render-documentation t)
  (lsp-enable-snippet t)                ; Enable snippet support
  (lsp-enable-file-watchers t)
  (lsp-file-watch-threshold 2000))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  ;; LSP-UI provides UI elements like sideline info, documentation, etc.
  (lsp-ui-doc-position 'bottom)
  (lsp-ui-doc-delay 0.5)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-sideline-delay 0.5)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-code-actions t))

(use-package lsp-ivy
  :after lsp)                           ; Ivy integration for LSP

(use-package lsp-treemacs
  :after lsp)                           ; Treemacs integration for LSP

;; ============================================================================
;; COMPANY (Completion)
;; ============================================================================

(use-package company
  :after lsp-mode
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  ;; Company provides auto-completion
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0)              ; Instant completion
  (company-selection-wrap-around t)
  (company-tooltip-align-annotations t))

(use-package company-box
  :hook (company-mode . company-box-mode))  ; Pretty completion boxes

;; ============================================================================
;; FLYCHECK (Syntax Checking)
;; ============================================================================

(use-package flycheck
  :init (global-flycheck-mode)
  :custom
  ;; Flycheck provides on-the-fly syntax checking
  (flycheck-check-syntax-automatically '(save mode-enabled))
  (flycheck-display-errors-delay 0.3))

;; ============================================================================
;; YASNIPPET (Snippets)
;; ============================================================================

(use-package yasnippet
  :config
  ;; YASnippet provides template expansion (like code snippets)
  (yas-global-mode 1))

(use-package yasnippet-snippets)        ; Collection of snippets

;; ============================================================================
;; TREEMACS (File Tree)
;; ============================================================================

(use-package treemacs
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag))
  :config
  ;; Treemacs provides a file tree sidebar
  (setq treemacs-width 35)              ; Increased from 30
  (setq treemacs-text-scale 0)          ; Use default font size
  (setq treemacs-is-never-other-window t))

(use-package treemacs-nerd-icons
  :ensure t
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))   ; Use nerd icons theme

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-evil
  :after (treemacs evil))               ; Evil bindings for Treemacs

;; ============================================================================
;; RAINBOW DELIMITERS (Colorful Parentheses)
;; ============================================================================

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))  ; Color-code nested parens

;; ============================================================================
;; LANGUAGE-SPECIFIC CONFIGURATION
;; ============================================================================

;; Python
(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  ;; Python LSP requires: pip install python-lsp-server
  (python-shell-interpreter "python3"))

;; JavaScript/TypeScript
(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  ;; TypeScript LSP requires: npm install -g typescript typescript-language-server
  (setq typescript-indent-level 2))

(use-package js2-mode
  :mode "\\.js\\'"
  :hook (js2-mode . lsp-deferred)
  :config
  ;; JavaScript LSP requires: npm install -g typescript-language-server
  (setq js2-basic-offset 2))

;; Web mode (HTML/CSS/JSX/etc)
(use-package web-mode
  :mode (("\\.html?\\'" . web-mode)
         ("\\.css\\'" . web-mode)
         ("\\.jsx?\\'" . web-mode)
         ("\\.tsx?\\'" . web-mode))
  :hook (web-mode . lsp-deferred)
  :config
  ;; Web mode handles multiple web languages
  ;; CSS LSP requires: npm install -g vscode-langservers-extracted
  ;; HTML LSP requires: npm install -g vscode-langservers-extracted
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2))

;; Rust
(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . lsp-deferred)
  :config
  ;; Rust LSP requires: rustup component add rust-analyzer
  (setq rust-format-on-save t))

;; Go
(use-package go-mode
  :mode "\\.go\\'"
  :hook (go-mode . lsp-deferred)
  :config
  ;; Go LSP requires: go install golang.org/x/tools/gopls@latest
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))

;; C/C++
(add-hook 'c-mode-hook 'lsp-deferred)
(add-hook 'c++-mode-hook 'lsp-deferred)
;; C/C++ LSP requires: Install clangd (part of LLVM/Clang)

;; Java
(use-package lsp-java
  :hook (java-mode . lsp-deferred))
;; Java LSP requires: The extension will download Eclipse JDT LS automatically

;; Ruby
(use-package ruby-mode
  :mode "\\.rb\\'"
  :hook (ruby-mode . lsp-deferred))
;; Ruby LSP requires: gem install solargraph

;; PHP
(use-package php-mode
  :mode "\\.php\\'"
  :hook (php-mode . lsp-deferred))
;; PHP LSP requires: composer require jetbrains/phpstorm-stubs:dev-master

;; Markdown
(use-package markdown-mode
  :mode "\\.md\\'"
  :config
  (setq markdown-command "multimarkdown"))

;; YAML
(use-package yaml-mode
  :mode "\\.ya?ml\\'")

;; JSON
(use-package json-mode
  :mode "\\.json\\'")

;; Docker
(use-package dockerfile-mode
  :mode "Dockerfile\\'")

;; ============================================================================
;; TERMINAL
;; ============================================================================

(use-package vterm
  :commands vterm
  :config
  ;; Vterm provides a full-featured terminal emulator
  (setq vterm-max-scrollback 10000))

;; ============================================================================
;; ORG-MODE CONFIGURATION
;; ============================================================================

(use-package org
  :config
  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers t
        org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 0
        org-hide-block-startup nil
        org-src-preserve-indentation nil
        org-startup-folded 'content
        org-cycle-separator-lines 2))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :config
  ;; Evil-org provides Evil bindings for org-mode
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; ============================================================================
;; ADDITIONAL VIM-LIKE FEATURES
;; ============================================================================

(use-package evil-numbers
  :after evil
  :config
  ;; Evil-numbers provides C-a/C-x number increment/decrement in Evil
  (define-key evil-normal-state-map (kbd "C-c +") 'evil-numbers/inc-at-pt)
  (define-key evil-normal-state-map (kbd "C-c -") 'evil-numbers/dec-at-pt))

(use-package evil-matchit
  :after evil
  :config
  ;; Evil-matchit extends % to match HTML tags, if/end, etc.
  (global-evil-matchit-mode 1))

(use-package evil-indent-plus
  :after evil
  :config
  ;; Text objects for indentation levels (ii, ai, iI, aI)
  (evil-indent-plus-default-bindings))

(use-package evil-exchange
  :after evil
  :config
  ;; Exchange operator (gx to mark, gx again to exchange)
  (evil-exchange-install))

(use-package evil-args
  :after evil
  :config
  ;; Motions and text objects for function arguments
  ;; cia changes inner argument, daa deletes an argument
  (define-key evil-inner-text-objects-map "a" 'evil-inner-arg)
  (define-key evil-outer-text-objects-map "a" 'evil-outer-arg)
  (define-key evil-normal-state-map "L" 'evil-forward-arg)
  (define-key evil-normal-state-map "H" 'evil-backward-arg)
  (define-key evil-motion-state-map "L" 'evil-forward-arg)
  (define-key evil-motion-state-map "H" 'evil-backward-arg))

(use-package evil-lion
  :after evil
  :config
  ;; Align operator (gl and gL)
  (evil-lion-mode))

(use-package evil-goggles
  :after evil
  :config
  ;; Visual feedback for evil operations (shows what you're operating on)
  (evil-goggles-mode)
  (setq evil-goggles-duration 0.1))

;; Avy - Jump to any visible text quickly (like vim-easymotion)
(use-package avy
  :after evil
  :config
  (define-key evil-normal-state-map (kbd "s") 'avy-goto-char-2)
  (define-key evil-normal-state-map (kbd "S") 'avy-goto-word-1)
  (setq avy-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (setq avy-timeout-seconds 0.3))

;; Vim-style search highlighting
(use-package evil-search-highlight-persist
  :after evil
  :config
  (global-evil-search-highlight-persist t)
  ;; Clear search highlight with <leader><space>
  ;; Note: This uses general.el leader key defined above
  (with-eval-after-load 'general
    (my/leader-keys "SPC" 'evil-search-highlight-persist-remove-all)))

;; Multiple cursors (like vim-multiple-cursors)
(use-package evil-multiedit
  :after evil
  :config
  ;; Match symbol at point and edit all matches
  (define-key evil-normal-state-map "M-d" 'evil-multiedit-match-and-next)
  (define-key evil-visual-state-map "M-d" 'evil-multiedit-match-and-next)
  (define-key evil-insert-state-map "M-d" 'evil-multiedit-toggle-marker-here)
  (define-key evil-normal-state-map "M-D" 'evil-multiedit-match-and-prev)
  (define-key evil-visual-state-map "M-D" 'evil-multiedit-match-and-prev)
  (define-key evil-visual-state-map "R" 'evil-multiedit-match-all)
  ;; Multiedit state keybindings
  (with-eval-after-load 'evil-multiedit
    (when (boundp 'evil-multiedit-state-map)
      (define-key evil-multiedit-state-map (kbd "RET") 'evil-multiedit-toggle-or-restrict-region)
      (define-key evil-multiedit-state-map (kbd "C-n") 'evil-multiedit-next)
      (define-key evil-multiedit-state-map (kbd "C-p") 'evil-multiedit-prev))))

;; Undo tree visualization (better than Vim's undo)
(use-package undo-tree
  :after evil
  :config
  (global-undo-tree-mode)
  (setq undo-tree-visualizer-timestamps t)
  (setq undo-tree-visualizer-diff t)
  (setq undo-tree-auto-save-history t)
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  (evil-set-undo-system 'undo-tree))

;; Relative line numbers (like Vim's relativenumber)
(use-package display-line-numbers
  :ensure nil  ; Built-in package
  :config
  (setq display-line-numbers-type 'relative)
  (global-display-line-numbers-mode))

;; Smooth scrolling (better than Vim's default)
(use-package smooth-scrolling
  :config
  (smooth-scrolling-mode 1)
  (setq smooth-scroll-margin 5))

;; Highlight matching parens
(use-package paren
  :ensure nil  ; Built-in
  :config
  (setq show-paren-delay 0)
  (show-paren-mode 1))

;; Expand region (like Vim's visual mode expansion)
(use-package expand-region
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

;; Quick buffer switching (like Vim's buffer navigation)
(use-package ace-window
  :bind (("M-o" . ace-window))
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (setq aw-scope 'frame))

;; Vim-style marks with visual feedback
(use-package bm
  :bind (("<C-f2>" . bm-toggle)
         ("<f2>" . bm-next)
         ("<S-f2>" . bm-previous))
  :config
  (setq bm-cycle-all-buffers t)
  (setq bm-highlight-style 'bm-highlight-only-fringe))

;; ============================================================================
;; PERFORMANCE OPTIMIZATIONS
;; ============================================================================

;; Increase garbage collection threshold
(setq gc-cons-threshold (* 100 1024 1024))  ; 100 MB

;; Increase amount of data read from process
(setq read-process-output-max (* 1024 1024))  ; 1 MB

;;; init.el ends here
