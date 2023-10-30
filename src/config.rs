use candid::CandidType;
use serde::{Deserialize, Serialize};

/// Canister configuration.
#[derive(Clone, Debug, CandidType, PartialEq, Eq, Serialize, Deserialize)]
pub struct Config {
    /// Amount of burned cycles per timer.
    pub burn_amount: u128,

    /// Interval between timers in seconds.
    pub interval_between_timers_in_seconds: u64,
}

impl Default for Config {
    fn default() -> Config {
        Config {
            burn_amount: 0,
            // Default interval between timers in one day.
            interval_between_timers_in_seconds: 86400,
        }
    }
}
