use candid::CandidType;
use serde::{Deserialize, Serialize};

/// Canister configuration.
#[derive(Clone, Debug, CandidType, PartialEq, Eq, Serialize, Deserialize)]
pub struct Config {
    /// Interval between timers in seconds.
    pub interval_between_timers_in_seconds: u128,

    /// Amount of burned cycles per timer.
    pub burn_amount: u128,
}

impl Default for Config {
    fn default() -> Config {
        Config {
            // Default interval between timers in one day.
            interval_between_timers_in_seconds: 86400,
            burn_amount: 0,
        }
    }
}
