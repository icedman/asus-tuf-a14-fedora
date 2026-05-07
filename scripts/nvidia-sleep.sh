#!/usr/bin/bash

if [ ! -f /proc/driver/nvidia/suspend ]; then
    exit 0
fi

RUN_DIR="/var/run/nvidia-sleep"
XORG_VT_FILE="${RUN_DIR}"/Xorg.vt_number

PATH="/bin:/usr/bin"

RestoreVT() {
    #
    # Check if Xorg was determined to be running at the time
    # of suspend, and whether its VT was recorded.  If so,
    # attempt to switch back to this VT.
    #
    if [[ -f "${XORG_VT_FILE}" ]]; then
        XORG_PID=$(cat "${XORG_VT_FILE}")
        rm "${XORG_VT_FILE}"
        chvt "${XORG_PID}"
    fi
}

case "$1" in
    is-suspend-then-hibernate-supported)
        # suspend-then-hibernate only works correctly if $SYSTEMD_SLEEP_ACTION
        # is supported, which was added in systemd 248.
        systemd_version=$(systemctl --version | head -n1 | cut -d' ' -f2)
        if [ "$systemd_version" -gt 247 ]; then
            exit 0
        fi

        echo "systemd version $systemd_version is too old to support suspend-then-hibernate with NVIDIA." 2>&1
        echo "Please upgrade to systemd 248 or newer." 2>&1
        exit 1
        ;;
    suspend|hibernate)
        /usr/local/sbin/save_kb.sh
        mkdir -p "${RUN_DIR}"
        fgconsole > "${XORG_VT_FILE}"
        chvt 63
        if [[ $? -ne 0 ]]; then
            exit $?
        fi
        echo "$1" > /proc/driver/nvidia/suspend
        RET_VAL=$?
        #
        # If suspend/hibernate entry fails, switch back to the active VT
        #
        if [[ $RET_VAL -ne 0 ]]; then
            RestoreVT
        fi
        exit $RET_VAL
        ;;
    resume)
        /usr/local/sbin/restore_kb.sh
        echo "$1" > /proc/driver/nvidia/suspend
        RestoreVT
        exit 0
        ;;
    *)
        exit 1
esac
