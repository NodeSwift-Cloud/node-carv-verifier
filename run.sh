#!/bin/sh

CONFIG_DIR="/data/config"
CONFIG_FILE="$CONFIG_DIR/config_docker.yaml"

mkdir -p $CONFIG_DIR

curl -sL https://raw.githubusercontent.com/NodeSwift-Cloud/node-carv-verifier/main/config_docker.yaml -o $CONFIG_FILE

sed -i "s/private_key: \"\"/private_key: \"$PRIVATE_KEY\"/" $CONFIG_FILE

API_URL="https://interface.carv.io/explorer_alphanet/verifier_delegations_count?verifier_address=${PUBLIC_KEY}"

check_delegations() {
  while true; do
    response=$(curl -s $API_URL)
    
    total_delegations=$(echo $response | jq -r '.data.total_delegations')

    if [ "$total_delegations" -gt 0 ]; then
      echo "Total delegations: $total_delegations. Starting verifier..."
      ./verifier -conf $CONFIG_FILE
      break
    else
      echo "Total delegations: $total_delegations. Retrying in 1 minute..."
      sleep 60  # Wait for 1 minute before retrying
    fi
  done
}

check_delegations
