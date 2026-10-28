#!/bin/sh

wallpaper_dir="/home/horrid/Pictures/Wallpapers"

if ! command -v awww >/dev/null 2>&1 || ! command -v awww-daemon >/dev/null 2>&1; then
    printf '%s\n' "awww and awww-daemon must be installed to start the wallpaper slideshow." >&2
    exit 1
fi

if [ ! -d "$wallpaper_dir" ]; then
    printf 'Wallpaper directory does not exist: %s\n' "$wallpaper_dir" >&2
    exit 1
fi

if ! awww query >/dev/null 2>&1; then
    awww-daemon &
    daemon_pid=$!

    attempts=0
    until awww query >/dev/null 2>&1; do
        if ! kill -0 "$daemon_pid" 2>/dev/null; then
            printf '%s\n' "awww-daemon exited before becoming ready." >&2
            exit 1
        fi

        attempts=$((attempts + 1))
        if [ "$attempts" -ge 30 ]; then
            printf '%s\n' "Timed out waiting for awww-daemon to start." >&2
            exit 1
        fi
        sleep 1
    done
fi

while :; do
    found_image=0

    for image in "$wallpaper_dir"/*; do
        [ -f "$image" ] || continue

        case "${image##*.}" in
            png|PNG|jpg|JPG|jpeg|JPEG|webp|WEBP|gif|GIF|bmp|BMP|tif|TIF|tiff|TIFF)
                found_image=1
                if ! awww img "$image" --transition-type random; then
                    printf 'Failed to load wallpaper: %s\n' "$image" >&2
                    exit 1
                fi
                sleep 900
                ;;
        esac
    done

    if [ "$found_image" -eq 0 ]; then
        printf 'No supported wallpaper images found in: %s\n' "$wallpaper_dir" >&2
        exit 1
    fi
done
