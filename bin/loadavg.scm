#!/bin/guile -s
!#
(use-modules (ice-9 rdelim)
             (patchouli))

(define loadavg (string->number (car (string-split
                                      (call-with-input-file "/proc/loadavg"
                                        (lambda (p)
                                          (read-line p))) #\space))))

(define nproc (string->number (string-trim-both (run "nproc"))))

(if (<= loadavg nproc)
    (begin (format #t "CPU: ~a~%" loadavg))
    (begin (display #t "CPU: ~a~%" loadavg) (exit 33)))
