#!/usr/bin/env bash
set -Eexuo pipefail

get_cycles_burner_canister_metrics() {
  canister_id=$(dfx canister id cycles-burner-canister)
  curl "http://127.0.0.1:8000/metrics?canisterId=$canister_id"
}

# Function to check for presence of specific names in the metrics.
check_metric_names() {
  METRIC_NAMES=(
    "burn_amount"
    "interval_between_timers_in_seconds"
    "counter"
    "total_cycles_burnt"
  )

  metrics=$(get_cycles_burner_canister_metrics)
  for name in "${METRIC_NAMES[@]}"; do
    if ! [[ $metrics == *"$name"* ]]; then
      echo "FAIL: $name not found in metrics of ${0##*/}"
      EXIT SIGINT
    fi
  done
}

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

check_metric_names

echo "SUCCESS: Metrics check completed successfully for ${0##*/}"
