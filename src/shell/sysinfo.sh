#!/bin/bash

# sysinfo.sh
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
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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

# Function to print messages based on verbosity
log() {
    local level=$1
    local message=$2
    if [ "$VERBOSE" = true ]; then
        case $level in
            "warning")
                echo -e "${YELLOW}$message${NC}"
                ;;
            "error")
                echo -e "${RED}$message${NC}" >&2
                ;;
        esac
    fi
}

# Function to display help message
show_help() {
    echo -e "${CYAN}Usage: luka sysinfo [options]${NC}"
    echo ""
    echo "Options:"
    echo "  -h, --help            Show this help message and exit"
    echo "  -q, --quiet           Run script in quiet mode (no colors)"
    echo "  -v, --verbose         Display detailed information"
    echo ""
    echo "Examples:"
    echo "  luka sysinfo -v"
    exit 0
}

# ==============================
#      System Information Functions
# ==============================

# Function to get OS type
get_os_type() {
    OS_NAME=$(uname -s)
    case "$OS_NAME" in
        Darwin)
            OS_TYPE="macOS"
            ;;
        Linux)
            OS_TYPE="Linux"
            ;;
        *)
            OS_TYPE="$OS_NAME"
            ;;
    esac
    log "info" "Operating System: $OS_TYPE"
}

# Function to get OS version
get_os_version() {
    if [[ "$OS_TYPE" == "macOS" ]]; then
        if command_exists sw_vers; then
            OS_VERSION=$(sw_vers -productVersion)
        else
            OS_VERSION="Unknown"
        fi
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS_VERSION="$PRETTY_NAME"
        else
            OS_VERSION="Unknown"
        fi
    else
        OS_VERSION="Unknown"
    fi
    log "info" "OS Version: $OS_VERSION"
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
    log "info" "CPU Architecture: $CPU_ARCH"
}

# Function to get hostname
get_hostname_info() {
    HOSTNAME_INFO=$(hostname)
    log "info" "Hostname: $HOSTNAME_INFO"
}

# Function to get kernel version
get_kernel_version_info() {
    KERNEL_VERSION=$(uname -r)
    log "info" "Kernel Version: $KERNEL_VERSION"
}

# Function to get memory information
get_memory_info() {
    if [[ "$OS_TYPE" == "macOS" ]]; then
        # Get free memory in MB
        MEMORY_FREE_PAGES=$(vm_stat | awk '/Pages free:/ {print $3}' | sed 's/\.//')
        MEMORY_FREE_MB=$((MEMORY_FREE_PAGES * 4096 / 1024 / 1024))
        FREE_MEMORY="${MEMORY_FREE_MB} MB"

        # Get total memory
        MEMORY_TOTAL_BYTES=$(sysctl -n hw.memsize)
        MEMORY_TOTAL_MB=$((MEMORY_TOTAL_BYTES / 1024 / 1024))
        TOTAL_MEMORY="${MEMORY_TOTAL_MB} MB"
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        MEMORY_FREE=$(free -m | awk '/Mem:/ { print $4 " MB"}')
        FREE_MEMORY="$MEMORY_FREE"

        MEMORY_TOTAL=$(free -m | awk '/Mem:/ { print $2 " MB"}')
        TOTAL_MEMORY="$MEMORY_TOTAL"
    else
        FREE_MEMORY="Unknown"
        TOTAL_MEMORY="Unknown"
    fi
    log "info" "Total Memory: $TOTAL_MEMORY"
    log "info" "Free Memory: $FREE_MEMORY"
}

# Function to get system uptime
get_uptime_info() {
    UPTIME=$(uptime -p 2>/dev/null || uptime | awk -F'( |,|:)+' '{print $6,$7,$8}')
    log "info" "System Uptime: $UPTIME"
}

# 以下の詳細情報取得関数も verbose モードでのみ実行されるようにします

get_network_info_func() {
    if [ "$VERBOSE" = true ]; then
        declare -A NETWORK
        if [[ "$OS_TYPE" == "macOS" ]]; then
            while read -r iface ip; do
                NETWORK["$iface"]="$ip"
            done < <(ifconfig | grep 'inet ' | awk '{print $1, $2}')
        elif [[ "$OS_TYPE" == "Linux" ]]; then
            while read -r iface ip; do
                NETWORK["$iface"]="$ip"
            done < <(ip -o -4 addr list up | awk '{print $2, $4}' | cut -d/ -f1)
        fi

        NETWORK_INFO=""
        for iface in "${!NETWORK[@]}"; do
            NETWORK_INFO+="Network.$iface.IP=\"${NETWORK[$iface]}\"\n"
            log "info" "Network Interface: $iface - IP: ${NETWORK[$iface]}"
        done
    fi
}

