#!/bin/guile -s
!#
(use-modules (ice-9 rdelim)
             (patchouli)
             (vars))

(define loadavg (string->number (car (string-split
                                      (call-with-input-file "/proc/loadavg"
                                        (lambda (p)
                                          (read-line p))) #\space))))

(define nproc (string->number (string-trim-both (run "nproc"))))

(case (get-button)
  ((3) (run (format #f "~a btop" terminal))))

(if (<= loadavg nproc)
    (format #t "CPU: ~a~%" loadavg) (begin (format #t "CPU: ~a~%" loadavg) (exit 33)))
