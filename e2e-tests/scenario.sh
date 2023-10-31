#!/usr/bin/env bash
set -Eexuo pipefail

get_balance() {
    dfx canister status cycles-burner-canister 2>&1 | grep "Balance: " | awk '{ print $2 }'
}

# Run dfx stop if we run into errors.
trap "dfx stop" EXIT SIGINT

dfx start --background --clean

INITIAL_BALANCE=100000000000
BURN_AMOUNT="10_000_000_000"
INTERVAL=10

# Deploy canister
dfx deploy --no-wallet --with-cycles "$INITIAL_BALANCE" cycles-burner-canister --argument "(opt record {
    interval_between_timers_in_seconds = $INTERVAL;
    burn_amount = $BURN_AMOUNT;
})"

CONFIG=$(dfx canister call --query cycles-burner-canister get_config)
EXPECTED_CONFIG="(
  record {
    interval_between_timers_in_seconds = $INTERVAL : nat;
    burn_amount = $BURN_AMOUNT : nat;
  },
)"

# Test that the config is initialized properly.
if [ "$CONFIG" != "$EXPECTED_CONFIG" ]; then
    echo "ERROR in get_config."
    EXIT SIGINT
fi

# Check the initial banance.
if [ "$(get_balance)" != "100_000_000_000" ]; then
    EXIT SIGINT
fi

# Wait for the global timer.
sleep $(($INTERVAL + 1))
# Test that the global timer is executed and the balance is updated.
if [ "$(get_balance)" != "90_000_000_000" ]; then
    EXIT SIGINT
fi

# Wait for the global timer.
sleep $(($INTERVAL + 1))
# Test that the global timer is executed and the balance is updated.
if [ "$(get_balance)" != "80_000_000_000" ]; then
    EXIT SIGINT
fi

echo "SUCCESS"
