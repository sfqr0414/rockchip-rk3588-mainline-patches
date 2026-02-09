#!/bin/bash
# SPDX-License-Identifier: (GPL-2.0+ OR MIT)
# Installation script for Rockchip RKVENC (VEPU580) encoder driver

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="rkvenc"
PACKAGE_NAME="rk-vcodec"
PACKAGE_VERSION="1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_kernel_headers() {
    local kernel_version=$(uname -r)
    local header_dir="/lib/modules/${kernel_version}/build"
    
    if [ ! -d "$header_dir" ]; then
        print_error "Kernel headers not found for ${kernel_version}"
        print_info "Please install kernel headers first:"
        print_info "  Ubuntu/Debian: sudo apt-get install linux-headers-\$(uname -r)"
        print_info "  Fedora/RHEL:   sudo dnf install kernel-devel"
        print_info "  Arch:          sudo pacman -S linux-headers"
        exit 1
    fi
    
    print_info "Found kernel headers at ${header_dir}"
}

build_module() {
    print_info "Building ${MODULE_NAME} module..."
    cd "$SCRIPT_DIR"
    make clean
    make
    
    if [ ! -f "${MODULE_NAME}.ko" ]; then
        print_error "Module build failed"
        exit 1
    fi
    
    print_info "Module built successfully"
}

install_module() {
    print_info "Installing ${MODULE_NAME} module..."
    cd "$SCRIPT_DIR"
    make install
    print_info "Module installed successfully"
}

install_dkms() {
    if ! command -v dkms &> /dev/null; then
        print_warn "DKMS not found. Please install DKMS for automatic kernel updates:"
        print_info "  Ubuntu/Debian: sudo apt-get install dkms"
        print_info "  Fedora/RHEL:   sudo dnf install dkms"
        print_info "  Arch:          sudo pacman -S dkms"
        return 1
    fi
    
    print_info "Installing with DKMS..."
    
    # Remove old version if exists
    if dkms status "${PACKAGE_NAME}/${PACKAGE_VERSION}" &> /dev/null; then
        print_info "Removing old DKMS installation..."
        dkms remove "${PACKAGE_NAME}/${PACKAGE_VERSION}" --all || true
    fi
    
    # Copy source to DKMS tree
    local dkms_dir="/usr/src/${PACKAGE_NAME}-${PACKAGE_VERSION}"
    print_info "Copying source to ${dkms_dir}..."
    rm -rf "$dkms_dir"
    mkdir -p "$dkms_dir"
    cp -r "$SCRIPT_DIR"/* "$dkms_dir/"
    
    # Add, build and install with DKMS
    print_info "Adding to DKMS..."
    dkms add -m "${PACKAGE_NAME}" -v "${PACKAGE_VERSION}"
    
    print_info "Building with DKMS..."
    dkms build -m "${PACKAGE_NAME}" -v "${PACKAGE_VERSION}"
    
    print_info "Installing with DKMS..."
    dkms install -m "${PACKAGE_NAME}" -v "${PACKAGE_VERSION}"
    
    print_info "DKMS installation completed"
    return 0
}

load_module() {
    print_info "Loading ${MODULE_NAME} module..."
    
    # Remove if already loaded
    if lsmod | grep -q "^${MODULE_NAME} "; then
        print_info "Module already loaded, reloading..."
        rmmod "${MODULE_NAME}" || true
    fi
    
    modprobe "${MODULE_NAME}"
    
    if lsmod | grep -q "^${MODULE_NAME} "; then
        print_info "Module loaded successfully"
        
        # Check for device node
        if [ -c "/dev/mpp_service" ]; then
            print_info "Device node /dev/mpp_service created"
        else
            print_warn "Device node /dev/mpp_service not found"
            print_info "This may be normal if the device is not present in device tree"
        fi
    else
        print_error "Failed to load module"
        print_info "Check dmesg for errors: sudo dmesg | tail -50"
        exit 1
    fi
}

uninstall() {
    print_info "Uninstalling ${MODULE_NAME}..."
    
    # Unload module
    if lsmod | grep -q "^${MODULE_NAME} "; then
        print_info "Unloading module..."
        rmmod "${MODULE_NAME}" || true
    fi
    
    # Remove from DKMS if installed
    if command -v dkms &> /dev/null; then
        if dkms status "${PACKAGE_NAME}/${PACKAGE_VERSION}" &> /dev/null; then
            print_info "Removing from DKMS..."
            dkms remove "${PACKAGE_NAME}/${PACKAGE_VERSION}" --all || true
            rm -rf "/usr/src/${PACKAGE_NAME}-${PACKAGE_VERSION}"
        fi
    fi
    
    # Remove module file
    local kernel_version=$(uname -r)
    local module_path="/lib/modules/${kernel_version}/extra/${MODULE_NAME}.ko"
    if [ -f "$module_path" ]; then
        print_info "Removing module file..."
        rm -f "$module_path"
        depmod -A
    fi
    
    print_info "Uninstallation completed"
}

show_usage() {
    cat << EOF
Rockchip RKVENC (VEPU580) Encoder Driver Installation Script

Usage: $0 [OPTION]

Options:
  install       Build and install the module (default)
  install-dkms  Install with DKMS for automatic kernel updates
  uninstall     Remove the module from the system
  build         Build the module without installing
  load          Load the module (must be installed first)
  help          Show this help message

Examples:
  sudo $0 install          # Standard installation
  sudo $0 install-dkms     # DKMS installation (recommended)
  sudo $0 uninstall        # Remove the driver

EOF
}

main() {
    local action="${1:-install}"
    
    case "$action" in
        install)
            check_root
            check_kernel_headers
            build_module
            install_module
            load_module
            print_info "Installation completed successfully!"
            print_info "Device: /dev/mpp_service"
            ;;
        install-dkms)
            check_root
            check_kernel_headers
            if install_dkms; then
                load_module
                print_info "DKMS installation completed successfully!"
                print_info "The module will be automatically rebuilt on kernel updates"
            else
                print_warn "DKMS installation failed, falling back to standard install"
                build_module
                install_module
                load_module
            fi
            ;;
        uninstall)
            check_root
            uninstall
            ;;
        build)
            check_kernel_headers
            build_module
            ;;
        load)
            check_root
            load_module
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown option: $action"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
