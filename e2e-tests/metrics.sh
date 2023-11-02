#!/usr/bin/env bash
set -Eexuo pipefail

INITIAL_BALANCE=100000000000
BURN_AMOUNT="10000000000"
INTERVAL=10

get_cycles_burner_canister_metrics() {
  canister_id=$(dfx canister id cycles-burner-canister)
  curl "http://127.0.0.1:8000/metrics?canisterId=$canister_id"
}

# Function to check for the presence of metric and value associated with it.
check_metrics() {
  METRIC_NAMES_AND_VALUES=(
    "burn_amount $1"
    "interval_between_timers_in_seconds $2"
    "counter $3"
    "total_cycles_burnt $4"
  )

  metrics=$(get_cycles_burner_canister_metrics)
  for name_and_value in "${METRIC_NAMES_AND_VALUES[@]}"; do
    if ! [[ $metrics == *"$name_and_value"* ]]; then
      echo "FAIL: metric with value: \"$name_and_value\" not found in metrics of ${0##*/}"
      EXIT 1
    fi
  done
}

# Run dfx stop if we run into errors.
trap "dfx stop" EXIT SIGINT

# Start dfx.
dfx start --background --clean

# Deploy canister.
dfx deploy --no-wallet --with-cycles "$INITIAL_BALANCE" cycles-burner-canister --argument "(opt record {
    interval_between_timers_in_seconds = $INTERVAL;
    burn_amount = $BURN_AMOUNT;
})"

# Check metrics after canister is deployed.
check_metrics $BURN_AMOUNT $INTERVAL 0 0

# Wait for the global timer.
sleep $((INTERVAL + 1))

# Check metrics after the first global timer is executed.
check_metrics $BURN_AMOUNT $INTERVAL 1 $BURN_AMOUNT

# Wait for the global timer.
sleep $((INTERVAL + 1))

# Check metrics after the second global timer is executed.
check_metrics $BURN_AMOUNT $INTERVAL 2 $((2 * BURN_AMOUNT))

echo "SUCCESS"

exit 0
