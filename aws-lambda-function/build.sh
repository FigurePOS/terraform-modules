#!/bin/sh

# Lambda build script for Terraform Lambda module
set -e

# Get absolute paths
START_DIR=$(pwd)
LAMBDA_NAME=$1
SOURCE_DIR=$2

if [ -z "$LAMBDA_NAME" ] || [ -z "$SOURCE_DIR" ]; then
  echo "Usage: ./build.sh <lambda_name> <source_dir>"
  echo "Example: ./build.sh offload-db-to-s3 /path/to/lambda/source"
  exit 1
fi

case "$SOURCE_DIR" in
  /*) ;;  # Absolute path, do nothing
  *) SOURCE_DIR="$START_DIR/$SOURCE_DIR" ;;  # Relative path, make it absolute
esac

OUTPUT_DIR="$START_DIR/.build"
mkdir -p "$OUTPUT_DIR"
OUTPUT_ZIP="$OUTPUT_DIR/$LAMBDA_NAME.zip"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERROR: Source directory $SOURCE_DIR does not exist"
  exit 1
fi

# Clean up any existing zip
rm -f "$OUTPUT_ZIP"

# Navigate to source directory
cd "$SOURCE_DIR"

npm ci --quiet --no-audit

npm run build

# Find the output directory from tsconfig.json
if grep -q "outDir" tsconfig.json; then
  TS_OUT_DIR=$(grep -o '"outDir":[^,}]*' tsconfig.json | cut -d'"' -f4)
  echo "TypeScript output directory from tsconfig.json: $TS_OUT_DIR"
else
  TS_OUT_DIR=".build"
  echo "No outDir in tsconfig.json, defaulting to '.build'"
fi

# Use absolute path for TS_OUT_DIR
TS_OUT_DIR="$SOURCE_DIR/$TS_OUT_DIR"

# Check if TS output directory was created
if [ ! -d "$TS_OUT_DIR" ]; then
  echo "ERROR: TypeScript output directory $TS_OUT_DIR was not created"
  ls -la "$SOURCE_DIR"
  echo "Looking for any .js files in source directory:"
  find "$SOURCE_DIR" -name "*.js" | grep -v node_modules
  exit 1
fi

# Create a temp directory - use POSIX-compliant approach
TMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'lambdabuild')

# Copy package.json and install production dependencies
cp "$SOURCE_DIR/package.json" "$SOURCE_DIR/package-lock.json" "$TMP_DIR/"

# Copy .npmrc if it exists (for private packages)
if [ -f "$SOURCE_DIR/.npmrc" ]; then
  cp "$SOURCE_DIR/.npmrc" "$TMP_DIR/"
fi

cd "$TMP_DIR"
npm ci --omit=dev --quiet --no-audit

# Copy compiled files (using absolute paths)
cp -r "$TS_OUT_DIR/"* "$TMP_DIR/" || echo "WARNING: Copy failed, but continuing"

# Create zip - use quiet mode to suppress verbose output
# Use -X to strip file attributes and -o to set identical modification time
# This makes zip output more deterministic across environments
zip -r -q -X -o "$OUTPUT_ZIP" .

# Clean up
cd "$START_DIR"
rm -rf "$TMP_DIR"

