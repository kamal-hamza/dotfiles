# Unlock Bitwarden for this shell (BW_SESSION) and sync the vault, so
# `chezmoi apply` can render secrets from it (.chezmoidata/secrets.yaml).
# First run logs in; --raw keeps the session key off the screen.
function bwu --description 'Unlock + sync Bitwarden for chezmoi'
    command -q bw; or begin
        echo "bw (Bitwarden CLI) is not installed" >&2
        return 1
    end
    set -l state (bw status 2>/dev/null | string match -rg '"status":"(\w+)"')
    set -l session
    switch "$state"
        case unauthenticated
            set session (bw login --raw); or return
        case unlocked
            if set -q BW_SESSION
                bw sync --quiet; and echo "Bitwarden already unlocked (synced)"
                return
            end
            set session (bw unlock --raw); or return
        case '*'
            set -e BW_SESSION # stale key from before a `bw lock`
            set session (bw unlock --raw); or return
    end
    test -n "$session"; or return 1
    set -gx BW_SESSION $session
    bw sync --quiet; and echo "Bitwarden unlocked for this shell"
end
