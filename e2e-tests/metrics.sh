#!/usr/bin/env bash
set -Eexuo pipefail

trap 'dfx stop' EXIT SIGINT

dfx start --background --clean

INITIAL_BALANCE=100000000000
BURN_AMOUNT="10_000_000_000"
INTERVAL=10

# Deploy canister
dfx deploy --no-wallet --with-cycles "$INITIAL_BALANCE" cycles-burner-canister --argument "(opt record {
    interval_between_timers_in_seconds = $INTERVAL;
    burn_amount = $BURN_AMOUNT;
})"