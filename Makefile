# This Makefile should be run inside the toplevel directory after a
# checkout of the repository. It assumes that the autotools (autoconf,
# automake) are installed.

HERE := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT = ${HERE}project
TESTDIR = p/test
PREPARE = p/prepare-spadunit
MKDIR_P = mkdir -p

# We generate any file inside a (newly created) "build" directory.
all: set-directories

set-directories:
	if test -e build; then \
	  echo "** The directory 'build' already exists. **"; \
	  echo "** Call 'make clean' first. **"; \
	  exit 1; \
	fi
	${MKDIR_P} build
	cp -a src/* build/
	cd build && test -d ${PROJECT} && ln -s ${PROJECT} p
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

%:
	P=${HERE}projects/$@; \
	if test -d $$P; then \
	  ${MAKE} PROJECT=$$P set-directories; \
	else \
	  echo "Target or project unknown."; exit 1; \
	fi
