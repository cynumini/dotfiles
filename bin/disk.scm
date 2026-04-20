#!/bin/guile -s
!#
(use-modules (patchouli)
             (vars))

(define (get-row-data path)
  (string-split (cadr (string-split (run (format #f "df ~a" path)) #\newline)) #\space))

(define (get-data path)
  (let ((data (reverse (get-row-data path))))
    (let ((mounted-on (car data)) (available (string->number (cadddr data))))
      (if (string=? mounted-on path) (round (/ available 1024)) #f))))

(define threshold (* 10 1024))

(define (get-readable value)
  (if (< value threshold) (format #f "~aMB" value) (format #f "~aGB" (round (/ value 1024)))))

(format #t "/: ~a" (get-readable (get-data "/")))
(let ((mnt (get-data "/mnt"))) (display (if mnt (format #f " /mnt: ~a~%" (get-readable mnt)) "\n")))
