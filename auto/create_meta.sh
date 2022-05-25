#!/bin/bash

create() {
    local desc=$*

    printf "#!/bin/sh\n"
    printf "# This file was automatically generated, do not edit!"
    printf "\n\n"

    printf "DESC=\"$desc\"\n" 
    printf "DEPS=\""
    while read repo; do
        [ -d repo/$repo ] && [ ! "$repo" = "meta" ] &&
            for name in $(ls -d repo/$repo/*); do
                printf " $(basename $name)"
            done
    done

    printf "\"\n"
}

mkdir -p repo/meta/all/
ls repo | create 'AlL tHe pacKageS!!' > repo/meta/all/all.xibuild

skip="skip meta"

for repo in $(ls repo); do
    pkg_name=repo-$repo
    if echo $skip | grep -q $repo; then
        echo "Skipping $repo"
    else
        mkdir -p repo/meta/$pkg_name
        echo $repo | create "All the the packages available in $repo" > repo/meta/$pkg_name/$pkg_name.xibuild
        echo "Generated $pkg_name.xibuild"
    fi
done
