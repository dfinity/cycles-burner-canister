#!/usr/bin/env bash
set -Eexuo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export PATH="$SCRIPT_DIR/target/bin:$PATH"

get_balance() {
    dfx canister status cycles-burner-canister 2>&1 | grep "Balance: " | awk '{ print $2 }'
}

# Run dfx stop if we run into errors.
trap "dfx stop" EXIT SIGINT

dfx start --background --clean

INITIAL_BALANCE=100000000000
BURN_RATE="10_000_000_000"
INTERVAL=10

dfx deploy --no-wallet --with-cycles "$INITIAL_BALANCE" cycles-burner-canister --argument "(record {
    burn_rate = $BURN_RATE;
    interval_between_timers_in_seconds = $INTERVAL;
})"

CONFIG=$(dfx canister call --query cycles-burner-canister get_config)
EXPECTED_CONFIG="(
  record {
    burn_rate = $BURN_RATE : nat;
    interval_between_timers_in_seconds = $INTERVAL : nat64;
  },
)"

if [ "$CONFIG" != "$EXPECTED_CONFIG" ]; then
    echo "ERROR in get_config."
    EXIT SIGINT
fi

if [ "$(get_balance)" != "100_000_000_000" ]; then
    EXIT SIGINT
fi
sleep $INTERVAL

if [ "$(get_balance)" != "90_000_000_000" ]; then
    EXIT SIGINT
fi
sleep $INTERVAL

if [ "$(get_balance)" != "80_000_000_000" ]; then
    EXIT SIGINT
fi

echo "SUCCESS"
