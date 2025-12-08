
function gtls --wraps "gt ls --stack"
  gt ls --stack $argv
end

function gtpub --wraps "gt submit --cli --ai --no-edit"
  gt submit --publish --cli --ai --no-edit $argv
end

function gtupd --wraps "gt submit --update-only"
  gt submit --update-only $argv
end
