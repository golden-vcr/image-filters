set -e

OPENCV_VERSION='4.9.0'

# Compute our source/build/install paths within this repo
ROOTDIR=$(pwd)
OPENCV_SOURCE_ROOT="$ROOTDIR/opencv"
OPENCV_BUILD_ROOT="$ROOTDIR/opencv-build"
OPENCV_INSTALL_ROOT="$ROOTDIR/opencv-linux"

# Clone the OpenCV source tree at our desired version, if not already present
if [ ! -d "$OPENCV_SOURCE_ROOT" ]; then
    git clone --branch "$OPENCV_VERSION" https://github.com/opencv/opencv "$OPENCV_SOURCE_ROOT"
fi

# Clear any preexisting CMake build state so we can start fresh
rm -rf "$OPENCV_BUILD_ROOT"
rm -rf "$OPENCV_INSTALL_ROOT"

# Invoke CMake to configure out static library build of OpenCV
cmake \
 -S"$OPENCV_SOURCE_ROOT" \
 -B"$OPENCV_BUILD_ROOT" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX="$OPENCV_INSTALL_ROOT" \
 -DBUILD_JAVA=OFF \
 -DBUILD_SHARED_LIBS=OFF \
 -DBUILD_JPEG=ON \
 -DBUILD_OPENJPEG=ON \
 -DBUILD_OPENPNG=ON \
 -DBUILD_PNG=ON \
 -DBUILD_WEBP=ON \
 -DBUILD_ZLIB=ON \
 -DBUILD_opencv_apps=OFF \
 -DBUILD_opencv_calib3d=OFF \
 -DBUILD_opencv_dnn=OFF \
 -DBUILD_opencv_features2d=OFF \
 -DBUILD_opencv_flann=OFF \
 -DBUILD_opencv_gapi=OFF \
 -DBUILD_opencv_highgui=OFF \
 -DBUILD_opencv_java_bindings_generator=OFF \
 -DBUILD_opencv_js=OFF \
 -DBUILD_opencv_js_bindings_generator=OFF \
 -DBUILD_opencv_ml=OFF \
 -DBUILD_opencv_objc_bindings_generator=OFF \
 -DBUILD_opencv_objdetect=OFF \
 -DBUILD_opencv_photo=OFF \
 -DBUILD_opencv_python3=OFF \
 -DBUILD_opencv_python_bindings_generator=OFF \
 -DBUILD_opencv_python_tests=OFF \
 -DBUILD_opencv_stitching=OFF \
 -DBUILD_opencv_ts=OFF \
 -DBUILD_opencv_video=OFF \
 -DBUILD_opencv_videoio=OFF \
 -DBUILD_opencv_world=OFF \
 -DWITH_EIGEN=OFF \
 -DWITH_FFPMEG=OFF \
 -DWITH_FLATBUFFERS=OFF \
 -DWITH_GSTREAMER=OFF \
 -DWITH_GTK=OFF \
 -DWITH_IMGCODEC_HDR=OFF \
 -DWITH_IMGCODEC_PFM=OFF \
 -DWITH_IMGCODEC_PXM=OFF \
 -DWITH_IMGCODEC_SUNRASTER=OFF \
 -DWITH_JASPER=OFF \
 -DWITH_LAPACK=OFF \
 -DWITH_OBSENSOR=OFF \
 -DWITH_OPENEXR=OFF \
 -DWITH_PROTOBUF=OFF \
 -DWITH_TIFF=OFF

# Build OpenCV from source, then install it to our target directory
cmake --build "$OPENCV_BUILD_ROOT"
cmake --install "$OPENCV_BUILD_ROOT"
