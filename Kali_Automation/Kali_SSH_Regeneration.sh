#!/bin/bash

# ============================================================ #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# << --- Kali SSH Regeneration ---
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# ============================================================ #

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# --- Script Header ---
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Summary --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# --Synopsis--
# Regenerate the SSH keys on a Kali Linux system.

# --Description--
# This script will regenerate the SSH keys on a Kali Linux system.
# This is useful if the keys have been compromised or if you are setting up a new system.

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Contact Information --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Kali Update and Upgrade
# Written by Ghost_Glitch
# Written on 22APR2025

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Version Control --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# 0001 - Initial Version - Ghost_Glitch - 22APR2025

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Debugging --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# --Troubleshooting --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# --- Functions ---
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Print Status in Color --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to show colored output and progress.
print_status() {
    local color_green="\033[0;32m"
    local color_yellow="\033[0;33m"
    local color_reset="\033[0m"
    
    case "$1" in
        "info") echo -e "${color_green}[INFO]${color_reset} $2" ;;
        "warn") echo -e "${color_yellow}[WARN]${color_reset} $2" ;;
        *) echo "$2" ;;
    esac

} # End of function "print_status".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Check Root --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to check if the script is run as root.
check_root() {

    # EUID stands for "Effective User ID".
    # EUID 0 is always the Root user.
    if [ "$EUID" -ne 0 ]; then

        # Announce that the scipt must run as root.
        print_status "warn" "Please run this script as root (sudo)." >&2

        # Exit the script with error code 1.        
        exit 1

    fi # End of If statement.

} # End of function "check_root".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Handle Error --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Error handling function.
# This function checks the exit code of the last command and prints a warning message if it failed.
handle_error() {

    # Get the exit code of the last command.
    local exit_code=$?

    # Get the command that was run.
    local command=$1
    
    # Check if the exit code is not zero (indicating an error).
    if [ $exit_code -ne 0 ]; then

        # Print a warning message with the command and exit code.
        print_status "warn" "Error: Command '$command' failed with exit code $exit_code"
        
        # Return 1 to indicate an error.
        return 1

    # End of the If statement.
    else

        # Print a success message
        print_status "info" "Command '$command' executed successfully."

    # End of the Else statement.    
    fi

    # Return 0 to indicate success
    return 0

} # End of function "handle_error".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# --Show SSH Keys--
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to display SSH keys.
show_ssh_keys() {

    # Announce that the script is displaying the current SSH keys.
    print_status "info" "Displaying current SSH keys..."

    # Check if the SSH keys exist and display them.
    # If a fil is found in the directory "/etc/ssh/ssh_host_*_key", display the key.
    # If no file is found, display a warning message.
    for key in /etc/ssh/ssh_host_*_key; do

        # Check if the key file exists.
        if [ -f "$key" ]; then

            # Display the key file name and its contents.
            print_status "info" "Key: $key"

            # Use 'sudo' to read the key file as it may require root permissions.
            ssh-keygen -lf "$key"

            # Print a blank line for better readability.
            print_status "info"  ""

        # If the key file does not exist, print a warning message.
        else

            # Print a warning message indicating that the key was not found.
            print_status "warn" "No key found: $key"
        
        # End of If statement.
        fi
    
    # End of For loop.
    done

} # End of function "show_ssh_keys".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# --Regenerate SSH Keys--
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to regenerate SSH keys.
regenerate_ssh_keys() {

    # Announce that the script is regenerating SSH keys for security.
    print_status "info" "Regenerating SSH keys for security..."

    # Stop the SSH service before regenerating keys.
    sudo systemctl stop ssh
    if ! handle_error "systemctl stop ssh"; then
        print_status "warn" "Failed to stop SSH service. Aborting."
        return 1
    fi

    # Backup existing SSH keys.
    # Create a backup directory for SSH keys.
    sudo mkdir -p /etc/ssh/backup_keys
    if ! handle_error "mkdir -p /etc/ssh/backup_keys"; then
        print_status "warn" "Failed to create backup directory. Restarting SSH and aborting."
        sudo systemctl start ssh
        return 1
    fi

    # Backup existing SSH keys with timestamp.
    backup_dir="/etc/ssh/backup_keys/$(date +%Y%m%d%H%M%S)"
    sudo mkdir -p "$backup_dir"
    sudo cp /etc/ssh/ssh_host_* "$backup_dir/"
    if ! handle_error "backup keys"; then
        print_status "warn" "Failed to backup SSH keys. Restarting SSH and aborting."
        sudo systemctl start ssh
        return 1
    fi

    # Generate new SSH keys (RSA, DSA, ECDSA, ED25519).
    sudo ssh-keygen -A
    if ! handle_error "ssh-keygen -A"; then
        print_status "warn" "Failed to generate SSH keys. Restoring from backup and restarting SSH."
        sudo cp "$backup_dir"/* /etc/ssh/
        sudo systemctl start ssh
        return 1
    fi

    # Start the SSH service after new keys have been generated.
    sudo systemctl start ssh
    if ! handle_error "systemctl start ssh"; then
        print_status "warn" "Failed to start SSH service. Please check the SSH configuration."
        return 1
    fi

    # Announce that the SSH keys have been regenerated and the SSH service has been restarted.
    print_status "info" "New SSH keys have been generated and the SSH service has been restarted."

    # Announce that the have been backed up.
    print_status "info" "Backup of old keys saved to $backup_dir"

} # End of function "regenerate_ssh_keys".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# --End Statement--
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to display a completion message.
end_statement() {

    # Announce that the script has completed.
    print_status "info" "SSH keys have been regenerated."

} # End of function "end_statement".


# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# --Cleanup Handler--
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to handle script interruption and ensure SSH service is running
cleanup() {
    print_status "warn" "Script interrupted. Ensuring SSH service is running..."
    sudo systemctl start ssh
    print_status "info" "SSH service status: $(systemctl is-active ssh)"
    exit 1
}

# Set trap for Ctrl+C and other termination signals
trap cleanup INT TERM


# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# --Main Script Execution--
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Main script execution.
main() {
    check_root
    show_ssh_keys
    regenerate_ssh_keys
    show_ssh_keys
    end_statement

} # End of function "main".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# --End of Script--
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Run the main function.
main

# Exit the script once it has completed.
exit 0