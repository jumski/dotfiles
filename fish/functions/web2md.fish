function web2md --description "Convert web page to markdown using r.jina.ai"
  if test (count $argv) -eq 0
    echo "Usage: web2md <url>" >&2
    echo "Example: web2md https://example.com" >&2
    return 1
  end

  set -l url $argv[1]

  # Ensure URL has a protocol
  if not string match -qr '^https?://' $url
    set url "https://$url"
  end

  curl -s "https://r.jina.ai/$url"
end
