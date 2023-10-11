mod storage;

use ic_cdk_macros::{init, query};
use std::cell::RefCell;

thread_local! {
    /// The local storage for the configuration.
    static CONFIG: RefCell<u128> = RefCell::new(0);
}

/// This function is called when the canister is created.
#[init]
fn init(config: u128) {
    crate::storage::set_config(config);
}

/// Returns the config.
#[query]
fn get_config() -> u128 {
    crate::storage::get_config()
}
