#!/bin/bash

input_dir="l0"
output_dir="l1"
rm -rf $output_dir
mkdir $output_dir

# for each L0 data file, extract text, data, bss and filename and append it to the appropraite L1 file
for csv_file in "$input_dir"/*.csv; do
  # Skip if no CSV files are found
  if [[ ! -f "$csv_file" ]]; then
    echo "No CSV files found in $input_dir."
    exit 1
  fi

  # Extract the commit and platform name from the filename
  commit=$(basename "$csv_file" | sed -n 's/.*size_\([a-f0-9]*\)_.*/\1/p')
  platform=$(basename "$csv_file" | sed -n 's/.*size_[a-f0-9]*_\(.*\)\.csv/\1/p')

  # Iterate over all lines except for the header
  tail -n +2 "$csv_file" | while IFS= read -r line; do
    # Process each line
    IFS=',' read -ra components <<< "$line"
    text="${components[0]}"
    data="${components[1]}"
    bss="${components[2]}"
    filename="${components[-1]}"
    output_file="$output_dir/size_${filename}.csv"

    # Add header if the file does not exist
    if [[ ! -f "$output_file" ]]; then
      echo "commit,platform,text,data,bss" >> $output_file
    fi

    # Append
    echo "${commit},${platform},${text},${data},${bss}" >> $output_file

  done

done
