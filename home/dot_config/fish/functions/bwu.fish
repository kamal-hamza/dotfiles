# Unlock Bitwarden for this shell (BW_SESSION) and sync the vault, so
# `chezmoi apply` can render secrets from it (.chezmoidata/secrets.yaml).
function bwu --description 'Unlock + sync Bitwarden for chezmoi'
    command -q bw; or begin
        echo "bw (Bitwarden CLI) is not installed" >&2
        return 1
    end
    if test "$(bw status 2>/dev/null | string match -r '"status":"(\w+)"')[2]" = unauthenticated
        bw login; or return
    end
    set -l session (bw unlock --raw); or return
    set -gx BW_SESSION $session
    bw sync --quiet; and echo "Bitwarden unlocked for this shell"
end
