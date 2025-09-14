#!/bin/bash

# Navigate to the Flutter project directory
cd /Users/jenkins/agent/workspace/pnjmobileapp

# Ensure pubspec.yaml exists
if [ ! -f pubspec.yaml ]; then
  echo "Error: pubspec.yaml not found!"
  exit 1
fi

# Extract the current version
version_line=$(grep '^version:' pubspec.yaml)
if [[ -z "$version_line" ]]; then
  echo "Error: Version line not found in pubspec.yaml!"
  exit 1
fi

# Extract major, minor, patch, and build numbers
regex='version: ([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)'
if [[ $version_line =~ $regex ]]; then
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
  build=${BASH_REMATCH[4]}
else
  echo "Error: Invalid version format!"
  exit 1
fi

# Increment the build number
new_build=$((build + 1))
new_version="version: $major.$minor.$patch+$new_build"

# Update the pubspec.yaml file
sed -i "s/^version: .*/$new_version/" pubspec.yaml

echo "Version updated to $new_version"
