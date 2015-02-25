rundir
======

A [runnable directory](https://en.wikipedia.org/wiki/Application_directory)
implementation that also allows for creating self-running archives of
runnable directories.

Copyright (c) 2014–2015 Scott Zeid <s@zeid.me>.  
http://code.s.zeid.me/rundir

Released under the X11 License:  <https://tldrlegal.com/license/x11-license>


Specification
-------------

This program's behavior is documented in [SPEC.md][spec-md].  It does implement
the optional self-extracting archive protocol.

[spec-md]: http://code.s.zeid.me/rundir/src/master/SPEC.md


Usage
-----

Run `rundir --help` for command-line usage information.


Portability
-----------

This script is intended to be as portable between \*nix systems as possible.
Therefore, an effort has been made to only use POSIX-defined commands,
POSIX-defined arguments to those commands, and POSIX-defined shell features.
The only exception is `tar`, but that is only used in the self-extracting
archive code.

Contributions to this script are welcome if and only if they meet those
criteria.

Also, this is written as a shell script and not in C/C++ because it is
intended to be portable across processor architectures *without* the need
to compile code.

Although this script is written to be portable, the same, however, is not
necessarily true for runnable directories themselves, obviously.  Authors
of runnable directories should take care to account for differences between
\*nix systems and processor architectures.
