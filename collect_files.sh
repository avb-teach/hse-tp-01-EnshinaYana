#!/bin/bash

set -e

if [[ $# -lt 2 || $# -gt 4 ]]; then
    echo "Usage: $0 [--max_depth N] input_dir output_dir" >&2
    exit 1
fi

max_depth=""
input_dir=""
output_dir=""

if [[ "$1" == "--max_depth" ]]; then
    if [[ $# -ne 4 ]]; then
        echo "Usage: $0 --max_depth N input_dir output_dir" >&2
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
    echo "Input directory does not exist: $input_dir" >&2
    exit 1
fi

mkdir -p "$output_dir"

copy_file() {
    local src_file="$1"
    local dst_dir="$2"

    local filename
    filename=$(basename -- "$src_file")  # Исправлено: добавлен --
    local dst_path="$dst_dir/$filename"

    if [[ ! -e "$dst_path" ]]; then
        cp -- "$src_file" "$dst_path"  # Исправлено: добавлен --
    else
        local name="${filename%.*}"
        local ext="${filename##*.}"

        # Обработка файлов без расширения
        if [[ "$name" == "$filename" ]]; then
            name="$filename"
            ext=""
        else
            ext=".$ext"
        fi

        local counter=1
        while [[ -e "${dst_dir}/${name}_${counter}${ext}" ]]; do
            counter=$((counter + 1))
        done

        cp -- "$src_file" "${dst_dir}/${name}_${counter}${ext}"  # Исправлено: добавлен --
    fi
}

find_cmd=(find "$input_dir" -type f)

if [[ -n "$max_depth" ]]; then
    find_cmd+=( -maxdepth "$max_depth" )
fi

"${find_cmd[@]}" -print0 | while IFS= read -r -d '' file; do
    copy_file "$file" "$output_dir"
done
