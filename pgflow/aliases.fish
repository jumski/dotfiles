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
  if test -t 2
    # stderr is a terminal, use color
    set_color brblack
    echo "\$ aichat $file_flags $argv" >&2
    set_color normal
  else
    # stderr is redirected, no color
    echo "\$ aichat $file_flags $argv" >&2
  end

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

function wip-notes
  test -d .notes || echo .notes does not exist && return
  pushd .notes
  echo Commiting notes...
  git wip
  echo Pushing notes...
  git push
  echo Done
  popd
end


function supabase-serve --wraps "npx supabase functions serve --no-verify-jwt"
  npx -y supabase functions serve --no-verify-jwt $argv 2>&1 | grep -Pv 'serving the request with supabase/functions/[a-zA-Z0-9-]+-worker|^\d{4}-\d{2}-\d{2}T[\d:.]+Z\s*$'
end
