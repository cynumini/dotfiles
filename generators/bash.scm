(use-modules (ice-9 format))
(use-modules (ice-9 match))

(use-modules (patchouli))

;; define functions
(define (expand path) (if (string=? "~/" (substring path 0 2)) (string-append "$HOME" (substring path 1)) path))

(define (render-expr expr)
  (match expr
    (('!= left right) (format #f "[[ ~a != ~a ]]" left right))
    (('test args ...) (format #f "[ ~a ]" (string-join args " ")))))

(define (render-node node level)
  (match node
    (('if expr body) (format #f "if ~a; then~%~afi~%" (render-expr expr) (render body (+ level 1))))
    (('source file) (format #f ". ~a~%" file))
    (('export key value) (format #f "export ~a=~a~%" key (expand value)))
    (('return) (format #f "return~%"))
    (('comment content) (format #f "# ~a~%" content))))

(define* (render ast #:optional (level 0))
  (apply string-append (map (lambda (x) (string-append (make-string level #\tab) (render-node x level))) ast)))

;; ~/.bash_profile
(display "bash.scm: ~/.bash_profile") (newline)
(with-output-to-file (with-home ".bash_profile")
  (lambda ()
    (display (render
              `((comment ,(warn-edit))
                ;; This file is sourced by bash for login shells.  The
                ;; following line runs your .bashrc and is recommended
                ;; by the bash info pages.
                (if (test "-f" "~/.bashrc") ((source "~/.bashrc")))
                (if (test "-f" "~/.private") ((source "~/.private")))
                (export "GUILE_LOAD_PATH" "~/projects/dotfiles/lib")
                (export "QT_QPA_PLATFORMTHEME" "qt6ct")
		(export "XMODIFIERS" "\"@im=fcitx\"")
		(export "GTK_IM_MODULE" "fcitx")
		(export "QT_IM_MODULE" "fcitx")
                (export "PATH" ,(string-join (map (lambda(x) (expand x))
                                                              '("$PATH"
                                                                "~/scripts"
                                                                "~/.local/bin"
                                                                "~/repos/koboldcpp"
                                                                "~/projects/dotfiles/bin")) ":")))))))

;; ~/.bashrc
(display "bash.scm: ~/.bashrc") (newline)
(with-output-to-file (with-home ".bashrc")
  (lambda ()
    (display (render
              `((comment ,(warn-edit))
                ;; Test for an interactive shell. There is no need to
                ;; set anything past this point for scp and rcp, and
                ;; it's important to refrain from outputting anything
                ;; in those cases.
                (if (!= "$-" "*i*") ((return))))))))
