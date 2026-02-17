!/bin/bash
# install_basic_setup.sh - Installation of basic packages and tools
#
# PURPOSE:
#   Install and configure basic packages and tools for users
#
# USAGE:
# ./install_basic_setup.sh
#
# EXIT CODES:
#   0 - Success
#   X - X installation/check failed

# DEBUG = 1

PACKAGES_LIST = [git, vim, ssh] # Basic packages and tools, (maybe add gcc/clang)

if [ "${DEBUG:-0}" -eq 1]; then
    set -x
fi

config_git() {
    echo "Configuring git..."
}

check_git() {
    git --version >/dev/null && echo "Git installed: $(git -version)" && return 1
    return 0
}

config_vim() {
    echo "Configuring vim..."
}

check_vim() {
    vim --version >/dev/null && "Git installed: $(vim --version)" && return 1
    return 0
}

config_ssh() {
    echo "Configuring ssh..."
}

# basic installation loop
# check if package installed, if not install and configure
# if installed do nothing
for p in PACKAGES_LIST do
    check_func = "check_$p"
    config_func = "config_$p"
    if ! $check_func; then
        echo "[Install]: Installing $p package"
        sudo apt install -y "$p"

        $config_func
    fi

fi

