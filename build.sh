#!/bin/bash
set -e

# Load JAVACARD_DIR and project setting environment variables from config.env.
source config.env
echo "[build] Using javacard directory: \"$JAVACARD_DIR\""

echo "[build] Setting up Java environment variables..."
export JAVA_HOME="$(readlink -f $JAVACARD_DIR/openlogic-openjdk-8u442-b06-linux-x64)"
export JC_HOME="$(readlink -f $JAVACARD_DIR/java_card_kit-2_2_2-rr-bin-linux-do)"

chmod +x "$JC_HOME/bin/converter"
export PATH="$JC_HOME/bin:$JAVA_HOME/bin:$PATH"

# Create build directories if needed.
[ -d "$BUILD_DIR" ] || mkdir -p "$BUILD_DIR"
[ -d "$CAP_BUILD_DIR" ] || mkdir -p "$CAP_BUILD_DIR"

# Java compiler: .java -> .class
echo "[build] Building Java source files..."
javac -target 1.1 -source 1.2 -classpath "$JC_HOME/lib/api.jar" -d "$BUILD_DIR" "$SOURCE_DIR"/*.java

# JavaCard converter: .class -> .cap
echo "[build] Converting classes to a CAP file..."
converter -exportpath "$JC_HOME/api_export_files" \
    -classdir "$BUILD_DIR" \
    -d "$CAP_BUILD_DIR" \
    -applet "$APPLET_AID" \
    "$PACKAGE_NAME.$APPLET_NAME" \
    "$PACKAGE_NAME" \
    "$PACKAGE_AID" \
    "$PACKAGE_VERSION"

CAP_FILE="$CAP_BUILD_DIR/$PACKAGE_NAME/javacard/$PACKAGE_NAME.cap"

echo "[build] Done. CAP file written to $CAP_FILE"

echo '==================================================================='
echo 'Congratulations! You can now install the applet to a physical card.'
echo '==================================================================='
