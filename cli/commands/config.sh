#!/bin/bash

# PARA Workspace Config Manager
# Usage: ./config.sh [get <key> | set <key> <value>]

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# Root of workspace is 5 levels up from cli/commands/
WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")")"
CONFIG_FILE="$WORKSPACE_ROOT/.para.json"

# Initialize config if not exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo '{"workflows": {"prefix": "p-"}}' > "$CONFIG_FILE"
fi

get_val() {
    key=$1
    jq -r ".$key" "$CONFIG_FILE"
}

set_val() {
    key=$1
    val=$2
    
    # Simple check for boolean or number vs string
    if [[ "$val" == "true" ]] || [[ "$val" == "false" ]] || [[ "$val" =~ ^[0-9]+$ ]]; then
        tmp=$(mktemp)
        jq ".$key = $val" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    else
        tmp=$(mktemp)
        jq ".$key = \"$val\"" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    fi
    echo "✅ Set $key = $val"
}

case "$1" in
    get)
        get_val "$2"
        ;;
    set)
        set_val "$2" "$3"
        ;;
    list)
        cat "$CONFIG_FILE"
        ;;
    *)
        echo "Usage: $0 [get <key> | set <key> <value> | list]"
        exit 1
        ;;
esac
