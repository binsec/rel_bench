Safe C Library - README
=======================

|safeclib support vis xs:code|

Copying
-------

This project’s licensing restrictions are documented in the file
‘COPYING’ under the root directory of this release. Basically it’s MIT
licensed.

Overview
--------

This library implements the secure C11 Annex K [1]_ functions on top of
most libc implementations, which are missing from them.

The ISO TR24731 Bounds Checking Interface documents indicate that the
key motivation for the new specification is to help mitigate the ever
increasing security attacks, specifically the buffer overrun. [2]_

The rationale document says *“Buffer overrun attacks continue to be a
security problem. Roughly 10% of vulnerability reports cataloged by CERT
from 01/01/2005 to 07/01/2005 involved buffer overflows. Preventing
buffer overruns is the primary, but not the only, motivation for this
technical report.”*\  [3]_

The rationale document continues *“that these only mitigate, that is
lessen, security problems. When used properly, these functions decrease
the danger buffer overrun attacks. Source code may remain vulnerable due
to other bugs and security issues. The highest level of security is
achieved by building in layers of security utilizing multiple
strategies.”*\  [4]_

The rationale document lists the following key points for TR24731:

-  Guard against overflowing a buffer
-  Do not produce unterminated strings
-  Do not unexpectedly truncate strings
-  Provide a library useful to existing code
-  Preserve the null terminated string datatype
-  Only require local edits to programs
-  Library based solution
-  Support compile-time checking
-  Make failures obvious
-  Zero buffers, null strings
-  Runtime-constraint handler mechanism
-  Support re-entrant code
-  Consistent naming scheme
-  Have a uniform pattern for the function parameters and return type
-  Deference to existing technology

and the following can be added…

-  provide a library of functions with like behavior
-  provide a library of functions that promote and increase code safety
   and security
-  provide a library of functions that are efficient

The C11 Standard adopted many of these points, and added some secure
``_s`` variants in the Annex K. The Microsoft Windows/MINGW secure API
did the same, but deviated in some functions from the standard. Besides
Windows (with its msvcrt, ucrt, reactos msvcrt and wine msvcrt variants)
only the unused stlport, Android’s Bionic, Huawei securec and
Embarcadero implemented this C11 secure Annex K API so far. They are
still missing from glibc, musl, FreeBSD, darwin and DragonFly libc,
OpenBSD libc, newlib, dietlibc, uClibc, minilibc.

Design Considerations
---------------------

This library implements since 3.0 all functions defined in the
specifications. [5]_ Included in the library are extensions to the
specification to provide a complementary set of functions with like
behavior.

This library is meant to be used on top of all the existing libc’s which
miss the secure C11 functions. Of course tighter integration into the
system libc would be better, esp. with the printf, scanf and IO
functions. See the seperate `libc-overview <doc/libc-overview.md>`__
document.

Austin Group Review of ISO/IEC WDTR 24731
http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1106.txt

C11 standard (ISO/IEC 9899:2011) http://en.cppreference.com/w/c

CERT C Secure Coding Standard [6]_

Stackoverflow discussion:
https://stackoverflow.com/questions/372980/do-you-use-the-tr-24731-safe-functions

DrDobbs review [7]_
http://www.drdobbs.com/cpp/the-new-c-standard-explored/232901670

C17 reconsidered safeclib but looked only at the old incomplete Cisco
version, not our complete and fixed version.
http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1967.htm

-  Use of errno

The TR24731 specification says an implementation may set errno for the
functions deﬁned in the technical report, but is not required to. This
library does not set ``errno`` in most functions, only in ``bsearch_s``,
``fscanf_s``, ``fwscanf_s``, ``gets_s``, ``gmtime_s``, ``localtime_s``,
``scanf_s``, ``sscanf_s``, ``swscanf_s``, ``strtok_s``, ``vfscanf_s``,
``vfwscanf_s``, ``vsscanf_s``, ``vswscanf_s``, ``wcstok_s``,
``wscanf_s``.

