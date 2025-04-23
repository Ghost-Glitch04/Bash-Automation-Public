#!/bin/bash

# ============================================================ #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# << ---Kali Update and Upgrade ---
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# ============================================================ #

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# ---Script Header ---
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Summary --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# --Synopsis--
# Short script to update and upgrade Kali Linux.
#
# --Description--
# This script will update and upgrade Kali Linux. Then will also remove any unnecessary packages.
# Used to test CURL commands and connectivity to github.

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

# 0001 - Uncomment the line 1 Shebang. - Ghost_Glitch - 06OCT2024

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# --Troubleshooting --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# In the Event that you run into problems during updates, try the following:
# sudo dpkg --configure -a
# sudo apt -fix-broken install -y



# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# --- Functions ---
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Check Root --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to check if the script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root (sudo)." >&2

        
        exit 1
    fi

} # End of function "check_root".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Auto Restart Services --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to configure automatic service restarts
auto_restart_services() {
    echo "Configuring system to automatically restart services during upgrades..."

    # Install debconf-utils if not already installed
    sudo apt-get install -y debconf-utils

    # Write the setting to automatically restart services without asking
    echo "* libraries/restart-without-asking boolean true" | sudo debconf-set-selections

} # End of function "auto_restart_services".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Update and Upgrade --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to update and upgrade the system
update_and_upgrade() {
    echo "Updating and upgrading the system..."
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get full-upgrade -y

} # End of function "update_and_upgrade".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Perform Dist Upgrade --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to perform dist-upgrade
perform_dist_upgrade() {
    print_status "info" "Performing distribution upgrade (more aggressive)..."
    sudo apt-get dist-upgrade -y

} # End of function "perform_dist_upgrade".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Fix Missing Dependencies --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to fix any broken dependencies.
fix_dependencies() {
    echo "Checking and fixing any missing dependencies..."
    sudo apt-get install -f -y

} # End of function "fix_dependencies".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Fix Broken Packages --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to fix broken packages.
fix_packages() {
    echo "Checking and fixing any broken packages..."
    sudo dpkg --configure -a
    sudo apt update && sudo apt --fix-broken install && sudo apt upgrade -y

} # End of function "fix_packages".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- cleanup_packages --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to clean up the system.
cleanup_packages() {
    echo "Cleaning up unnecessary packages..."

    # Remove packages that were automatically installed but are no longer required.
    sudo apt-get autoremove -y

    # Clean up the local repository of retrieved package files.
    sudo apt-get clean

    # Find and report orphaned packages (but don't remove them automatically).
    print_status "info" "Checking for orphaned packages..."
    orphaned=$(dpkg -l | grep "^rc" | awk '{print $2}')
    
    if [ -n "$orphaned" ]; then
        print_status "warn" "Found orphaned packages configuration files:"
        echo "$orphaned"
        print_status "info" "To remove these configuration files, run: sudo dpkg --purge \$(dpkg -l | grep '^rc' | awk '{print \$2}')"
    else
        print_status "info" "No orphaned package configurations found."
    fi

} # End of function cleanup_packages.

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- End Statement --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to display a completion message.
end_statement() {
    echo "System has been updated and upgraded."

} # End of function "end_statement".

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# --- Code Flow ---
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Main Script Execution --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Main script execution.
main() {
    check_root
    auto_restart_services
    update_and_upgrade
    # Uncomment the line below if you want to always perform dist-upgrade
    # perform_dist_upgrade
    fix_dependencies
    fix_packages
    cleanup_packages
    end_statement

} # End of "main" function.

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Call Main Function --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Run the main function.
main

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- End of Script --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Exit the script once it has completed.
exit 0