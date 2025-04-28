#!/bin/bash

if [[ "$1" == "--max_depth" ]]; then
    if (( $# != 4 )); then
        echo "Использование: $0 --max_depth N входная_директория выходная_директория" >&2
        exit 1
    fi
    max_depth="$2"
    input_dir="$3"
    output_dir="$4"
else
    if (( $# != 2 )); then
        echo "Использование: $0 [--max_depth N] входная_директория выходная_директория" >&2
        exit 1
    fi
    max_depth=100  # Достаточно большая глубина по умолчанию
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

counter_file=$(mktemp) || {
    echo "Ошибка: не удалось создать временный файл" >&2
    exit 1
}
trap 'rm -f "$counter_file"' EXIT

find "$input_dir" -type f -maxdepth "$max_depth" -print0 | while IFS= read -r -d '' file; do
    filename=$(basename -- "$file")

    count=$(grep -c "^${filename}=" "$counter_file" 2>/dev/null || echo 0)

    if (( count > 0 )); then
        if [[ "$filename" =~ ^(.+)\.(.+)$ ]]; then
            new_name="${BASH_REMATCH[1]}_${count}.${BASH_REMATCH[2]}"
        else
            new_name="${filename}_${count}"
        fi
    else
        new_name="$filename"
    fi

    if ! cp -- "$file" "$output_dir/$new_name"; then
        echo "Ошибка копирования: $file -> $output_dir/$new_name" >&2
        continue
    fi

    echo "${filename}=$((count + 1))" >> "$counter_file"
done
