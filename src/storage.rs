use crate::config::Config;
use crate::CONFIG;

/// Returns the configuration from the local storage.
pub fn get_config() -> Config {
    CONFIG.with(|cell| cell.borrow().clone())
}

/// Sets the configuration in the local storage.
pub fn set_config(config: Config) {
    CONFIG.with(|cell| *cell.borrow_mut() = config);
}