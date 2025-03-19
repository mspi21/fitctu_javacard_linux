# Java Card linux/amd64 template

This repository serves as a template for simple JavaCard 2.1 applet development. No IDEs, no plug-ins, no system-breaking installs. Just the SDKs, a couple of bash scripts and some python for testing.

The main purpose of this template is to help students at FIT CTU in Prague who want to (or need to) write JavaCard programs on Linux instead of Windows.

## User guide

### Prerequisites

To set up a development environment for JavaCard 2.1, you need:
- to be running Linux on an **AMD64 processor** (if you're on ARM, you can still edit the setup script and everything should work, but I'm not bothered with that),
- have these programs available: `bash`, `wget`, `git`, `sha256sum`, `tar`, `unzip`, `python3` (tested with version 3.13.2).

### Project files

- `config.env`: Edit this file to suit your needs. Defines the package and applet names, AIDs, etc. All following helper scripts read this file and use the values defined there.
- `setup.sh`: This is the starting point. After cloning the repo, run this script to:
    1. download JDK 8 (Java 1.8) from OpenJDK,
    2. extract and prepare the Java Card SDK,
    3. download GlobalPlatformPro from GitHub,
    4. create a Python virtual environment and install necessary packages.
    - At every step, the script will ask for confirmation, just to be safe. If run repeatedly, it will not re-download files, though it will check their hashes and re-extract archives.
- `build.sh`: This script will compile Java source files to Java class files and 'link' them into a single CAP file that can be installed onto the card. This step can be done without any card being connected. The source and build directories can be configured in `config.env`.
- `install.sh`: This script will install the (last successful build of) the package onto the connected card. **This script assumes only one card is ever connected to your device!** It will not let you choose.
- `send_apdu.py`: Once you've installed your app onto the card, use this script to test individual commands. The input to this script is a single APDU command. The script will automatically look up the applet AID from `config.env` and select it. It will then send your APDU request and print the response.
- `src/TestApplet.java`: Example source file. Responds with `Hello` to this APDU: `80 2a 00 00`.
- `javacard/java_card_kit-2_2_2-linux.zip`: This is the official JavaCard development kit (v2.2.2). It cannot be easily downloaded programmatically, since it requires confirmation of an EULA. Unlike other tools, this software has a proprietary licence. You are encouraged to familiarize yourself with it before commencing any usage.

### Limitations

The environment currently does not contain an emulator.

### Bugs

Please report any issues, improvement ideas and similar directly wherever this repository is publicly hosted, or send an email to spinkmil `\x40` fit.cvut.cz.
