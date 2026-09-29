# GarminIQ-CoachCompanion
GarminIQ Data Field app for using the RunWalkRun method with coached workouts.

## GitHub Codespaces

This repository includes a development container with:

- Ubuntu 22.04 and the Connect IQ 9.2.0 Linux SDK
- The Garmin Monkey C extension for Visual Studio Code
- Java 17 and the Linux libraries required by the compiler and simulator
- The Connect IQ SDK Manager
- A browser-accessible desktop for the graphical SDK Manager and simulator

Creating a Codespace downloads the Garmin SDK. By downloading or using it, you
accept the [Connect IQ SDK license agreement](https://developer.garmin.com/connect-iq/sdk/).

### First-time setup

The SDK archive does not include device profiles, and Garmin requires an account
login to download them. After the Codespace has been created:

1. Run `sdkmanager` in the Visual Studio Code terminal.
2. Open the forwarded port named **Connect IQ desktop** (port 6080).
3. Select **Connect** and use the default desktop password `vscode`.
4. Sign in to the SDK Manager and download the device profiles needed by this app.
	The SDK itself is already installed and selected, so downloading another SDK
	is optional.
5. Run **Monkey C: Verify Installation** from the Visual Studio Code command
	palette.

The container creates a developer signing key at
`~/.Garmin/ConnectIQ/developer_key`. Back up this key before publishing an app:
the same key is required for every future update to that app.

Use the Monkey C extension's **Build Current Project**, **Build for Device**, and
debug commands for normal development. Graphical simulator windows appear in the
same forwarded desktop.
