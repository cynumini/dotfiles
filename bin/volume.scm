#!/bin/guile -s
!#
(if (= 2 (length (command-line)))
    (let ((arg (cadr (command-line))))
      (case (string->symbol arg)
        ((+) (system "wpctl set-volume @DEFAULT_SINK@ 5%+ -l 1 && pkill -RTMIN+1 i3blocks"))
        ((-) (system "wpctl set-volume @DEFAULT_SINK@ 5%- -l 1 && pkill -RTMIN+1 i3blocks"))))
    (system "wpctl get-volume @DEFAULT_SINK@"))

