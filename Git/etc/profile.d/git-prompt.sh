if test -f /etc/profile.d/git-sdk.sh; then
    TITLEPREFIX=SDK-${MSYSTEM#MINGW}
else
    TITLEPREFIX=$MSYSTEM
fi

if test -f ~/.config/git/git-prompt.sh; then
    . ~/.config/git/git-prompt.sh
else
    # PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]' 	# set window title
    PS1='\[\033]0;bash:$PWD\007\]' # set window title

    PS1="$PS1"'\[\033[0m\]' # change color to white
    PS1="$PS1"' \u '        # user@host<space>

    PROMPT_DIRTRIM=1
    # PS1="$PS1"'\[\e[1;34;7m\] \w \[\e(B\e[m\]'	# current working directory
    PS1="$PS1"'\[\e[1;34;7m\] \W \[\e(B\e[m\]' # current working directory (short)

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
                PS1="$PS1"'\[\e[1;34m\]\[\e[m\]' # dir to branch
            else
                PS1="$PS1"'\[\e[1;34;42m\]\[\e[m\]'                   # dir to branch
                PS1="$PS1"'\[\e[32;7m\]  ${BRANCH:2:-1} \[\e(B\e[m\]' # bash function
                PS1="$PS1"'\[\033[32m\]'
            fi
        fi
    fi

    PS1="$PS1"'\n' # new line
    git_diff_icon() {
        if git rev-parse --git-dir >/dev/null 2>&1; then
            color=""
            if git diff --quiet 2>/dev/null >&2; then
                gitstatus=$(git status 2>/dev/null | tail -n1)
                if [ "$gitstatus" == "nothing to commit, working tree clean" ]; then
                    color='\033[1;32m'
                else
                    color='\033[1;33m'
                fi
            else
                color='\033[1;31m'
            fi
        else
            return 0
        fi
        echo -ne $color
    }

    PS1="$PS1"'$(git_diff_icon)\[\e[m\] ' # prompt: 
    PS1="$PS1"'\[\033[0m\]'                  # change color to white
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
