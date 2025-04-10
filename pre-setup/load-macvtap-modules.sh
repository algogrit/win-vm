#!/usr/bin/env bash

REQUIRED_MODULES=("macvtap" "macvlan" "tun")
ADDED=0

for mod in "${REQUIRED_MODULES[@]}"; do
    if lsmod | grep -q "^$mod"; then
        echo "✅ Module '$mod' is already loaded."
    else
        echo "🔧 Loading module '$mod'..."
        sudo modprobe "$mod"
        if lsmod | grep -q "^$mod"; then
            echo "✅ Module '$mod' loaded successfully."
        else
            echo "❌ Failed to load module '$mod'."
        fi
    fi

    if ! grep -q "^$mod\$" /etc/modules; then
        echo "📌 Adding '$mod' to /etc/modules for auto-loading at boot..."
        echo "$mod" | sudo tee -a /etc/modules >/dev/null
        ADDED=1
    fi
done

if [ $ADDED -eq 1 ]; then
    echo "🔁 Changes made to /etc/modules. These modules will now load at boot."
else
    echo "👍 All modules were already configured to load at boot."
fi
