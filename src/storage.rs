use crate::CONFIG;

/// Returns the configuration from the local storage.
pub fn get_config() -> u128 {
    CONFIG.with(|cell| *cell.borrow())
}

/// Sets the configuration in the local storage.
pub fn set_config(config: u128) {
    CONFIG.with(|cell| *cell.borrow_mut() = config);
}
