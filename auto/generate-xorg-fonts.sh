#!/bin/sh

make_xibuild () {
    local lib=$1
    local ver=$2
    local xibuild="repo/font/${lib,,}.xibuild"

    cat > $xibuild << "EOF"
#!/bin/bash

MAKEDEPS=(make asciidoc xmlto lynx)
DEPS=(fontconfig libxcb elogind)

EOF
    echo "PKG_VER=$ver" >> $xibuild
    printf 'SOURCE=https://www.x.org/pub/individual/font/%s-$PKG_VER.tar.bz2\n' $lib >> $xibuild

    echo "" >> $xibuild
    echo "build () {" >> $xibuild
    printf '    ./configure $XORG_CONFIG\n' >> $xibuild
    echo "  make" >> $xibuild
    echo "}" >> $xibuild
    echo "" >> $xibuild

    echo "package () {" >> $xibuild
    printf '    make DESTDIR=$PKG_DEST install\n\n'  >> $xibuild
    printf 'install -v -d -m755 $PKG_DEST/usr/share/fonts                               &&\nln -svfn $XORG_PREFIX/share/fonts/X11/OTF $PKG_DEST/usr/share/fonts/X11-OTF &&\nln -svfn $XORG_PREFIX/share/fonts/X11/TTF $PKG_DEST/usr/share/fonts/X11-TTF\n}' >> $xibuild
    printf "${lib,,} "
}

cat > /tmp/fonts.versions << "EOF"
encodings 1.0.5
font-alias 1.0.4
font-adobe-utopia-type1 1.0.4
font-bh-ttf 1.0.3
font-bh-type1 1.0.3
font-ibm-type1 1.0.3
font-misc-ethiopic 1.0.4
font-xfree86-type1 1.0.4
EOF

while IFS= read -r line; do
    make_xibuild $line
done < /tmp/fonts.versions
