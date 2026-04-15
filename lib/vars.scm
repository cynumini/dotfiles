(define-module (vars) #:export (font font-size wallpaper-path))

(use-modules (patchouli))

(define font "Iosevka Nerd Font")
(define font-size 13)
(define wallpaper-path (with-home "pictures/wallpaper.png"))
