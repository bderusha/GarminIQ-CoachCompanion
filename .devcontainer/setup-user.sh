#!/usr/bin/env bash
set -euo pipefail

readonly data_dir="${HOME}/.Garmin/ConnectIQ"
readonly sdk_dir="${CONNECTIQ_SDK_HOME:-/opt/garmin/connectiq-sdk}"
readonly sdk_manager="/opt/garmin/sdk-manager/bin/sdkmanager"
readonly developer_key="${data_dir}/developer_key"

mkdir -p "${data_dir}/Devices" "${data_dir}/Sdks"
ln -s "/workspaces/GarminIQ-CoachCompanion/developer_key" "${developer_key}" || true

# These files are how the Garmin Monkey C extension discovers the active SDK
# and SDK Manager on Linux.
printf '%s\n' "${sdk_dir}" > "${data_dir}/current-sdk.cfg"
printf '%s\n' "${sdk_manager}" > "${data_dir}/sdkmanager-location.cfg"
touch "${data_dir}/sdkmanager-config.ini"


echo "Connect IQ SDK $(cat "${sdk_dir}/bin/version.txt") is ready."
echo "Before the first device build, run 'sdkmanager' in a terminal and use the forwarded desktop to download device profiles."