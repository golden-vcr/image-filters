# image-filters

The **image-filters** library exports functions that can be used by
[**dynamo**](https://github.com/golden-vcr/dynamo) in order to perform a discrete set of
image processing operations on generated images.

To build for Windows, open `build/image-filters.sln`. The **image-filters** project
contains the implementation of the library and builds to
`lib/win/release/image-filters.lib`. The **imf** project contains the source for a
command-line test utility which builds to `bin/win/release/imf.exe`.

To build for Linux, run `make`: this will produce a static library at
`lib/linux/image-filters.a` as well as a test binary at `bin/linux/imf`.
