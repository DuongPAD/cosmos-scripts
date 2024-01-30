#!/bin/bash

# Tên file CSV
csv_file="output.csv"

# Kiểm tra tồn tại của file CSV
if [ ! -f "$csv_file" ]; then
  echo "Lỗi: File CSV không tồn tại."
  exit 1
fi

# Chuyển đổi CSV sang JSON và xuất kết quả
awk -F',' 'NR>1 {printf("{\"address\":\"%s\",\"phrase\":\"%s\"},\n", $2, $3)}' "$csv_file" | sed '$s/,$//' > output.json

echo "Đã xuất dữ liệu sang file output.json"
