function datify_filename
    set file $argv[1]
    set extension (string split -r -m 1 . $file)[2]
    set basename (string split -r -m 1 . $file)[1]
    set date (date "+%Y-%m-%d")
    set newfile "$basename-$date.$extension"
    mv $file $newfile
    echo "Renamed $file to $newfile"
end

