rundir Runnable Directory Specification
=======================================

A [runnable directory](https://en.wikipedia.org/wiki/Application_directory)
mechanism that also optionally allows for creating self-running archives of
runnable directories.


Version 0.0.1, 2015-02-24  
Copyright (c) 2014–2015 Scott Zeid.

This specification and its reference implementation are released under [the X11
License](https://tldrlegal.com/license/x11-license), but code samples in this
document are public domain (or a legal equivalent) via [the Creative Commons
Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/).


The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and
"OPTIONAL" in this document are to be interpreted as described in
[RFC 2119](http://tools.ietf.org/html/rfc2119).

The term "portable shell" is defined as the intersection of the latest
versions at the time of implementation of the POSIX standard and [the
GNU Autoconf manual's guide to Portable Shell Programming][portable-shell],
adapted as necessary to accomodate not running in an autoconf environment.
[portable-shell]: https://www.gnu.org/software/autoconf/manual/html_node/Portable-Shell.html

Paragraphs and other logical sections preceded with the word "rationale"
or substantially similar text SHALL NOT be treated as part of this
specification.

A reference implementation, written in portable \*nix shell, of this
specification is available at
  <http://code.s.zeid.me/rundir>,
  <https://bitbucket.org/scottywz/rundir>,
and
  <https://github.com/scottywz/rundir>.
Those links all point to the same program in the same git repository.


Contents
--------

* TL;DR
* Runnable directory structure
* Running directories
* Invoking a runnable directory implementation
* Runnable directory guidelines
* Self-extracting archives


TL;DR
-----

(This section is NOT part of the specification.  Conformant implementations
MUST conform to the long form that this section summarizes.)

* Runnable directory structure:
    - `bin/` (optional)  
      (Prepended to $PATH, but not for `AppRun` since ROX doesn't do this.)
    - `run`, `run.mk`, or `AppRun`, in that order (the **runfile**)  
      (`AppRun` is for compatibility with ROX.  DOS/Windows will also
      consider `run.exe` before `run`.)
    - `<zero or more arbitrary items>`

* `run.mk`, if used, is a makefile with "default" being the default
  target (only the first argument is considered for that purpose).

* Owners of `bin/` and the runfile must be the same as the runnable
  directory's owner for security reasons.

* Makefile runfiles are executed with the runnable directory itself as the
  working directory; other runfiles will use the working directory with which
  the runnable directory implementation was invoked.

* Except as described above for `run.mk`, arguments are not treated specially.

* However, command-line implementations may accept their own arguments if
  they understand `--` as an optional separator between implementation
  arguments and the payload and its arguments.

* Optionally, implementations can support making self-extracting archives
  out of runnable directories.

* The reference implementation is written in portable \*nix shell for
  maximum portability across \*nixes.


Runnable directory structure
----------------------------

The structure of the top level of the runnable directory MUST be as follows:

- **`bin/`** (optional)
  This directory, if present, MUST be prepended to the $PATH used to
  run the runfile if and only if the runfile is NOT named `AppRun`.

- **`run`, `run.mk`, or `AppRun`** (this is called the **runfile**)
  The file executed when running the directory MUST be ONLY the first
  of the above names, when searched for in the left-to-right order
  listed above, that exists (regardless of what type of file it is
  or even if it's a directory).  In addition, the name **`run.exe`**
  MUST be considered before `run` if running in DOS, Microsoft Windows,
  or alternate implementations thereof (e.g. ReactOS).

- **`<zero or more arbitrary items>`**

_**Rationale:**
 The name `AppRun` is required for compatibility with the ROX desktop
 environment.  Also, since ROX does not support special treatment of
 a `bin` directory, special treatment of a `bin` directory is forbidden
 when the runfile is named `AppRun`._


Running directories
-------------------

When running a directory, the runfile and the `bin` directory, if it is a
directory, MUST be sanity checked as follows:

* The runfile MUST be executable if it is not a makefile.

* The runfile MUST have the same owner as the runnable directory itself.

* The `bin` directory immediately inside the runnable directory, if it is
  a directory, MUST have the same owner as the runnable directory itself.

* Files and directories contained within the `bin` directory SHOULD have
  owners that match the runnable directory's owner, and this check MUST
  be done recursively if it is done at all.

If ANY of the above criteria are not met, then running the directory MUST
fail.  However, executable bits and file or directory owners do NOT need
to be checked in environments that do not support them, as applicable.

_**Rationale:**
 Compliant implementations fail if the runfile's owner and/or `bin`'s owner
 is not the same as the directory's owner, in order to prevent attacks such
 as dropping a runfile in `/tmp` and then tricking someone to run `/tmp`
 (e.g. by making a symlink to `/tmp` with an innocuous-looking name).  `/tmp`
 could also be any other directory writable by users other than the owner._

If the runfile is a makefile, then `default` must be used as the default
make target instead of `all`.  Only the first argument to the runnable
directory shall be used to determine the default target.  The `make`
implementation used MUST be told to "always make", e.g. with the `-B`
argument to a standard `make` implementation.

Makefile runfiles shall be executed with the runnable directory itself as
the working directory.

Implementations of `make` with non-standard invocations, such as Mozilla's
`pymake`, MAY be used.

A conforming runnable directory implementation does NOT need to provide
or guarantee the presence of a `make` implementation and MUST fail if there
is none available.

_**Rationale:**
 Makefiles used as runfiles will likely need to behave differently than
 makefiles used to compile software.  For example, they may be used to
 compile a program and then run it, or as a wrapper for simple shell
 tasks (although this is not portable).
 
 Makefiles are designed to work with files in their own directory;
 therefore, we change to the runnable directory when the runfile is a
 makefile.
 
 Since makefiles are not portable, their support is optional on systems
 without an available `make` implementation._

The runfile SHALL be run with the following stipulations:

* If the `bin` directory immediately inside the runnable directory is a
  directory, it must be prepended to the $PATH or $PATH equivalent used
  when running the directory.  It MUST NOT be used in the $PATH or $PATH
  equivalent used to run the runnable directory implementation itself
  unless it already happens to be there.  (This behavior is OPTIONAL
  if the environment does not support $PATH or an equivalent to $PATH.)

* For all runfiles other than makefiles, the runnable directory
  implementation MUST NOT change the working directory for any reason
  whatsoever.

* Command-line arguments not consumed by the runnable directory
  implementation MUST be passed as-is to the runfile, except:

* If the runfile is a makefile, the first such argument MUST be observed
  to determine the default target, and if there are no arguments, then
  the first argument to a makefile runfile MUST be set to `default`.

* If the runfile is a directory or a link to one, execution MUST fail.


Invoking a runnable directory implementation
--------------------------------------------

In this section, "exit" is defined to mean any means of passing control
back to the environment that called the implementation, and return codes
are only required when the implementation is actually invoked as a
command or command equivalent (e.g. shell function).

Runnable directory implementations MAY support command-line arguments, and
if and only if they do, the following applies:

* The implementation MUST support passing arguments to the runnable directory.

* Command-line arguments not consumed by the runnable directory
  implementation MUST be passed as-is to the runfile, except:

* If the runfile is a makefile, the first such argument MUST be observed
  to determine the default target, and if there are no arguments, then
  the first argument to a makefile runfile MUST be set to `default`.

* `--` MUST be understood to separate options to the implementation from
  the runnable directory's path or name and arguments to the runnable
  directory, even if the implementation does not understand any other
  arguments.  The implementation MUST also allow `--` to be omitted.

* `--help`/`-h` MUST print a usage string and exit with code 0.

* `--search-path`/`-p` MUST cause the runnable directory to be treated as
  a plain filename to search for on the $PATH or $PATH equivalent, and
  the found filename MUST be used as the runnable directory.  If no filename
  is found, the implementation MUST exit with code 127.

* `--make-sfx` must be reserved for a conforming self-running archive
  generator and must exit with code 2 in the case of bad arguments.  If
  this argument is supplied and implemented, the next two arguments MUST
  be, in order, the path to the runnable directory and the output filename,
  and subsequent arguments MUST be treated as invalid.

* Invocation with invalid arguments MUST result in an exit code of 2.

If the implementation is invoked as a command or command equivalent, it MUST
exit with code 0 in the event of success (and, as applicable, success of the
runfile), 2 in the event of bad arguments, or 127 in the case of any other
error.

_**Rationale:**
 Return code 127 is used in the event of general failure since the runfile
 may return a lower code, which users will generally want to see as-is._


Runnable directory guidelines
-----------------------------

Makefile runfiles SHOULD only assume standard makefile syntax, and not any
vendor extensions.

Runnable directories SHOULD contain only regular files, directories, or
*relative* symbolic links to regular files or directories contained somewhere
within the runnable directory.

If your runfile is a shell script, it SHOULD have the shebang line `#!/bin/sh`
with no extra arguments or trailing whitespace.  Shell script runfiles SHOULD
be "portable shell" as defined at the beginning of this document.

To implement a runnable directory that runs with itself as the current working
directory, and with the runfile being a shell script, the runfile SHOULD use
an incantation similar to:

```sh
dir=`dirname "$0"`; dir=`(cd "$dir"; pwd)`
cd "$dir"
```

or

```sh
dir=`dirname "$0"`; cd "$dir"; dir=`pwd`
```

To just get the runnable directory's path but not change to it:

```sh
dir=`dirname "$0"`; dir=`(cd "$dir"; pwd)`
```

The rationale for doing this instead of, for example,

```sh
dir=$(cd "`dirname "$0"`; pwd)
```

is that (a) `$(...)` is not portable, (b) backtick substitutions with double
quotes both inside and surrounding the substituions are not portable, (c)
directory names with spaces must be accounted for, and (d) it is best practice
to not use all caps for global shell variables.

The first incantation for changing to the runnable directory may be easier to
remember for copy/paste purposes when one only wants to get the path of the
runnable directory.  (Remember that the code samples here are public domain
via CC0.)

It should be noted that on some older systems, `pwd` will yield a physical
path (symbolic links resolved), whereas most modern systems use logical
paths (symbolic links *not* resolved).  The `-L` and `-P` options to change
this behavior are *not* portable.  This is one reason why symbolic links in
runnable directories SHOULD ONLY be relative and SHOULD ONLY point to files
or directories contained within the runnable directory.

`dirname` (and `basename`) may not be portable to very old systems, but they
are part of POSIX, and enough systems should support them by now that it should
not be too much of a concern.  If it is, runnable directory authors may wish to
include portable shell script implementations in the runnable directory's `bin`
directory.


Self-extracting archives
------------------------

It is OPTIONAL for conforming implementations to implement this section.

An implementation MAY be capable of producing self-extracting archives that
run immediately on extraction to a temporary directory, which is deleted
after execution.

A conforming self-extracting archive MUST NOT treat any command-line
arguments specially (except for the first argument when the runfile is
a makefile) and MUST accept ALL of the following environment variables,
or the equivalent behavior when environment variables are unsupported
by the environment or otherwise not applicable:

- `RUNDIR_SFX_EXTRACT=<dirname>`:  extract to `<directory>`
- `RUNDIR_SFX_LIST=1|true`:  list the archive's contents
- `RUNDIR_SFX_CAT=1|true`:  dump the archive to stdout
- `RUNDIR_SFX_HELP=1|true`:  print this usage message
- `RUNDIR_SFX_USAGE=1|true`:  print this usage message
- `RUNDIR_SFX_TMP=<directory>`:  use `<directory>` instead of `/tmp`

All of these variables or their equivalent actions MUST cancel the
usual behavior EXCEPT for `RUNDIR_SFX_TMP`.

The SFX archives MUST BE shell scripts that conform to the following:

* They MUST have the shebang line `#!/bin/sh` with no extra arguments or
  trailing whitespace.

* They MUST conform to the intersection of POSIX and the [GNU Autoconf
  Portable Shell Programming guide][portable-shell], adapted as necessary
  for a generic, non-autoconf environment.

* They MUST have a GZIP-compressed TAR archive containing the payload
  appended after the marker line `__ARCHIVE_FOLLOWS_IF_SFX__`.

* They MUST use UNIX line endings (`\n` only) before and including the
  marker line.

* They MUST NOT require any interaction between or after the archive's own
  invocation and the payload's invocation.  The payload, of course, MAY
  require interaction.

* Upon invocation, they MUST extract their contents to a temporary directory
  or emulate a file system containing the payload, execute the payload as
  a normal runnable directory described by the mandatory parts of this
  specification, and then delete the temporary directory or destroy the
  emulated file system.

* The exit code of the payload MUST be preserved if the environment supports
  exit codes.
