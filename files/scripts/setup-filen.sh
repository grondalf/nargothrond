#!/bin/bash

set -euo pipefail

REPO="FilenCloudDienste/filen-desktop"
RPM="Filen_linux_x86_64.rpm"
SUM="Filen_linux_x86_64.rpm.sha256.txt"

# Function to check and install dependencies
check_dependencies() {
    echo "Checking dependencies..."
    
    local deps=("curl" "jq" "sha256sum")
    local missing_deps=()
    
    # Check for required commands
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    # Install missing dependencies
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "Installing missing dependencies: ${missing_deps[*]}"
        
        if command -v dnf5 &>/dev/null; then
            dnf5 install -y "${missing_deps[@]}"
        elif command -v dnf &>/dev/null; then
            dnf install -y "${missing_deps[@]}"
        elif command -v yum &>/dev/null; then
            yum install -y "${missing_deps[@]}"
        else
            echo "Error: No package manager found (dnf5, dnf, or yum)"
            exit 1
        fi
    else
        echo "All dependencies are already installed."
    fi
}

# Function to check RPM dependencies before installation
check_rpm_dependencies() {
    echo "Checking RPM package dependencies..."
    
    if ! command -v rpm &>/dev/null; then
        echo "Warning: rpm command not available, skipping dependency check"
        return 0
    fi
    
    # Extract RPM requirements
    local rpm_deps
    rpm_deps=$(rpm -qp --requires "$RPM" 2>/dev/null | grep -E "(so\\.|lib)" | head -10 || true)
    
    if [[ -n "$rpm_deps" ]]; then
        echo "Package requires these dependencies:"
        echo "$rpm_deps"
    fi
}

# Function to cleanup downloaded files
cleanup() {
    echo "Cleaning up downloaded files..."
    [[ -f "$RPM" ]] && rm -f "$RPM"
    [[ -f "$SUM" ]] && rm -f "$SUM"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Main execution
main() {
    # Check and install script dependencies
    check_dependencies
    
    # Get latest release URLs
    echo "Fetching latest release information..."
    API="https://api.github.com/repos/$REPO/releases/latest"
    RPM_URL=$(curl -s "$API" | jq -r ".assets[] | select(.name==\"$RPM\") | .browser_download_url")
    SUM_URL=$(curl -s "$API" | jq -r ".assets[] | select(.name==\"$SUM\") | .browser_download_url")

    if [[ -z "$RPM_URL" || -z "$SUM_URL" ]]; then
        echo "Failed to retrieve URLs for $RPM and $SUM"
        exit 1
    fi

    echo "Downloading files..."
    # Download files
    curl -L -o "$RPM" "$RPM_URL"
    curl -L -o "$SUM" "$SUM_URL"

    # Check RPM dependencies
    check_rpm_dependencies

    # Verify checksum
    echo "Verifying checksum..."
    CHECKSUM_EXPECTED=$(cut -d ' ' -f1 "$SUM")
    CHECKSUM_ACTUAL=$(sha256sum "$RPM" | cut -d ' ' -f1)

    if [[ "$CHECKSUM_EXPECTED" == "$CHECKSUM_ACTUAL" ]]; then
        echo "Checksum OK, installing $RPM ..."
        if command -v dnf5 &>/dev/null; then
            dnf5 install -y "$RPM"
        else
            dnf install -y "$RPM"
        fi
        echo "Installation completed successfully!"
    else
        echo "Checksum mismatch, aborting."
        echo "Expected: $CHECKSUM_EXPECTED"
        echo "Actual:   $CHECKSUM_ACTUAL"
        exit 1
    fi
    
    # Cleanup will happen automatically due to trap
}

# Run main function
main "$@"