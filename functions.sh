#
# Navigates to a repository with a given partial directory name.
# If multiple matches are found use the second argument to select one.
#
# cds [<partial-name>] [index]
#
cds()
{
    if [ "${#DF_REPO_DIRS[@]}" -eq 0 ]; then
        echo 'Array $DF_REPO_DIRS must not be empty' >&2;
        return 6;
    fi

    local repo_list=$(find $DF_REPO_DIRS[@] -maxdepth ${DF_MAX_DEPTH:-2} -type d -name '.git' 2>/dev/null | sed 's/\/.git//' | sort | uniq);
    local search="${1}";
    if [ -z "${search}" ]; then
        echo "${repo_list}";
        return 0;
    fi

    if [ -d "${search}" ]; then
        cd "${search}" && return 0 || return 1;
    fi

    local matches=$(echo "${repo_list}" | grep -ie "/[^/]*${search}[^/]*$");
    if [ -z "${matches}" ]; then
        echo "No matches found for '${search}*'" >&2;
        return 2;
    fi

    if [ -d "${matches}" ]; then
        echo "${matches}";
        cd "${matches}" && return 0 || return 3;
    fi

    local index="${2}";
    if [ -n "${index}" ]; then
        local line=$(echo "${matches}" | sed -n "${index}p");
        if [ -d "${line}" ]; then
            echo "${line}";
            cd "${line}" && return 0 || return 4;
        fi

        echo "Invalid index '${index}'" >&2;
    fi

    echo 'Multiple matches found:' >&2;
    echo "${matches}" >&2;

    return 5;
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

    ssh-add >/dev/null;
    [ -n "${SSH_AGENT_PID}" ] && echo "SSH agent running under pid ${SSH_AGENT_PID}" || echo 'SSH agent running';
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

