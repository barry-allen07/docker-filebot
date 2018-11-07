#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

LICENSE_PATH=/config/license.psm

# Make sure required directories exists
mkdir -p "$XDG_DATA_HOME"

# Copy default config.
if [ ! -f /config/prefs.properties ]; then
    cp /defaults/prefs.properties /config/
    touch /config/.licensed_version
fi

# Clear the fstab file to make sure its content is not displayed when opening
# files.
echo > /etc/fstab

# Install the license to the proper location.
if [ ! -f "$LICENSE_PATH" ]; then
    LFILE="$(find /config -maxdepth 1 -name "*.psm" -type f)"
    if [ "${LFILE:-UNSET}" != "UNSET" ]; then
        LFILE_COUNT="$(echo "$LFILE" | wc -l)"
        if [ "$LFILE_COUNT" -eq 1 ]; then
            log "installing license file $(basename "$LFILE")..."
            mv "$LFILE" "$LICENSE_PATH"
        else
            log "multiple license files found: skipping installation"
        fi
    fi
fi

# Take ownership of the config directory content.
find /config -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;

# vim: set ft=sh :
