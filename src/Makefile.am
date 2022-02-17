###################################################################
#
# SPADUNIT
# Copyright (C) 2010, 2015, 2018  Ralf Hemmecke <ralf@hemmecke.org>
#
###################################################################
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
###################################################################
# This is the main Makefile of the testing framework.
# Nothing will be installed via 'make install'.
###################################################################

# The variables 'ascompiler', 'spadcompiler', and 'interpreter'
# are set at configure time.

# Default target is to compile the spadunit.spad file.
all: spadunit.log

# Make sure generated files are removed via 'make clean'.
# Also remove test related files.
CLEANFILES = \
  $(TESTS) \
  $(check_DATA) \
  libdb.text \
  spadunit.log \
  *.ao \
  *.asy \
  *.fasl \
  *.lsp \
  *~

clean-local:
	-rm -rf *.erlib *.NRLIB

###################################################################
# For the following includes see Makefile.mk.
###################################################################

# Define check_DATA variable.
# This target will only be built during "make check".
# TODO: Take care of what will got into the distribution tarball.
include checkdata.mk

# Define the TESTS variable.
include tests.mk

# Define the XFAIL_TESTS variable.
include xfailtests.mk

# Build rules for the testfiles from their respective sources.
include rules.mk


TEST_EXTENSIONS = .input
INPUT_LOG_COMPILER = ${interpreter}
check_SCRIPTS = interpreter ascompiler spadcompiler

# We have to give rules how the generate the respective files for each
# of the TEST_EXTENSIONS.
.SECONDARY: $(TESTS) # don't delete intermediate .input files
define input_generate
    # setup code
    echo ')sys date +"DATETIMEbeg %F %H:%M:%S %s $@"' > $@
    echo -e ")library SPADZERO\n)library SPADUNIT" >> $@
    if test -r loadlibs.input; then \
      echo -e ")read loadlibs.input\n)cd ${abs_builddir}" >> $@; \
    fi
    awk '/^--setup$$/,/^--endsetup$$/ {print}' $< >>$@
    # actual test code
    perl \
      -e '$$t="$@"; $$t =~ s/^[^.]+\.([^.]+)\..*/$$1/;' \
      -e 'while(<>) {' \
      -e '  if (/^--test:$$t(\s|$$)/)  {$$p=1}' \
      -e '  if ($$p) {print}' \
      -e '  if (/^--endtest$$/) {$$p=0}' \
      -e '}' $< >> $@
    # tear down code
    # TODO: Tear down code should be called without having an effect on the
    # outcome of the actual test.
    # awk '/^--teardown$$/,/^--endteardown$$/ {print}' $< >>$@
    echo ')sys date +"DATETIMEend %F %H:%M:%S %s $@"' >> $@
endef

###################################################################
# Compile auxiliary stuff that is used during "make check".
${check_data_as}: %.log: p/test/%
	${ascompiler} $< > $@ 2>&1
${check_data_spad}: %.log: p/test/%
	${spadcompiler} $< > $@ 2>&1
spadunit.log: spadunit.spad
	${spadcompiler} $< > $@ 2>&1
