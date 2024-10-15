#!/bin/bash

# sysinfo.sh - A script to display comprehensive system information
# Author: rxxuzi
# License: CC0

# Exit immediately if a command exits with a non-zero status
set -e

# ==============================
#         Color Codes
# ==============================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ==============================
#      Helper Functions
# ==============================

# Function to display error messages
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ==============================
#      System Information Functions
# ==============================

# Function to get OS type
get_os_type() {
    OS_NAME=$(uname -s)
    case "$OS_NAME" in
        Darwin)
            echo -e "${BLUE}Operating System:${NC} macOS"
            ;;
        Linux)
            echo -e "${BLUE}Operating System:${NC} Linux"
            ;;
        *)
            echo -e "${BLUE}Operating System:${NC} $OS_NAME"
            ;;
    esac
}

# Function to get OS version
get_os_version() {
    if [[ "$OS_NAME" == "Darwin" ]]; then
        if command_exists sw_vers; then
            OS_VERSION=$(sw_vers -productVersion)
            echo -e "${BLUE}OS Version:${NC} $OS_VERSION"
        else
            echo -e "${BLUE}OS Version:${NC} Unknown"
        fi
    elif [[ "$OS_NAME" == "Linux" ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo -e "${BLUE}OS Version:${NC} $PRETTY_NAME"
        else
            echo -e "${BLUE}OS Version:${NC} Unknown"
        fi
    else
        echo -e "${BLUE}OS Version:${NC} Unknown"
    fi
}

# Function to get CPU architecture
get_cpu_arch() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64 | amd64)
            CPU_ARCH="x64"
            ;;
        arm64 | aarch64)
            CPU_ARCH="ARM64"
            ;;
        i386 | i686)
            CPU_ARCH="x86"
            ;;
        *)
            CPU_ARCH="$ARCH"
            ;;
    esac
    echo -e "${BLUE}CPU Architecture:${NC} $CPU_ARCH"
}

# Function to get hostname
get_hostname() {
    HOSTNAME=$(hostname)
    echo -e "${BLUE}Hostname:${NC} $HOSTNAME"
}

# Function to get kernel version
get_kernel_version() {
    KERNEL_VERSION=$(uname -r)
    echo -e "${BLUE}Kernel Version:${NC} $KERNEL_VERSION"
}

# Function to get memory information
get_memory_info() {
    if [[ "$OS_NAME" == "Darwin" ]]; then
        # Get free memory in MB
        MEMORY_FREE=$(vm_stat | awk '/Pages free:/ {print $3}' | sed 's/\.//')
        MEMORY_FREE_MB=$((MEMORY_FREE * 4096 / 1024 / 1024))
        echo -e "${BLUE}Free Memory:${NC} ${MEMORY_FREE_MB} MB"
    elif [[ "$OS_NAME" == "Linux" ]]; then
        MEMORY_FREE=$(free -m | awk '/Mem:/ { print $4 " MB"}')
        echo -e "${BLUE}Free Memory:${NC} $MEMORY_FREE"
    else
        echo -e "${BLUE}Free Memory:${NC} Unknown"
    fi
}

# Function to get total memory
get_total_memory() {
    if [[ "$OS_NAME" == "Darwin" ]]; then
        MEMORY_TOTAL=$(sysctl -n hw.memsize)
        MEMORY_TOTAL_MB=$((MEMORY_TOTAL / 1024 / 1024))
        echo -e "${BLUE}Total Memory:${NC} ${MEMORY_TOTAL_MB} MB"
    elif [[ "$OS_NAME" == "Linux" ]]; then
        MEMORY_TOTAL=$(free -m | awk '/Mem:/ { print $2 " MB"}')
        echo -e "${BLUE}Total Memory:${NC} $MEMORY_TOTAL"
    else
        echo -e "${BLUE}Total Memory:${NC} Unknown"
    fi
}

