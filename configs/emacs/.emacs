(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(use-package doom-themes :ensure t :config (load-theme 'doom-gruvbox t))
(use-package magit :ensure t)
(use-package company :ensure t)
(use-package zig-mode :ensure t)
(use-package fancy-compilation
  :ensure t
  :commands (fancy-compilation-mode))

(with-eval-after-load 'compile
  (fancy-compilation-mode))

(set-fontset-font "fontset-default" 'han "Noto Sans CJK JP")
(set-fontset-font "fontset-default" 'kana "Noto Sans CJK JP ")
(set-fontset-font "fontset-default" 'cjk-misc "Noto Sans CJK JP ")

(add-hook 'before-make-frame-hook (lambda ()
                                    (set-fontset-font "fontset-default" 'han "Noto Sans CJK JP")
                                    (set-fontset-font "fontset-default" 'kana "Noto Sans CJK JP ")
                                    (set-fontset-font "fontset-default" 'cjk-misc "Noto Sans CJK JP ")))

(defconst fancy-startup-text `((:face (default) "その目、だれの目？")))

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(defun insert-date ()
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

(keymap-global-set "C-c d" 'insert-date)

(require 'mozc)
;; (set-language-environment "Japanese")
(setq default-input-method "japanese-mozc")

(add-hook 'c-mode-hook
          (lambda () (setq c-basic-offset 4)))

(add-hook 'flymake-mode-hook
          (lambda ()
	    (define-key flymake-mode-map (kbd "M-n") #'flymake-goto-next-error)
	    (define-key flymake-mode-map (kbd "M-p") #'flymake-goto-prev-error)))

(keymap-global-set "C-c c" 'comment-or-uncomment-region)

(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (define-key eglot-mode-map (kbd "C-c a") 'eglot-code-actions)
            (define-key eglot-mode-map (kbd "C-c r") 'eglot-rename)
            (define-key eglot-mode-map (kbd "C-c f") 'eglot-format-buffer)
            (define-key eglot-mode-map (kbd "C-c i") 'eglot-inlay-hints-mode)
            (define-key eglot-mode-map (kbd "C-c k") 'eldoc)))

(load-file "~/private.el")
(setq custom-file "~/custom.el")

(load-file custom-file)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
