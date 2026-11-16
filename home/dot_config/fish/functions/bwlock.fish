# Lock Bitwarden (revokes every session key issued so far) and drop this
# shell's BW_SESSION, so later bw commands don't trip over the dead key.
function bwlock --description 'Lock Bitwarden and clear BW_SESSION'
    command -q bw; or return 1
    env -u BW_SESSION bw lock >/dev/null 2>&1
    set -e BW_SESSION
    echo "Bitwarden locked"
end
