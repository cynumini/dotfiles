;; define functions
(use-modules (ice-9 format))

;; runs your .bashrc and is recommended by the bash info pages
(define (run-bashrc) (format #t "if [ -f ~~/.bashrc ]; then . ~~/.bashrc; fi~&"))

(define (warning) (format #t "# Don't edit this file; edit ~a instead!~&" (current-filename)))

(define (expand path)
  (if (string=? "~/" (substring path 0 2))
      (string-append "$HOME" (substring path 1))
      path))

(define (export key value)
   (format #t "export ~a=~a~&" key (expand value)))

(define (path . args)
  (export "PATH"
          (string-append (string-join (map (lambda (x) (expand x)) args) ":") ":$PATH")))



;; ~/.bash_profile
(with-output-to-file (string-append (getenv "HOME") "/.bash_profile")
  (lambda ()
    (warning)
    (run-bashrc)
    (export "GUILE_LOAD_PATH" "~/projects/dotfiles/lib")
    (export "QT_QPA_PLATFORMTHEME" "qt6ct")
    (path
     "~/scripts"
     "~/.local/bin"
     "~/repos/koboldcpp"
     "~/projects/dotfiles/bin")))
