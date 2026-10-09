fn main() {
    if let Ok(bundled) = std::env::var("TEXTEDITOR_BUNDLE").or_else(|_| std::env::var("GRAM_BUNDLE")) {
        println!("cargo:rustc-env=TEXTEDITOR_BUNDLE={}", bundled);
        println!("cargo:rustc-env=GRAM_BUNDLE={}", bundled);
    }
}
