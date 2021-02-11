Set-PSDebug -Trace 1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'
function ThrowOnNativeFailure {
    if (-not $?)
    {
        throw 'Native Failure'
    }
}

$THIS_DIR="$PSScriptRoot"

$PROJECT_ROOT_DIR="$THIS_DIR/.."
$BUILD_DIR="$PROJECT_ROOT_DIR/.build/Release"
$INSTALL_DIR="$PROJECT_ROOT_DIR/.out"

$CMAKE_BUILD_TYPE="Release"
$NEXTALIGN_STATIC_BUILD=1

conan profile new default --detect
ThrowOnNativeFailure

conan remote add bincrafters https://api.bintray.com/conan/bincrafters/public-conan
ThrowOnNativeFailure

pushd "$PROJECT_ROOT_DIR/3rdparty/tbb"
conan create . local/stable -s build_type="$CMAKE_BUILD_TYPE" -o shared=False
ThrowOnNativeFailure
popd


conan install "$PROJECT_ROOT_DIR" -s build_type="$CMAKE_BUILD_TYPE" -o tbb:shared=False -o boost:header_only=True --build missing
ThrowOnNativeFailure

#-DCMAKE_GENERATOR_TOOLSET="v141" `

cmake $PROJECT_ROOT_DIR `
-G "Visual Studio 16 2019" -A "x64" -T "ClangCl" `
-DCMAKE_MODULE_PATH="$BUILD_DIR" `
-DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" `
-DCMAKE_EXPORT_COMPILE_COMMANDS=1 `
-DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" `
-DNEXTALIGN_STATIC_BUILD="$NEXTALIGN_STATIC_BUILD" `
-DNEXTALIGN_BUILD_BENCHMARKS=0 `
-DNEXTALIGN_BUILD_TESTS=0
ThrowOnNativeFailure

cmake --build "$BUILD_DIR" --config "$CMAKE_BUILD_TYPE"
ThrowOnNativeFailure

cmake --install "$BUILD_DIR" --config "$CMAKE_BUILD_TYPE" --strip
ThrowOnNativeFailure

Get-ChildItem "$INSTALL_DIR"
ThrowOnNativeFailure
