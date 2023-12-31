mod config;
mod metrics;
mod storage;
mod types;

use crate::config::Config;
use crate::types::{CandidHttpRequest, CandidHttpResponse};
use ic_cdk::api::call::{reject, reply};
use ic_cdk_macros::{init, inspect_message, post_upgrade, pre_upgrade, query};
use serde_bytes::ByteBuf;
use std::{cell::RefCell, time::Duration};

thread_local! {
    /// The local storage for the configuration.
    static CONFIG: RefCell<Config> = RefCell::new(Config::default());
    /// The global counter to increment periodically.
    static COUNTER: RefCell<u32> = RefCell::new(0);
    /// Canister cycles usage tracked in the periodic task.
    static TOTAL_CYCLES_BURNT: RefCell<u128> = RefCell::new(0);
}

/// Increments counter representing the number of executed global timers.
fn increment_counter() {
    COUNTER.with(|counter| {
        *counter.borrow_mut() += 1;
        ic_cdk::println!("Timer canister: Counter: {}", counter.borrow());
    });
}

/// Tracks the amount of cycles burnt by the periodic task.
fn track_cycles_burnt(amount_burnt: u128) {
    TOTAL_CYCLES_BURNT.with(|total_cycles_burnt| {
        *total_cycles_burnt.borrow_mut() += amount_burnt;
        ic_cdk::println!(
            "Cycles {} are burnt. Total number of cycles burnt is: {}",
            amount_burnt,
            total_cycles_burnt.borrow()
        );
    });
}

fn periodic_task() {
    let actual_amount_burnt = ic_cdk::api::cycles_burn(crate::storage::get_config().burn_amount);
    increment_counter();
    track_cycles_burnt(actual_amount_burnt);
}

fn start_with_interval_secs() {
    let secs =
        Duration::from_secs(crate::storage::get_config().interval_between_timers_in_seconds as u64);
    ic_cdk::println!("Timer canister: Starting a new timer with {secs:?} interval...");
    // Schedule a new periodic task.
    ic_cdk_timers::set_timer_interval(secs, periodic_task);
}

#[query(manual_reply = true)]
pub fn get_config() {
    match ic_cdk::api::data_certificate() {
        None => reject("get_config cannot be called in replicated mode"),
        _ => reply((crate::storage::get_config(),)),
    }
}

#[inspect_message]
fn inspect_message() {
    // Reject all replicated ingress calls.
}

/// This function is called when the canister is created.
#[init]
fn init(config: Option<Config>) {
    init_private(config, None, None);
}

fn init_private(config: Option<Config>, counter: Option<u32>, total_cycles_burnt: Option<u128>) {
    if let Some(config) = config {
        crate::storage::set_config(config);
    }
    if let Some(counter) = counter {
        COUNTER.with(|c| *c.borrow_mut() = counter);
    }
    if let Some(total_cycles_burnt) = total_cycles_burnt {
        TOTAL_CYCLES_BURNT.with(|c| *c.borrow_mut() = total_cycles_burnt);
    }
    start_with_interval_secs();
}
fn main() {}

#[pre_upgrade]
fn pre_upgrade() {
    let config = crate::storage::get_config();
    let counter = get_counter();
    let total_cycles_burnt = get_total_cycles_burnt();
    ic_cdk::storage::stable_save((config, counter, total_cycles_burnt))
        .expect("Saving data to stable store must succeed.");
}

#[post_upgrade]
fn post_upgrade() {
    let (config, counter, total_cycles_burnt) =
        ic_cdk::storage::stable_restore::<(Config, u32, u128)>()
            .expect("Failed to read data from stable memory.");

    init_private(Some(config), Some(counter), Some(total_cycles_burnt));
}

/// Processes external HTTP requests.
#[query]
pub fn http_request(request: CandidHttpRequest) -> CandidHttpResponse {
    let parts: Vec<&str> = request.url.split('?').collect();
    match parts[0] {
        "/metrics" => crate::metrics::get_metrics(),
        _ => CandidHttpResponse {
            status_code: 404,
            headers: vec![],
            body: ByteBuf::from(String::from("Not found.")),
        },
    }
}

fn get_counter() -> u32 {
    COUNTER.with(|c| *c.borrow())
}

fn get_total_cycles_burnt() -> u128 {
    TOTAL_CYCLES_BURNT.with(|c| *c.borrow())
}
