(use-modules (ice-9 format))
(use-modules (ice-9 string-fun))
(use-modules (ice-9 match))

(use-modules (patchouli))
(use-modules (vars))

;; define functions
(define (exec-sanitize command)
  (if (string-contains command ",")
      (format #f "\"~a\"" (string-replace-substring command "\"" "\\\\\"")) command))
(define (exec command newline)
  (format #f (string-append "exec --no-startup-id ~a" (if newline "~%" "")) (exec-sanitize command)))

(define (render-node node level)
  (match node
    (('set name value) (format #f "set $~a ~a~%" name value) )
    (('exec command) (exec command #t))
    (('comment content) (format #f "# ~a~%" content))
    (('floating-modifier value) (format #f "floating_modifier ~a~%" value))
    (('tiling-drag args ...) (format #f "tiling_drag ~a~%" (string-join args " ")))
    (('bindsym key command) (format #f "bindsym ~a ~a~%" key command))
    (('bar status-command) (format #f "bar {~%\tstatus_command ~a~%}~%" status-command))
    (('mode name body) (format #f "mode \"~a\" {~%~a}~%" name (render body (+ level 1))))
    (('font name size) (format #f "font pango:~a ~a~%" name size))))

(define* (render ast #:optional (level 0))
  (apply string-append (map (lambda (x) (string-append (make-string level #\tab) (render-node x level))) ast)))

(define autostart
  `("dex --autostart --environment"
   ,(format #f "xss-lock --transfer-sleep-lock -- i3lock -i ~a --nofork" wallpaper-path)
   "nm-applet"
   "~/.fehbg"))

(define bindsym-exec `(
                       ("$mod+q" "i3-sensible-terminal")
                       ("$mod+r" "rofi -show drun -show-icons")
                       ("$mod+Shift+r" "rofi -show run")
                       ("$mod+Shift+equal" "cboomer")
                       ("Print" "screenshot.sh")
                       ("$mod+Shift+s" "screenshot.sh temp")
                       ("$mod+z" "record-audio.sh")
                       ("$mod+Shift+z" "anki-screenshot.sh")
                       ("$mod+minus" "volume.scm -")
                       ("$mod+equal" "volume.scm +")
                       ;; exit i3 (logs you out of your X session)
                       ("$mod+x" ,(string-join '("i3-nagbar -t warning -m 'You pressed the exit shortcut. Do"
                                                 "you really want to exit i3? This will end your X session.'"
                                                 "-B 'Yes, exit i3' 'i3-msg exit'")) " ")))

(define bindsym `(
                  ;; kill focused window
                  ("$mod+Shift+c" "kill")
                  ;; change focus
                  ("$mod+h" "focus left")
                  ("$mod+j" "focus down")
                  ("$mod+k" "focus up")
                  ("$mod+l" "focus right")
                  ;; move focused window
                  ("$mod+Shift+h" "move left")
                  ("$mod+Shift+j" "move down")
                  ("$mod+Shift+k" "move up")
                  ("$mod+Shift+l" "move right")
                  ;; split in horizontal orientation
                  ("$mod+Shift+v" "split h")
                  ("$mod+v" "split v")
                  ;; enter fullscreen mode for the focused container
                  ("$mod+Shift+f" "fullscreen toggle")
                  ;; tabbed layout
                  ("$mod+f" "layout tabbed")
                  ;; split layout
                  ("$mod+t" "layout toggle split")
                  ;; toggle tiling / floating
                  ("$mod+w" "floating toggle")
                  ;; change focus between tiling / floating windows
                  ("$mod+Shift+w" "focus mode_toggle")
                  ;; focus the parent container
                  ("$mod+a" "focus parent")
                  ;; focus the child container
                  ("$mod+Shift+a" "focus child")
                  ;; reload the configuration file
                  ("$mod+p" "reload")
                  ;; restart i3 inplace (preserves your
                  ;; layout/session, can be used to upgrade i3)
                  ("$mod+Shift+p" "restart")
                  ;; toggle bar
                  ("$mod+b" "bar mode toggle")))

(define (workspaces i len)
  (if (> i len) '()
      (append
       `((bindsym ,(format #f "$mod+~a" i) ,(format #f "workspace number ~a" i))
         (bindsym ,(format #f "$mod+Shift+~a" i) ,(format #f "move container to workspace number ~a" i)))
       (workspaces (+ i 1) len))))

;; ~/.config/i3/config
(display "i3.scm: ~/.config/i3/config") (newline)
(with-output-to-file (with-home ".config/i3/config")
  (lambda ()
    (display (render
              `((comment ,(warn-edit))
                (set "mod" "Mod4")
                (font ,font ,font-size)
                ,@(map (lambda (x) `(exec ,x)) autostart)
                ;; use Mouse+$mod to drag floating windows to their
                ;; wanted position
                (floating-modifier "$mod")
                ;; move tiling windows via drag & drop by
                ;; left-clicking into the title bar, or left-clicking
                ;; anywhere into the window while holding the floating
                ;; modifier.
                (tiling-drag "modifier" "titlebar")
                ,@(map (lambda (x) `(bindsym ,(car x) ,(exec (cadr x) #f))) bindsym-exec)
                ,@(map (lambda (x) `(bindsym ,(car x) ,(cadr x))) bindsym)
                ;; 9 workspaces
                ,@(workspaces 1 9)
                ;; resize window (you can also use the mouse for that)
                (mode "resize" ,(map (lambda (x) `(bindsym ,(car x) ,(cadr x)))
                                     '(("h" "resize shrink width 10 px or 10 ppt")
                                       ("j" "resize grow height 10 px or 10 ppt")
                                       ("k" "resize shrink height 10 px or 10 ppt")
                                       ("l" "resize grow width 10 px or 10 ppt")
                                       ("Return" "mode \"default\"")
                                       ("Escape" "mode \"default\"")
                                       ("$mod+r" "mode \"default\""))))
                (bindsym "$mod+g" "mode \"resize\"")
                ;; Start i3bar to display a workspace bar (plus the
                ;; system information i3status finds out, if
                ;; available)
                (bar "i3blocks"))))))
