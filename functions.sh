#
# Populate the list for cds.
#
# @see cds()
#
function repo-search()
{
    echo 'Searching for repositories. Please hold...';
    find / -type d -name '.git' -and -not -wholename '*/vendor/*' -print0 2> /dev/null | xargs -r0n1 dirname | grep -vFf "${DOTFILES_DIR}/repo-list/ignores.txt" 2> /dev/null | tee "${DOTFILES_DIR}/repo-list/new.txt";
    mv "${DOTFILES_DIR}/repo-list/new.txt" "${DOTFILES_DIR}/repo-list/repos.txt";
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
function cds()
{
    if [[ -d "${1}" ]]; then
        cd "${1}";
        return 0;
    fi

    if [[ ! -f "${DOTFILES_DIR}/repo-list/repos.txt" ]]; then
        echo 'No repository list found; please run repo-search and try again' >&2;
        return 1;
    fi

    if [[ -z "${1}" ]]; then
        cat "${DOTFILES_DIR}/repo-list/repos.txt";
        return 0;
    fi

    local match=$(grep -ie "/[^/]*${1}[^/]*$" "${DOTFILES_DIR}/repo-list/repos.txt");
    if [[ -z "${match}" ]]; then
        echo 'No match found' >&2;
        return 2;
    fi

    if [[ -d "${match}" ]]; then
        cd "${match}";
        return 0;
    fi

    local end_match=$(grep -ie "/[^/]*${1}$" "${DOTFILES_DIR}/repo-list/repos.txt");
    if [[ -d "${end_match}" ]]; then
        cd "${end_match}";
        return 0;
    fi

    echo -e "More than 1 match was found. Please be more specific:\n${match}" >&2;
    return 3;
}

#
# Starts a SSH agent.
#
function sha()
{
    case $(ssh-add -l >/dev/null 2>&1; echo $?) in
        2)
            eval $(ssh-agent -s) > /dev/null 2>&1;
            ;&
        1)
            ssh-add >/dev/null;
            echo "SSH agent running under pid ${SSH_AGENT_PID}";
            ;;
        0)
            echo "SSH agent already running under pid ${SSH_AGENT_PID}";
            ;;
    esac
}

#
# Navigates to, or prints the root of the current repository.
# Use -e to print the root diretory to STDOUT.
#
# repo-root [-e]
#
function repo-root()
{
    local repo_root=$(git rev-parse --show-toplevel 2> /dev/null);
    if [[ -z "${repo_root}" ]]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    [[ "${1}" == '-e' ]] && echo "${repo_root}" || cd "${repo_root}";
}

#
# Wrapper aournd git commit, adding in a few checks.
#
# 1. Is the commit message long enough? (minimum required: 3 characters)
# 2. Are we not committing in master?
# 3. Are we committing in our own fork? (skip this check using -f)
# 4. Are there staged changes?
# 5. Are the DOS line endings? (skip with -e)
#
function gitt()
{
    if [[ ! $(git remote 2> /dev/null) ]]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local check_line_endings="1";
    local check_fork="1";

    while getopts 'ef' arg; do
        case "${arg}" in
            e)
                check_line_endings="0" ;;
            f)
                check_fork="0" ;;
        esac;
    done

    shift $(expr $OPTIND - 1);
    local commit_message="${1}";

    if [[ "${#commit_message}" -lt 3 ]]; then
        echo 'A commit message requires at least 3 characters' >&2;
        return 2;
    fi

    if [[ $(git symbolic-ref --short HEAD 2> /dev/null) == 'master' ]]; then
        echo 'Not commiting in master' >&2;
        return 3;
    fi

    if [[ "${check_fork}" == "1" && ! $(git remote | grep upstream 2> /dev/null) ]]; then
        echo 'Not in your fork' >&2;
        return 4;
    fi

    local git_status=$(git status --porcelain 2> /dev/null);
    if [[ -z $(echo "${git_status}" | grep -E '^M ') ]]; then
        echo 'No staged changes' >&2;
        return 5;
    fi

    [[ "${check_line_endings}" == "1" && $(echo "${git_status}" | awk '{print $2}' | xargs -n 1 file | grep 'CRLF' | awk -F ':' '{ print $1 " has dos line endings" }' | tee /dev/stderr) ]] && return 6;

    local untracked_files=$(git status --porcelain | grep '??' | awk '{print $2}');
    if [[ ! -z "${untracked_files}" ]]; then
        echo -e "There are untracked files:\n${untracked_files}\n";
    fi

    git commit -m "${commit_message}";
    local result="${?}";

    git_status=$(git status --porcelain);
    echo '';
    echo '--------------------------';
    if [[ -z "${git_status}" ]]; then
        echo 'Working tree clean';
    else
        echo "${git_status}";
    fi

    return "${result}";
}

