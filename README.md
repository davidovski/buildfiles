# XiLinux buildfiles

## Layout
- /repo
 +   repos full of packages
- /auto
 +   extra scripts to aid with automating package maintenance

## How to write a buildfile

packages are stored within folders inside their corresponding repo, for example the xipkg package is inside `/repo/xi/xipkg`

Each package folder contains .xibuild files which desribe the packages that are to be built

If there are multiple xibuild files in one package folder, then the one named after that folder will always be executed first. These additional xibuild files will inherit all of the variables defined in the main xibuild file, though functions will not be inherited. This means that, for example, the main package can build the main project and its files, and then subpackages can only implement the packaging of extra files. 

Other files may be placed within the folder which can be referenced within the .xbuilds. These should only be copied if they are linked in `$ADDITIONAL`

### xibuild attributes

A xibuild file can implement a number of different attributes that will be used within or later when describing the package

- `NAME`: the name of the package, optional
- `DESC`: description of the package contents
- `DEPS`: other packages that this package depends on
- `MAKE_DEPS`: other packages required to build this package
- `PKG_VER`: the version of the package
- `SOURCE`: the external resource to be downloaded and unpacked, typically a tar.gz of the sourcecode
- `ADDITIONAL`: extra files that will be included, can be external or local

### xibuild constants

These are constants that will be passed to the xibuild environment when building the package
- `$PKG_DEST`: the output location that the package's contents should be written to
- `$BUILD_ROOT`: the path of the build root


