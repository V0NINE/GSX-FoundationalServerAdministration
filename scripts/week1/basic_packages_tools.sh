!/bin/bash

PACKAGES_LIST = [git, vim, ssh] # Basic packages and tools, (maybe add gcc/clang)
PACKAGES_CONFIG_LIST = [config_git, config_vim, config_ssh] # functions that set up configuration for each package

config_git() {
    echo "Configuring git..."
}

config_vim() {
    echo "Configuring vim..."
}

config_ssh() {
    echo "Configuring ssh..."
}
