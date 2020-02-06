#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")/.."; pwd)"

cd "$dir"

PAYLOAD=$(bash scripts/s3-put-payload.sh labels/$1)

source settings.sh

# filename (without the path)
BASENAME=$(basename $1)
# filename (also without the extension)
NOEXTNAME=${BASENAME%.*}

# create missing directories
mkdir --parents "invokes/label"

aws lambda invoke \
    --region $REGION \
    --function-name $LABEL_FUNCTION \
    --payload "$PAYLOAD" \
    "invokes/label/$NOEXTNAME.json"