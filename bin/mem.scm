#!/bin/guile -s
!#
(use-modules (ice-9 rdelim)
             (ice-9 textual-ports)
             (patchouli))

(define (get-data) (string-split (call-with-input-file "/proc/meminfo"
               (lambda (p)
                 (get-string-all p))) #\newline))

(define (get-value key)
  (round
   (/ (string->number
       (cadr (reverse (string-split (car (filter (lambda (x) (string-prefix? key x)) data) ) #\space)))) 1024)))

(define data (get-data))
(define swap-total (get-value "SwapTotal"))

(define (update)
  (set! data (get-data))
  (set! swap-total (get-value "SwapTotal")))

(case (get-button)
  ((3) (if (zero? swap-total)
           (begin (run "sudo -A swapon -a") (update))
           (begin (run "sudo -A swapoff -a") (update)))))

(define output (format #f "RAM: ~aMB~a~%"
                       (- (get-value "MemTotal") (get-value "MemAvailable"))
                       (if (not (zero? swap-total))
                           (format #f " SWAP: ~aMB" (- swap-total (get-value "SwapFree"))) "")))

(display output) (newline)
