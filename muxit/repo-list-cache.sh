#!/bin/bash
REPOSITORIES_DIR="/home/jumski/Code/"
REPOSITORIES_CACHE="/home/jumski/.repositories.cache"

rebuild_cache() {
  echo "Rebuilding cache..."
  fd -H -t d --exec echo {//} \; --glob .git "$REPOSITORIES_DIR" | sort > "$REPOSITORIES_CACHE"
  echo "Cache updated."
  cat "$REPOSITORIES_CACHE"
}

rebuild_cache

# inotifywait -mr -e create,delete,move --format "%e %w%f" "$REPOSITORIES_DIR" | while read -r event file
# do
#   if [[ "$file" =~ "/.git$" ]]; then
#     echo "Git repository change detected: ${file%/\.git}"
#     echo "Event: $event"
#     rebuild_cache
#   fi
# done

inotifywait -r -m -e create --format '%w%f' --exclude "/\.git/.*" "$REPOSITORIES_DIR" |

# Read the output of inotifywait and process it line by line
while read full_path; do
    # Check if the new file or directory is a .git folder
    if [[ "$full_path" =~ /\.git$ ]]; then
        # If it is a .git folder, print the path to the screen
        echo "New .git folder created: $full_path"
    fi
done
