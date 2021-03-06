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

    if ln -snf "${1}" "${2}"; then
        output_success "linked ${1} to ${2}"
    else
        output_error "linked ${1} to ${2}"
    fi
}

doIt () {
    # Create config files
    for file in $(find $ROOT_PATH \
        -maxdepth 1 \
        -name ".*" \
        -not -name ".gitignore" \
        -not -name ".extra" \
        -not -name ".gitconfig_private" \
        -not -name ".git" \
        -not -name ".idea" \
        -not -name "*.swp" \
        -not -path "*.gitmodules*" \
        -not -path "*.git/*")
    do
        linkFiles "$file" "$HOME/$(basename $file)"
    done

    # Create private files if they do not exist
    for file in ".extra" ".gitconfig_private"
    do
        if [[ ! -f "$HOME/$file" ]]; then
            cp "$file" "$HOME"
            output_success "Create $file in home $HOME"
        else
            output_info "SKIP private file '$file' -> already exists"
        fi
    done

    # Install manpage
    if [[ ! -f /usr/local/share/man/man1/z.1 ]]; then
        sudo mkdir -p /usr/local/share/man/man1
        sudo cp z/z.1 /usr/local/share/man/man1
        sudo mandb

        output_success "Custom manpage installed"
    else
        output_info "SKIP custom manpage already installed"
    fi
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
