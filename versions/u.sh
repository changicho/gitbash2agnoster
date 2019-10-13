if test -f /etc/profile.d/git-sdk.sh; then
    TITLEPREFIX=SDK-${MSYSTEM#MINGW}
else
    TITLEPREFIX=$MSYSTEM
fi

if test -f ~/.config/git/git-prompt.sh; then
    . ~/.config/git/git-prompt.sh
else
    PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]'           # set window title

    PS1="$PS1"'\[\033[0m\]' # change to white
    PS1="$PS1"' \u '                              # user@host<space>

    PS1="$PS1"'\[\e[34;7m\] \w \[\e(B\e[m\]'      # current working directory

    if test -z "$WINELOADERNOEXEC"; then
        GIT_EXEC_PATH="$(git --exec-path 2>/dev/null)"
        COMPLETION_PATH="${GIT_EXEC_PATH%/libexec/git-core}"
        COMPLETION_PATH="${COMPLETION_PATH%/lib/git-core}"
        COMPLETION_PATH="$COMPLETION_PATH/share/git/completion"
        if test -f "$COMPLETION_PATH/git-prompt.sh"; then
            . "$COMPLETION_PATH/git-completion.bash"
            . "$COMPLETION_PATH/git-prompt.sh"
            BRANCH=$(__git_ps1)

            if [ -z $BRANCH ]; then
                PS1="$PS1"'\[\e[34m\]\[\e[m\]'    # dir to branch
            else
                NEW_BRANCH=${BRANCH:2:-1}
                PS1="$PS1"'\[\e[34;42m\]\[\e[m\]'                # dir to branch
                PS1="$PS1"'\[\e[32;7m\]  $NEW_BRANCH \[\e(B\e[m\]' # bash function
                PS1="$PS1"'\[\033[32m\]'
            fi
        fi
    fi

    PS1="$PS1"'\n'             # new line
    PS1="$PS1"'\[\033[1;34m\]' # change to light blue
    PS1="$PS1"'\[\e[m\] '   # prompt: 
    PS1="$PS1"'\[\033[0m\]' # change to white
fi

MSYS2_PS1="$PS1" # for detection by MSYS2 SDK's bash.basrc

# Evaluate all user-specific Bash completion scripts (if any)
if test -z "$WINELOADERNOEXEC"; then
    for c in "$HOME"/bash_completion.d/*.bash; do
        # Handle absence of any scripts (or the folder) gracefully
        test ! -f "$c" ||
            . "$c"
    done
fi
