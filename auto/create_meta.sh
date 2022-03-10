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
            for file in $(ls repo/$repo/*.xibuild); do
                local name=$(basename -s ".xibuild" $file)
                printf " $name"
            done
    done

    printf "\"\n"
}

ls repo | create 'AlL tHe pacKageS!!' > repo/meta/all.xibuild

skip="skip meta"

for repo in $(ls repo); do
    pkg_name=repo-$repo
    if echo $skip | grep -q $repo; then
        echo "Skipping $repo"
    else
        echo $repo | create "All the the packages available in $repo" > repo/meta/$pkg_name.xibuild
        echo "Generated $pkg_name.xibuild"
    fi
done
