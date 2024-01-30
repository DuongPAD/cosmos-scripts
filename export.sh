#!/bin/bash

# Tên file JSON
json_file="oliver.json"

# Kiểm tra tồn tại của file JSON
if [ ! -f "$json_file" ]; then
  echo "Lỗi: File JSON không tồn tại."
  exit 1
fi

# Chuyển đổi JSON sang CSV và xuất kết quả
jq -r '.[] | "\(.address),\(.phrase)"' "$json_file" | awk 'BEGIN{print "#,Address,Phrase"} {print NR","$0}' > output.csv

echo "Đã xuất dữ liệu sang file output.csv"
