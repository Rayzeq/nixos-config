use cxx_qt_build::{CxxQtBuilder, PluginType, QmlModule};

fn main() {
    let module = QmlModule::new("RustExtensions").plugin_type(PluginType::Dynamic);

    CxxQtBuilder::new_qml_module(module)
        .file("src/clipboard/mod.rs")
        .build();

    println!("cargo::rustc-link-arg-cdylib=-Wl,--version-script=qt-plugin.version");
}
