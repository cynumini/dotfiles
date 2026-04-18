(define-module (patchouli) #:export (assert flat with-home warn-edit run get-button))

(use-modules (ice-9 popen)
             (ice-9 format)
             (ice-9 textual-ports))

(define (run command) (begin
                        (define pipe (open-pipe command OPEN_READ))
                        (define output (get-string-all pipe))
                        (close-pipe pipe) output))

(define-syntax assert
  (syntax-rules ()
    ((_ condition)
     (if (not condition)
         (error (format #f "Assertion failed: ~a" 'condition)) #t))))

(define (flat lst)
  (apply append (map (lambda (x) (if (list? x) x (list x))) lst)))

(define (with-home path) (string-append (getenv "HOME") "/" path))

(define-syntax warn-edit
  (syntax-rules () ((_) (format #f "Don't edit this file; edit ~a instead!" (current-filename)))))

(define (get-button)
  (string->number (or (getenv "BLOCK_BUTTON") "")))
