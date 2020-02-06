#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")/.."; pwd)"

cd "$dir"

source settings.sh

saw watch \
    --region $REGION \
    $LABEL_LOG_GROUP