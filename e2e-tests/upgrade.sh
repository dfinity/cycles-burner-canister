#!/usr/bin/env bash
set -Eexuo pipefail

trap 'dfx stop' EXIT SIGINT

dfx start --background --clean

INITIAL_BALANCE=100000000000
BURN_AMOUNT="10_000_000_000"
INTERVAL=10

# Deploy canister
dfx deploy --no-wallet --with-cycles "$INITIAL_BALANCE" cycles-burner-canister --argument "(record {
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

# Stop canister
dfx canister stop cycles-burner-canister

# Verify that the canister now exists and is already stopped.
if ! [[ $(dfx canister status cycles-burner-canister 2>&1) == *"Status: Stopped"* ]]; then
  echo "Failed to create and stop cycles-burner-canister."
  exit 1
fi

# Upgrade canister
dfx deploy --no-wallet --with-cycles "$INITIAL_BALANCE" cycles-burner-canister

dfx canister start cycles-burner-canister

CONFIG=$(dfx canister call --query cycles-burner-canister get_config)

# Test that the config is persisted after upgrade.
if [ "$CONFIG" != "$EXPECTED_CONFIG" ]; then
    echo "ERROR in get_config."
    EXIT SIGINT
fi

echo "SUCCESS"
