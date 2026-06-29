cmake_minimum_required(VERSION 3.28)
project(rust_extensions LANGUAGES CXX)

set(CMAKE_INSTALL_RPATH "$ORIGIN")
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

find_package(Qt6 COMPONENTS Core Gui Qml QuickControls2 REQUIRED)

include(FetchContent)
FetchContent_Declare(
    CxxQt
    SOURCE_DIR ${FETCHCONTENT_SOURCE_DIR_CXXQT}
)
FetchContent_MakeAvailable(CxxQt)

cxx_qt_import_crate(
    MANIFEST_PATH "Cargo.toml"
    CRATES rust_extensions
    QT_MODULES Qt::Core Qt::Gui Qt::Qml Qt::QuickControls2
)

cxx_qt_import_qml_module(rust_extensions_qml_module
    URI "RustExtensions"
    SOURCE_CRATE rust_extensions
    OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}
)
