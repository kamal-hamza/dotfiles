# SSH agent socket (Linux; macOS's launchd already sets SSH_AUTH_SOCK).
# Prefers GNOME Keyring's gcr-ssh-agent (desktop: remembers key passphrases in
# the login keyring, which ly unlocks at login via pam_gnome_keyring), then
# OpenSSH's systemd ssh-agent.socket. Both are user units enabled from
# .chezmoidata/system-arch.yaml. An existing (e.g. forwarded) socket is kept.
if test -z "$SSH_AUTH_SOCK"; and set -q XDG_RUNTIME_DIR
    for sock in $XDG_RUNTIME_DIR/gcr/ssh $XDG_RUNTIME_DIR/ssh-agent.socket
        if test -S $sock
            set -gx SSH_AUTH_SOCK $sock
            break
        end
    end
end
