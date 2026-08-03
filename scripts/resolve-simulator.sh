#!/bin/bash
#
# Print the UDID of an available iPhone simulator, or fail loudly.
#
# Resolved from whatever the machine actually has rather than by naming a model.
# Hard-coding "iPhone 15 Pro" ties CI to one runner image; GitHub rolls those
# forward, the named device disappears, and the resulting failure reads like a
# broken test instead of a missing device.
#
# Usage:  scripts/resolve-simulator.sh

set -euo pipefail

xcrun simctl list devices available --json | python3 -c '
import json, sys

devices = json.load(sys.stdin)["devices"]

candidates = [
    dev
    for runtime, devs in devices.items()
    if "iOS" in runtime
    for dev in devs
    if dev.get("isAvailable") and "iPhone" in dev.get("name", "")
]

if not candidates:
    sys.exit(
        "no available iPhone simulator found.\n"
        "On a laptop: xcodebuild -downloadPlatform iOS\n"
        "On CI: the runner image has no iOS runtime installed."
    )

print(candidates[0]["udid"])
'
