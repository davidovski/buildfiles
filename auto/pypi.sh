if [ $# = 0 ]; then
    printf "Name of package: python-"
    read name
else
    name=$1
fi

if ! pip show $name > /dev/null; then
   echo "Failed to find $name" 
   exit 1
fi

json=$(curl -SsL https://pypi.org/pypi/$name/json)
version=$(echo $json | jq -r '.info.version')
desc=$(echo $json | jq -r '.info.summary')
url=$(echo $json | jq -r '.urls[] | select((.version="1.0.3")) | .url' | grep -v "whl" | sed "s/$version/\$PKG_VER/g")
deps=$(echo $json | jq -r '.info.requires_dist | .[]' | cut -d' ' -f1 | tr '\n' ' ')
if [ ${#deps} != 0 ]; then
    package_deps=$(echo $deps | sed 's/\(\w*\)/python-\1/g')
    echo $package_deps
fi

file=repo/python/python-$name.xibuild

cat templates/pypi.xibuild |
    sed "s@^SOURCE=.*@SOURCE=$url@g" |
    sed "s/^PKG_VER=.*/PKG_VER=$version/g" |
    sed "s/^DESC=.*/DESC=\"$desc\"/g" |
    sed "s/^DEPS=.*/DEPS=\"$package_deps\"/g"  > $file
echo written to $file

if [ ${#deps} != 0 ]; then
    for p in $deps; do
        $0 $p
    done
fi

