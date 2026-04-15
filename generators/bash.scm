;; define functions
(use-modules (ice-9 format))
(use-modules (patchouli))

(define (warning) (format #t "# Don't edit this file; edit ~a instead!~&" (current-filename)))

;; This file is sourced by bash for login shells.  The following line
;; runs your .bashrc and is recommended by the bash info pages.
(define (run-bashrc) (format #t "if [ -f ~~/.bashrc ]; then . ~~/.bashrc; fi~&"))

(define (expand path)
  (if (string=? "~/" (substring path 0 2))
      (string-append "$HOME" (substring path 1))
      path))

(define (set-env key value)
   (format #t "export ~a=~a~&" key (expand value)))

(define (set-path . args)
  (set-env "PATH"
          (string-append (string-join (map (lambda (x) (expand x)) args) ":") ":$PATH")))

;; ~/.bash_profile
(with-output-to-file (with-home ".bash_profile")
  (lambda ()
    (warning)
    (run-bashrc)
    (set-env "GUILE_LOAD_PATH" "~/projects/dotfiles/lib")
    (set-env "QT_QPA_PLATFORMTHEME" "qt6ct")
    (set-path
     "~/scripts"
     "~/.local/bin"
     "~/repos/koboldcpp"
     "~/projects/dotfiles/bin")))

;; Test for an interactive shell. There is no need to set anything
;; past this point for scp and rcp, and it's important to refrain from
;; outputting anything in those cases.
(define (test-for-interactive-shell) (format #t"if [[ $- != *i* ]] ; then return; fi~&"))

;; ~/.bashrc
(with-output-to-file (with-home ".bashrc")
  (lambda ()
    (warning)
    (test-for-interactive-shell)))
