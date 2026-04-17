#!/bin/guile -s
!#
(use-modules (ice-9 format) (ice-9 rdelim) (patchouli))

(define (get-button)
  (string->number (or (getenv "BLOCK_BUTTON") "")))

(define (set-volume diff)
  (let ((command "wpctl set-volume @DEFAULT_SINK@ ~a -l 1") (value (abs diff)))
    (system (format #f command (if (< diff 0) (format #f "~a%-" value) (format #f "~a%+" value))))))

(define (update)
  (system "pkill -RTMIN+1 i3blocks"))

(define (volume-from-string string)
  (inexact->exact (round (* 100 (string->number string)))))

(define (get-volume)
  (volume-from-string (string-trim-both (cadr (string-split (run "wpctl get-volume @DEFAULT_SINK@") #\space)))))

(if (= 2 (length (command-line)))
    (let ((arg (cadr (command-line))))
      (case (string->symbol arg)
        ((+) (begin (set-volume 5) (update)))
        ((-) (begin (set-volume -5) (update)))))
    (begin
      (case (get-button)
        ((4) (set-volume 5))
        ((5) (set-volume -5)))
      (format #t "VOL: ~d%~%" (get-volume))))
