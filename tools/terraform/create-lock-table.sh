#!/usr/bin/env bash

set -eu

# shellcheck disable=SC2046
cd $(dirname "$0") || exit

if [[ ! -e ../../env.sh ]]; then
    echo "env.sh is not found."
    exit 1
fi

source ../../env.sh

export AWS_PAGER=""

TABLE_NAME="${PREFIX}-${APPLICATION_NAME}-terraform-lock"
echo "TABLE_NAME=$TABLE_NAME"

aws --profile "$AWS_PROFILE" dynamodb \
  create-table \
  --table-name "$TABLE_NAME" \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10