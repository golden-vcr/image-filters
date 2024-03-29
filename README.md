# image-filters

The **image-filters** library exports functions that can be used by
[**dynamo**](https://github.com/golden-vcr/dynamo) in order to perform a discrete set of
image processing operations on generated images.

## Prerequisites

In addition to git, you'll need to install CMake along with the appropriate C++ build
toolchain for your platform.

On Linux:

- `sudo apt update && sudo apt install -y cmake g++ wget unzip`

On Windows, install Microsoft Visual Studio 2022 (MSVC 17).

## Building

To build for Windows, run `install-opencv.bat`, then open `build/image-filters.sln`. The
**image-filters** project contains the implementation of the library and builds to
`lib/win/release/image-filters.lib`. The **imf** project contains the source for a
command-line test utility which builds to `bin/win/release/imf.exe`.

To build for Linux, run `make`: this will produce a static library at
`lib/linux/image-filters.a` as well as a test binary at `bin/linux/imf`.
