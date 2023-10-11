mod config;
mod storage;

use crate::config::Config;
use ic_cdk_macros::{init, inspect_message, query};
use std::{
    cell::RefCell,
    sync::atomic::{AtomicU64, Ordering},
    time::Duration,
};

#[allow(clippy::unused_unit)]
mod ic0 {
    #[link(wasm_import_module = "ic0")]
    extern "C" {
        pub fn cycles_burn128(amount_high: u64, amount_low: u64, dst: u32) -> ();
    }
}

thread_local! {
    /// The local storage for the configuration.
    static CONFIG: RefCell<Config> = RefCell::new(Config::default());
    /// The global counter to increment periodically.
    static COUNTER: RefCell<u32> = RefCell::new(0);
}

/// Initial canister balance to track the cycles usage.
static INITIAL_CANISTER_BALANCE: AtomicU64 = AtomicU64::new(0);
/// Canister cycles usage tracked in the periodic task.
static CYCLES_USED: AtomicU64 = AtomicU64::new(0);

fn cycles_burn() {
    let mut bytes = vec![0u8; 16];
    let cycles = crate::storage::get_config().burn_rate;
    let amount_high: u64 = (cycles >> 64) as u64;
    let amount_low: u64 = ((cycles << 64) >> 64) as u64;
    unsafe { ic0::cycles_burn128(amount_high, amount_low, bytes.as_mut_ptr() as u32) }
}

fn increment_counter() {
    COUNTER.with(|counter| {
        *counter.borrow_mut() += 1;
        ic_cdk::println!("Timer canister: Counter: {}", counter.borrow());
    });
}

/// Tracks the amount of cycles used for the periodic task.
fn track_cycles_used() {
    // Update the `INITIAL_CANISTER_BALANCE` if needed.
    let current_canister_balance = ic_cdk::api::canister_balance();
    INITIAL_CANISTER_BALANCE.fetch_max(current_canister_balance, Ordering::Relaxed);
    // Store the difference between the initial and the current balance.
    let cycles_used = INITIAL_CANISTER_BALANCE.load(Ordering::Relaxed) - current_canister_balance;
    CYCLES_USED.store(cycles_used, Ordering::Relaxed);
}

fn periodic_task() {
    cycles_burn();
    // Just increment the counter.
    increment_counter();
    track_cycles_used();
}

fn start_with_interval_secs() {
    let secs = Duration::from_secs(crate::storage::get_config().interval_between_timers_in_seconds);
    ic_cdk::println!("Timer canister: Starting a new timer with {secs:?} interval...");
    // Schedule a new periodic task.
    ic_cdk_timers::set_timer_interval(secs, periodic_task);
}

/// This function is called when the canister is created.
#[init]
fn init(config: Config) {
    crate::storage::set_config(config);
    start_with_interval_secs();
}

/// Returns the config.
#[query]
fn get_config() -> Config {
    crate::storage::get_config()
}

#[inspect_message]
fn inspect_message() {
    // Reject all replicated calls.
}
