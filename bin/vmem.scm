#!/bin/guile -s
!#
(use-modules (ice-9 rdelim)
             (ice-9 textual-ports)
             (patchouli)
             (vars))

(define (get-data)
  (map (lambda (x) (string-trim-both x))(string-split (run "nvidia-smi -q -d MEMORY") #\newline)))

(define used (string->number
              (cadr (reverse (string-split
                              (car (filter (lambda (x) (string-prefix? "Used" x)) (get-data))) #\space)))))

(case (get-button)
  ((3) (run (format #f "~a nvtop" terminal))))

(format #t "VRAM: ~aMB" used) (newline)
