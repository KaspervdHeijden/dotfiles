#
# Populate the list for cds.
#
# @see cds()
#
repo-search()
{
    echo 'Searching for repositories. Please hold...';
    find / -type d -name '.git' -and -not -wholename '*/vendor/*' $(printf "-and -not -wholename *%s* " $(cat "${DOTFILES_DIR}/repo-list/ignores.txt")) -print0 2> /dev/null | xargs -r0n1 dirname 2> /dev/null | tee "${DOTFILES_DIR}/repo-list/new.txt";
    mv "${DOTFILES_DIR}/repo-list/new.txt" "${DOTFILES_DIR}/repo-list/repos.txt";
}

#
# Adds a repository to the list.
#
# repo-add <dir>
#
repo-add()
{
    if [ ! -x "$(which git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    local dir_to_add="${1-$(pwd)}";
    if [ ! -d "${dir_to_add}" ]; then
        echo 'Not a directory' >&2;
        return 1;
    fi

    local repo_root=$(cd "${dir_to_add}"; git rev-parse --show-toplevel 2> /dev/null);
    if [ -z "${repo_root}" ]; then
        echo 'Not a valid git repository' >&2;
        return 2;
    fi

    [ ! -f "${DOTFILES_DIR}/repo-list/repos.txt" ] && touch "${DOTFILES_DIR}/repo-list/repos.txt";
    if [ $(grep -q "${repo_root}" "${DOTFILES_DIR}/repo-list/repos.txt") ]; then
        echo 'Repository already present' >&2;
        return 3;
    fi

    echo "Adding ${repo_root}";
    echo "${repo_root}" >> "${DOTFILES_DIR}/repo-list/repos.txt";
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
# which can be created using repo-searech.
#
# @see repo-search
#
cds()
{
    if [ -d "${1}" ]; then
        cd "${1}";
        return 0;
    fi

    if [ ! -f "${DOTFILES_DIR}/repo-list/repos.txt" ]; then
        echo 'No repository list found; please run repo-search and try again' >&2;
        return 1;
    fi

    if [ -z "${1}" ]; then
        cat "${DOTFILES_DIR}/repo-list/repos.txt";
        return 0;
    fi

    local match=$(grep -ie "/[^/]*${1}[^/]*$" "${DOTFILES_DIR}/repo-list/repos.txt");
    if [ -z "${match}" ]; then
        echo 'No match found' >&2;
        return 2;
    fi

    if [ -d "${match}" ]; then
        cd "${match}";
        return 0;
    fi

    local end_match=$(grep -ie "/[^/]*${1}$" "${DOTFILES_DIR}/repo-list/repos.txt");
    if [ -d "${end_match}" ]; then
        cd "${end_match}";
        return 0;
    fi

    echo 'More than 1 match was found. Please be more specific:' >&2;
    echo "${match}" >&2;
    return 3;
}

#
# Starts a SSH agent.
#
sha()
{
    local message='';
    local return_code=$(ssh-add -l >/dev/null 2>&1);

    if [ "${return_code}" = 2 ]; then
        eval $(ssh-agent -s) > /dev/null 2>&1;
    fi

    if [ "${return_code}" = 0 ]; then
        message='SSH agent running';
        ssh-add >/dev/null;
    else
        message='SSH agent already running';
    fi

    [ -n "${SSH_AGENT_PID}" ] && message="${message} under pid ${SSH_AGENT_PID}";
    echo $message;
}

#
# Navigates to, or prints the root of the current repository.
# Use -e to print the root diretory to STDOUT.
#
# repo-root [-e]
#
repo-root()
{
    if [ ! -x "$(which git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    local repo_root=$(git rev-parse --show-toplevel 2> /dev/null);
    if [ -z "${repo_root}" ]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    [ "${1}" = '-e' ] && echo "${repo_root}" || cd "${repo_root}";
}

#
# Wrapper around git commit, adding in a few checks.
#
# 1. Is the commit message long enough? (minimum required: 3 characters)
# 2. Are we not committing in master?
# 3. Are we committing in our own fork? (skip this check using -f)
# 4. Are there staged changes?
# 5. Are there DOS line endings? (skip with -n)
#
# gitc [-nf]
#
gitc()
{
    if [ ! -x "$(which git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    if [ ! $(git remote 2> /dev/null) ]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local check_line_endings=$(git config --local --no-includes --get dotfiles.checkLineEndings || echo '1');
    local check_fork=$(git config --local --no-includes --get dotfiles.checkFork || echo '1');

    while getopts 'nf' arg; do
        case "${arg}" in
            n) check_line_endings='0' ;;
            f) check_fork='0' ;;
        esac;
    done

    shift $(expr $OPTIND - 1);
    local commit_message="${1}";

    if [ "${#commit_message}" -lt 3 ]; then
        echo 'A commit message requires at least 3 characters' >&2;
        return 2;
    fi

    if [ "$(git symbolic-ref --short HEAD 2> /dev/null)" = 'master' ]; then
        echo 'Not commiting in master' >&2;
        return 3;
    fi

    if [ "${check_fork}" = "1" -a ! $(git remote | grep -q upstream 2> /dev/null) ]; then
        echo 'Not in your fork' >&2;
        return 4;
    fi

    local git_status=$(git status --porcelain 2> /dev/null);
    if [ -z "$(echo "${git_status}" | grep -E '^M|A|R')" ]; then
        echo 'No staged changes' >&2;
        return 5;
    fi

    [ "${check_line_endings}" = '1' -a $(echo "${git_status}" | awk '{print $2}' | xargs -n 1 file | grep 'CRLF' | awk -F':' '{ print $1 " has dos line endings" }' | tee /dev/stderr) ] && return 6;
    git commit -m "${commit_message}" || return 7;

    local git_status_after=$(git status --porcelain 2> /dev/null);
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
    if [ ! -x "$(which git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    local remotes=$(git remote 2> /dev/null);
    if [ -z "${remotes}" ]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null);
    local remote_name='';

    if [ -n "${1}" ]; then
        remote_name="${1}";
    elif [ $(echo "${remotes}" | grep -q 'upstream') ]; then
        remote_name='upstream';
    else
        remote_name='origin';
    fi

    if [ ! $(echo "${remotes}" | grep -q "${remote_name}") ]; then
        echo "Unknown remote ${remote_name}" >&2;
        return 2;
    fi

    echo "Pulling ${remote_name} ${branch_name}";
    git pull "${remote_name}" "${branch_name}";
}

#
# Pushes the current branch to origin.
# Use -f to force push (with lease).
#
# gith [-f] [<remote=origin>]
#
gith()
{
    if [ ! -x "$(which git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    local remotes=$(git remote 2> /dev/null);
    if [ -z "${remotes}" ]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2> /dev/null);
    local remote_name='origin';
    local force_flag='';

    for arg in "$@"; do
        if [ "${arg}" = '-f' ]; then
            force_flag='--force-with-lease';
        else
            remote_name="${arg}";
        fi
    done

    if [ ! $(echo "${remotes}" | grep -q "${remote_name}") ]; then
        echo "Unknown remote ${remote_name}" >&2;
        return 2;
    fi

    git push $force_flag "${remote_name}" "${branch_name}";
}

#
# Creates a new branch from a fresh master.
# Use -s to slug the parameter.
#
# gitb newFeatureBranch
#
gitb()
{
    if [ ! -x "$(which git)" ]; then
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

    local remotes=$(git remote 2> /dev/null);
    if [ -z "${remotes}" ]; then
        echo 'Not in a git repository' >&2;
        return 2;
    fi

    if [ $(git branch | grep -q "${new_branch_name}") ]; then
        echo "Branch ${new_branch_name} already exists" >&2;
        return 3;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2> /dev/null);
    if [ "${branch_name}" != 'master' ]; then
        git checkout master || return 4;
    fi

    local remote_name='origin';
    if [ $(echo "${remotes}" | grep -q 'upstream') ]; then
        remote_name='upstream';
    fi

    git pull "${remote_name}" master && git checkout -b "${new_branch_name}";
}

#
# Executes phpunit in the current repository.
#
phpu()
{
    if [ -z $(git remote 2>/dev/null) ]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null);
    if [ ! -x "${repo_root}/vendor/phpunit/phpunit/phpunit" ]; then
        echo 'Cannot locate phpunit' >&2;
        return 2;
    fi

    (cd "${repo_root}" && './vendor/phpunit/phpunit/phpunit');
}

