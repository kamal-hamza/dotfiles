;;; early-init.el --- Early initialization -*- lexical-binding: t -*-
;;; Commentary:
;; Emacs 27+ loads this before init.el

;;; Code:

;; Disable package.el in favor of Elpaca
(setq package-enable-at-startup nil)

;; Increase garbage collection threshold for faster startup
(setq gc-cons-threshold most-positive-fixnum)

;; Restore after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1024 1024))))

;;; early-init.el ends here
