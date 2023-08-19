require 'abbrev'

texts = ARGV.fetch(0).split(',').map(&:strip)
abbrevs = Abbrev.abbrev(texts)

reverted = abbrevs.reduce({}) do |memo, (abbrev, original_text)|
  memo[original_text] ||= []
  memo[original_text].push(abbrev)
  memo
end

puts reverted
