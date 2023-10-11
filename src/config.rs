use candid::CandidType;
use serde::{Deserialize, Serialize};

/// Canister configuration.
#[derive(Clone, Debug, CandidType, PartialEq, Eq, Serialize, Deserialize)]
pub struct Config {
    /// Amount of burned cycles per timer.
    pub burn_rate: u128,

    /// Interval between timers in seconds.
    pub interval_between_timers_in_seconds: u64,
}

impl Config {
    pub fn default() -> Config {
        Config {
            burn_rate: 0,
            interval_between_timers_in_seconds: 86400,
        }
    }
}
