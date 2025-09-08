#!/bin/sh

# Lambda build script for Terraform Lambda module
set -e

# Get absolute paths
LAMBDA_NAME=$1
SOURCE_DIR=$2
OUTPUT_ZIP=$3

if [ -z "$LAMBDA_NAME" ] || [ -z "$SOURCE_DIR" ] || [ -z "$OUTPUT_ZIP" ]; then
  echo "Usage: ./build.sh <lambda_name> <source_dir> <output_zip>"
  echo "Example: ./build.sh token-invalidation /path/to/lambda/source /path/to/output.zip"
  exit 1
fi

# Convert to absolute paths for consistent handling (portable approach)
# Validate source directory exists first
if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERROR: Source directory $SOURCE_DIR does not exist"
  exit 1
fi

SOURCE_DIR=$(cd "$SOURCE_DIR" && pwd)

# Convert output zip to absolute path
case "$OUTPUT_ZIP" in
  /*) ;;  # Already absolute
  *) OUTPUT_ZIP="$(pwd)/$OUTPUT_ZIP" ;;  # Make relative paths absolute
esac

# Get output directory from zip path and create temp build directory
OUTPUT_DIR=$(dirname "$OUTPUT_ZIP")
BUILD_DIR="$OUTPUT_DIR/.tmp-build-$$"

echo "Building Lambda function $LAMBDA_NAME"
echo "Source: $SOURCE_DIR"
echo "Output: $OUTPUT_ZIP"

# Ensure output directory exists and clean build directory
mkdir -p "$OUTPUT_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$SOURCE_DIR"

# Validate required files exist
if [ ! -f "package.json" ]; then
  echo "ERROR: package.json not found in source directory"
  exit 1
fi

if [ ! -f "package-lock.json" ]; then
  echo "ERROR: package-lock.json not found in source directory"
  exit 1
fi

# Install dependencies
echo "Installing dependencies..."
if ! npm ci --quiet --no-audit --no-fund; then
  echo "ERROR: Failed to install dependencies"
  exit 1
fi

# Build the project
echo "Building project..."
if ! npm run build; then
  echo "ERROR: Build command failed"
  exit 1
fi

# Check if build output exists
BUILD_OUT_DIR="$SOURCE_DIR/.build"
if [ ! -d "$BUILD_OUT_DIR" ] || [ -z "$(ls -A "$BUILD_OUT_DIR" 2>/dev/null)" ]; then
  echo "ERROR: Build output directory $BUILD_OUT_DIR is empty or does not exist"
  exit 1
fi

# Copy build output to build directory
echo "Copying build output..."
cp -r "$BUILD_OUT_DIR/"* "$BUILD_DIR/"

# Create a temporary directory for production dependencies
TMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'lambdabuild')

# Copy package files to temp directory
cp "$SOURCE_DIR/package.json" "$SOURCE_DIR/package-lock.json" "$TMP_DIR/"

if [ -f "$SOURCE_DIR/.npmrc" ]; then
  cp "$SOURCE_DIR/.npmrc" "$TMP_DIR/"
fi

# Install production dependencies
echo "Installing production dependencies..."
cd "$TMP_DIR"
if ! npm ci --omit=dev --quiet --no-audit --no-fund; then
  echo "ERROR: Failed to install production dependencies"
  cd /
  rm -rf "$TMP_DIR" "$BUILD_DIR"
  exit 1
fi

# Remove package files
rm -rf package.json package-lock.json .npmrc

# Copy node_modules to build directory
if [ -d "node_modules" ]; then
  cp -r node_modules "$BUILD_DIR/"
fi

# Clean up temp directory
cd /
rm -rf "$TMP_DIR"

# Create the zip file
echo "Creating Lambda deployment package..."
cd "$BUILD_DIR"
if ! zip -rq "$OUTPUT_ZIP" .; then
  echo "ERROR: Failed to create zip package"
  cd /
  rm -rf "$BUILD_DIR"
  exit 1
fi

# Verify zip was created
if [ ! -f "$OUTPUT_ZIP" ]; then
  echo "ERROR: Zip file was not created at $OUTPUT_ZIP"
  cd /
  rm -rf "$BUILD_DIR"
  exit 1
fi

# Clean up build directory
cd /
rm -rf "$BUILD_DIR"

echo "Build completed successfully. Lambda package: $OUTPUT_ZIP ($(du -h "$OUTPUT_ZIP" | cut -f1))"