#
# Pulls the current branch from origin.
#
# gitl [<remote=origin>]
#
function gitl()
{
    local remotes=$(git remote 2> /dev/null);
    if [[ -z "${remotes}" ]]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null);
    local remote_name='';

    if [[ ! -z "${1}" ]]; then
        remote_name="${1}";
    elif [[ $(echo "${remotes}" | grep 'upstream') ]]; then
        remote_name='upstream';
    else
        remote_name='origin';
    fi

    if [[ ! $(echo "${remotes}" | grep "${remote_name}") ]]; then
        echo "Unknown remote ${remote}" >&2;
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
function gith()
{
    local remotes=$(git remote 2> /dev/null);
    if [[ -z "${remotes}" ]]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2> /dev/null);
    local remote_name='origin';
    local force_flag='';

    for arg in "$@"; do
        if [[ "${arg}" == '-f' ]]; then
            force_flag='--force-with-lease';
        else
            remote_name="${arg}";
        fi
    done

    if [[ ! $(echo "${remotes}" | grep "${remote_name}") ]]; then
        echo "Unknown remote ${remote_name}" >&2;
        return 2;
    fi

    git push $force_flag "${remote_name}" "${branch_name}";
}

#
# Creates a new branch from a fresh master.
#
# gitb newFeatureBranch
#
function gitb()
{
    local new_branch_name="${1}";
    if [[ -z "${new_branch_name}" ]]; then
        echo 'No branch name given' >&2;
        return 1;
    fi

    local remotes=$(git remote 2> /dev/null);
    if [[ -z "${remotes}" ]]; then
        echo 'Not in a git repository' >&2;
        return 2;
    fi

    if [[ $(git branch | grep "${new_branch_name}") ]]; then
        echo "Branch ${new_branch_name} already exists" >&2;
        return 3;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2> /dev/null);
    if [[ "${branch_name}" != 'master' ]]; then
        git checkout master || return 4;
    fi

    local remote_name='origin';
    if [[ $(echo "${remotes}" | grep 'upstream') ]]; then
        remote_name='upstream';
    fi

    git pull "${remote_name}" master && git checkout -b "${new_branch_name}";
}

#
# Executes phpunit in the current repository.
#
function phpu()
{
    if [[ ! -n $(git remote 2>/dev/null) ]]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null);
    if [[ ! -x "${repo_root}/vendor/phpunit/phpunit/phpunit" ]]; then
        echo 'Cannot locate phpunit' >&2;
        return 2;
    fi

    ( cd "${repo_root}" && './vendor/phpunit/phpunit/phpunit'; );
}

#
# Displays a line and optionally a column for a specific (csv) file.
# line <filename> <linenumber> [<column>] [<separator=,>]
#
function line()
{
    if [[ -z "${1}" ]]; then
        echo 'No filename given' >&2;
        return 1;
    fi

    if [[ ! -f "${1}" ]]; then
        echo "Filename '${1}' does not exist" >&2;
        return 2;
    fi

    if [[ -z "${2}" ]]; then
        echo 'No linenumber given' >&2;
        return 3;
    fi

    if [[ -z "${3}" ]]; then
        sed "${2}! d" "${1}";
    else
        sed "${2}! d" "${1}" | awk -F"${4:-,}" '{print $col}' col="${3}";
    fi
}

#
# Slugifies all parameters in a single slug string.
#
# slug <param1> [<params2>] [...]
#
function slug()
{
    local slugged=$(echo "$@" | xargs echo | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^0-9a-z-]//g');
    [[ ! -z "${slugged}" ]] && echo "${slugged}";
}
