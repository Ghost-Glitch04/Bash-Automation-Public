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
# -- Print Status in Color --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to show colored output and progress
print_status() {
    local color_green="\033[0;32m"
    local color_yellow="\033[0;33m"
    local color_reset="\033[0m"
    
    case "$1" in
        "info") echo -e "${color_green}[INFO]${color_reset} $2" ;;
        "warn") echo -e "${color_yellow}[WARN]${color_reset} $2" ;;
        *) echo "$2" ;;
    esac
}

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Check Root --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to check if the script is run as root
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
# -- Auto Restart Services --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to configure automatic service restarts
auto_restart_services() {

    # Announce the system wil be configured with automatic service restarts.
    print_status "info" "Configuring system to automatically restart services during upgrades..."

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

    # Announce that the sysem will Update and Upgrade.
    print_status "info" "Updating and upgrading the system..."

    # Update and Upgrade
    # "upgrade" will perform on existing packages.
    sudo apt-get update && sudo apt-get upgrade -y

    # Full Upgrade
    # Full Upgrade will install new packages and resolve dependancies.
    sudo apt-get full-upgrade -y

} # End of function "update_and_upgrade".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Perform Dist Upgrade --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to perform dist-upgrade
perform_dist_upgrade() {

    # Announce a distribution upgrade.
    print_status "info" "Performing distribution upgrade (more aggressive)..."

    # Upgrade to the lastest Distro.
    sudo apt-get dist-upgrade -y

} # End of function "perform_dist_upgrade".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Fix Missing Dependencies --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to fix any broken dependencies.
fix_dependencies() {

    # Announce the system will check and fix any missing dependencies.
    print_status "info" "Checking and fixing any missing dependencies..."

    # Start the package management utility and fix broken dependencies.
    # -f is short for "--fix-broken"
    sudo apt-get install -f -y

} # End of function "fix_dependencies".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- Fix Broken Packages --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to fix broken packages.
fix_packages() {

    # Announce the system will check and fix any broken packages.
    print_status "info" "Checking and fixing any broken packages..."

    # Scans for packages that were interrupted during installation
    # Attempts to complete the configuration process for these packages
    # Does NOT install new packages or download missing dependencies
    # --configure is used to configure unpacked but unconfigured packages
    # -a is short for "--all"
    sudo dpkg --configure -a

    # Resolves dependency problems by installing missing dependencies
    # May remove problematic packages if necessary
    # Fixes the package database to ensure consistency
    sudo apt update && sudo apt --fix-broken install && sudo apt upgrade -y

} # End of function "fix_packages".

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- cleanup_packages --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to clean up the system.
cleanup_packages() {

    # Announce the clenaing up unnecessary packages.
    print_status "info" "Cleaning up unnecessary packages..."

    # Remove packages that were automatically installed but are no longer required.
    sudo apt-get autoremove -y

    # Clean up the local repository of retrieved package files.
    sudo apt-get clean

    # Find and report orphaned packages (but don't remove them automatically).
    print_status "info" "Checking for orphaned packages..."

    # List all packages that are no longer required and have been marked for removal.
    # The command "dpkg -l" lists all the installed packages recorded in the dpkg database.
    # The command "grep '^rc'" filters the list to show only packages that are marked as "rc" (removed but configuration files remain).
    # The command "awk '{print $2}'" extracts the second column of the output, which contains the package names.
    # The result is stored in the variable "orphaned".
    orphaned=$(dpkg -l | grep "^rc" | awk '{print $2}')
    
    # Detection of orphaned packages.
    if [ -n "$orphaned" ]; then

        # Announce that orphaned packages have been found.
        print_status "warn" "Found orphaned packages configuration files:"

        # Announce the list of orphaned packages.
        print_status "warn" "$orphaned"

        # Announce the next steps to remove orphaned packages.
        print_status "info" "To remove these configuration files, run: sudo dpkg --purge \$(dpkg -l | grep '^rc' | awk '{print \$2}')"

    # When no orphaned packages are found.
    else

        # Announce that no orphaned packages were found.
        print_status "info" "No orphaned package configurations found."

    fi # End of If/Else statement.

} # End of function cleanup_packages.

# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# -- End Statement --
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

# Function to display a completion message.
end_statement() {

    # Announce the script has completed.
    print_status "info" "System has been updated and upgraded."

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