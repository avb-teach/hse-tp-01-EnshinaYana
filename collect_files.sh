#!/bin/bash

set -e

max_depth=""
input_dir=""
output_dir=""

# Парсим аргументы
while [[ $# -gt 0 ]]; do
  case "$1" in
    --max_depth)
      max_depth="$2"
      shift 2
      ;;
    *)
      if [[ -z "$input_dir" ]]; then
        input_dir="$1"
      elif [[ -z "$output_dir" ]]; then
        output_dir="$1"
      else
        echo "Usage: $0 [--max_depth N] input_dir output_dir" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

# Проверка, что input_dir и output_dir заданы
if [[ -z "$input_dir" || -z "$output_dir" ]]; then
  echo "Usage: $0 [--max_depth N] input_dir output_dir" >&2
  exit 1
fi

# Проверка существования папки
if [[ ! -d "$input_dir" ]]; then
  echo "Input directory does not exist: $input_dir" >&2
  exit 1
fi

mkdir -p "$output_dir"

copy_file() {
  local src_file="$1"
  local dst_dir="$2"

  local filename
  filename=$(basename -- "$src_file")
  local base="${filename%.*}"
  local ext="${filename##*.}"

  # Если файл без расширения
  if [[ "$base" == "$filename" ]]; then
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

  cp -- "$src_file" "$target"
}

# Формируем команду поиска
find_cmd=(find "$input_dir" -type f)

if [[ -n "$max_depth" ]]; then
  find_cmd+=( -maxdepth "$max_depth" )
fi

# Копируем файлы
"${find_cmd[@]}" -print0 | while IFS= read -r -d '' file; do
  copy_file "$file" "$output_dir"
done
