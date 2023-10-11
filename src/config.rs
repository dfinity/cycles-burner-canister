use candid::CandidType;
use serde::{Deserialize, Serialize};

/// Canister configuration.
#[derive(Clone, Debug, CandidType, PartialEq, Eq, Serialize, Deserialize)]
pub struct Config {
    pub burning_rate: u128,
}

impl Config {
    pub fn new() -> Config {
        Config { burning_rate: 0 }
    }
}
