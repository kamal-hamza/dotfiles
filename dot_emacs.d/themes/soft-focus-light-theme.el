(deftheme soft-focus-light
      "Soft Focus Light Theme for Emacs.
       Auto-generated from central color palette.")

    (let ((class '((class color) (min-colors 89)))
          ;; Palette Variables
          (bg      "#ffffff")
          (bg-alt  "#f5f5f5")
          (bg-hl   "#eeeeee")
          (fg      "#000000")
          (fg-alt  "#666666")
          (fg-dim  "#888888")
          (primary "#448cbb")
          (second  "#4da6ff")
          (third   "#77d5ff")
          (mint    "#2d5f4f")

          ;; Semantic
          (success "#558855")
          (warning "#b8943d")
          (err     "#C42847")
          (info    "#4da6ff")

          ;; UI Elements
          (cursor  "#000000")
          (region  "#e0e0e0")
          (ln-bg   "#f0f0f0")
          (border  "#d0d0d0")
          (border-active "#448cbb")
          (search  "#d5d5d5")

           ;; Syntax (derived from base palette colors)
          (comment "#888888")
          (keyword "#C42847")
          (func    "#4da6ff")
          (string  "#558855")
          (type    "#448cbb")
          (const   "#b8943d")
          (var     "#000000")
          (operator "#666666")
          (property "#4da6ff")
          (attribute "#b8943d")
          (tag "#C42847")
          (punctuation "#666666")

          ;; Diff
          (diff-add-bg "#d0f5d0")
          (diff-add-fg "#558855")
          (diff-chg-bg "#f5f5d0")
          (diff-chg-fg "#b8943d")
          (diff-del-bg "#f5d0d0")
          (diff-del-fg "#C42847")

          ;; Terminal Colors
          (ansi-black   "#000000")
          (ansi-red     "#C42847")
          (ansi-green   "#558855")
          (ansi-yellow  "#b8943d")
          (ansi-blue    "#448cbb")
          (ansi-magenta "#9a6e6d")
          (ansi-cyan    "#4da6ff")
          (ansi-white   "#f5f5f5")
          (ansi-br-black   "#666666")
          (ansi-br-red     "#ff4c6a")
          (ansi-br-green   "#77aa77")
          (ansi-br-yellow  "#D4B87B")
          (ansi-br-blue    "#67b7f5")
          (ansi-br-magenta "#B88E8D")
          (ansi-br-cyan    "#77d5ff")
          (ansi-br-white   "#ffffff"))

      (custom-theme-set-faces
       'soft-focus-light

       ;; --- Core UI ---
       `(default ((,class (:foreground ,fg :background ,bg))))
       `(cursor ((,class (:background ,cursor))))
       `(region ((,class (:background ,region :extend t))))
       `(highlight ((,class (:background ,ln-bg :foreground ,fg))))
       `(hl-line ((,class (:background ,ln-bg :extend t))))
       `(fringe ((,class (:background ,bg :foreground ,fg-dim))))
       `(vertical-border ((,class (:foreground ,border))))
       `(window-divider ((,class (:foreground ,border))))
       `(window-divider-first-pixel ((,class (:foreground ,border))))
       `(window-divider-last-pixel ((,class (:foreground ,border))))
       `(minibuffer-prompt ((,class (:foreground ,primary :weight bold))))
       `(link ((,class (:foreground ,second :underline t))))
       `(link-visited ((,class (:foreground ,third :underline t))))
       `(error ((,class (:foreground ,err :weight bold))))
       `(warning ((,class (:foreground ,warning :weight bold))))
       `(success ((,class (:foreground ,success :weight bold))))
       `(shadow ((,class (:foreground ,fg-dim))))

       ;; --- Mode Line ---
       `(mode-line ((,class (:background ,bg-hl :foreground ,fg :box (:line-width 1 :color ,border)))))
       `(mode-line-inactive ((,class (:background ,bg :foreground ,fg-alt :box (:line-width 1 :color ,border)))))
       `(mode-line-buffer-id ((,class (:weight bold :foreground ,primary))))
       `(mode-line-emphasis ((,class (:weight bold :foreground ,second))))
       `(header-line ((,class (:inherit mode-line-inactive))))

       ;; --- Font Lock (Syntax Highlighting) ---
       `(font-lock-builtin-face ((,class (:foreground ,func))))
       `(font-lock-comment-face ((,class (:foreground ,comment :slant italic))))
       `(font-lock-comment-delimiter-face ((,class (:foreground ,comment))))
       `(font-lock-constant-face ((,class (:foreground ,const))))
       `(font-lock-doc-face ((,class (:foreground ,comment :slant italic))))
       `(font-lock-function-name-face ((,class (:foreground ,func))))
       `(font-lock-keyword-face ((,class (:foreground ,keyword))))
       `(font-lock-negation-char-face ((,class (:foreground ,operator))))
       `(font-lock-preprocessor-face ((,class (:foreground ,keyword))))
       `(font-lock-string-face ((,class (:foreground ,string))))
       `(font-lock-type-face ((,class (:foreground ,type))))
       `(font-lock-variable-name-face ((,class (:foreground ,var))))
       `(font-lock-warning-face ((,class (:foreground ,warning :weight bold))))
       `(font-lock-regexp-grouping-backslash ((,class (:foreground ,const))))
       `(font-lock-regexp-grouping-construct ((,class (:foreground ,const))))
       `(font-lock-operator-face ((,class (:foreground ,operator))))
       `(font-lock-property-face ((,class (:foreground ,property))))
       `(font-lock-punctuation-face ((,class (:foreground ,punctuation))))
       `(font-lock-bracket-face ((,class (:foreground ,punctuation))))
       `(font-lock-delimiter-face ((,class (:foreground ,punctuation))))

       ;; --- Line Numbers ---
       `(line-number ((,class (:foreground ,fg-dim :background ,bg))))
       `(line-number-current-line ((,class (:foreground ,primary :background ,ln-bg :weight bold))))

       ;; --- Search ---
       `(isearch ((,class (:background ,search :foreground ,fg :weight bold))))
       `(isearch-fail ((,class (:background ,err :foreground ,bg))))
       `(lazy-highlight ((,class (:background ,region :foreground ,fg))))
       `(match ((,class (:background ,search :foreground ,fg))))

       ;; --- Parens / Smartparens ---
       `(show-paren-match ((,class (:background ,region :weight bold))))
       `(show-paren-mismatch ((,class (:background ,err :foreground ,bg :weight bold))))
       `(sp-show-pair-match-face ((,class (:background ,region))))

       ;; --- Org Mode ---
       `(org-level-1 ((,class (:foreground ,primary :weight bold :height 1.3))))
       `(org-level-2 ((,class (:foreground ,second :weight bold :height 1.15))))
       `(org-level-3 ((,class (:foreground ,mint :weight bold :height 1.05))))
       `(org-level-4 ((,class (:foreground ,ansi-blue :weight bold))))
       `(org-level-5 ((,class (:foreground ,ansi-magenta :weight bold))))
       `(org-level-6 ((,class (:foreground ,ansi-cyan :weight bold))))
       `(org-level-7 ((,class (:foreground ,ansi-green :weight bold))))
       `(org-level-8 ((,class (:foreground ,ansi-yellow :weight bold))))
       `(org-date ((,class (:foreground ,second :underline t))))
       `(org-footnote ((,class (:foreground ,third :underline t))))
       `(org-link ((,class (:foreground ,second :underline t))))
       `(org-special-keyword ((,class (:foreground ,fg-alt))))
       `(org-block ((,class (:background ,bg-alt :extend t))))
       `(org-block-begin-line ((,class (:foreground ,fg-dim :background ,bg-alt :extend t))))
       `(org-block-end-line ((,class (:foreground ,fg-dim :background ,bg-alt :extend t))))
       `(org-quote ((,class (:inherit org-block :slant italic))))
       `(org-code ((,class (:foreground ,success :background ,bg-alt))))
       `(org-verbatim ((,class (:foreground ,success :background ,bg-alt))))
       `(org-table ((,class (:foreground ,fg))))
       `(org-formula ((,class (:foreground ,const))))
       `(org-checkbox ((,class (:foreground ,primary :weight bold))))
       `(org-todo ((,class (:foreground ,warning :weight bold))))
       `(org-done ((,class (:foreground ,success :weight bold))))
       `(org-tag ((,class (:foreground ,fg-alt :weight bold))))
       `(org-priority ((,class (:foreground ,warning))))
       `(org-document-title ((,class (:foreground ,primary :weight bold :height 1.5))))
       `(org-document-info ((,class (:foreground ,fg-alt))))
       `(org-meta-line ((,class (:foreground ,fg-dim))))

       ;; --- Markdown ---
       `(markdown-header-face-1 ((,class (:inherit org-level-1))))
       `(markdown-header-face-2 ((,class (:inherit org-level-2))))
       `(markdown-header-face-3 ((,class (:inherit org-level-3))))
       `(markdown-code-face ((,class (:inherit org-code))))
       `(markdown-markup-face ((,class (:foreground ,fg-dim))))
       `(markdown-url-face ((,class (:foreground ,second))))

       ;; --- Tree Sitter ---
       `(tree-sitter-hl-face:attribute ((,class (:foreground ,attribute))))
       `(tree-sitter-hl-face:method.call ((,class (:foreground ,func))))
       `(tree-sitter-hl-face:function.call ((,class (:foreground ,func))))
       `(tree-sitter-hl-face:operator ((,class (:foreground ,operator))))
       `(tree-sitter-hl-face:type.builtin ((,class (:foreground ,type))))
       `(tree-sitter-hl-face:number ((,class (:foreground ,const))))
       `(tree-sitter-hl-face:property ((,class (:foreground ,property))))
       `(tree-sitter-hl-face:punctuation ((,class (:foreground ,punctuation))))
       `(tree-sitter-hl-face:punctuation.bracket ((,class (:foreground ,punctuation))))
       `(tree-sitter-hl-face:punctuation.delimiter ((,class (:foreground ,punctuation))))
       `(tree-sitter-hl-face:constructor ((,class (:foreground ,type))))
       `(tree-sitter-hl-face:keyword ((,class (:foreground ,keyword))))
       `(tree-sitter-hl-face:string ((,class (:foreground ,string))))
       `(tree-sitter-hl-face:tag ((,class (:foreground ,tag))))
       `(tree-sitter-hl-face:variable ((,class (:foreground ,var))))
       `(tree-sitter-hl-face:constant ((,class (:foreground ,const))))
       `(tree-sitter-hl-face:type ((,class (:foreground ,type))))

       ;; --- LSP Mode / Flycheck ---
       `(lsp-face-highlight-textual ((,class (:background ,region))))
       `(lsp-face-highlight-read ((,class (:background ,region))))
       `(lsp-face-highlight-write ((,class (:background ,region))))
       `(flycheck-error ((,class (:underline (:style wave :color ,err)))))
       `(flycheck-warning ((,class (:underline (:style wave :color ,warning)))))
       `(flycheck-info ((,class (:underline (:style wave :color ,info)))))
       `(flymake-error ((,class (:underline (:style wave :color ,err)))))
       `(flymake-warning ((,class (:underline (:style wave :color ,warning)))))
       `(flymake-note ((,class (:underline (:style wave :color ,info)))))

       ;; --- Magit ---
       `(magit-section-heading ((,class (:foreground ,primary :weight bold))))
       `(magit-branch-local ((,class (:foreground ,success))))
       `(magit-branch-remote ((,class (:foreground ,second))))
       `(magit-tag ((,class (:foreground ,third))))
       `(magit-hash ((,class (:foreground ,fg-dim))))
       `(magit-diff-added ((,class (:background ,diff-add-bg :foreground ,diff-add-fg))))
       `(magit-diff-added-highlight ((,class (:background ,diff-add-bg :foreground ,diff-add-fg :weight bold))))
       `(magit-diff-removed ((,class (:background ,diff-del-bg :foreground ,diff-del-fg))))
       `(magit-diff-removed-highlight ((,class (:background ,diff-del-bg :foreground ,diff-del-fg :weight bold))))
       `(magit-diff-context ((,class (:foreground ,fg-dim))))
       `(magit-diff-context-highlight ((,class (:background ,bg-hl :foreground ,fg))))
       `(magit-diff-hunk-heading ((,class (:background ,bg-hl :foreground ,fg))))
       `(magit-diff-hunk-heading-highlight ((,class (:background ,ln-bg :foreground ,fg :weight bold))))
       `(magit-process-ok ((,class (:foreground ,success :weight bold))))
       `(magit-process-ng ((,class (:foreground ,err :weight bold))))

       ;; --- Git Gutter / Diff-HL ---
       `(git-gutter:added ((,class (:foreground ,success))))
       `(git-gutter:deleted ((,class (:foreground ,err))))
       `(git-gutter:modified ((,class (:foreground ,warning))))
       `(diff-hl-insert ((,class (:foreground ,success :background ,diff-add-bg))))
       `(diff-hl-delete ((,class (:foreground ,err :background ,diff-del-bg))))
       `(diff-hl-change ((,class (:foreground ,warning :background ,diff-chg-bg))))

       ;; --- Vertico / Selectrum / Ivy ---
       `(vertico-current ((,class (:background ,ln-bg :weight bold))))
       `(vertico-group-title ((,class (:foreground ,fg-alt :weight bold))))
       `(vertico-group-separator ((,class (:foreground ,border))))
       `(ivy-current-match ((,class (:background ,ln-bg :weight bold))))
       `(ivy-minibuffer-match-face-1 ((,class (:foreground ,fg-dim))))
       `(ivy-minibuffer-match-face-2 ((,class (:foreground ,success :weight bold))))
       `(ivy-minibuffer-match-face-3 ((,class (:foreground ,warning :weight bold))))
       `(ivy-minibuffer-match-face-4 ((,class (:foreground ,err :weight bold))))

       ;; --- Company (Completion) ---
       `(company-tooltip ((,class (:background ,bg-hl :foreground ,fg))))
       `(company-tooltip-selection ((,class (:background ,primary :foreground ,bg))))
       `(company-tooltip-annotation ((,class (:foreground ,fg-alt))))
       `(company-tooltip-common ((,class (:foreground ,second :weight bold))))
       `(company-scrollbar-bg ((,class (:background ,bg-alt))))
       `(company-scrollbar-fg ((,class (:background ,fg-dim))))
       `(company-preview ((,class (:foreground ,fg-dim))))
       `(company-preview-common ((,class (:foreground ,fg-dim))))

       ;; --- Corfu ---
       `(corfu-default ((,class (:background ,bg-hl :foreground ,fg))))
       `(corfu-current ((,class (:background ,primary :foreground ,bg))))
       `(corfu-bar ((,class (:background ,fg-dim))))
       `(corfu-border ((,class (:background ,border))))

       ;; --- Rainbow Delimiters ---
       `(rainbow-delimiters-depth-1-face ((,class (:foreground ,primary))))
       `(rainbow-delimiters-depth-2-face ((,class (:foreground ,second))))
       `(rainbow-delimiters-depth-3-face ((,class (:foreground ,third))))
       `(rainbow-delimiters-depth-4-face ((,class (:foreground ,success))))
       `(rainbow-delimiters-depth-5-face ((,class (:foreground ,warning))))
       `(rainbow-delimiters-depth-6-face ((,class (:foreground ,info))))
       `(rainbow-delimiters-depth-7-face ((,class (:foreground ,fg-alt))))
       `(rainbow-delimiters-depth-8-face ((,class (:foreground ,fg-dim))))
       `(rainbow-delimiters-unmatched-face ((,class (:foreground ,err :weight bold))))

       ;; --- NeoTree / Treemacs ---
       `(neo-root-dir-face ((,class (:foreground ,primary :weight bold))))
       `(neo-file-link-face ((,class (:foreground ,fg))))
       `(neo-dir-link-face ((,class (:foreground ,second))))
       `(treemacs-root-face ((,class (:foreground ,primary :weight bold :height 1.2))))
       `(treemacs-file-face ((,class (:foreground ,fg))))
       `(treemacs-directory-face ((,class (:foreground ,second))))
       `(treemacs-git-modified-face ((,class (:foreground ,warning))))
       `(treemacs-git-added-face ((,class (:foreground ,success))))
       `(treemacs-git-untracked-face ((,class (:foreground ,success))))
       `(treemacs-git-conflict-face ((,class (:foreground ,err :weight bold))))

       ;; --- Terminal (vterm) ---
       `(vterm-color-default ((,class (:foreground ,fg :background ,bg))))
       `(vterm-color-black ((,class (:foreground ,ansi-black :background ,ansi-black))))
       `(vterm-color-red ((,class (:foreground ,ansi-red :background ,ansi-red))))
       `(vterm-color-green ((,class (:foreground ,ansi-green :background ,ansi-green))))
       `(vterm-color-yellow ((,class (:foreground ,ansi-yellow :background ,ansi-yellow))))
       `(vterm-color-blue ((,class (:foreground ,ansi-blue :background ,ansi-blue))))
       `(vterm-color-magenta ((,class (:foreground ,ansi-magenta :background ,ansi-magenta))))
       `(vterm-color-cyan ((,class (:foreground ,ansi-cyan :background ,ansi-cyan))))
       `(vterm-color-white ((,class (:foreground ,ansi-white :background ,ansi-white))))

       ;; --- Web Mode ---
       `(web-mode-html-tag-face ((,class (:foreground ,primary))))
       `(web-mode-html-attr-name-face ((,class (:foreground ,second))))
       `(web-mode-html-attr-value-face ((,class (:foreground ,string))))
       `(web-mode-doctype-face ((,class (:foreground ,fg-dim))))
       `(web-mode-keyword-face ((,class (:foreground ,keyword))))
       `(web-mode-function-name-face ((,class (:foreground ,func))))

       ;; --- Dired ---
       `(dired-directory ((,class (:foreground ,second :weight bold))))
       `(dired-symlink ((,class (:foreground ,third :slant italic))))
       `(dired-ignored ((,class (:foreground ,fg-dim))))
       `(dired-header ((,class (:foreground ,primary :weight bold))))
      ))

    ;;;###autoload
    (and load-file-name
        (boundp 'custom-theme-load-path)
        (add-to-list 'custom-theme-load-path
                     (file-name-as-directory
                      (file-name-directory load-file-name))))

    (provide-theme 'soft-focus-light)

    ;;; soft-focus-light-theme.el ends here
    