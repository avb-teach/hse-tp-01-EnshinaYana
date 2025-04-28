#!/bin/bash

if [[ "$1" == "--max_depth" ]]; then
    if [[ $# -ne 4 ]]; then
        echo "Использование: $0 --max_depth N входная_директория выходная_директория" >&2
        exit 1
    fi
    max_depth="$2"
    input_dir="$3"
    output_dir="$4"
else
    if [[ $# -ne 2 ]]; then
        echo "Использование: $0 [--max_depth N] входная_директория выходная_директория" >&2
        exit 1
    fi
    max_depth=""
    input_dir="$1"
    output_dir="$2"
fi

if [[ ! -d "$input_dir" ]]; then
    echo "Ошибка: входная директория '$input_dir' не существует" >&2
    exit 1
fi

mkdir -p "$output_dir" || {
    echo "Ошибка: не удалось создать выходную директорию '$output_dir'" >&2
    exit 1
}

declare -A file_counts

get_unique_name() {
    local base="$1"
    local count="${file_counts[$base]:-0}"

    if (( count == 0 )); then
        echo "$base"
    else
        if [[ "$base" =~ ^(.+)\.([^.]+)$ ]]; then
            echo "${BASH_REMATCH[1]}${count}.${BASH_REMATCH[2]}"
        else
            echo "${base}${count}"
        fi
    fi
}

if [[ -n "$max_depth" ]]; then
    find "$input_dir" -maxdepth "$max_depth" -type f -print0
else
    find "$input_dir" -type f -print0
fi | while IFS= read -r -d '' file; do
    filename=$(basename -- "$file")
    new_filename=$(get_unique_name "$filename")

    while [[ -e "$output_dir/$new_filename" ]]; do
        ((file_counts["$filename"]++))
        new_filename=$(get_unique_name "$filename")
    done

    if ! cp -- "$file" "$output_dir/$new_filename"; then
        echo "Ошибка копирования: $file -> $output_dir/$new_filename" >&2
    fi

    ((file_counts["$filename"]++))
done
