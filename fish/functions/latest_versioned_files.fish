function latest_versioned_files
  set dir $argv[1]
  set files (versioned_files $dir)

  # Create an associative array to store the latest versions
  set -A latest_versions

  # Loop through each file
  for file in $files
    # Extract the version number from the file name
    set version (echo $file | grep -oP '(?<=_v)\d+(?=\.)')
    echo file $file @ $version

    # # Get the current latest version for the file
    # set current_version $latest_versions[$file]

    # # If the version number is greater than the current latest version, update it
    # if test -z $current_version -o $version -gt $current_version
    #   set latest_versions[$file] $version
    # end
  end
  return

  # Output the latest versions
  for file in $files
    set version $latest_versions[$file]
    if test -n $version
      echo $file
    end
  end
end
