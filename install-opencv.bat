@echo off

set OPENCV_VERSION=4.9.0

rem Get the directory path for the root of this repo
set ROOTDIR=%~dp0
set ROOTDIR=%ROOTDIR:~0,-1%

rem Determine where we'll clone the opencv source and generate build files with CMake
set OPENCV_SOURCE_ROOT=%ROOTDIR%\opencv
set OPENCV_BUILD_ROOT=%ROOTDIR%\opencv-build
set OPENCV_INSTALL_ROOT=%ROOTDIR%\opencv-win

rem Verify that git is installed
where git >nul 2>nul
if %ERRORLEVEL% equ 0 goto git_installed
echo ERROR: git is not in the PATH.
echo Install it from: https://git-scm.com/download/win
exit /b 1
:git_installed

rem Verify that CMake is installed and is in the PATH
where cmake >nul 2>nul
if %ERRORLEVEL% equ 0 goto cmake_installed
echo ERROR: cmake is not in the PATH.
echo Install it from: https://cmake.org/download/
echo Or, if installed, ensure that cmake binaries are in the PATH.
exit /b 1
:cmake_installed

rem Verify that the required version of Visual Studio is installed
set MSVS_VERSION=Visual Studio 17 2022
set DEVENV_COM_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.com
if exist "%DEVENV_COM_PATH%" goto devenv_installed
echo ERROR: %MSVS_VERSION% is not installed at %DEVENV_COM_PATH%.
echo Install it from: https://visualstudio.microsoft.com/vs/
echo Or, if installed to a different location, update DEVENV_COM_PATH in this script.
exit /b 1
:devenv_installed

rem Clone the OpenCV source tree at our desired version, if not already present
if not exist "%OPENCV_SOURCE_ROOT%" (
    git clone --branch %OPENCV_VERSION% https://github.com/opencv/opencv "%OPENCV_SOURCE_ROOT%"
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
)

rem Clear out any preexisting CMake build state so we can start fresh
if exist "%OPENCV_BUILD_ROOT%" (
    rmdir /s /q "%OPENCV_BUILD_ROOT%"
)
if exist "%OPENCV_INSTALL_ROOT%" (
    rmdir /s /q "%OPENCV_INSTALL_ROOT%"
)

rem Invoke CMake to generate a new Visual Studio project to build OpenCV as a static lib
cmake^
 -S"%OPENCV_SOURCE_ROOT%"^
 -B"%OPENCV_BUILD_ROOT%"^
 -G"%MSVS_VERSION%"^
 -Ax64^
 -DCMAKE_BUILD_TYPE=Release^
 -DCMAKE_INSTALL_PREFIX="%OPENCV_INSTALL_ROOT%"^
 -DBUILD_JAVA=OFF^
 -DBUILD_SHARED_LIBS=OFF^
 -DBUILD_opencv_apps=OFF^
 -DBUILD_opencv_calib3d=OFF^
 -DBUILD_opencv_dnn=OFF^
 -DBUILD_opencv_features2d=OFF^
 -DBUILD_opencv_flann=OFF^
 -DBUILD_opencv_gapi=OFF^
 -DBUILD_opencv_highgui=OFF^
 -DBUILD_opencv_java_bindings_generator=OFF^
 -DBUILD_opencv_js=OFF^
 -DBUILD_opencv_js_bindings_generator=OFF^
 -DBUILD_opencv_ml=OFF^
 -DBUILD_opencv_objc_bindings_generator=OFF^
 -DBUILD_opencv_objdetect=OFF^
 -DBUILD_opencv_photo=OFF^
 -DBUILD_opencv_python3=OFF^
 -DBUILD_opencv_python_bindings_generator=OFF^
 -DBUILD_opencv_python_tests=OFF^
 -DBUILD_opencv_stitching=OFF^
 -DBUILD_opencv_ts=OFF^
 -DBUILD_opencv_video=OFF^
 -DBUILD_opencv_videoio=OFF^
 -DBUILD_opencv_world=OFF
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Verify that OpenCV.sln was generated as expected
set OPENCV_SLN_PATH=%OPENCV_BUILD_ROOT%\OpenCV.sln
if exist "%OPENCV_SLN_PATH%" goto opencv_sln_exists
echo ERROR: CMake failed to produce %OPENCV_SLN_PATH%
exit /b 1
:opencv_sln_exists

rem Use Visual Studio to build the solution's ALL_BUILD target, in release mode
"%DEVENV_COM_PATH%" "%OPENCV_SLN_PATH%" /Build Release /Project ALL_BUILD
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Invoke another build to run the INSTALL target
"%DEVENV_COM_PATH%" "%OPENCV_SLN_PATH%" /Build Release /Project INSTALL
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem OK; we now have static libs and headers in opencv-win
echo OK.
echo include and lib files can be found at: %OPENCV_INSTALL_ROOT%
echo You may delete the source and build directories if desired:
echo - %OPENCV_SOURCE_ROOT%
echo - %OPENCV_BUILD_ROOT%
echo OpenCV install complete.
