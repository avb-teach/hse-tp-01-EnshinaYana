#!/bin/bash

# Обработка аргументов
if [[ "$1" == "--max_depth" ]]; then
    if [ $# -ne 4 ]; then
        echo "Использование: $0 --max_depth N входная_директория выходная_директория"
        exit 1
    fi
    max_depth="$2"
    input_dir="$3"
    output_dir="$4"
else
    if [ $# -ne 2 ]; then
        echo "Использование: $0 [--max_depth N] входная_директория выходная_директория"
        exit 1
    fi
    max_depth=999
    input_dir="$1"
    output_dir="$2"
fi

# Проверки директорий
if [ ! -d "$input_dir" ]; then
    echo "Ошибка: входная директория не существует" >&2
    exit 1
fi

mkdir -p "$output_dir" || { echo "Ошибка создания выходной директории" >&2; exit 1; }

# Основная логика
find "$input_dir" -type f -maxdepth "$max_depth" -print0 | while IFS= read -r -d '' file; do
    filename=$(basename -- "$file")
    count=0
    new_filename="$filename"
    
    # Обработка дубликатов
    while [ -e "$output_dir/$new_filename" ]; do
        ((count++))
        if [[ "$filename" =~ ^(.*)\.([^.]*)$ ]]; then
            new_filename="${BASH_REMATCH[1]}_$count.${BASH_REMATCH[2]}"
        else
            new_filename="${filename}_$count"
        fi
    done
    
    cp -- "$file" "$output_dir/$new_filename" || echo "Ошибка копирования $file" >&2
done
