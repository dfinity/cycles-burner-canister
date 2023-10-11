mod config;
mod storage;

use crate::config::Config;
use ic_cdk_macros::{init, query};
use std::cell::RefCell;

thread_local! {
    /// The local storage for the configuration.
    static CONFIG: RefCell<Config> = RefCell::new(Config::new());
}

/// This function is called when the canister is created.
#[init]
fn init(config: Config) {
    crate::storage::set_config(config);
}

/// Returns the config.
#[query]
fn get_config() -> Config {
    crate::storage::get_config()
}
