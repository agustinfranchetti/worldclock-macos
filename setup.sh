#!/bin/bash
set -e

# Check for Xcode Command Line Tools (provides swiftc)
if ! xcode-select -p &>/dev/null || ! xcrun --find swiftc &>/dev/null; then
    echo "Xcode Command Line Tools not found. Installing..."
    echo "A dialog will appear — click Install and wait for it to finish."
    xcode-select --install

    # Wait until swiftc becomes available
    echo "Waiting for installation to complete..."
    until xcrun --find swiftc &>/dev/null; do
        sleep 5
    done
    echo "Xcode Command Line Tools installed."
fi

bash "$(dirname "$0")/build.sh"
