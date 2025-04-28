#!/bin/bash

if [ "$1" == "--max_depth" ]; then
    if [ $# -ne 4 ]; then
        echo "Использование: $0 --max_depth N входная_директория выходная_директория" >&2
        exit 1
    fi
    max_depth="$2"
    input_dir="$3"
    output_dir="$4"
else
    if [ $# -ne 2 ]; then
        echo "Использование: $0 [--max_depth N] входная_директория выходная_директория" >&2
        exit 1
    fi
    max_depth=99999
    input_dir="$1"
    output_dir="$2"
fi

[ ! -d "$input_dir" ] && { echo "Ошибка: входная директория не существует: $input_dir" >&2; exit 1; }
mkdir -p "$output_dir" || { echo "Ошибка: не удалось создать выходную директорию" >&2; exit 1; }

tmp_counter=$(mktemp -d) || { echo "Ошибка: не удалось создать временный каталог" >&2; exit 1; }

find "$input_dir" -type f -maxdepth "$max_depth" -print0 | while IFS= read -r -d '' file; do
    filename=$(basename -- "$file")
    counter_file="$tmp_counter/$filename"

    [ -f "$counter_file" ] && count=$(<"$counter_file") || count=0

    if (( count > 0 )); then
        if [[ "$filename" =~ ^(.*)\.([^.]*)$ ]]; then
            new_name="${BASH_REMATCH[1]}_$count.${BASH_REMATCH[2]}"
        else
            new_name="${filename}_$count"
        fi
    else
        new_name="$filename"
    fi

    if ! cp -- "$file" "$output_dir/$new_name"; then
        echo "Ошибка: не удалось скопировать $file" >&2
        continue
    fi

    echo $((count + 1)) > "$counter_file"
done

rm -rf "$tmp_counter"
