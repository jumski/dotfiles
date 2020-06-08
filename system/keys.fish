# Pipe my public key to my clipboard.
function pubkey
   xclip -sel clipboard ~/.ssh/id_rsa.pub | echo '=> Public key copied to pasteboard.'
end
