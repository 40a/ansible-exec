#!/bin/bash

function usage {
    echo "Usage: $0 PLAYBOOK [ -i inventory ] [--VAR VALUE [...]] [ -- ANSIBLE-PLAYBOK_ARGS ]"
}

function get_arg {
    opt=$1
    shift
    if [ -z "$1" ]; then
        return 1
    fi
    echo $1
}

function args_error {
    echo "Option $1 requires an argument" >&2
    exit 1
}

if [ $# = 0 ]; then
    usage
    exit 0
fi

playbook=$1
playbook_dir=`dirname "$playbook"`
inventory="ansible_exec_dummy,"
ansible_playbook=ansible_playbook
ansible_args=()

shift
while [ -n "$1" ]; do
    case "$1" in
        --)
            shift
            ansible_args+=($@)
            break
            ;;
        -i)
            inventory=`get_arg "$@"` || args_error $1
            shift
            ;;
        --*)
            var=${1#--}
            value=`get_arg "$@"` || args_error $1
            ansible_args+=(-e "$var=\"$value\"")
            shift
            ;;
        *)
            echo "$0: Invalid argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

echo cd "$playbook_dir"
echo $ansible_playbook -i "$inventory" "$playbook" "${ansible_args[@]}"