In most cases the safeclib extended ES\* errors do not set ``errno``,
only when the underlying insecure system call fails, errno is set. The
library does use ``errno`` return codes as required by functional APIs.
Specific Safe C String and Safe C Memory errno codes are defined in the
``safe_errno.h`` file.

-  Runtime-constraints

Per the spec, the library verifies that the calling program does not
violate the function’s runtime-constraints. If a runtime-constraint is
violated, the library calls the currently registered runtime-constraint
handler.

Per the spec, multiple runtime-constraint violations in the same call to
a library function result in only one call to the runtime-constraint
handler. The first violation encountered invokes the runtime-constraint
handler.

With ``--disable-constraint-handler`` calling the runtime-constraint
handler can be disabled, saving some memory, but not much run-time
performance.

The runtime-constraint handler might not return. If the handler does
return, the library function whose runtime-constraint was violated
returns an indication of failure as given by the function’s return. With
valid dest and dmax values, dest is cleared. With the optional
``--disable-null-slack`` only the first value of dest is cleared,
otherwise the whole dest buffer.

``rsize_t`` The specification defines a new type. This type,
``rsize_t``, is conditionally defined in the ``safe_lib.h`` header file.

``RSIZE_MAX`` The specification defines the macro ``RSIZE_MAX`` which
expands to a value of type ``rsize_t``. The specification uses
``RSIZE_MAX`` for both the string functions and the memory functions.
This implementation defines two macros: ``RSIZE_MAX_STR`` and
``RSIZE_MAX_MEM``. ``RSIZE_MAX_STR`` defines the range limit for the
safe string functions. ``RSIZE_MAX_MEM`` defines the range limit for the
safe memory functions. The point is that string limits can and should be
different from memory limits. There also exist ``RSIZE_MAX_WSTR``,
``RSIZE_MAX_MEM16``, ``RSIZE_MAX_MEM32``.

-  Compile-time constraints

With supporting compilers the dmax overflow checks and several more are
performed at compile-time. Currently only since clang-5 with
``diagnose_if`` support. This checks similar to ``_FORTIFY_SOURCE=2`` if
the ``__builtin_object_size`` of the dest buffer is the same size as
dmax, and errors if dmax is too big. With the optional
``--enable-warn-dmax`` it prints a warning if the sizes are different,
which is esp. practical as compile-time warning. It can be promoted via
the optional ``--enable-error-dmax`` to be fatal. On unsupported
compilers, the overflow check and optional equality warn-dmax check is
deferred to run-time. This check is only possible with
``__builtin_object_size`` and ``-O2`` when the dest buffer size is known
at compile-time, otherwise only the simplier ``dest == NULL``,
``dmax == 0`` and ``dmax > RSIZE_MAX`` checks are performed.

-  Header Files

The specification states the various functions would be added to
existing Standard C header files: stdio.h, string.h, etc. This
implementation separates the memory related functions into the
``safe_mem_lib.h`` header, the string related functions into the
``safe_str_lib.h`` header, and the rest into the ``safe_lib.h`` header.
There are also the internal ``safe_compile.h``, ``safe_config.h``
``safe_lib_errno.h`` and ``safe_types.h`` headers, but they do not need
to be included.

The make file builds a single library ``libsafec-VERSION.a`` and
``.so``. Built but not installed are also libmemprims, libsafeccore and
libstdunsafe.

It is possible to split the make such that a separate
``safe_mem_lib.so`` and ``safe_str_lib.so`` are built. It is also
possible to integrate the prototypes into the Standard C header files,
but that may require changes to your development tool chain.

Userspace Library
-----------------

The build system for the userspace library is the well known *GNU build
system*, a.k.a. Autotools. This system is well understood and supported
by many different platforms and distributions which should allow this
library to be built on a wide variety of platforms. See the `Tested
platforms <#tested-platforms>`__ section for details on what platforms
this library was tested on during its development.

-  Building

For those familiar with autotools you can probably skip this part. For
those not and want to get right to building the code see below. And, for
those that need additional information see the ``INSTALL`` file in the
same directory.

To build you do the following:

::

   ./build-aux/autogen.sh
   ./configure
   make

