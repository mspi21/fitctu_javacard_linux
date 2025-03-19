#!/bin/bash
set -e

# Load JAVACARD_DIR and project setting environment variables from config.env.
source config.env
echo "[install] Using javacard directory: \"$JAVACARD_DIR\""

GP_JAR="$JAVACARD_DIR/gp.jar"
CAP_FILE="$CAP_BUILD_DIR/$PACKAGE_NAME/javacard/$PACKAGE_NAME.cap"

echo "[install] Setting up Java environment variables..."
export JAVA_HOME="$(readlink -f $JAVACARD_DIR/openlogic-openjdk-8u442-b06-linux-x64)"
export PATH="$JAVA_HOME/bin:$PATH"

# Run GP to program the card.
echo "[install] Installing the CAP file to the card using GlobalPlatformPro..."
# -v for verbose output,
# -f to force installation even if an applet with the same AID is already on the card.
java -jar "$GP_JAR" -v --install "$CAP_FILE" -f
echo "[install] Done."

echo '=========================================================='
echo 'Congratulations! The card was programmed with your applet.'
echo '=========================================================='
