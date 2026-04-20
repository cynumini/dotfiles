#!/bin/guile -s
!#
(use-modules (patchouli)
             (vars))

(define (get-button)
  (string->number (or (getenv "BLOCK_BUTTON") "")))

(define max-len 50)

(define (get-title)
  (let ((title (string-trim-both (run "playerctl metadata title"))))
    (if (< (string-length title) max-len)
        title (string-append (substring title 0 (- max-len 3)) "..."))
    ))

(define (play-pause)
  (system "playerctl play-pause"))

(define (next)
  (system "playerctl next"))

(define (previous)
  (system "playerctl previous"))

(define (update)
  (system "pkill -RTMIN+2 i3blocks"))

(define (get-status)
  (if (string=? (string-trim-both (run "playerctl status")) "Playing") "⏸️" "▶️"))

(if (= 2 (length (command-line)))
    (let ((arg (cadr (command-line))))
      (case (string->symbol arg)
        ((play-pause) (begin (play-pause) (update)))
        ((next) (begin (next) (update)))
        ((previous) (begin (previous) (update)))))
    (begin
      (case (get-button)
        ((1) (play-pause))
        ((4) (previous))
        ((5) (next)))
      (usleep 100000) ;; can't get proper status without waiting 0.1s
      (format #t "~a~a\n" (get-status) (get-title))))
