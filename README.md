SpadUnit
========

SpadUnit is a testing framework. It is basically the standard
[automake](https://www.gnu.org/software/automake/) test framework with
parallel builds enabled.
It is written for
[FriCAS](http://fricas.github.io), but is actually (relatively)
independent of
[FriCAS](http://fricas.github.io),
so that it can also made to work with
[Axiom](http://axiom-developer.org) and
[OpenAxiom](http://www.open-axiom.org).

SpadUnit allows to write testfiles in a simple input format.
In fact, it *is* a in the format of an ordinary
[FriCAS](http://fricas.github.io) `.input` file,
but with testing function as defined in `src/spadunit.spad` enabled,
namely

     assertTrue:  Boolean -> Void
     assertFalse: Boolean -> Void
     assertEquals:    (T, T) -> Void
     assertNotEquals: (T, T) -> Void

where `T: SetCategory`, i.e., where `T` exports the following functions.

    =: (T, T) -> Boolean
    coerce: T -> OutputForm

Note that the `assert...` functions are designed to exit a
[FriCAS](http://fricas.github.io) session
with a non-zero exit code if the assertion fails to hold.
See Section [PanAxiom conditions](#panaxiom-conditions).

**Example**

    --test:set0
    s: List Integer := [];
    assertTrue(empty? s);
    assertEquals(#s, 0)
    --endtest

For more detail see Section [The testfile format](#the-testfile-format).


Prerequisites
-------------

Before you can work with SpadUnit, make sure you have a GNU automake
and autoconf running in a recent version.
Automake 1.15.1 and autoconf 2.69 are known to work,
but the most important feature of automake that we are using is its
[Parallel Test Harness](http://www.gnu.org/software/automake/manual/html_node/Simple-Tests.html).
Thus, also slightly older versions should be OK.

The executable `fricas` should be in your `PATH`.
You can relax this condition, see Section
[Important files](#important-files).

If you are using SpadUnit with
[Axiom](http://axiom-developer.org) or
[OpenAxiom](http://www.open-axiom.org), then
look into [PanAxiom conditions](#panaxiom-conditions).


Installation
------------

In order to work with SpadUnit, it is enoough to clone the sources
from Github.

    git clone https://github.com/hemmecke/spadunit.git


How to use SpadUnit
-------------------

SpadUnit wants to know two things, a project directory and a test
directory.
You initialize SpadUnit by calling

    make PROJECT=/path/to/toplevel/projectdir TESTDIR=/path/to/test

The path for `PROJECT` **must** be an **absolute** path pointing
to the top-level directory of the project that you want to test.
See Section
[How SpadUnit works internally](#how-spadunit-works-internally)
for more details.

The variable `TESTDIR` should point to the directory that contains the
test files of the form `*.input.test`.
Look into `projects/fricas/test` for examples of such test files.

If the parameter `TESTDIR` is missing from the `make` call,
it is equivalent to `$PROJECT/test`.

If the parameter `PROJECT` is missing, it defaults to
`${pwd}/project`. In other words, if you have a project in
`/path/to/project` with a subdirectory `/path/to/project/test`
that contains the test files, then it is enough to say

    cd spadunit
    ln -s /path/to/project project
    make

In order to actually run the tests, simply call

    make check

You might also consider a silent and parallel run.

    make -s -j8 check

Note that `$PROJECT/prepare-spad` is called each time when
`make check` is invoked, which gives you a hook to recompile
your project in case anything changed.

SpadUnit will automatically recreate the `.input` files from the
`.input.test` files if it detects any modification.

Other calling options are

    make recheck

and

    make clean

where the first will rerun the tests that have failed and
the latter will completely remove the `build` subdirectory.

**Example**

SpadUnit comes with a little example project under `projects/fricas`.
To try it out, issue the following:

    cd spadunit
    ln -s `pwd`/projects/fricas project
    make
    make -s check


Further notes
-------------

The test framework has mainly been developed to check commands from
`*.input` files (see Section
[The testfile format](#the-testfile-format)). However, any file in the
test directory that ends in `.spad` or `.as` will be compiled before
any test is started. Thus, the framework can be used to quickly check
whether modifying an existing `.spad` file under `src/algebra` of the
[FriCAS](http://fricas.github.io) source code tree passes a number
of tests without recompiling all of [FriCAS](http://fricas.github.io).
For that, simply put the respective `.spad` file into the `$TESTDIR`
directory, modify it accordingly, and provide corresponding
`*.input.test` files that test the (new/modified) features.

In order to work with `.as` files you must have the
[Aldor](https://github.com/pippijn/aldor) compiler available
and have a compiled `libaxiom.al`.
The `aldor` executable must be in your `PATH`, but see Section
[Important files](#important-files).


The testfile format
-------------------

The code chunks of testfiles (`*.input.test`) must follow the
following convention.

  * Each test is written in a chunk of the following pattern.

        --test:NAME
        CODE OF THE TEST IN SEVERAL LINES
        --endtest

    The `--` must appear in the first position of the line.

  * Since `NAME` is used as part of a filename, it should not contain
    any strange characters. Restriction to names matching the regular
    expression `[a-zA-Z0-9_-]+` is appreciated. In particular, no
    spaces or dots are allowed. However, there is no code that checks
    this. But be prepared that the testing framework might not
    function properly if strange names appear.

  * Duplicates of `--test:NAME` with identical `NAME` part per file are
    joined together and executed as one chunk.

  * Optionally each `.test` file can contain two special chunks, namely

        --setup
        LINES OF SETUP CODE
        --endsetup

    and

        --teardown
        LINES OF TEAR DOWN CODE
        --endteardown

     The `--` must appear in the first position of the line.

     If existing, these are prepended and appended to each test of the
     respective `*.input.test` file and should contain preparation and
     clean-up code. For example, some test might write files.

     The teardown code should make sure that everything is cleaned up again.

     **NOTE:** The teardown code is currently being ignored, i.e., that
     feature is not implemented.


Important files
---------------

  * `src/interpreter`

    Script to call the PanAxiom interpreter with a `.input` file like

        interpreter foo.input

    `interpreter` exits with a zero exit code on success and **must**
    abort with non-zero exit code if an error occurs.

  * `src/spadcompiler`

    Compile a `.spad` file so that the respective constructors from
    that file can be used via `)library foo` from inside the
    interpreter.

        spadcompiler foo.spad

    `spadcompiler` exits with a zero exit code on success and **must**
    abort with non-zero exit code if the compilation fails.

  * `src/ascompiler`

    Compile a `.as` file so that the respective constructors from
    that file can be used via `)library foo` from inside the
    interpreter.

        ascompiler foo.as

    `ascompiler` exits with a zero exit code on success and **must**
    abort with non-zero exit code if the compilation fails.

How SpadUnit works internally
-----------------------------

By design SpadUnit creates a (new) subdirectory `build`, if it does
not yet exist. Otherwise it (re-)uses every data that lies there.
SpadUnit never writes a file outside this `build` directory.

After running

    make PROJECT=/path/to/toplevel/projectdir TESTDIR=/path/to/test

there will be two subdirectories (which are actually symbolic links),
namely

    build/p -> $PROJECT
    build/t -> $TESTDIR

The `build` directory is the working directory for running any
compilation relevant for SpadUnit.

SpadUnit first runs

    cd build
    p/prepare-spadunit

if `prepare-spadunit` exists.
If needed, this program can write a file `loadlibs.input` into
the `build` directory.
If SpadUnit find `loadlibs.input`, it reads that file before
a test is executed.

**Example for a prepare-spad shell script**

    # Assume that the target 'compile-spad' put all things into
    # the 'tmp' subdirectory of the project directory including
    # a file 'projectlibs.input' with a list of `)lib' commands
    # and a file 'projectmacros.input' with common macros.

    # Only change the directory in a subshell.
    (cd p; make compile-spad)

    cat <<EOF > loadlibs.input
    )cd p/tmp
    )read projectlibs
    )read projectmacros
    EOF


After calling `prepare-spadunit`, SpadUnit creates the
`*.input` files from the respective
`--test:NAME` entries in the `t/*.input.test` files and
compiles any `t/*.spad` and any `t/*.as` files.


PanAxiom conditions
-------------------

In order to use SpadUnit as is, PanAxiom must implement a Lisp
function `exit-with-status` that can be called from `spadunit.spad`
as `EXIT_-WITH_-STATUS(1$Integer)$Lisp`. See
[fricas-lisp.lisp](https://github.com/fricas/fricas/blob/master/src/lisp/fricas-lisp.lisp#L210)
for how such a function is defined in FriCAS.

The scripts `interpreter`, `spadcompiler`, and `ascompiler` must
return a non-zero exit code if an error occurs.
In [FriCAS](http://fricas.github.io), that
behaviour can be enabled by executing

    )set breakmode quit

Known issues
------------

  * Spelling errors are not caught. For example, a test like

        assertTruE(false)

    will not fail, because the spelling of `assertTrue` is wrong. The
    interpreter will complain, but we cannot currently catch that error.

  * TODO: The teardown code is currently never called.
