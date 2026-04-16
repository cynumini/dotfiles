#!/bin/guile -s
!#
(display "run: bash.scm") (newline)
(load "generators/bash.scm")
(display "run: i3.scm") (newline)
(load "generators/i3.scm")
(display "run: i3blocks.scm") (newline)
(load "generators/i3blocks.scm")
