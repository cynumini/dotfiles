;;; -*- lexical-binding: t -*-
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(use-package zig-mode :ensure t)
(use-package lua-mode :ensure t)
(use-package doom-themes :ensure t)
(use-package magit :ensure t)
(use-package company :ensure t)
(use-package eglot :ensure t)
(use-package glsl-mode :ensure t)
(use-package json-mode :ensure t)
(use-package meson-mode :ensure t)

(require 'mozc)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `(python-mode . ,(eglot-alternatives
                                 '(("basedpyright-langserver" "--stdio")
                                   ("ruff" "server")))))
  (add-to-list 'eglot-server-programs
               `(lua-mode . ,(eglot-alternatives
                                 '(("lua-language-server"))))))

(keymap-global-set "C-c d"
                   (lambda ()
                     (interactive)
                     (insert (format-time-string "%Y-%m-%d"))))

(keymap-global-set "C-c o"
                   (lambda ()
                     (interactive)
                     (dired "~/documents/org")))

(keymap-global-set "C-c c" 'comment-or-uncomment-region)

(add-hook 'flymake-mode-hook
          (lambda ()
            (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error)
            (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)))

(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (define-key eglot-mode-map (kbd "C-c a") 'eglot-code-actions)
            (define-key eglot-mode-map (kbd "C-c r") 'eglot-rename)
            (define-key eglot-mode-map (kbd "C-c f") 'eglot-format-buffer)
            (define-key eglot-mode-map (kbd "C-c i") 'eglot-inlay-hints-mode)
            (define-key eglot-mode-map (kbd "C-c e") 'eglot)
            (define-key eglot-mode-map (kbd "C-c k") 'eldoc)))

(eglot--code-action eglot-code-action-fixall "source.fixAll")

(add-hook 'zig-mode-hook
          (lambda ()
            (add-hook 'before-save-hook
                      (lambda ()
                        (call-interactively 'eglot-format)
                        (call-interactively 'eglot-code-action-organize-imports)
                        (call-interactively 'eglot-code-action-fixall))
                      nil t)))

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(set-fontset-font "fontset-default" 'han "Noto Sans CJK JP")
(set-fontset-font "fontset-default" 'kana "Noto Sans CJK JP")
(set-fontset-font "fontset-default" 'cjk-misc "Noto Sans CJK JP")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(backup-directory-alist '(("." . "~/.local/state/emacs")))
 '(c-basic-offset 4)
 '(column-number-mode t)
 '(custom-enabled-themes '(doom-gruvbox))
 '(custom-safe-themes
   '("f1e8339b04aef8f145dd4782d03499d9d716fdc0361319411ac2efc603249326"
     default))
 '(default-frame-alist '((alpha-background . 90)))
 '(delete-selection-mode t)
 '(display-line-numbers-type 'relative)
 '(global-company-mode t)
 '(global-display-line-numbers-mode t)
 '(global-whitespace-mode t)
 '(indent-tabs-mode nil)
 '(menu-bar-mode nil)
 '(meson-indent-basic 4)
 '(org-agenda-files '("~/documents/org/life.org"))
 '(org-log-repeat nil)
 '(package-selected-packages
   '(company doom-themes eglot glsl-mode goto-chg json-mode lua-mode
             magit meson-mode zig-mode))
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil)
 '(vc-follow-symlinks t)
 '(whitespace-style
   '(face trailing tabs spaces newline missing-newline-at-eof empty
          space-after-tab space-before-tab space-mark tab-mark)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Iosevka" :height 127)))))
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
