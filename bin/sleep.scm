#!/bin/guile -s
!#
(use-modules (patchouli)
             (vars))

(define (get-button)
  (string->number (or (getenv "BLOCK_BUTTON") "")))

(define (enabled)
  (string=?
   (caddr (reverse (map (lambda (x) (string-trim-both x))(string-split (run "xset -q") #\newline))))
   "DPMS is Enabled"))

(define (off)
  (begin (system "xset s off") (system "xset -dpms")))

(define (on)
  (begin (system "xset s on") (system "xset +dpms")))

(define (update)
  (system "pkill -RTMIN+3 i3blocks"))

(if (= 2 (length (command-line)))
    (let ((arg (cadr (command-line))))
      (case (string->symbol arg)
        ((on) (begin (on) (update)))
        ((off) (begin (off) (update)))))
    (begin
      (case (get-button)
        ((1) (if (enabled) (off) (on))))
        (format #t "~a\n" (if (enabled) "💤" "☕"))))
