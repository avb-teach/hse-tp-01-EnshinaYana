#!/bin/bash

set -e

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 input_dir output_dir" >&2
    exit 1
fi

input_dir="$1"
output_dir="$2"

mkdir -p "$output_dir"

# дальше идет основная логика