get_gpu_info_func() {
    if [ "$VERBOSE" = true ]; then
        if command_exists lspci; then
            GPU_DEVICES=$(lspci | grep -i -E 'VGA|3D|Display')
            if [ -n "$GPU_DEVICES" ]; then
                GPU_INFO=$(echo "$GPU_DEVICES" | awk '{print "GPU.Device=\"" $0 "\""}')
                log "info" "GPU Device: $GPU_DEVICES"
            else
                GPU_INFO="GPU.Device=\"No GPU information found.\""
                log "info" "GPU Information: No GPU information found."
            fi
        else
            GPU_INFO="GPU.Device=\"GPU information not available (lspci command not found).\""
            log "info" "GPU Information: lspci command not found."
        fi

        if command_exists nvidia-smi; then
            NVIDIA_INFO=$(nvidia-smi --query-gpu=name,driver_version,memory.total,memory.used,memory.free --format=csv,noheader,nounits | awk -F', ' '
                {
                    print "GPU.NVIDIA." NR ".Name=\"" $1 "\""
                    print "GPU.NVIDIA." NR ".Driver_Version=\"" $2 "\""
                    print "GPU.NVIDIA." NR ".Memory_Total_MB=" $3
                    print "GPU.NVIDIA." NR ".Memory_Used_MB=" $4
                    print "GPU.NVIDIA." NR ".Memory_Free_MB=" $5
                }
            ')
            GPU_INFO+=$'\n'"$NVIDIA_INFO"
            log "info" "NVIDIA GPU Information:"
            log "info" "$NVIDIA_INFO"
        else
            log "info" "NVIDIA GPU Information: nvidia-smi not found."
        fi

        GPU_INFO_FINAL="$GPU_INFO"
    fi
}

get_cpu_info_func() {
    if [ "$VERBOSE" = true ]; then
        if [[ "$OS_TYPE" == "macOS" ]]; then
            if command_exists sysctl; then
                CPU_INFO=$(sysctl -n machdep.cpu.brand_string)
            else
                CPU_INFO="Unknown CPU Information"
            fi
        elif [[ "$OS_TYPE" == "Linux" ]]; then
            if [ -f /proc/cpuinfo ]; then
                CPU_INFO=$(grep 'model name' /proc/cpuinfo | uniq | awk -F ': ' '{print $2}')
            else
                CPU_INFO="Unknown CPU Information"
            fi
        else
            CPU_INFO="Unknown CPU Information"
        fi
        log "info" "CPU Information: $CPU_INFO"
    fi
}

get_cpu_cores_func() {
    if [ "$VERBOSE" = true ]; then
        CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")
        log "info" "CPU Cores: $CPU_CORES"
    fi
}

get_disk_usage_func() {
    if [ "$VERBOSE" = true ]; then
        if [[ "$OS_TYPE" == "Linux" ]]; then
            DISK_USAGE=$(df -h --output=source,fstype,size,used,avail,pcent,target | grep -E 'Filesystem|/dev/sd|/dev/nvme|/')
        elif [[ "$OS_TYPE" == "macOS" ]]; then
            DISK_USAGE=$(df -h)
        else
            DISK_USAGE=$(df -h)
        fi

        DISK_INFO=""
        while read -r line; do
            if [[ $line == Filesystem* ]]; then
                continue
            fi
            set -- $line
            DISK_INFO+="Disk.$1.Type=\"$2\"\n"
            DISK_INFO+="Disk.$1.Size=\"$3\"\n"
            DISK_INFO+="Disk.$1.Used=\"$4\"\n"
            DISK_INFO+="Disk.$1.Available=\"$5\"\n"
            DISK_INFO+="Disk.$1.UsePercent=\"$6\"\n"
            DISK_INFO+="Disk.$1.Mounted_on=\"$7\"\n"
            log "info" "Disk: $1 - Type: $2, Size: $3, Used: $4, Available: $5, Use%: $6, Mounted on: $7"
        done <<< "$DISK_USAGE"
    fi
}

get_installed_software_versions() {
    if [ "$VERBOSE" = true ]; then
        declare -A SOFTWARE
        SOFTWARE["bash"]=$(bash --version | head -n1 | awk '{print $4}')
        if command_exists python3; then
            SOFTWARE["python3"]=$(python3 --version 2>&1 | awk '{print $2}')
        else
            SOFTWARE["python3"]="Not Installed"
        fi
        if command_exists git; then
            SOFTWARE["git"]=$(git --version | awk '{print $3}')
        else
            SOFTWARE["git"]="Not Installed"
        fi
        if command_exists docker; then
            SOFTWARE["docker"]=$(docker --version | awk '{print $3}' | sed 's/,//')
        else
            SOFTWARE["docker"]="Not Installed"
        fi

        SOFTWARE_INFO=""
        for key in "${!SOFTWARE[@]}"; do
            SOFTWARE_INFO+="Software.$key.Version=\"${SOFTWARE[$key]}\"\n"
            log "info" "Installed Software: $key - Version: ${SOFTWARE[$key]}"
        done
    fi
}

# ==============================
#      Main Execution
# ==============================

# Default options
VERBOSE=false

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            show_help
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
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
if [ "$QUIET" = true ]; then
    GREEN=''
    BLUE=''
    RED=''
    YELLOW=''
    CYAN=''
    NC=''
fi

# Gather system information
get_os_type
get_os_version
get_cpu_arch
get_hostname_info
get_kernel_version_info
get_memory_info
get_uptime_info

# Gather extended information if verbose
if [ "$VERBOSE" = true ]; then
    get_memory_info
    get_uptime_info
    get_network_info_func
    get_gpu_info_func
    get_cpu_info_func
    get_cpu_cores_func
    get_disk_usage_func
    get_installed_software_versions
else
    get_memory_info
    get_uptime_info
fi

# Prepare key=value pairs
SYSTEM_INFO=""
SYSTEM_INFO+="Operating_System=\"$OS_TYPE\"\n"
SYSTEM_INFO+="OS_Version=\"$OS_VERSION\"\n"
SYSTEM_INFO+="CPU_Architecture=\"$CPU_ARCH\"\n"

if [ "$VERBOSE" = true ]; then
    SYSTEM_INFO+="CPU_Information=\"$CPU_INFO\"\n"
    SYSTEM_INFO+="CPU_Cores=\"$CPU_CORES\"\n"
    SYSTEM_INFO+="Total_Memory=\"$TOTAL_MEMORY\"\n"
    SYSTEM_INFO+="Free_Memory=\"$FREE_MEMORY\"\n"
    SYSTEM_INFO+="Hostname=\"$HOSTNAME_INFO\"\n"
    SYSTEM_INFO+="Kernel_Version=\"$KERNEL_VERSION\"\n"
    SYSTEM_INFO+="System_Uptime=\"$UPTIME\"\n"
    SYSTEM_INFO+="$NETWORK_INFO"
    SYSTEM_INFO+="$GPU_INFO_FINAL\n"
    SYSTEM_INFO+="$DISK_INFO"
    SYSTEM_INFO+="$SOFTWARE_INFO"
else
    SYSTEM_INFO+="Total_Memory=\"$TOTAL_MEMORY\"\n"
    SYSTEM_INFO+="Free_Memory=\"$FREE_MEMORY\"\n"
    SYSTEM_INFO+="System_Uptime=\"$UPTIME\"\n"
fi

# Function to output in text format
output_text() {
    echo -e "${GREEN}==============================${NC}"
    echo -e "${GREEN}       System Information    ${NC}"
    echo -e "${GREEN}==============================${NC}"

    if [ "$VERBOSE" = true ]; then
        echo -e "$SYSTEM_INFO" | while IFS='=' read -r key value; do
            formatted_key=$(echo "$key" | sed -E 's/^([^.]*)\.(.*)$/\1: \2/')
            echo -e "${BLUE}${formatted_key}:${NC} $value"
        done
    else
        echo -e "Operating System: $OS_TYPE"
        echo -e "OS Version: $OS_VERSION"
        echo -e "CPU Architecture: $CPU_ARCH"
        echo -e "Hostname: $HOSTNAME_INFO"
        echo -e "Kernel Version: $KERNEL_VERSION"
    fi

    echo -e "${GREEN}==============================${NC}"
}

# Display system information in text format
output_text
