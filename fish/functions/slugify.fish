function slugify
  set input "$argv[1]"

  # Replace non-word characters with underscores
  set slug (echo $input | tr -cs '[:alnum:]' '_')

  # Replace multiple underscores with a single underscore
  set slug (echo $slug | sed 's/__*/_/g')

  # Remove leading and trailing underscores
  set slug (echo $slug | sed 's/^_//;s/_$//')

  # Convert to lowercase
  set slug (echo $slug | tr '[:upper:]' '[:lower:]')

  echo -n $slug
end
