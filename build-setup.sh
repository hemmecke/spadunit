#! /bin/sh

# This script should be run inside the toplevel directory after a
# checkout of the repository. It assumes that the autotools (autoconf,
# automake) are installed.

# It can be called with an argument that specifies the directory of the
# test sources. If that argument is missing, it defaults to 'src'.

error() {
    echo "$1" && exit 1
}

testsrc=src
if test $# -gt 0; then testsrc="$1"; fi
if test -e testsrc; then
    if test -L testsrc; then
        unlink testsrc
    else
        error 'You must remove the file/directory "testsrc".'
    fi
fi
echo "Creating link to test sources... 'ln -s $testsrc testsrc'."
ln -s $testsrc testsrc || error "Could not create testsrc directory."

echo "Generating *.mk files..."
make -f Makefile.mk || error "Problem during generation of *.mk files."

# Initialize the build system using the GNU AutoTools.
echo "Calling autoreconf ..."
autoreconf -i --verbose -Wall || \
    error "autoreconf could not generate all necessary files."
