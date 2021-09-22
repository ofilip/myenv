#/bin/bash

trap interrupt_soft SIGINT SIGTERM SIGHUP
set -o nounset
set -o pipefail
# set -o xtrace

interrupt_soft() {
    trap interrupt_hard SIGINT SIGTERM SIGHUP ERR
    echo "*** INTERRUPTED ***"
    echo "Cleanup in progress (Ctrl+C to skip)"
    cleanup
    exit 1

}

interrupt_hard() {
    echo "*** INTERRUPTED ***"
    echo "Hard interruption, exiting..."
    exit 1
}

usage() {
    echo "$0 [-hv] [list of modules]"
    echo -e "  -v  Verbose."
    echo -e "  -h  Print help and exit"
}

error() {
    echo -e ERROR: $@
}

warn() {
    echo -e WARNING $@
}

info() {
    echo -e INFO $@
}

fail() {
    error $@
    echo "Known issues:"
    echo "  * There are no known issues at a time (feel free to update related section in the script)"
    [ "$VERBOSE" -eq 0 ] && echo "Try to rerun with -v to see more information"
    exit 1
}

subcmd() {
    if [ $VERBOSE -eq 1 ]; then
        echo "CMD $@"
        cmdName=$(basename $1)
        "$@" 2>&1 | sed -b "s|^|  $cmdName> |"
        res=${PIPESTATUS[0]}
    else
        "$@" &> /dev/null
        res=$?
    fi
    [ -z "$res" -o "$res" == "0" ]
}

cleanup() {
# CLEANUP CODE
    :
}


get_profile() {
    local result_var=$1
    if [ -z "$PROFILE" ]; then
        ok=
        while [ -z "$ok" ]; do
            echo -n "Choose profile ($VALID_PROFILES): "
            read profile
            for valid_profile in $VALID_PROFILES; do
                if [ "$profile" == "$valid_profile" ]; then
                    ok=1
                    break
                fi
            done
        done
        PROFILE=$profile
    fi
    eval $result_var=$PROFILE
}


VERBOSE=0
LIST_MODULES=0
PROFILE=  # do not access directly, use get profile

VALID_PROFILES="seznam private"

while getopts ":vhe:flp:" opt; do
    case "$opt" in
        v) VERBOSE=1 ;;
        h) usage ; exit 0 ;;
        p) 
            PROFILE="$OPTARG"
            profile_ok=0
            msg="Invalid profile given. Available profiles are:"
            for profile in $VALID_PROFILES; do
                msg="\n${msg}- $profile"
                if [ "$PROFILE" == "$profile" ]; then
                    profile_ok=1
                fi
            done
            if [ $profile_ok == 0 ]; then
                fail "$msg"
            fi
            ;;
        l) LIST_MODULES=1 ;;
        *)
            echo "ERROR: Invalid option -$OPTARG given"
            usage 
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

pathogen_url=https://github.com/tpope/vim-pathogen
vim_plugins=(
    https://github.com/tpope/vim-sensible
    https://github.com/nvie/vim-flake8
)


install_vimrc() {
    subcmd mkdir -p ~/.vim || error "Failed to create ~/.vim"
    if [ -e ~/.vim/headers ]; then
        # TODO check if link leads where it is supposed to lead
        warn "~/.vim/headers already exists, skipping"
    else
        if subcmd ln -s "$(pwd)/vim_files/headers" "$HOME/.vim/headers"; then
            info "Created ~/.vim/headers"
        else
            error "Failed to create ~/.vim/headers"
        fi
    fi

    if [ -e ~/.vimrc ]; then
        # TODO
        warn "~/.vimrc already exists, skipping"
    else
        if subcmd ln -s "$(pwd)/.vimrc" "$HOME/.vimrc"; then
            info "Created ~/.vimrc"
        else
            error "Failed to create ~/.vimrc"
        fi
    fi

    [ -d vim_files/vim-pathogen ] || subcmd git clone $pathogen_url vim_files/vim-pathogen \
        || { error "Can't get pathogen"; break; }
    subcmd mkdir -p ~/.vim/autoload || { error "Cant' create ~/.vim/autoload"; break; }
    subcmd mkdir -p ~/.vim/bundle || { error "Cant' create ~/.vim/bundle"; break; }
    pathogen_dest="$(pwd)/vim_files/vim-pathogen/autoload/pathogen.vim"
    pathogen_link="$HOME/.vim/autoload/pathogen.vim"
    [ -e "$pathogen_link" ] || subcmd ln -s "$pathogen_dest" "$pathogen_link" \
        || { error "Can't link pathogen"; break; }
    for plugin_url in ${vim_plugins[@]}; do
        basedir=$(basename plugin_url)
        fulldir="$(pwd)/vim_files/bundle/$basedir"
        [ -e "$fulldir" ] || subcmd git clone $plugin_url "$fulldir"
    done
}

install_bashrc() {
    filename="$(pwd)/bashrc_common"
    include_command="source $filename"
    if grep -q -e "$include_command" ~/.bashrc; then
        info "bashrc_common already referenced"
    else
        if echo "$include_command" >> ~/.bashrc; then
            info "bashrc_common installed"
        else
            error "Failed to append to ~/.bashrc"
        fi
    fi
}

install_zshrc() {
    filename="$(pwd)/zshrc_common"
    include_command="source $filename"
    if grep -q -e "$include_command" ~/.zshrc; then
        info "zshrc_common already referenced"
    else
        if echo "$include_command" >> ~/.zshrc; then
            info "zshrc_common installed"
        else
            error "Failed to append to ~/.zshrc"
        fi
    fi
}

install_git() {
    get_profile profile
    source git_config/common.sh
    source git_config/$profile.sh
}

modules_all="vimrc bashrc git zshrc"

list_modules() {
    echo "Available modules are:"
    for module in $modules_all; do
        echo " - $module"
    done
}

if [ $LIST_MODULES -eq 1 ]; then
    list_modules
    exit 1
fi

if [ $# -ge 1 ]; then
    for module in $@; do
        found=0
        for present_module in $modules_all; do
            if [ "$module" == "$present_module" ]; then
                found=1
                break
            fi
        done
        if [ $found -eq 0 ]; then
            fail "No such module: $module"
            list_modules
        else
            modules="$modules $module"
        fi
    done
    modules="$@"

else
    modules="$modules_all"
fi

for module in $modules; do
    info "Installing $module..."
    cmd="install_$module"
    $cmd
done


cleanup
echo "SUCCESS: Script exited correctly"
exit 0
