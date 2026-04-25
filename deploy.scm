#!/bin/guile -s
!#
(use-modules (ice-9 format))

(define (stow name) (begin
                      (format #t "stow: ~a~%" name)
                      (let ((command (format #f "stow -d configs ~a -t ~~/" name)))
                        (format #t "~a~%" command)
                        (system command))))

(display "run: bash.scm") (newline)
(load "generators/bash.scm")
(display "run: i3.scm") (newline)
(load "generators/i3.scm")
(display "run: i3blocks.scm") (newline)
(load "generators/i3blocks.scm")

(stow "emacs")
(stow "fonts")
