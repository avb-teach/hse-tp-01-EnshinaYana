#!/bin/bash

set -e

if [[ $# -lt 2 || $# -gt 4 ]]; then
    echo "Usage: $0 [--max_depth DEPTH] input_dir output_dir" >&2
    exit 1
fi

max_depth=""
input_dir=""
output_dir=""

if [[ "$1" == "--max_depth" ]]; then
    if [[ $# -ne 4 ]]; then
        echo "Usage: $0 --max_depth DEPTH input_dir output_dir" >&2
        exit 1
    fi
    max_depth="$2"
    input_dir="$3"
    output_dir="$4"
else
    if [[ $# -ne 2 ]]; then
        echo "Usage: $0 input_dir output_dir" >&2
        exit 1
    fi
    input_dir="$1"
    output_dir="$2"
fi

if [[ ! -d "$input_dir" ]]; then
    echo "Error: input_dir does not exist: $input_dir" >&2
    exit 1
fi

mkdir -p "$output_dir"

copy_file() {
    local src_file="$1"
    local dst_dir="$2"

    local filename
    filename=$(basename "$src_file")
    local base="${filename%.*}"
    local ext="${filename##*.}"

    if [[ "$ext" == "$filename" ]]; then
        ext=""
    else
        ext=".$ext"
    fi

    local target="$dst_dir/$filename"
    local counter=1

    while [[ -e "$target" ]]; do
        target="${dst_dir}/${base}_${counter}${ext}"
        counter=$((counter + 1))
    done

    cp "$src_file" "$target"
}

find_command=(find "$input_dir" -type f)

if [[ -n "$max_depth" ]]; then
    find_command+=( -maxdepth "$max_depth" )
fi

"${find_command[@]}" -print0 | while IFS= read -r -d '' file; do
    copy_file "$file" "$output_dir"
done
