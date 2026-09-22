#!/usr/bin/env bash

delay=0.08
max_loops=0

usage() {
    cat <<'EOF'
Usage: ./run_pig.sh [OPTIONS]

Options:
  -d, --delay SECONDS   Frame delay (default: 0.08)
  -l, --loops COUNT     Number of full screen passes (default: infinite)
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--delay)
            delay="$2"
            shift 2
            ;;
        -l|--loops)
            max_loops="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

if ! [[ "$delay" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Invalid delay: $delay" >&2
    exit 1
fi

if ! [[ "$max_loops" =~ ^[0-9]+$ ]]; then
    echo "Invalid loop count: $max_loops" >&2
    exit 1
fi

trap 'printf "\033[?25h"; clear; exit' INT TERM EXIT

# Скрываем курсор
printf '\033[?25l'

pig1='  ^-----^
 (  o o  )
  (  Y  )
   \(_)/
   /| |\
  / | | \'

pig2='  ^-----^
 (  o o  )
  (  Y  )
   \(_)/
    | |\
   /|  \'

completed_loops=0
while true; do
    cols=$(tput cols)
    max_x=$((cols - 12))
    if (( max_x < 1 )); then
        max_x=1
    fi

    for ((x=0; x<max_x; x++)); do
        clear

        padding=$(printf "%${x}s" "")

        if (( x % 2 == 0 )); then
            while IFS= read -r line; do
                printf '%s%s\n' "$padding" "$line"
            done <<< "$pig1"
        else
            while IFS= read -r line; do
                printf '%s%s\n' "$padding" "$line"
            done <<< "$pig2"
        fi

        sleep "$delay"
    done

    ((completed_loops++))
    if (( max_loops > 0 && completed_loops >= max_loops )); then
        break
    fi
done
