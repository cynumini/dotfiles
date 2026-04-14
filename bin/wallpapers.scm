#!/bin/guile -s
!#
(use-modules (patchouli))

(define (sub . args)
  (append (list "(") args (list ")")))

(define (magick . args)
  (apply system* (cons "magick" (flat args))))

(define args (command-line))

(assert (= (length args) 2))

(define image-path (cadr args))

(assert (file-exists? image-path))

(define wallpaper-path (string-append (getenv "HOME") "/pictures/wallpaper.png"))

(assert (= 0 (magick (sub image-path ;; blurred image as background
                          "-resize" "1920x"
                          "-blur" "0x8" ;; 0x8 = {radius}x{sigma}
                          "-gravity" "center"
                          "-crop" "1920x1080+0+0") ;; outputs a single image using "+0+0"
                     (sub image-path "-resize" "x1080" ) ;; resized image
                     "-gravity" "center"
                     "-composite"
                     wallpaper-path)))

(assert (= 0 (system* "feh" "--bg-fill" wallpaper-path)))
