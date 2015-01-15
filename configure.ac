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
# This is the configure.ac file of the testing framework.
# We don't bother much about finding required programs, since
# we assume that configure will be called from a place where
# all the required programs can be made available through the PATH
# environment variable. We basically do only a sanity check here.
###################################################################
AC_PREREQ(2.68)
AC_INIT(
  [SpadUnit],
  [0.0.1],
  [ralf@hemmecke.org])

# Sanity check
AC_CONFIG_SRCDIR([build-setup.sh])

# Certain configuration files are kept in the config subdirectory.
AC_CONFIG_AUX_DIR(config)
AC_CONFIG_MACRO_DIR(config)

# Init Automake (non-gnu standard)
AM_INIT_AUTOMAKE([-Wall -Werror foreign parallel-tests color-tests])

###################################################################
# Check for existing compiler and interpreter scripts.
###################################################################
# ascompiler
###################################################################
ascompiler=$srcdir/ascompiler
AC_ARG_WITH([ascompiler],
    [AS_HELP_STRING([--with-ascompiler],
                    [specify place of the comiler for .as files])],
    [ascompiler=$withval],
    []
)
# accompiler must be executable. Anything else will be an error.
AS_IF([test -x $ascompiler],
    [],
    [AC_MSG_ERROR([ascompiler must be executable])])

# Now we do a sanity check. ascompiler must compile a good .as program
# and fail on a bad .as program.
AC_MSG_CHECKING([for correct .as compilation])
cat >conftest.as <<_ACEOF
#include "axiom"
foo(n: Integer): Integer == 2*n
_ACEOF

result_ok=yes
AS_IF([${ascompiler} conftest.as > conftest.log 2>&1],
    AC_MSG_RESULT([ok]),
    [AC_MSG_RESULT([no])
     result_ok=no]
)

AC_MSG_CHECKING([for aborting .as compilation])
cat >conftest.as <<_ACEOF
#include "axiom"
foo(n: )Integer Integer == 2*n
_ACEOF

AS_IF([${ascompiler} conftest.as > conftest.log 2>&1],
    [AC_MSG_RESULT([no])
     result_ok=no],
    AC_MSG_RESULT([ok])
)

# The ascompiler test is only relevant if we have .as files to compile.
AS_IF([grep '^check_data_as.*\.as' testsrc/checkdata.mk > /dev/null],
    [AS_IF([test "$result_ok" = "no"],
        [AC_MSG_ERROR([ascompiler does not behave as expected.])],[])],
    [])

AC_SUBST(ascompiler)

###################################################################
# spadcompiler
###################################################################
spadcompiler=$srcdir/spadcompiler
AC_ARG_WITH([spacompiler],
    [AS_HELP_STRING([--with-spadcompiler],
                    [specify place of the comiler for .spad files])],
    [spadcompiler=$withval],
    []
)
# spadcompiler must be executable. Anything else will be an error.
AS_IF([test -x $spadcompiler],
    [],
    [AC_MSG_ERROR([spacompiler must be executable])])

# Now we do a sanity check. spadcompiler must compile a good .spad
# program and fail on a bad .spad program.
AC_MSG_CHECKING([for correct .spad compilation])
cat >conftest.spad <<_ACEOF
)abbrev package RHXCONFT RHX_ConfTest
RHX_ConfTest(): with
    foo: Integer -> Integer
  == add
    foo(n: Integer): Integer == 2*n
_ACEOF

result_ok=yes
AS_IF([${spadcompiler} conftest.spad > conftest.log 2>&1],
    AC_MSG_RESULT([ok]),
    [AC_MSG_RESULT([no])
     result_ok=no]
)

rm -rf RHXCONFT.* libdb.text

AC_MSG_CHECKING([for aborting .spad compilation])
cat >conftest.spad <<_ACEOF
)abbrev package RHXCONFT RHX_ConfTest
RHX_ConfTest(): with
    foo: Integer -> Integer
  == add
    foo(n: Integer): Intege == 2*n
--------------------------^
_ACEOF

AS_IF([${spadcompiler} conftest.spad > conftest.log 2>&1],
    [AC_MSG_RESULT([no])
     result_ok=no],
    AC_MSG_RESULT([ok])
)

rm -rf RHXCONFT.* libdb.text

AS_IF([test $result_ok = "no"],
    [AC_MSG_ERROR([spadcompiler does not behave as expected.])],[])

AC_SUBST(spadcompiler)

###################################################################
# interpreter
###################################################################
interpreter=$srcdir/interpreter
AC_ARG_WITH([interpreter],
    [AS_HELP_STRING([--with-interpreter],
                    [specify place of the comiler for .input files])],
    [interpreter=$withval],
    []
)
# spadcompiler must be executable. Anything else will be an error.
AS_IF([test -x $interpreter],
    [],
    [AC_MSG_ERROR([interpreter must be executable])])

# Now we do a sanity check. interpreter must execute a good .input
# session and fail on a .input session that generates an error.
AC_MSG_CHECKING([for correct .input testing])
cat >conftest.input <<_ACEOF
1+2
_ACEOF

result_ok=yes
AS_IF([${interpreter} conftest.input > conftest.log 2>&1],
    AC_MSG_RESULT([ok]),
    [AC_MSG_RESULT([no])
     result_ok=no]
)

AC_MSG_CHECKING([for aborting .input testing])
cat >conftest.input <<_ACEOF
error "conftest"
_ACEOF

AS_IF([${interpreter} conftest.input > conftest.log 2>&1],
    [AC_MSG_RESULT([no])
     result_ok=no],
    AC_MSG_RESULT([ok])
)

AS_IF([test $result_ok = "no"],
    [AC_MSG_ERROR([interpreter does not behave as expected.])],[])

AC_SUBST(interpreter)

###################################################################

# We want GNU Make.
AC_CHECK_PROGS([MAKE], [gmake make])
if ! $MAKE --version | grep 'GNU Make' 2> /dev/null; then
   AC_MSG_ERROR([Need GNU Make to continue])
fi

# The Makefiles
AC_CONFIG_FILES([Makefile])

# Output everything
AC_OUTPUT
