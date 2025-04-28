#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Использование: $0 входная_директория выходная_директория"
    exit 1
fi

input_dir="$1"
output_dir="$2"

if [ ! -d "$input_dir" ]; then
    echo "Входная директория не существует: $input_dir"
    exit 1
fi

mkdir -p "$output_dir"

temp_dir=$(mktemp -d)

find "$input_dir" -type f -print0 | while IFS= read -r -d '' file; do
    filename=$(basename -- "$file")
    count_file="$temp_dir/$filename"

    if [ -f "$count_file" ]; then
        count=$(cat "$count_file")
    else
        count=0
    fi

    if [ $count -eq 0 ]; then
        new_filename="$filename"
    else
        if [[ "$filename" =~ ^(.*)\.([^.]+)$ ]]; then
            name="${BASH_REMATCH[1]}"
            ext="${BASH_REMATCH[2]}"
            new_filename="${name}_${count}.${ext}"
        else
            new_filename="${filename}_${count}"
        fi
    fi

    echo $((count + 1)) > "$count_file"
    cp -- "$file" "$output_dir/$new_filename" || echo "Ошибка копирования: $file" >&2
done

rm -rf "$temp_dir"
