#!/bin/bash

if [ "$1" = "--max_depth" ]; then
    if [ $# -ne 4 ]; then
        echo "Usage: $0 [--max_depth DEPTH] INPUT_DIR OUTPUT_DIR" >&2
        exit 1
    fi
    max_depth="$2"
    input_dir="$3"
    output_dir="$4"
else
    if [ $# -ne 2 ]; then
        echo "Usage: $0 [--max_depth DEPTH] INPUT_DIR OUTPUT_DIR" >&2
        exit 1
    fi
    max_depth=""
    input_dir="$1"
    output_dir="$2"
fi

if [ ! -d "$input_dir" ]; then
    echo "Input directory does not exist: $input_dir" >&2
    exit 1
fi

mkdir -p "$output_dir" || {
    echo "Failed to create output directory: $output_dir" >&2
    exit 1
}

process_file() {
    local file="$1"
    local output_dir="$2"

    local filename base ext new_ext candidate new_name
    filename=$(basename -- "$file")
    base="${filename%.*}"
    ext="${filename##*.}"

    if [ "$base" = "$filename" ]; then
        new_ext=""
    else
        new_ext=".$ext"
    fi

    candidate="$output_dir/$filename"
    if [ ! -e "$candidate" ]; then
        cp -- "$file" "$candidate" || echo "Failed to copy $file" >&2
    else
        counter=1
        while true; do
            new_name="${base}_${counter}${new_ext}"
            candidate="$output_dir/$new_name"
            if [ ! -e "$candidate" ]; then
                cp -- "$file" "$candidate" || echo "Failed to copy $file" >&2
                break
            fi
            counter=$((counter + 1))
        done
    fi
}

find_args=("$input_dir")
if [ -n "$max_depth" ]; then
    find_args+=(-maxdepth "$max_depth")
fi
find_args+=(-type f)

find "${find_args[@]}" -print0 | while IFS= read -r -d '' file; do
    process_file "$file" "$output_dir"
done
