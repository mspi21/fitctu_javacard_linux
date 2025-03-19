#!/bin/bash
set -e

echo '===================================================================='
echo 'The setup will download and extract OpenJDK 1.8, which is required'
echo "for this version of the JavaCard SDK. The setup assumes that you're"
echo 'running Linux on an amd64 (a.k.a. x86_64) machine.'
echo '===================================================================='
read -p 'Continue [y/n]? ' -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo 'Ok, quitting.'
    exit 1
fi

# Load JAVACARD_DIR environment variable from config.env.
source config.env
echo "[setup] Using javacard directory: \"$JAVACARD_DIR\""

# Create the javacard directory, if it doesn't already exist.
[ -d "$JAVACARD_DIR" ] || mkdir -p "$JAVACARD_DIR"

# Download the JDK, if it's not already downloaded.
jdk_download_url='https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u442-b06/openlogic-openjdk-8u442-b06-linux-x64.tar.gz'
echo '[setup] Starting download using wget...'
wget "$jdk_download_url" -nc -P "$JAVACARD_DIR"
echo '[setup] Download done.'

JDK_TAR_FILE="$JAVACARD_DIR/openlogic-openjdk-8u442-b06-linux-x64.tar.gz"
JDK_TAR_HASH="d22faef8fdaea057354206f6857027f7f17a25ab6758b7a10e8e9028feba9451"

# Check the hash.
echo '[setup] Checking archive integrity.'
hash=$(sha256sum "$JDK_TAR_FILE" | cut -d' ' -f1)
if [ ! "$hash" = "$JDK_TAR_HASH" ]; then
    rm "$JDK_TAR_FILE"
    echo '[setup] Hash mismatch!' "Expected $JDK_TAR_HASH, got $hash." 'Aborting.'
    exit 1
fi
echo '[setup] Integrity check OK.'

# Extract the JDK archive.
echo '[setup] Extracting JDK archive...'
tar xaf "$JDK_TAR_FILE" --directory "$JAVACARD_DIR"
echo '[setup] JDK archive extracted.'

# Now extract the JavaCard SDK, assuming the user agrees to Oracle's terms, blah blah...

echo '====================================================================='
echo 'The JavaCard development kit has a proprietary licence from Oracle.'
echo 'By continuing, you confirm that you have read and agreed to the terms'
echo 'at https://www.oracle.com/java/technologies/javacard-downloads.html .'
echo '====================================================================='
read -p 'Continue [y/n]? ' -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo 'Ok, quitting.'
    exit 1
fi

# Extract the JDK archive.
echo '[setup] Extracting JavaCard devkit archive...'
unzip -d "$JAVACARD_DIR" -j "$JAVACARD_DIR/java_card_kit-2_2_2-linux.zip" java_card_kit-2_2_2/java_card_kit-2_2_2-rr-bin-linux-do.zip
unzip -d "$JAVACARD_DIR/java_card_kit-2_2_2-rr-bin-linux-do" "$JAVACARD_DIR/java_card_kit-2_2_2-rr-bin-linux-do.zip"
echo '[setup] JavaCard devkit archive extracted.'

# Finally, download GlobalPlatformPro.

echo '==================================================================='
echo 'The setup will now download GlobalPlatformPro (gp) version 20.01.23'
echo 'from GitHub into the javacard directory.'
echo '==================================================================='
read -p 'Continue [y/n]? ' -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo 'Ok, quitting.'
    exit 1
fi

gp_download_url='https://github.com/martinpaljak/GlobalPlatformPro/releases/download/v20.01.23/gp.jar'
echo '[setup] Starting download using wget...'
wget "$gp_download_url" -nc -P "$JAVACARD_DIR"
echo '[setup] Download done.'

GP_FILE="$JAVACARD_DIR/gp.jar"
GP_HASH="1e22bd641ec72e81b221704d67d351b07b268805b2bebd3a9ef5b93352fea8f7"

# Check the hash.
echo '[setup] Checking archive integrity.'
hash=$(sha256sum "$GP_FILE" | cut -d' ' -f1)
if [ ! "$hash" = "$GP_HASH" ]; then
    rm "$GP_FILE"
    echo '[setup] Hash mismatch!' "Expected $GP_HASH, got $hash." 'Aborting.'
    exit 1
fi
echo '[setup] Integrity check OK.'

echo '==============================================================='
echo 'The setup will create a Python virtual environment and install'
echo 'the pyscard package, which is required for the send_apdu script'
echo 'to communicate with your smart card reader(s).'
echo '==============================================================='
read -p 'Continue [y/n]? ' -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo 'Ok, quitting.'
    exit 1
fi

echo '[setup] Setting up Python virtual environment.'
python3 -m venv .venv
echo '[setup] Installing the pyscard Python package.'
.venv/bin/pip install pyscard
echo '[setup] Installing the python-dotenv Python package.'
.venv/bin/pip install python-dotenv
echo '[setup] Python virtual environment successfully set up in .venv.'

echo '==============================================================='
echo 'Congratulations! You can now use the build and install scripts.'
echo '==============================================================='
