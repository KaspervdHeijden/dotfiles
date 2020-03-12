#
# Populate the list for cds.
#
# @see cds()
#
repo_search()
{
    local target=/dev/tty;
    [ "${1}" = "-q" ] && target=/dev/null;

    echo 'Searching for repositories. Please hold...' >$target;
    find / -type d -name '.git' -and -not -wholename '*/vendor/*' $(printf "-and -not -wholename *%s* " $(cat "${DOTFILES_DIR}/repo-list/ignores.txt")) -print0 2>/dev/null | xargs -r0n1 dirname 2>/dev/null | tee "${DOTFILES_DIR}/repo-list/new.txt" >$target;
    [ -f "${DOTFILES_DIR}/repo-list/new.txt" ] && mv "${DOTFILES_DIR}/repo-list/new.txt" "${DOTFILES_DIR}/repo-list/repos.txt";
}

#
# Navigates to a repository with a name.
#
# cds [<partial-name>]
#
# View a list of all repositories by calling
# cds without arguments.
#
# If given, the parital name should uniquely
# identify a repository from this list.
#
# This method requires a list of repositories,
# which can be created using repo_search.
#
# @see repo_search
#
cds()
{
    [ -d "${1}" ] && cd "${1}" && return 0;
    if [ ! -f "${DOTFILES_DIR}/repo-list/repos.txt" ]; then
        echo 'No repository list found; please run repo-search and try again' >&2;
        return 1;
    fi

    [ -z "${1}" ] && cat "${DOTFILES_DIR}/repo-list/repos.txt" && return 0;

    local match=$(grep -ie "/[^/]*${1}[^/]*$" "${DOTFILES_DIR}/repo-list/repos.txt");
    if [ -z "${match}" ]; then
        echo 'No match found' >&2;
        return 2;
    fi

    [ -d "${match}" ] && cd "${match}" && return 0;

    local end_match=$(grep -ie "/[^/]*${1}$" "${DOTFILES_DIR}/repo-list/repos.txt");
    [ -d "${end_match}" ] && cd "${end_match}" && return 0;

    echo 'More than 1 match was found. Please be more specific:' >&2;
    echo "${match}" >&2;

    return 3;
}

#
# Starts a SSH agent.
#
sha()
{
    case $(ssh-add -l >/dev/null 2>&1; echo $?) in
        0) echo 'SSH agent already running' >&2; return 1 ;;
        2) eval $(ssh-agent -s) >/dev/null 2>&1 ;;
    esac

    local message='SSH agent running';
    ssh-add >/dev/null;

    [ -n "${SSH_AGENT_PID}" ] && message="${message} under pid ${SSH_AGENT_PID}";
    echo "${message}";
}

#
# Prints the root of the current repository.
#
# repo_root
#
repo_root()
{
    if [ ! -x "$(command -v git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null);
    if [ -z "${repo_root}" ]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    if [ ! -d "${repo_root}" ]; then
        echo 'Root is not a directory' >&2;
        return 2;
    fi

    echo "${repo_root}";
}

#
# Wrapper around git commit, adding in a few checks.
#
# 1. Is the commit message long enough? (minimum required: 3 characters)
# 2. Are we not committing in master? (override with -m)
# 3. Are we committing in our own fork? (override with -f)
# 4. Are there staged changes?
# 5. Are there DOS line endings? (override with -n)
#
# gitc [-nfm]
#
gitc()
{
    if [ ! -x "$(command -v git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    if ! git remote >/dev/null 2>&1; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local check_line_endings=$(git config --local --no-includes --get dotfiles.checkLineEndings || echo "${DF_CHECK_LINE_ENDINGS:-1}");
    local check_master=$(git config --local --no-includes --get dotfiles.checkMaster || echo "${DF_CHECK_MASTER:-1}");
    local check_fork=$(git config --local --no-includes --get dotfiles.checkFork || echo "${DF_CHECK_FORK:-1}");

    while getopts 'nmf' arg; do
        case "${arg}" in
            n) check_line_endings='0' ;;
            m) check_master='0'       ;;
            f) check_fork='0'         ;;
        esac;
    done

    shift "$(expr $OPTIND - 1)";
    local commit_message="${1}";

    if [ "${#commit_message}" -lt "5" ]; then
        echo 'A commit message requires at least 5 characters' >&2;
        return 2;
    fi

    if [ "${check_master}" = "1" ] && [ "$(git symbolic-ref --short HEAD 2>/dev/null)" = 'master' ]; then
        echo 'Not commiting in master. Use -m to override.' >&2;
        return 3;
    fi

    if [ "${check_fork}" = "1" ] && ! git remote | grep -q 'upstream' 2>/dev/null; then
        echo 'Not in your fork. Use -f to override.' >&2;
        return 4;
    fi

    local git_status=$(git status --porcelain 2>/dev/null);
    if ! echo "${git_status}" | grep -qE '^M|A|R'; then
        echo 'No staged changes' >&2;
        return 5;
    fi

    [ "${check_line_endings}" = '1' ] && [ -n "$(echo "${git_status}" | awk '{print $2}' | xargs -n1 file | grep 'CRLF' | awk -F':' '{ print $1 " has dos line endings. Use -n to override." }' | tee /dev/stderr)" ] && return 6;
    git commit -m "${commit_message}" || return 7;

    local git_status_after=$(git status --porcelain 2>/dev/null);
    if [ -n "${git_status_after}" ]; then
        echo '----------------------------';
        echo "${git_status_after}";
        echo '----------------------------';
    fi

    return 0;
}

