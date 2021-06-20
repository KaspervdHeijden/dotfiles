#
# Navigates to a repository with a given partial directory name.
# If multiple matches are found use the second argument to select one.
#
# cds [<partial-name>] [index]
#
cds()
{
    local search="${1}";
    if [ -d "${search}" ]; then
        cd "${search}" && return 0 || return 1;
    fi

    [ "${#DF_REPO_DIRS[@]}" -eq 0 ] && DF_REPO_DIRS=("${HOME}");

    local repo_list=$(find $DF_REPO_DIRS[@] -maxdepth ${DF_MAX_DEPTH:-2} -type d -name '.git' 2>/dev/null | sed 's/\/.git//' | sort | uniq);
    if [ -z "${search}" ]; then
        echo "${repo_list}";
        return 0;
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
    echo "${matches}" | awk '{print NR ": " $0}' >&2;

    return 5;
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

    [ "${1}" = '-c' ] && cd "${repo_root}" || echo "${repo_root}";
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
        echo 'Not commiting in master (use -m to override)' >&2;
        return 3;
    fi

    if [ "${check_fork}" = "1" ] && ! git remote | grep -q 'upstream' 2>/dev/null; then
        echo 'Not in your fork (use -f to override)' >&2;
        return 4;
    fi

    local git_status=$(git status --porcelain 2>/dev/null);
    if ! echo "${git_status}" | grep -qE '^M|A|R|D'; then
        echo 'No staged changes' >&2;
        return 5;
    fi

    if [ "${check_line_endings}" = '1' ]; then
        local files_with_dos_lines=$(echo "${git_status}" | awk '{print $2}' | xargs -n1 file | grep 'CRLF' | awk -F':' '{print $1 " has dos line endings"}');
        if [ -n "${files_with_dos_lines}" ]; then
            echo "${files_with_dos_lines}" >&2;
            echo ' (use -n to override)' >&2;
            return 6;
        fi
    fi;
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
    elif echo "${remotes}" | grep -q 'upstream' 2>/dev/null; then
        remote='upstream';
    else
        remote='origin';
    fi

    if ! echo "${remotes}" | grep -q "${remote}" 2>/dev/null; then
        echo "Unknown remote '${remote}'" >&2;
        return 2;
    fi

    echo "Pulling ${remote} ${branch}";
    git pull "${remote}" "${branch}" || return 3;
}

#
# Pushes the current branch to a remote.
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

    if ! echo "${remotes}" | grep -q "${remote}" 2>/dev/null; then
        echo "Unknown remote '${remote}'" >&2;
        return 2;
    fi

    git push $flags "${remote}" "${branch}" || return 3;
}

#
# Creates a new branch from a fresh master.
#
# gitb new-feature-branch
#
gitb()
{
    if [ ! -x "$(command -v git)" ]; then
        echo 'Git not installed' >&2;
        return 10;
    fi

    local remotes=$(git remote 2>/dev/null);
    if [ -z "${remotes}" ]; then
        echo 'Not in a git repository' >&2;
        return 2;
    fi

    local current_branch_name=$(git symbolic-ref --short HEAD 2>/dev/null);
    local source_branch='master';
    local new_branch_name='';

    for arg in "$@"; do
        if [ "${arg}" = '-c' ]; then
            source_branch="${current_branch_name}";
        else
            new_branch_name="${arg}";
        fi
    done

    if [ -z "${new_branch_name}" ]; then
        echo 'No branch name given' >&2;
        return 1;
    fi

    if git branch 2>/dev/null | grep -q "${new_branch_name}" 2>/dev/null; then
        echo "Branch '${new_branch_name}' already exists" >&2;
        return 3;
    fi

    local remote_name='origin';
    if echo "${remotes}" | grep -q 'upstream'; then
        remote_name='upstream';
    fi

    if [ "${current_branch_name}" != "${source_branch}" ]; then
        git checkout "${source_branch}" || return 4;
    fi

    if [ "${source_branch}" = 'master' ]; then
        git pull "${remote_name}" "${source_branch}" || return 5;
    else
        echo "Not pulling '${source_branch}'";
    fi

    git checkout -b "${new_branch_name}" || return 6;
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

    (cd "${repo_root}" && sh -c './vendor/bin/phpunit');
}

#
# Executes phpstan from any directory within a repository.
#
phps()
{
    if ! git remote >/dev/null 2>&1; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null);
    if [ ! -x "${repo_root}/vendor/bin/phpstan" ]; then
        echo "Could not execute phpstan from '${repo_root}/vendor/bin/phpstan'" >&2;
        return 2;
    fi

    (cd "${repo_root}" && sh -c "./vendor/bin/phpstan analyse -vvv$([ -f ./phpstan.neon ] && echo ' -c phpstan.neon')");
}

#
# Executes phpcs from any directory within a repository.
#
phpcs()
{
    if ! git remote >/dev/null 2>&1; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null);
    if [ ! x "${repo_root}/vendor/bin/phpcs" ]; then
        echo 'Cannot locate phpcs' >&2;
        return 2;
    fi

    (cd "${repo_root}" &&  sh -c './vendor/bin/phpcs');
}


#
# Starts a SSH agent.
#
sha()
{
    if [ ! -x "$(command -v ssh-add)" ]; then
        echo 'Dependency ssh-add not found' >&2;
        return 1;
    fi

    case $(ssh-add -l >/dev/null 2>&1; echo $?) in
        0) echo 'SSH agent already running' >&2; return 2 ;;
        2) eval $(ssh-agent -s) >/dev/null 2>&1           ;;
    esac

    ssh-add >/dev/null || return 3;
    [ -n "${SSH_AGENT_PID}" ] && echo "SSH agent running under pid ${SSH_AGENT_PID}" || echo 'SSH agent running';
}

#
# Slugifies all parameters in a single slugged string.
#
# slug <param1> [<params2>] [...]
#
slug()
{
    local slugged="$(echo "$@" | xargs | tr '[A-Z]' '[a-z]' | sed 's/[ _]/-/g; s/[^0-9a-z-]//g; s/\-\{2,\}/-/g')";
    [ -n "${slugged}" ] && echo "${slugged}";
}

dotf()
{
    case "${1}" in
        update)
            (cd "${DOTFILES_DIR}" && git pull --ff "$(git remote -v | grep 'KaspervdHeijden@github.com/KaspervdHeijden/dotfiles.git (fetch)' | cut -f1)" master) ;;
        env)
            local all_vars=$(grep --color=never '# export '  "${DOTFILES_DIR}/setup/config.sh");
            local used_vars=$(env | grep --color=never 'DF_\|DOTFILES_');

            echo "${used_vars}" | cut -d'=' -f1 | while read var_name; do all_vars=$(echo "${all_vars}" | grep -v "${var_name}"); done;
            echo "${used_vars}";
            echo "${all_vars}" ;;
        reload)
            source "${DOTFILES_DIR}/shells/$(ps -p $$ | tail -1 | awk '{print $4}')/rc.sh" ;;
        nav)
            cd "${DOTFILES_DIR}" ;;
        *)
            echo "command not recognized: '${1}', expecting 'update', 'env', 'reload' or 'nav'" >&2;
            return 2;;
    esac
}

