(define-module (patchouli) #:export (assert flat with-home))

(define-syntax assert
  (syntax-rules ()
    ((assert condition)
     (if (not condition)
         (error (format #f "Assertion failed: ~a" 'condition)) #t))))

(define (flat lst)
  (apply append (map (lambda (x) (if (list? x) x (list x))) lst)))

(define (with-home path) (string-append (getenv "HOME") "/" path))
