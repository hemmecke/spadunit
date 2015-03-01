###################################################################
#
# SPADUNIT
# Copyright (C) 2010, 2015,  Ralf Hemmecke <ralf@hemmecke.org>
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
include testsrc/checkdata.mk

# Define the TESTS variable.
include testsrc/tests.mk

# Define the XFAIL_TESTS variable.
include testsrc/xfailtests.mk

# Build rules for the testfiles from their respective sources.
include testsrc/rules.mk


TEST_EXTENSIONS = .input
INPUT_LOG_COMPILER = ${interpreter}
check_SCRIPTS = interpreter ascompiler spadcompiler

# We have to give rules how the generate the respective files for each
# of the TEST_EXTENSIONS.
.SECONDARY: $(TESTS) # don't delete intermediate .input files
define input_generate
# setup code
echo -e ")library SPADZERO\n)library SPADUNIT" > $@
awk '/^--setup$$/,/^--endsetup$$/ {print}' $< >>$@
# actual test code
perl \
  -e '$$t="$@"; $$t =~ s/\..*//;' \
  -e 'while(<>) {' \
  -e '  if (/^--test:$$t(\s|$$)/)  {$$p=1}' \
  -e '  if ($$p) {print}' \
  -e '  if (/^--endtest$$/) {$$p=0}' \
  -e '}' $< >> $@
# tear down code
# TODO: Tear down code should be called without having an effect on the
# outcome of the actual test.
# awk '/^--teardown$$/,/^--endteardown$$/ {print}' $< >>$@
endef

###################################################################
# Compile auxiliary stuff that is used during "make check".
${check_data_as}: %.log: testsrc/%
	${ascompiler} $< > $@ 2>&1
${check_data_spad}: %.log: testsrc/%
	${spadcompiler} $< > $@ 2>&1
spadunit.log: spadunit.spad
	${spadcompiler} $< > $@ 2>&1
