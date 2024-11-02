#!bin/bash
# func.bashrc
# author  : github.com/rxxuzi
# license : cc0

# lpath function for PATH management
lpath() {
    local num_args=$#
    if [ "$num_args" -lt 1 ]; then
        echo "Usage:"
        echo "  lpath += <path>    : Add a new path to PATH (temporary)"
        echo "  lpath ++= <path>   : Add a new path to PATH (persistent)"
        echo "  lpath -= <path>    : Remove a path from PATH"
        echo "  lpath !            : Clean up duplicate paths in PATH"
        echo "  lpath list         : List all paths in PATH"
        echo "  lpath help         : Show this help message"
        return 1
    fi

    local action="$1"
    local path="$2"
    local shell_profile

    # Determine the shell profile file based on the shell type
    if [ -n "$BASH_VERSION" ]; then
        shell_profile="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_profile="$HOME/.zshrc"
    else
        shell_profile="$HOME/.profile"
    fi

    case "$action" in
        "+="|"add")
            if [ -z "$path" ]; then
                echo "Error: No path provided for 'add' command."
                echo "Usage: lpath += <path> or lpath add <path>"
                return 1
            fi
            local abs_path
            abs_path=$(realpath -m "$path")
            if echo ":$PATH:" | grep -q ":$abs_path:"; then
                echo "Path already exists: $abs_path"
            else
                export PATH="$PATH:$abs_path"
                echo "Path added temporarily: $abs_path"
            fi
            ;;
        "++="|"addp")
            if [ -z "$path" ]; then
                echo "Error: No path provided for '++=' command."
                echo "Usage: lpath ++= <path>"
                return 1
            fi
            local abs_persistent_path
            abs_persistent_path=$(realpath -m "$path")
            if echo ":$PATH:" | grep -q ":$abs_persistent_path:"; then
                echo "Path already exists in PATH: $abs_persistent_path"
            else
                export PATH="$PATH:$abs_persistent_path"
                echo "Path added temporarily: $abs_persistent_path"
            fi

            # Check if the path is already in the shell profile
            if grep -Fxq "export PATH=\"\$PATH:$abs_persistent_path\"" "$shell_profile"; then
                echo "Path already exists in $shell_profile"
            else
                echo "" >> "$shell_profile"
                echo "# Added by lpath ++= command" >> "$shell_profile"
                echo "export PATH=\"\$PATH:$abs_persistent_path\"" >> "$shell_profile"
                echo "Path added persistently to $shell_profile: $abs_persistent_path"
            fi
            ;;
        "-="|"remove"|"del")
            if [ -z "$path" ]; then
                echo "Error: No path provided for 'remove' command."
                echo "Usage: lpath -= <path> or lpath remove <path> or lpath del <path>"
                return 1
            fi
            local abs_remove
            abs_remove=$(realpath -m "$path")
            PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^$abs_remove$" | paste -sd ':' -)
            export PATH
            echo "Path removed: $abs_remove"

            # Remove from shell profile if present
            if grep -Fxq "export PATH=\"\$PATH:$abs_remove\"" "$shell_profile"; then
                sed -i.bak "\|export PATH=\"\$PATH:$abs_remove\"|d" "$shell_profile"
                echo "Path removed from $shell_profile: $abs_remove"
            fi
            ;;
        "!")
            PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | paste -sd ':' -)
            export PATH
            echo "PATH has been cleaned up. Duplicates removed."
            ;;
        "list"|"-l")
            echo "PATH Entries:"
            IFS=':' read -ra ADDR <<< "$PATH"
            for i in "${!ADDR[@]}"; do
                printf "%d. %s\n" $((i+1)) "${ADDR[i]}"
            done
            ;;
        "help"|"--help"|"-h")
            echo "Usage:"
            echo "  lpath +=  <path>   : Add a new path to PATH (temporary)"
            echo "  lpath ++= <path>   : Add a new path to PATH (persistent)"
            echo "  lpath -=  <path>   : Remove a path from PATH"
            echo "  lpath !            : Clean up duplicate paths in PATH"
            echo "  lpath list         : List all paths in PATH"
            echo "  lpath help         : Show this help message"
            return 0
            ;;
        *)
            echo "Unknown command: $action"
            echo "Use 'lpath help' to see available commands."
            return 1
            ;;
    esac
}
