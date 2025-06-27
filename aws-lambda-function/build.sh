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

if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERROR: Source directory $SOURCE_DIR does not exist"
  exit 1
fi

rm -f "$OUTPUT_ZIP"

cd "$SOURCE_DIR"

npm ci --quiet --no-audit

if ! npm run build --silent; then
  echo "ERROR: Build failed. Make sure 'npm run build' is properly configured."
  exit 1
fi

BUILD_OUT_DIR="$SOURCE_DIR/.build"

mkdir -p "$BUILD_OUT_DIR"

if [ ! -d "$BUILD_OUT_DIR" ]; then
  echo "ERROR: Build output directory $BUILD_OUT_DIR was not created"
  echo "Make sure your build script outputs to '.build' directory"
  exit 1
fi

TMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'lambdabuild')

cp "$SOURCE_DIR/package.json" "$SOURCE_DIR/package-lock.json" "$TMP_DIR/"

if [ -f "$SOURCE_DIR/.npmrc" ]; then
  cp "$SOURCE_DIR/.npmrc" "$TMP_DIR/"
fi

cd "$TMP_DIR"
npm ci --omit=dev --quiet --no-audit

rm -rf package.json package-lock.json .npmrc

cp -r "$BUILD_OUT_DIR/"* "$TMP_DIR/"

cd "$TMP_DIR"
zip -r -q -X -o "$OUTPUT_ZIP" .

cd "$START_DIR"
rm -rf "$TMP_DIR"

if [ ! -f "$OUTPUT_ZIP" ]; then
  echo "ERROR: Build script failed to create zip file at $OUTPUT_ZIP"
  exit 1
fi

echo "Build successful, zip created at $OUTPUT_ZIP ($(echo "scale=2; $(stat -f%z "$OUTPUT_ZIP" 2>/dev/null || stat -c%s "$OUTPUT_ZIP") / 1024 / 1024" | bc) MB)"
