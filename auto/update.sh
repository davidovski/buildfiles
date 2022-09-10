#!/bin/sh

. /usr/lib/colors.sh
. /usr/lib/glyphs.sh

# increment a version string
#
#   point - decimal point to update from
#   version - string of the version (ie 1.4.7)
#
increment_ver () {
    point=$1
    version=$2

    IFS='.'; set -- $version
    i=$# out=""

    [ "$point" -gt "$#" ] && {
        IFS='.'; printf "%s\n" "$version"
        return
    }

    while [ "$#" -gt "0" ]; do 
        p=$1

        [ "$#" -eq "$point" ] && p=$((p+1))
        [ "$#" -lt "$point" ] && p=0

        out="$out$p."
        shift
    done

    IFS='.'; set -- $out
    printf "%s\n" "${*%${!#}}"
    IFS=' '
}

get_source () {
    local name ver
    name=$1
    ver=$2

    cp repo/$name/$name.xibuild /tmp/xibuild
    sed "s/PKG_VER=.*/PKG_VER=$ver/" repo/$name/$name.xibuild > /tmp/xibuild
    . /tmp/xibuild
    echo "$SOURCE"
}

get_type () {
    case "$(get_source $1)" in 
        git://*|*.git)
            echo "git"
            ;;
        "")
            echo "none"
            ;;
        *)
            echo "archive"
            ;;
    esac
}

check_exists () {
    local code 
    [ -n "$1" ] && {
        code=$(curl -sSL -I -o /dev/null -w "%{http_code}" $1)
        [ "$code" = "200" ]
    } 
}

cur_ver () {
    local name
    name=$1
    . repo/$name/$name.xibuild 
    echo "$PKG_VER"
}

new_ver () {
    local name exists point new_ver ver url
    name=$1

    ver=$(cur_ver $name)
    point=1
    while true; do
        new_ver=$(increment_ver $point $ver)
        url=$(get_source $name $new_ver)
        
        check_exists $url && {
            point=1

            [ "$new_ver" = "$ver" ] && {
                echo "$ver"
                return
            }

            ver=$new_ver
        } || {
            point=$((point+1))
        }


        # check new_ver is real
        # if is real ; repeat again with same point
        # if not, increment point and then check
    done
}

for pkg in $(ls repo); do 
    printf "${LIGHT_BLUE}%s " "$pkg"
    case "$(get_type $pkg)" in
        "git"|"none")
            printf "${LIGHT_WHITE}skipped"
            ;;
        *)
        cur="$(cur_ver $pkg)"
        new="$(new_ver $pkg)"

        [ "$cur" = "$new" ] && 
            printf "${LIGHT_WHITE}%s ${CHECKMARK}" "$cur" || 
            printf "${GREEN}%s > %s" "$cur" "$new"
    esac
    printf "\n"
done


