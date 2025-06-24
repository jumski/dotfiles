function pgflow_clip_important_files
  cat (cat /home/jumski/Code/pgflow-dev/important-files.txt) | xclip -sel clipboard
end

function pgflow_ai
  set -l important_files_path /home/jumski/Code/pgflow-dev/important-files.txt
  
  # Check if important files file exists
  if not test -f $important_files_path
    set_color red
    echo "Error: Important files list not found at $important_files_path" >&2
    set_color normal
    return 1
  end
  
  # Read the important files and build -f flags
  set -l file_flags
  for file in (cat $important_files_path)
    set file_flags $file_flags -f $file
  end
  
  # Show the command to be executed
  set_color brblack
  echo "\$ aichat $file_flags $argv" >&2
  set_color normal
  
  # Check if stdin is available (piped input)
  if test -t 0
    # No piped input, run aichat directly
    aichat $file_flags $argv
  else
    # Piped input, pass it through
    cat | aichat $file_flags $argv
  end
end

# Use the same completions as aichat
complete -c pgflow_ai -w aichat
