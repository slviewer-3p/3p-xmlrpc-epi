#!/bin/bash

cd "$(dirname "$0")"

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

XMLRPCEPI_VERSION="0.54.1"
XMLRPCEPI_SOURCE_DIR="xmlrpc-epi-$XMLRPCEPI_VERSION"

if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

# load autbuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
set -x

stage="$(pwd)/stage"
pushd "$XMLRPCEPI_SOURCE_DIR"
    case "$AUTOBUILD_PLATFORM" in
        "windows")
            load_vsvars
            
            build_sln "xmlrpcepi.sln" "Debug|Win32" "xmlrpc-epi"
            build_sln "xmlrpcepi.sln" "Release|Win32" "xmlrpc-epi"
            mkdir -p "$stage/lib/debug"
            mkdir -p "$stage/lib/release"
            cp "contrib/vstudio/vc10/x86/xmlrpc-epiDebug/xmlrpc-epi.lib" \
                "$stage/lib/debug/xmlrpc-epid.lib"
            cp "contrib/vstudio/vc10/x86/xmlrpc-epiRelease/xmlrpc-epi.lib" \
                "$stage/lib/release/xmlrpc-epi.lib"
            mkdir -p "$stage/include/xmlrpc-epi"
            cp {xmlrpc-epi.h} "$stage/include/xmlrpc-epi"
        ;;
        "darwin")
            ./configure --prefix="$stage"
            make
            make install
			mkdir -p "$stage/include/xmlrpc-epi"
			mv "$stage/include/"*.h "$stage/include/xmlrpc-epi/"
        ;;
        "linux")
            CFLAGS="-m32" CXXFLAGS="-m32" ./configure --prefix="$stage"
            make
            make install
			mkdir -p "$stage/include/xmlrpc-epi"
			mv "$stage/include/"*.h "$stage/include/xmlrpc-epi/"
        ;;
    esac
    mkdir -p "$stage/LICENSES"
    tail -n 31 README > "$stage/LICENSES/xmlrpc-epi.txt"
popd

pass
