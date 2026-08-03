#!/bin/bash
#
# Assert that an `xcodebuild test` run actually executed tests.
#
# xcodebuild exits 0 for a run that executed nothing: a scheme with no test
# target attached, a destination that matched no tests, a suite skipped
# wholesale. The exit code alone cannot tell "71 tests passed" from "no tests
# were found", and both render as a green tick.
#
# That failure mode is not hypothetical here. This repository shipped a CI check
# called "Build & Test" that ran no tests for the whole life of the branch,
# while VisualAssistTests held 71 test functions. The check was green the entire
# time. This script is what stops the same claim being made again by a job name.
#
# Usage:  scripts/assert-test-results.sh <path/to/TestResults.xcresult> [minimum]
#
# Lives in a file rather than inline in the workflow so it can be run — and
# negative-tested — on a laptop, which is the only way to know a CI gate works
# before trusting it.

set -euo pipefail

BUNDLE="${1:?usage: assert-test-results.sh <TestResults.xcresult> [minimum]}"

# A floor, not an exact count. Tests get added, and a gate that must be edited
# every time someone writes a test gets deleted instead. 60 sits below the 71
# that exist and far above zero, which is the number actually being guarded.
MINIMUM="${2:-60}"

if [ ! -e "$BUNDLE" ]; then
  echo "FAIL: no result bundle at '$BUNDLE'."
  echo "      The test step did not produce one, which means it did not run."
  exit 1
fi

# `xcresulttool get test-results summary` exists only from Xcode 16. GitHub's
# macos-14 runners ship Xcode 15.x, where the same call dies with
#   error: unexpected argument test-results
# and then the parser chokes on an empty stdin, which reads as a test failure
# rather than a toolchain difference. So: try the modern command, fall back to
# the legacy schema, and tell the caller which one answered.
SUMMARY=""
SCHEMA=""
if SUMMARY=$(xcrun xcresulttool get test-results summary --path "$BUNDLE" 2>/dev/null) \
   && [ -n "$SUMMARY" ]; then
  SCHEMA="modern"
else
  # --legacy is required on Xcode 16+ and rejected on 15.x, so try both.
  SUMMARY=$(xcrun xcresulttool get --legacy --format json --path "$BUNDLE" 2>/dev/null) \
    || SUMMARY=$(xcrun xcresulttool get --format json --path "$BUNDLE" 2>/dev/null)
  SCHEMA="legacy"
fi

if [ -z "$SUMMARY" ]; then
  echo "FAIL: could not read '$BUNDLE' with any known xcresulttool interface." >&2
  exit 1
fi

printf '%s' "$SUMMARY" | MINIMUM="$MINIMUM" SCHEMA="$SCHEMA" python3 -c '
import json, os, sys

d = json.load(sys.stdin)
minimum = int(os.environ["MINIMUM"])
schema = os.environ["SCHEMA"]

if schema == "modern":
    passed  = d.get("passedTests", 0)
    failed  = d.get("failedTests", 0)
    skipped = d.get("skippedTests", 0)
    result  = d.get("result", "?")
    for cfg in d.get("devicesAndConfigurations", []):
        dev = cfg.get("device", {})
        print("device: {} - {} {}".format(
            dev.get("deviceName", "?"), dev.get("platform", "?"), dev.get("osVersion", "?")))
else:
    # Xcode 15 wraps every scalar as {"_value": "..."} and OMITS the failure and
    # skip counters entirely when they are zero -- so a missing key means none,
    # not unknown. `passed` is derived, because this schema reports only a total.
    def scalar(node, key, default=0):
        v = node.get(key)
        if isinstance(v, dict):
            v = v.get("_value", default)
        return int(v) if v is not None else default

    metrics = d.get("metrics", {})
    total   = scalar(metrics, "testsCount")
    failed  = scalar(metrics, "testsFailedCount")
    skipped = scalar(metrics, "testsSkippedCount")
    passed  = total - failed - skipped
    result  = "Passed" if failed == 0 else "Failed"

print(f"schema={schema} passed={passed} failed={failed} skipped={skipped} result={result}")

errors = []
if result != "Passed":
    errors.append(f"result is {result!r}, not Passed")
if failed:
    errors.append(f"{failed} test(s) failed")
if skipped:
    errors.append(f"{skipped} test(s) skipped -- a skipped suite is not a passing suite")
if passed < minimum:
    errors.append(
        f"only {passed} tests ran, expected at least {minimum}. "
        "A green build that executed nothing is the failure this check exists for."
    )

if errors:
    for e in errors:
        print("FAIL:", e)
    sys.exit(1)

print(f"OK: {passed} tests executed and passed, 0 skipped")
'