# Function to get system uptime
get_uptime() {
    UPTIME=$(uptime -p 2>/dev/null || uptime | awk -F'( |,|:)+' '{print $6,$7,$8}')
    echo -e "${BLUE}System Uptime:${NC} $UPTIME"
}

# Function to get network information
get_network_info() {
    echo -e "${BLUE}Network Information:${NC}"
    if [[ "$OS_NAME" == "Darwin" ]]; then
        # Get IP addresses for common interfaces
        for iface in en0 en1; do
            if command_exists ipconfig; then
                IP=$(ipconfig getifaddr "$iface" 2>/dev/null)
                if [ -n "$IP" ]; then
                    echo -e "${BLUE}$iface:${NC} $IP"
                fi
            fi
        done
        # If no IP found
        if ! ipconfig getifaddr en0 >/dev/null 2>&1 && ! ipconfig getifaddr en1 >/dev/null 2>&1; then
            echo "No active network interfaces found."
        fi
    elif [[ "$OS_NAME" == "Linux" ]]; then
        if command_exists hostname; then
            IP_ADDR=$(hostname -I | awk '{print $1}')
            echo -e "${BLUE}IP Address:${NC} ${IP_ADDR:-Not Available}"
        else
            echo "IP Address: Unknown"
        fi
    else
        echo "Network Information Not Available"
    fi
}

# Function to get GPU information
get_gpu_info() {
    echo -e "${BLUE}GPU Information:${NC}"
    if command_exists lspci; then
        # Filter for VGA, 3D, or display controllers
        GPU_INFO=$(lspci | grep -i -E 'VGA|3D|Display')
        if [ -n "$GPU_INFO" ]; then
            echo "$GPU_INFO"
        else
            echo "No GPU information found."
        fi
    else
        echo "GPU information not available (lspci command not found)."
    fi
}

# Function to get CPU information
get_cpu_info() {
    echo -e "${BLUE}CPU Information:${NC}"
    if [[ "$OS_NAME" == "Darwin" ]]; then
        if command_exists sysctl; then
            sysctl -n machdep.cpu.brand_string
        else
            echo "Unknown CPU Information"
        fi
    elif [[ "$OS_NAME" == "Linux" ]]; then
        if [ -f /proc/cpuinfo ]; then
            grep 'model name' /proc/cpuinfo | uniq | awk -F ': ' '{print $2}'
        else
            echo "Unknown CPU Information"
        fi
    else
        echo "Unknown CPU Information"
    fi
}

# Function to get number of CPU cores
get_cpu_cores() {
    CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")
    echo -e "${BLUE}CPU Cores:${NC} $CPU_CORES"
}

# Function to get disk usage
get_disk_usage() {
    echo -e "${BLUE}Disk Usage:${NC}"
    # Display disk usage without using 'column'
    # Exclude tmpfs and udev for Linux; adjust as needed for other OSes
    if [[ "$OS_NAME" == "Linux" ]]; then
        df -h --exclude-type=tmpfs --exclude-type=udev | awk 'NR==1 || /\/$/' 
    else
        df -h
    fi
}

# ==============================
#      Main Execution
# ==============================

# Parse command-line arguments
QUIET=false

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -h, --help      Show this help message and exit"
            echo "  -q, --quiet     Run script in quiet mode (no colors)"
            echo ""
            echo "Examples:"
            echo "  $0               Display system information with colors"
            echo "  $0 --help        Show help message"
            echo "  $0 --quiet       Display system information without colors"
            exit 0
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

# If quiet mode, disable colors
if $QUIET; then
    GREEN=''
    BLUE=''
    RED=''
    NC=''
fi

# Display system information
echo -e "${GREEN}==============================${NC}"
echo -e "${GREEN}       System Information    ${NC}"
echo -e "${GREEN}==============================${NC}"

get_os_type
get_os_version
get_cpu_arch
get_cpu_info
get_cpu_cores
get_total_memory
get_memory_info
get_hostname
get_kernel_version
get_uptime
get_network_info
get_gpu_info
echo ""
get_disk_usage
echo -e "${GREEN}==============================${NC}"