#
# Executes phpstan from any directory within a repository.
#
phps()
{
    local repo_root=$(git rev-parse --show-toplevel 2> /dev/null);
    if [ ! -x "${repo_root}/vendor/bin/phpstan" ]; then
        echo "Could not execute phpstan from '${repo_root}/vendor/bin/phpstan'" >&2;
        return 1;
    fi

    (cd "${repo_root}" && vendor/bin/phpstan -vvv analyse -c phpstan.neon);
}

#
# Displays a line and optionally a column for a specific (csv) file.
# line <filename> <linenumber> [<column>] [<separator=,>]
#
line()
{
    if [ -z "${1}" ]; then
        echo 'No filename given' >&2;
        return 1;
    fi

    if [ ! -f "${1}" ]; then
        echo "Filename '${1}' does not exist" >&2;
        return 2;
    fi

    if [ -z "${2}" ]; then
        echo 'No linenumber given' >&2;
        return 3;
    fi

    if [ -z "${3}" ]; then
        sed "${2}! d" "${1}";
    else
        sed "${2}! d" "${1}" | awk -F"${4:-,}" '{print $col}' col="${3}";
    fi
}

#
# Slugifies all parameters in a single slugged string.
#
# slug <param1> [<params2>] [...]
#
slug()
{
    local slugged=$(echo "$@" | xargs echo | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g; s/_/-/g; s/[^0-9a-z-]//g; s/\-\{2,\}/-/g');
    [ -n "${slugged}" ] && echo "${slugged}";
}

#
# Calulates a mathmatical expression.
#
# calc <formula>
#
calc()
{
    [ -n "${1}" ] && awk "BEGIN {printf \"%.2f\n\", $1}" | sed 's/\.00$//';
}

