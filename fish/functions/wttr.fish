function wttr
  set -l place (string join " " $argv)

  if test -z "$place"
    set place "Strzelce_Wielkie"
  end

  set slug (slugify "$place")
  echo curl "wttr.in/$slug"
  curl "wttr.in/$slug"
end
