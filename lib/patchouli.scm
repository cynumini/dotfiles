(define-module (patchouli) #:export (assert flat))

(define-syntax assert
  (syntax-rules ()
    ((assert condition)
     (if (not condition)
         (error (format #f "Assertion failed: ~a" 'condition)) #t))))

(define (flat lst)
  (apply append (map (lambda (x) (if (list? x) x (list x))) lst)))
