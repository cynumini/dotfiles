#!/usr/bin/sh

plasmashell --replace &
sleep 2

kquitapp6 krunner
sleep 1
krunner &

cat > "$HOME/.config/breezerc" <<'EOF'
[Common]
ShadowSize=ShadowNone
EOF
qdbus6 org.kde.KWin /KWin reconfigure
sleep 0.5

rm -f "$HOME/.config/breezerc"
qdbus6 org.kde.KWin /KWin reconfigure