#
# Pulls the current branch from origin.
#
# gitl [<remote=origin>]
#
gitl()
{
    if [ ! -x "$(command -v git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    local remotes=$(git remote 2>/dev/null);
    if [ -z "${remotes}" ]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local branch=$(git symbolic-ref --short HEAD 2>/dev/null);
    local remote='';

    if [ -n "${1}" ]; then
        remote="${1}";
    elif echo "${remotes}" | grep -q 'upstream'; then
        remote='upstream';
    else
        remote='origin';
    fi

    if ! echo "${remotes}" | grep -q "${remote}"; then
        echo "Unknown remote ${remote}" >&2;
        return 2;
    fi

    echo "Pulling ${remote} ${branch}";
    git pull "${remote}" "${branch}";
}

#
# Pushes the current branch to origin.
# Use -f to force-with-lease, or -ff to force.
#
# gith [-f] [-ff] [<remote=origin>]
#
gith()
{
    if [ ! -x "$(command -v git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    local remotes=$(git remote 2>/dev/null);
    if [ -z "${remotes}" ]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local branch=$(git symbolic-ref --short HEAD 2>/dev/null);
    local remote='origin';
    local flags='';

    for arg in "$@"; do
        if [ "${arg}" = '-f' ]; then
            flags='--force-with-lease';
        elif [ "${arg}" = '-ff' ]; then
            flags='--force';
        else
            remote="${arg}";
        fi
    done

    if ! echo "${remotes}" | grep -q "${remote}"; then
        echo "Unknown remote ${remote}" >&2;
        return 2;
    fi

    git push $flags "${remote}" "${branch}";
}

#
# Creates a new branch from a fresh master.
#
# gitb newFeatureBranch
#
gitb()
{
    if [ ! -x "$(command -v git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    if [ "$#" -gt 1 ]; then
        local new_branch_name=$(slug "$@");
    else
        local new_branch_name="${1}";
    fi

    if [ -z "${new_branch_name}" ]; then
        echo 'No branch name given' >&2;
        return 1;
    fi

    local remotes=$(git remote 2>/dev/null);
    if [ -z "${remotes}" ]; then
        echo 'Not in a git repository' >&2;
        return 2;
    fi

    if git branch 2>/dev/null | grep -q "${new_branch_name}"; then
        echo "Branch ${new_branch_name} already exists" >&2;
        return 3;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null);
    if [ ! "${branch_name}" = 'master' ]; then
        git checkout master || return 4;
    fi

    local remote_name='origin';
    if echo "${remotes}" | grep -q 'upstream'; then
        remote_name='upstream';
    fi

    git pull "${remote_name}" master && git checkout -b "${new_branch_name}";
}

#
# Executes phpunit in the current repository.
#
phpu()
{
    if ! git remote >/dev/null 2>&1; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null);
    if [ ! -x "${repo_root}/vendor/bin/phpunit" ]; then
        echo 'Cannot locate phpunit' >&2;
        return 2;
    fi

    (cd "${repo_root}" && ./vendor/bin/phpunit);
}

#
# Executes phpstan from any directory within a repository.
#
phps()
{
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null);
    if [ ! -x "${repo_root}/vendor/bin/phpstan" ]; then
        echo "Could not execute phpstan from '${repo_root}/vendor/bin/phpstan'" >&2;
        return 1;
    fi

    (
        cd "${repo_root}" || return 2;
        if [ -f ./phpstan.neon ]; then
            ./vendor/bin/phpstan -vvv analyse -c phpstan.neon;
        else
            ./vendor/bin/phpstan -vvv analyse;
        fi
    );
}

#
# Slugifies all parameters in a single slugged string.
#
# slug <param1> [<params2>] [...]
#
slug()
{
    local slugged=$(echo "$@" | xargs | tr '[A-Z]' '[a-z]' | sed 's/[ _]/-/g; s/[^0-9a-z-]//g; s/\-\{2,\}/-/g');
    [ -n "${slugged}" ] && echo "${slugged}";
}

#
# Calulates a mathmatical expression.
#
# calc <formula> [<formula>] [...]
#
calc()
{
    for arg in "$@"; do
        [ -n "${arg}" ] && awk "BEGIN {printf \"%.2f\n\", ${arg}}" | sed 's/\.00$//';
    done;
}

