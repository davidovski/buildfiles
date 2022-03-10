#!/bin/sh

make_xibuild () {
    local lib=$1
    local ver=$2
    local xibuild="repo/x11/${lib,,}.xibuild"

    cat > $xibuild << "EOF"
#!/bin/bash

MAKEDEPS=(make asciidoc xmlto)
DEPS=(libpng mesa xbitmaps xcb-util pam)

EOF
    echo "PKG_VER=$ver" >> $xibuild
    printf 'SOURCE=https://www.x.org/pub/individual/app/%s-$PKG_VER.tar.bz2\n' $lib >> $xibuild



    echo "" >> $xibuild
    echo "build () {" >> $xibuild
    printf '    ./configure $XORG_CONFIG\n' >> $xibuild
    echo "  make" >> $xibuild
    echo "}" >> $xibuild
    echo "" >> $xibuild

    echo "package () {" >> $xibuild
    printf '    make DESTDIR=$PKG_DEST install\n}\n'  >> $xibuild
    printf "${lib,,} "
}

cat > /tmp/xapps.versions << "EOF"
iceauth				1.0.8
luit				1.1.1
mkfontscale			1.2.1
sessreg				1.1.2
setxkbmap			1.3.2
smproxy				1.0.6
x11perf				1.6.1
xauth				1.1.1
xbacklight			1.2.3
xcmsdb				1.0.5
xcursorgen			1.0.7
xdpyinfo			1.3.2
xdriinfo			1.0.6
xev			    	1.2.4
xgamma				1.0.6
xhost				1.0.8
xinput				1.6.3
xkbcomp				1.4.5
xkbevd				1.1.4
xkbutils			1.0.4
xkill				1.0.5
xlsatoms			1.1.3
xlsclients			1.1.4
xmessage			1.0.5
xmodmap				1.0.10
xpr			    	1.0.5
xprop				1.2.5
xrandr				1.5.1
xrdb				1.2.1
xrefresh			1.0.6
xset				1.2.4
xsetroot			1.1.2
xvinfo				1.1.4
xwd			    	1.0.8
xwininfo			1.1.5
xwud				1.0.5
EOF

while IFS= read -r line; do
    make_xibuild $line
done < /tmp/xapps.versions
