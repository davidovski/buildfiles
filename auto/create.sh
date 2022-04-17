#!/bin/sh
read -p "package name> " name
repo=$(ls repo/ | fzf --prompt="repo> ")
read -p "package version> " version
read -p "description> " desc
deps=$(find repo -type f | xargs -I % basename % .xibuild | fzf -m --prompt="dependencies> " | tr '\n' ' ')
read -p "source url> " url
read -p "additional urls> " additional
type=$(find ./templates -type f | xargs -I % basename % .xibuild | fzf --prompt="build type> ")

clear
echo Name: $name
echo Repo: $repo
echo Deps: $deps
echo Desc: $desc
echo Vers: $version
echo Sour: $url
echo Addi: $additional
echo Type: $type
read -p "Ok? " go

template=./templates/$type.xibuild
buildfile=repo/$repo/$name.xibuild

[ -f $buildfile ] && read -p "Buildfile already exists, overwrite? " go

url=$(echo $url | sed "s/$version/\$PKG_VER/g" | sed "s/pkgver/PKG_VER/g")
makedeps=""

case $type in
    make|configure)
        makedeps="make $makedeps" 
        ;;
    meson)
        makedeps="meson ninja $makedeps" 
        ;;
    cmake)
        makedeps="cmake $makedeps" 
        ;;
    python)
        makedeps="python python-setuptools $makedeps" 
        ;;
esac

cat > $buildfile << EOF
#!/bin/sh

NAME="$name"
DESC="$desc"

MAKEDEPS="$makedeps"
DEPS="$deps"

PKG_VER=$version
SOURCE="$url"
EOF

 
[ "${#additional}" = 0 ] || {
    filenames=""
    mkdir extra/$name
    for l in $additional; do
        filename=$(basename $l)
        curl -SsL $l > extra/$name/$filename  
        filenames="$filename $filenames"
    done
    echo "ADDITIONAL=\"$filenames\"" >> $buildfile
    
    echo $filenames | grep -q ".patch " && {
    cat >> $buildfile << EOF

prepare () {
    apply_patches
}
EOF
    }
}

echo >> $buildfile
cat $template >> $buildfile
vim $buildfile

# remove any things i may have copied from alpine's build scripts
sed -i "s/\$pkgname/$name/g" $buildfile
sed -i "s/\$pkgver/\$PKG_VER/g" $buildfile
sed -i "s/\$pkgdir/\$PKG_DEST/g" $buildfile
