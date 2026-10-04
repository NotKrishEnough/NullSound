slint::include_modules!();

#[cfg(target_os = "android")]
#[unsafe(no_mangle)]
pub fn android_main(app: slint::android::AndroidApp) {
    slint::android::init(app).expect("failed to initialize Android backend");
    run_app().expect("failed to run NullSound");
}

#[cfg(not(target_os = "android"))]
fn main() {
    run_app().expect("failed to run NullSound");
}

fn run_app() -> Result<(), slint::PlatformError> {
    let window = MainWindow::new()?;

    let weak = window.as_weak();
    window.on_select_tab(move |tab| {
        if let Some(window) = weak.upgrade() {
            window.set_selected_tab(tab);
        }
    });

    let weak = window.as_weak();
    window.on_play_demo(move || {
        if let Some(window) = weak.upgrade() {
            window.set_now_playing("NullSound demo track".into());
            window.set_status("Playback engine ready".into());
        }
    });

    let weak = window.as_weak();
    window.on_search(move |query| {
        if let Some(window) = weak.upgrade() {
            let query = query.trim().to_string();
            if query.is_empty() {
                window.set_status("Type a song or artist to search.".into());
            } else {
                window.set_status(format!("Searching for “{query}”…").into());
            }
        }
    });

    window.run()
}
