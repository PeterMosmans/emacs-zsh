# Emacs 23 daemon capability is a killing feature.
# One emacs process handles all your frames whether
# you use a frame opened in a terminal via a ssh connection or X frames
# opened on the same host.

# Benefits are multiple
# - You don't have the cost of starting Emacs all the time anymore
# - Opening a file is as fast as Emacs does not have anything else to do.
# - You can share opened buffered across opened frames.
# - Configuration changes made at runtime are applied to all frames.


if "$ZSH/tools/require_tool.sh" emacsclient 24 2>/dev/null ; then
    export EMACS_PLUGIN_LAUNCHER="$(dirname "$(readlink -f "$0")")/emacsclient.sh"

    # set EDITOR if not already defined.
    export EDITOR="${EDITOR:-${EMACS_PLUGIN_LAUNCHER}}"

    # if ZSH_EMACS_NOX is true (no X windows), use the -nw flag by default
    if [[ -z "$ZSH_EMACS_NOX" ]]; then
        alias emacs="$EMACS_PLUGIN_LAUNCHER --no-wait"
    else
        # open terminal emacsclient
        alias emacs="$EMACS_PLUGIN_LAUNCHER -nw"
    fi
    alias e=emacs
    # open terminal emacsclient
    alias te="$EMACS_PLUGIN_LAUNCHER -nw"

    # same than M-x eval but from outside Emacs.
    alias eeval="$EMACS_PLUGIN_LAUNCHER --eval"
    # create a new X frame
    alias eframe='emacsclient --alternate-editor "" --create-frame'


    # Write to standard output the path to the file
    # opened in the current buffer.
    function efile {
        local cmd="(buffer-file-name (window-buffer))"
        "$EMACS_PLUGIN_LAUNCHER" --eval "$cmd" | tr -d \"
    }

    # Write to standard output the directory of the file
    # opened in the the current buffer
    function ecd {
        local cmd="(let ((buf-name (buffer-file-name (window-buffer))))
                     (if buf-name (file-name-directory buf-name)))"

        local dir="$($EMACS_PLUGIN_LAUNCHER --eval $cmd | tr -d \")"
        if [ -n "$dir" ] ;then
            echo "$dir"
        else
            echo "can not deduce current buffer filename." >/dev/stderr
            return 1
        fi
    }
fi

## Local Variables:
## mode: sh
## End:
