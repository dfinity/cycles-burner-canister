#!/usr/bin/env bash
set -Eexuo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export PATH="$SCRIPT_DIR/target/bin:$PATH"

# Run dfx stop if we run into errors.
trap "dfx stop" EXIT SIGINT

dfx start --background --clean

dfx deploy --no-wallet cycles-burner-canister --argument "(record {
    burn_rate = 1_000_000_000;
    interval_between_timers_in_seconds = 10;
})"

#sleep 15

dfx canister call --query cycles-burner-canister get_config 