``autogen.sh`` only needs to be run if you are building from the git
repository. Optionally, you can do ``make check`` if you want to run the
unit tests.

-  Installing

Installation must be preformed by ``root``, an ``Administrator`` on most
systems. The following is used to install the library.

::

   sudo make install

Safe Linux Kernel Module
------------------------

The build for the kernel module has not been integrated into the
autotools build infrastructure. Consequently, you have to run a
different makefile to build the kernel module.

-  Building

.To build do the following:

::

   ./configure --disable-wchar
   make -f Makefile.kernel

This assumes you are compiling on a Linux box and this makefile supports
the standard kernel build system infrastructure documented in:
``/usr/src/linux-kernel/Documentation/kbuild/modules.txt``

NOTE: If you build the kernel module then wish to build the userspace
library or vice versa you will need to do a ``make clean`` otherwise a
``make check`` will fail to build.

-  Installing

The kernel module will be found at the root of the source tree called
``slkm.ko``. The file ``testslkm.ko`` are the unit tests run on the
userspace library but in Linux kernel module form to verify
functionality within the kernel.

Tested Platforms
----------------

The library has been tested on the following systems:

-  Linux Fedora core 31 - 32 amd64/i386 glibc 2.28 - 2.31 (all gcc’s +
   clang’s)
-  Mac OS X 10.6-12 w/ Apple developer tools and macports (all gcc’s +
   clang’s)
-  Linux Debian 9 - 11 amd64/i386 glibc 2.24 - 2.28 (all gcc’s +
   clang’s)
-  Linux centos 7 amd64
-  Linux Void amd64 musl-1.1.16
-  x86_64-w64-mingw32 native and cross-compiled
-  i686-w64-mingw32 native, and cross-compiled and tested under wine
-  i386-mingw32 cross-compiled
-  cygwin32 gcc (newlib)
-  cygwin64 gcc -std=c99 (newlib)
-  freebsd 10 - 12 amd64
-  linux docker images under qemu: i386/debian, x86_64/rhel,
   arm32v7/debian, aarch64: arm64v8/{debian,centos,rhel,fedora},
   s390x/fedora (the only big endian test I could find),
   ppc64le/{debian,ubuntu,fedora,centos,rhel}
-  User Mode Linux (UML), Linux kernel version v3.5.3 w/ Debian Squeeze
   rootfs

with most available compilers. See ``build-aux/smoke.sh`` and the
various CI configs.

-  https://travis-ci.org/github/rurban/safeclib/
-  https://ci.appveyor.com/project/rurban/safeclib/
-  https://cirrus-ci.com/github/rurban/safeclib
-  https://cloud.drone.io/rurban/safeclib/

Known Issues
------------

1. If you are building the library from the git repository you will have
   to first run ``build-aux/autogen.sh`` which runs autoreconf to
   ``install`` the autotools files and create the configure script.

References
----------

.. [1]
   C11 Standard (ISO/IEC 9899:2011) Annex K

.. [2]
   Programming languages, their environments and system software
   interfaces, Extensions to the C Library, Part I: Bounds-checking
   interfaces, ISO/IEC TR 24731-1.

.. [3]
   Rationale for TR 24731 Extensions to the C Library Part I:
   Bounds-checking interfaces, ISO/IEC JTC1 SC22 WG14 N1225.

.. [4]
   Rationale for TR 24731 Extensions to the C Library Part I:
   Bounds-checking interfaces, ISO/IEC JTC1 SC22 WG14 N1225.

.. [5]
   The Open Group Base Specifications Issue 7
   http://pubs.opengroup.org/onlinepubs/9699919799/functions/contents.html

.. [6]
   CERT C Secure Coding Standard
   https://www.securecoding.cert.org/confluence/display/seccode/CERT+C+Secure+Coding+Standard

.. [7]
   DrDobbs review
   http://www.drdobbs.com/cpp/the-new-c-standard-explored/232901670

.. |safeclib support vis xs:code| image:: doc/safeclib-banner.png
   :target: https://xscode.com/rurban/safeclib
