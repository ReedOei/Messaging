#!/usr/bin/env bash

echo "Name: "
read -r name

(
    echo "\"account(\\\"$name\\\")\""

    while read -r line; do
        if [[ "$line" =~ ^\/all ]]; then
            echo "\"allMessages\""
        else
            echo "\"text($(date +"%s"), \\\"$(echo "$line" | sed -E "s/\"/\\\\\\\\\"/g")\\\")\""
        fi
    done
) | netcat localhost 8080 | while read -r line; do
    timestamp="$(echo "$line" | sed -E "s/\"text\(([0-9]+),.*/\1/g")"
    sender="$(echo "$line" | sed -E "s/\"text\(([0-9]+),\\\\\"([^ ]+):.*/\2/g")"
    raw_text="$(echo "$line" | sed -E "s/\"text\(([0-9]+),\\\\\"([^ ]+): (.*)\\\\\"\)\"/\3/g" | sed -E "s/\\\\//g")"
    escaped_text="$(printf "%q" "$raw_text")"
    display_text="$(eval "echo $escaped_text")"

    echo "[$(date -d @"$timestamp")] $sender: $display_text"
done

