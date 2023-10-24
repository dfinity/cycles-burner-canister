#!/usr/bin/env bash
set -Eexuo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export PATH="$SCRIPT_DIR/target/bin:$PATH"

set_correct_replica_and_canister_sandbox(){
    curl -L "https://dash.zh1-idx1.dfinity.network/file/download?bytestream_url=bytestream%3A%2F%2Fbazel-remote.idx.dfinity.network%2Fblobs%2F99abd2bf0e575c098a8ab04b196e1006598efd16939ef54f3cf362f1a5514d64%2F18118712&invocation_id=02a24682-cdd3-4042-bc3b-fe1a5f7c8b42&request_context=GIj%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEqDUV1cm9wZS9adXJpY2g%3D&filename=rs%2Fcanister_sandbox%2Fcanister_sandbox" -o canister_sandbox
    curl -L "https://dash.zh1-idx1.dfinity.network/file/download?bytestream_url=bytestream%3A%2F%2Fbazel-remote.idx.dfinity.network%2Fblobs%2F4a7ac9171eb54e3f51536a700a18e17a30cf84caf868ee473b97d268e13f830f%2F88082600&invocation_id=4dcd0ffa-3dd0-4625-b58a-8f766817b9bf&request_context=GIj%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEqDUV1cm9wZS9adXJpY2g%3D&filename=rs%2Freplica%2Freplica" -o replica
    chmod +x canister_sandbox replica
    PATH_TO_DFX_CACHE="$HOME/.cache/dfinity/versions/$(dfx --version | awk '{ print $2 }')"
    rm -f "$PATH_TO_DFX_CACHE/replica" "$PATH_TO_DFX_CACHE/canister_sandbox"
    mv canister_sandbox "$PATH_TO_DFX_CACHE"
    mv replica "$PATH_TO_DFX_CACHE"
}

get_balance() {
    dfx canister status cycles-burner-canister 2>&1 | grep "Balance: " | awk '{ print $2 }'
}

# Run dfx stop if we run into errors.
trap "dfx stop" EXIT SIGINT

set_correct_replica_and_canister_sandbox

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
