#!/usr/bin/env bash

set -euo pipefail

ROOT_PATH=$(
    set -e
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd
)

cd "${ROOT_PATH}"

source "./.functions"

linkFiles () {
    if [[ -L "${2}" ]]; then
        output_info "SKIP '${1}' -> symlink already exists in '${2}'"
        return 0;
    fi

    if [[ -d "${2}"  && ! -L "${2}" ]]; then
        read -p "Directory '${2}' already exists. Do you want to sync it and create symlink ?(y/n) " -n 1;
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rsync -ah "${2}" "$(dirname ${1})" --delete
            rm -rf "${2}"
        else
            return 0;
        fi
    fi

    if ln -snfT "${1}" "${2}"; then
        output_success "linked ${1} to ${2}"
    else
        output_error "linked ${1} to ${2}"
    fi
}

doIt () {
    # Create config files
    for file in $(find ${ROOT_PATH} \
        -maxdepth 1 \
        -name ".*" \
        -not -name ".gitignore" \
        -not -name ".extra" \
        -not -name ".gitconfig_private" \
        -not -name ".git" \
        -not -name ".idea" \
        -not -name ".local" \
        -not -name ".config" \
        -not -name "*.swp" \
        -not -path "*.gitmodules*" \
        -not -path "*.git/*")
    do
        linkFiles "${file}" "${HOME}/$(basename ${file})"
    done
    
    mkdir -p "${HOME}/.config/zellij"
    linkFiles "${ROOT_PATH}/.config/starship.toml" "${HOME}/.config/starship.toml"
    linkFiles "${ROOT_PATH}/.config/zellij/config.kdl" "${HOME}/.config/zellij/config.kdl"

    mkdir -p "${HOME}/.local/bin"
    for script in script/*
    do
        linkFiles "${ROOT_PATH}/${script}" "${HOME}/.local/bin/$(basename ${script})"
    done

    # Create private files if they do not exist
    for file in ".extra" ".gitconfig_private"
    do
        if [[ ! -f "${HOME}/${file}" ]]; then
            cp "${file}" "${HOME}"
            output_success "Create ${file} in home ${HOME}"
        else
            output_info "SKIP private file '${file}' -> already exists"
        fi
    done
}

if [[ "${1:-}" == "--force" || "${1:-}" == "-f" ]]; then
    doIt
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt
    fi
fi

unset doIt
