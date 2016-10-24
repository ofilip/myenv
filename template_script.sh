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
    echo "$0 [-hvf] [-e TEXT]"
    echo -e "  -v  Verbose."
    echo -e "  -h  Print help and exit"
    echo -e "  -e  Text to print (example flag)"
    echo -e "  -f  Demonstrate fail() capability (example flag)"
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
ECHO=
SHOW_FAIL=0

[ $# -gt 0 ] || { usage ; exit 0 ; }

while getopts ":vhe:f" opt; do
    case "$opt" in
    v) VERBOSE=1 ;;
    h) usage ; exit 0 ;;
    e) ECHO="$OPTARG" ;; # sample echo flag
    f) SHOW_FAIL=1 ;;
    *)
        echo "ERROR: Invalid option -$OPTARG given"
        usage 
        exit 1
        ;;
    esac
done


## MAIN PART  ##

subcmd seq 5 # Try -v to see command with its output
info $ECHO || fail "Echo failed"

if [ $SHOW_FAIL == 1 ]; then
    subcmd false || fail "false failed"
fi

################


cleanup
echo "SUCCESS: Script exited correctly"
exit 0
