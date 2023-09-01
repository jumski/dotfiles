function worldtime
    set -l format "+%H:%M"

    set -l poland (env TZ=Europe/Warsaw date $format)
    set -l austin (env TZ=America/Chicago date $format)
    set -l manilla (env TZ=Asia/Manila date $format)

    printf 'Austin:      %s\n' $austin
    printf 'Phillipines: %s\n' $manilla
    printf 'Poland:      %s\n' $poland
end
