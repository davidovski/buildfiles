for xipkg in $(find /var/lib/xib/repo -name '*.xipkg'); do
    name=$(basename $xipkg .xipkg)
    buildfile=$(realpath $(find -name "$name.xibuild" | tail -1))
    info_file=$xipkg.info 
    echo $name $buildfile

    . $buildfile

    pkg_ver=$PKG_VER
    [ -z "$pkg_ver" ] && pkg_ver=$BRANCH
    [ -z "$pkg_ver" ] && pkg_ver="latest"

    {
        echo "# XiPKG info file version $XIPKG_INFO_VERSION"
        echo "# automatically generated from the built packages"
        echo "NAME=$name"
        echo "DESCRIPTION=$DESC"
        echo "PKG_FILE=$name.xipkg"
        echo "CHECKSUM=$(sha512sum $xipkg | awk '{ print $1 }')"
        echo "VERSION=$pkg_ver"
        echo "REVISION=$(cat ${buildfile%/*}/*.xibuild | sha512sum | cut -d' ' -f1)"
        echo "SOURCE=$SOURCE"
        echo "DATE=$(stat -t $xipkg | cut -d' ' -f13 | xargs date -d)"
        echo "DEPS=${DEPS}"
        echo "MAKE_DEPS=${MAKE_DEPS}"
        echo "ORIGIN=$NAME"
    } > $info_file



done

#for repo in $(ls); do
#    for package in $(ls $repo); do
#        [ -f "/var/lib/xib/repo/$repo/$package.xipkg.info" ] && {
#            [ -f "/var/lib/xib/repo/$repo/$package.xipkg" ] && {
#                sed -rni 's/^REVISION=.*$//' /var/lib/xib/repo/$repo/$package.xipkg.info
#                echo "$package"; 
#                printf "REVISION=%s" $(cat $repo/$package/*.xibuild | sha512sum | cut -d" " -f1) >> /var/lib/xib/repo/$repo/$package.xipkg.info; 
#                true
#            } || {
#                rm /var/lib/xib/repo/$repo/$package.xipkg.info
#            }
#        }
#    done;
#done
