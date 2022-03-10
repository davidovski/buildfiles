#!/bin/sh

make_xibuild () {
    local lib=$1
    local ver=$2
    local xibuild="repo/x11/${lib,,}.xibuild"

    cat > $xibuild << "EOF"
#!/bin/bash

MAKEDEPS=(make asciidoc xmlto lynx)
DEPS=(fontconfig libxcb elogind)

EOF
    echo "PKG_VER=$ver" >> $xibuild
    printf 'SOURCE=https://www.x.org/pub/individual/lib/%s-$PKG_VER.tar.bz2\n' $lib >> $xibuild

    echo "" >> $xibuild
    echo "build () {" >> $xibuild
    printf '    ./configure $XORG_CONFIG --docdir=$XORG_PREFIX/share/doc/%s-$PKG_VER\n' $lib >> $xibuild
    echo "  make" >> $xibuild
    echo "}" >> $xibuild
    echo "" >> $xibuild

    echo "package () {" >> $xibuild
    printf '    make DESTDIR=$PKG_DEST install\n}\n'  >> $xibuild
    printf "${lib,,} "
}

cat > /tmp/xlibs.versions << "EOF"
xtrans				1.4.0
libX11				1.7.3.1
libXext				1.3.4
libFS				1.0.8
libICE				1.0.10
libSM				1.2.3
libXScrnSaver		1.2.3
libXt				1.2.1
libXmu				1.1.3
libXpm				3.5.13
libXaw				1.0.14
libXfixes			6.0.0
libXcomposite		0.4.5
libXrender			0.9.10
libXcursor			1.2.0
libXdamage			1.1.5
libfontenc			1.1.4
libXfont2			2.0.5
libXft				2.3.4
libXi				1.8
libXinerama			1.1.4
libXrandr			1.5.2
libXres				1.2.1
libXtst				1.2.3
libXv				1.0.11
libXvMC				1.0.12
libXxf86dga			1.1.5
libXxf86vm			1.1.4
libdmx				1.1.4
libpciaccess		0.16
libxkbfile		    1.1.0
libxshmfence		1.3
EOF

while IFS= read -r line; do
    make_xibuild $line
done < /tmp/xlibs.versions
