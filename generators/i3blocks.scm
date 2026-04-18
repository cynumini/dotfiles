(use-modules (ice-9 format))
(use-modules (ice-9 string-fun))
(use-modules (ice-9 match))

(use-modules (patchouli))

;; define functions

(define (render-node node level)
  (case level
    ((0) (format #f "[~a]~%~a" (car node) (render (cadr node) (+ level 1))))
    ((1) (format #f "~a=~a~%" (car node) (cadr node)))))

(define* (render ast #:optional (level 0))
  (apply string-append (map (lambda (x) (render-node x level)) ast)))

;; ~/.config/i3blocks/config
(display "i3blocks.scm: ~/.config/i3blocks/config") (newline)
(define output-path (with-home ".config/i3blocks/config"))
(unless (file-exists? output-path) (mkdir (dirname output-path)))
(with-output-to-file output-path
  (lambda ()
    (format #t "# ~a~%" (warn-edit))
    (display (render `(
                       ("vmem"
                        (("command" "vmem.scm")
                         ("interval" "30")))
                       ("mem"
                        (("command" "mem.scm")
                         ("interval" "30")))
                       ("loadavg"
                        (("command" "loadavg.scm")
                         ("interval" "30")))
                       ("volume"
                        (("command" "volume.scm")
                         ("signal" "1")
                         ("interval" "60")))
                       ("date"
                        (("command" "date +\"%F %a %T\"")
                         ("interval" "1"))))))))

