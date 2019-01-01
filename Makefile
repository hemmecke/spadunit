# This Makefile should be run inside the toplevel directory after a
# checkout of the repository. It assumes that the autotools (autoconf,
# automake) are installed.
#
# All generated files and are put into a (newly created) subdirectory
# "build". In this build directory there will also be links to the
# directory of the test files (that link is named "t") and the
# actual (external) project that is to be testet (that link is named "p").
#
# Call like
#
#   make PROJECT=/path/to/toplevel/projectdir TESTDIR=/path/to/test
#   make check
#
# If PROJECT is missing, then PROJECT=`pwd`/project.
# Inside this directory, the Makefile is looking for an (optional)
# script with name 'prepare-spadunit'.
#
# If TESTDIR is missing it defaults to TESTDIR=p/test, which is
# equivalent to TESTDIR=${PROJECT}/test.
# Inside TESTDIR the testfiles are expected.
#
# The PROJECT directory will be linked to build/p.
# The TESTDIR directory will be linked to build/t.
#
# In other, words if the "test" directory is a direct subdir of the
# project directory then one can link it to project and does not
# have to worry about the PROJECT and TESTDIR variable any further.
#
#   ln -s ${PROJECT} project
#   make
#   make check
#
# The script "prepare-spadunit" should compile any .spad file and write a
# file "loadlibs.input" into the current directory. When ")read
# loadlibs.input" is executed inside a FriCAS session with the current
# working directory being "build", it should read all the libraries
# from the project that are relevant to execute the tests from the
# subdirectory "t".

HERE := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT = ${HERE}project
TESTDIR = p/test
PREPARE = p/prepare-spadunit
MKDIR_P = mkdir -p

# We generate any file inside a (newly created) "build" directory.
all: set-directories
	${MAKE} update

set-directories:
	${MKDIR_P} build
	cp -a src/* build/
	-unlink build/p
	cd build && test -d ${PROJECT} && ln -s ${PROJECT} p
	-unlink build/t
	cd build && test -d ${TESTDIR} && ln -s ${TESTDIR} t

update:
	+cd build && if test -x ${PREPARE}; then ${PREPARE}; fi
	cd build && ${MAKE} -f Makefile.mk

# Just forward the actual "make check" call to the build subdir.
check recheck: update
	cd build && $(MAKE) $@

# We add dependencies to make sure that we are in the right directory.
clean: LICENSE Makefile src
	rm -rf build

###################################################################
.PHONY: project.link testdir.link
project.link:
