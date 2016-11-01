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
    echo ERROR: $@
}

warn() {
    echo WARNING $@
}

info() {
    echo INFO $@
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


VERBOSE=0
LIST_MODULES=0

while getopts ":vhe:fl" opt; do
    case "$opt" in
    v) VERBOSE=1 ;;
    h) usage ; exit 0 ;;
    l) LIST_MODULES=1 ;;
    *)
        echo "ERROR: Invalid option -$OPTARG given"
        usage 
        exit 1
        ;;
    esac
done

shift $((OPTIND-1))

install_vimrc() {
    subcmd mkdir -p ~/.vim || error "Failed to create ~/.vim"
    if [ -f ~/.vim/headers ]; then
        error "~/.vim/headers already exists, skipping"
    else
        if subcmd ln -s "$(pwd)/vim_files/headers" "$HOME/.vim/headers"; then
            info "Created ~/.vim/headers"
        else
            error "Failed to create ~/.vim/headers"
        fi
    fi
    if [ -f ~/.vimrc ]; then
        error "~/.vimrc already exists, skipping"
    else
        if subcmd ln -s "$(pwd)/.vimrc" "$HOME/.vimrc"; then
            info "Created ~/.vimrc"
        else
            error "Failed to create ~/.vimrc"
        fi
    fi
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

modules_all="vimrc bashrc"

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
