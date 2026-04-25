#!/bin/guile -s
!#
(use-modules (patchouli)
             (vars))

(define (sub . args)
  (append (list "(") args (list ")")))

(define (magick . args)
  (apply system* (cons "magick" (flat args))))

(define args (command-line))

(define image-path (if (= (length args) 2) (cadr args) (run "xclip -o -sel clip")))

(assert (file-exists? image-path))

(assert (file-exists? (dirname wallpaper-path)))

(assert (= 0 (magick (sub image-path ;; blurred image as background
                          "-resize" "1920x"
                          "-blur" "0x8" ;; 0x8 = {radius}x{sigma}
                          "-gravity" "center"
                          "-crop" "1920x1080+0+0") ;; outputs a single image using "+0+0"
                     (sub image-path "-resize" "x1080" ) ;; resized image
                     "-gravity" "center"
                     "-composite"
                     wallpaper-path)))

(assert (= 0 (system* "xwallpaper" "--center" wallpaper-path)))
