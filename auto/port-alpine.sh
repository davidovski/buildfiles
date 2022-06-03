#!/bin/sh
#
# port a package from alpine linux
#

package=$1
aports_dir="/home/david/docs/proj/alpine/aports"

pkgbuild=$(find $aports_dir -name "$package" -type d | head -1)

[ ! -d "$pkgbuild" ] && printf "${RED}package not found" && exit 1 

apkbuild="$pkgbuild/APKBUILD"
additional=$(ls $pkgbuild | grep -v ^APKBUILD$)

. $apkbuild


name=$pkgname

version=$pkgver

# some use a _ pkg ver 
[ ! -z "$_pkgver"] && version=$_pkgver

url=$(echo "$source" | head -1)
makedeps=""
for dep in $makedepends; do 
    makedeps="$makedeps $(echo $dep | sed -E 's/(-dev|-lib|-doc)$//g')"
done

builddir="repo/$package"
buildfile="$builddir/$package.xibuild"
mkdir -p $builddir
touch $buildfile

cat > $buildfile << EOF
#!/bin/sh

NAME="$pkgname"
DESC="$pkgdesc"

MAKEDEPS="$makedeps"

PKG_VER=$version
EOF

grep "source=" $apkbuild | sed 's/source=/SOURCE=/g' | sed 's/pkgver/PKG_VER/g' | sed -r 's/([^"])$/\1"/' >> $buildfile
echo >> $buildfile

[ "${#additional}" != "0" ] && {
    echo "ADDITIONAL=\"" >> $buildfile
    for file in $additional; do 
        echo $file >> $buildfile
        [ -f $pkgbuild/$file ] && cp $pkgbuild/$file $builddir/
    done
    echo '"' >> $buildfile
    echo >> $buildfile
}

# TODO make this better
counting=false
while IFS= read -r line; do
    case "$line" in 
        *"()"*"{") counting=true;;
        sha512sums=*) counting=false;;
    esac

    $counting && printf "%s\n" "$line" >> $buildfile
done < $apkbuild

sed -i "s/\$pkgname/$name/g" $buildfile
sed -i "s/\$pkgver/\$PKG_VER/g" $buildfile
sed -i "s/\$pkgdir/\$PKG_DEST/g" $buildfile
sed -i "s/\$subpkgdir/\$PKG_DEST/g" $buildfile
sed -i "s/\$srcdir/\$BUILD_ROOT/g" $buildfile
sed -i "s/\$builddir/\$BUILD_ROOT/g" $buildfile
sed -i "s/^sha512sums=.*$//g" $buildfile
# ignore build and host options for configure; we arent cross compiling
sed -i "s/^\w*--build=//g" $buildfile
sed -i "s/^\w*--host=//g" $buildfile

sed -i 's/abuild-meson/meson --prefix=\/usr \\\n/' $buildfile

echo "press enter to edit"
read edit

vim -O $buildfile $apkbuild
