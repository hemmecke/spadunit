# This Makefile should be run inside the toplevel directory after a
# checkout of the repository. It assumes that the autotools (autoconf,
# automake) are installed.

HERE := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT = ${HERE}project
TESTDIR = p/test
PREPARE = p/prepare-spadunit
MKDIR_P = mkdir -p

# Tests introduced via "--test:NAME" are supposed to take
# less than 10 seconds. Longer tests should be marked via
# "--test:timexxxx-NAME" where xxxx are digits and represent
# approximately how many seconds the test runs.
TESTTIME = 10

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
	cd build && ${MAKE} -f Makefile.mk clean
	cd build && ${MAKE} -f Makefile.mk TESTTIME="${TESTTIME}"

# Just forward the actual "make check" call to the build subdir.
check recheck:
	make TESTTIME="${TESTTIME}" update
	cd build && $(MAKE) $@

checkfile:
	make TESTTIME="${TESTTIME}" update
	TESTS="$(shell sed -n 's/^input\t$(FILE)\t\(.*\)$$/$(FILE).\1.input/p;' build/tests.list)" && \
	cd build && $(MAKE) TESTS="$$TESTS" check

timelog:
	cd build && perl -n \
	  -e 'if (/^DATETIMEbeg (.*) (.*) (\d*) (.*)/) {' \
	  -e '  $$d=$$1; $$t=$$2; $$s=$$3; $$f=$$4;};' \
	  -e 'if (/^DATETIMEend (.*) (.*) (\d*) (.*)/) {' \
	  -e '  printf("%s %s %6d %s\n", $$d, $$t, $$3-$$s, $$f);}' \
	  *.log \
	| sort -nk3

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
