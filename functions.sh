#!/usr/bin/env false

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
        cd "${search}" && return 0 || return 11;
    fi

    local search_path="$(echo "${DF_CDS_REPO_DIRS}" | sed 's/:/ /g')";
    [ "${search_path}" = '' ] && search_path="${HOME}";

    local repo_list="$(find $(echo "${search_path}") -maxdepth "${DF_CDS_MAX_DEPTH:-2}" -type d -name '.git' | sed 's/\/.git//' | sort | uniq)";
    if [ -z "${search}" ]; then
        echo "${repo_list}";
        return 0;
    fi

    local matches="$(echo "${repo_list}" | grep -ie "/[^/]*${search}[^/]*$")";
    if [ -z "${matches}" ]; then
        echo "no matches found for '${search}*'" >&2;
        return 12;
    fi

    [ ! -d "${matches}" ] && matches="$(echo "${repo_list}" | grep -ie "/[^/]*${search}$")";
    if  [ -d "${matches}" ]; then
        echo "${matches}";
        cd "${matches}" && return 0 || return 13;
    fi

    echo 'multiple matches found' >&2;
    echo "${matches}";

    return 14;
}

#
# Prints the root of the current repository.
#
repo_root()
(
    if [ ! -x "$(command -v git)" ]; then
        echo 'git not installed' >&2;
        return 10;
    fi

    local repo_root_dir="$(git rev-parse --show-toplevel 2>/dev/null)";
    if [ ! -d "${repo_root_dir}" ]; then
        echo 'root is not a directory' >&2;
        return 11;
    fi

    echo "${repo_root_dir}";
)

#
# Wrapper around git commit, adding in a few checks.
#
# 1. Is the commit message long enough? (minimum required: 3 characters)
# 2. Are we not committing in the default branch? (override with -d)
# 3. Are we committing in our own fork? (override with -f)
# 4. Are there staged changes?
# 5. Are there DOS line endings? (override with -n)
#
# gitc [-dfn]
#
gitc()
(
    if [ ! -x "$(command -v git)" ]; then
        echo 'git not installed' >&2;
        return 10;
    fi

    if ! git remote >/dev/null 2>&1; then
        echo 'not a git repository' >&2;
        return 9;
    fi

    check_default_branch="$(git config --local --no-includes --get dotfiles.checkDefaultBranch || echo "${DF_CHECK_DEFAULT_BRANCH:-1}")";
    check_line_endings="$(git config --local --no-includes --get dotfiles.checkLineEndings || echo "${DF_CHECK_LINE_ENDINGS:-1}")";
    check_fork="$(git config --local --no-includes --get dotfiles.checkFork || echo "${DF_CHECK_FORK:-1}")";

    while getopts 'ndf' arg; do
        case "${arg}" in
            d) check_default_branch='0';;
            n) check_line_endings='0'  ;;
            f) check_fork='0'          ;;
        esac;
    done

    shift "$(expr $OPTIND - 1)";
    commit_message="${1}";

    if [ "${#commit_message}" -lt '5' ]; then
        echo 'commit message requires at least 5 characters' >&2;
        return 11;
    fi

    if [ "${check_default_branch}" = '1' ]; then
        current_branch="$(git symbolic-ref --short HEAD 2>/dev/null)";
        repo_root="$(git rev-parse --show-toplevel 2>/dev/null)";
        default_branch="${current_branch}";

        for candidate in master default main trunk development; do
            [ -f "${repo_root}/.git/refs/heads/${candidate}" ] && default_branch="${candidate}";
        done

        if [ "${current_branch}" = "${default_branch}" ]; then
            echo "not commiting in ${default_branch} (use -d to override)" >&2;
            return 12;
        fi
    fi

    if [ "${check_fork}" = '1' ] && ! git remote | grep -q 'upstream' 2>/dev/null; then
        echo 'not in your fork (use -f to override)' >&2;
        return 13;
    fi

    git_status="$(git status --porcelain 2>/dev/null)";
    if ! echo "${git_status}" | grep -qE '^M|A|R|D'; then
        echo 'no staged changes' >&2;
        return 14;
    fi

    if [ "${check_line_endings}" = '1' ]; then
        if [ -n "$(echo "${git_status}" | awk '{print $2}' | xargs -n1 file | grep 'CRLF' | awk -F':' '{print $1 " has dos line endings"}' | tee /dev/stderr)" ]; then
            echo ' (use -n to override)' >&2;
            return 15;
        fi
    fi;

    git commit -m "${commit_message}" || return 7;

    git_status_after="$(git status --porcelain 2>/dev/null)";
    if [ -n "${git_status_after}" ]; then
        echo '----------------------------';
        echo "${git_status_after}";
        echo '----------------------------';
    fi
)

#
# Pulls the current branch from origin.
#
# gitl [<remote=origin>]
#
gitl()
(
    if [ ! -x "$(command -v git)" ]; then
        echo 'git not installed' >&2;
        return 10;
    fi

    remotes="$(git remote 2>/dev/null)";
    if [ -z "${remotes}" ]; then
        echo 'not a git repository' >&2;
        return 9;
    fi

    branch="$(git symbolic-ref --short HEAD 2>/dev/null)";
    remote='';

    if [ -n "${1}" ]; then
        remote="${1}";
    elif echo "${remotes}" | grep -q 'upstream' 2>/dev/null; then
        remote='upstream';
    else
        remote='origin';
    fi

    if ! echo "${remotes}" | grep -q "${remote}" 2>/dev/null; then
        echo "unknown remote '${remote}'" >&2;
        return 11;
    fi

    echo "pulling ${remote} ${branch}";
    git pull "${remote}" "${branch}" || return 12;
)

#
# Pushes the current branch to a remote.
# Use -f to force-with-lease, or -ff to force.
#
# gith [-f] [-ff] [<remote=origin>]
#
gith()
(
    if [ ! -x "$(command -v git)" ]; then
        echo 'git not installed' >&2;
        return 10;
    fi

    remotes="$(git remote 2>/dev/null)";
    if [ -z "${remotes}" ]; then
        echo 'not a git repository' >&2;
        return 9;
    fi

    branch="$(git symbolic-ref --short HEAD 2>/dev/null)";
    remote='origin';
    flags='';

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
        echo "unknown remote '${remote}'" >&2;
        return 3;
    fi

    git push $flags "${remote}" "${branch}" || return 11;
)

#
# Creates a new branch branched from a fresh default branch.
# Use -c to branch from current branch instead.
#
# gitb [-c] new-feature-branch
#
gitb()
(
    if [ ! -x "$(command -v git)" ]; then
        echo 'git not installed' >&2;
        return 10;
    fi

    remotes="$(git remote 2>/dev/null)";
    if [ -z "${remotes}" ]; then
        echo 'not a git repository' >&2;
        return 9;
    fi

    current_branch_name="$(git symbolic-ref --short HEAD 2>/dev/null)";
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null)";
    default_branch='master';
    source_branch='master';
    new_branch_name='';

    for candidate in main default; do
        if [ -f "${repo_root}/.git/refs/heads/${candidate}" ]; then
            default_branch="${candidate}";
            source_branch="${candidate}";
        fi
    done

    for arg in "$@"; do
        if [ "${arg}" = '-c' ]; then
            source_branch="${current_branch_name}";
        else
            new_branch_name="${arg}";
        fi
    done

    if [ -z "${new_branch_name}" ]; then
        echo 'no branch name given' >&2;
        return 11;
    fi

    if git branch 2>/dev/null | grep -q "${new_branch_name}"; then
        echo "branch '${new_branch_name}' already exists" >&2;
        return 12;
    fi

    remote_name='origin';
    if echo "${remotes}" | grep -q 'upstream'; then
        remote_name='upstream';
    fi

    if [ "${current_branch_name}" != "${source_branch}" ]; then
        git checkout "${source_branch}" || return 13;
    fi

    if [ "${source_branch}" = "${default_branch}" ]; then
        git pull "${remote_name}" "${source_branch}" || return 14;
    else
        echo "not pulling '${source_branch}'";
    fi

    git checkout -b "${new_branch_name}" || return 15;
)

masin()
(
    if [ ! -x "$(command -v git)" ]; then
        echo 'git not installed' >&2;
        return 10;
    fi

    source_branch="${1:-master}";
    target_branch="$(git symbolic-ref --short HEAD 2>/dev/null)";

    if [ "${source_branch}" = "${target_branch}" ]; then
        echo "already on ${source_branch}" >&2;
        return 3;
    fi

    remotes="$(git remote 2>/dev/null)";
    if echo "${remotes}" | grep -q 'upstream' 2>/dev/null; then
        remote='upstream';
    else
        remote='origin';
    fi

    git checkout "${source_branch}" && \
        git pull "${remote}" "${source_branch}" && \
        git checkout "${target_branch}" && \
        git rebase "${source_branch}";
)

#
# Executes phpunit in the current repository.
#
phpu()
(
    if ! git remote >/dev/null 2>&1; then
        echo 'not a git repository' >&2;
        return 9;
    fi

    repo_root="$(git rev-parse --show-toplevel 2>/dev/null)";
    if [ ! -x "${repo_root}/vendor/bin/phpunit" ]; then
        echo 'cannot locate phpunit' >&2;
        return 11;
    fi

    cd "${repo_root}" && sh -c './vendor/bin/phpunit';
)

#
# Executes phpstan from any directory within a repository.
#
phps()
(
    if ! git remote >/dev/null 2>&1; then
        echo 'not a git repository' >&2;
        return 9;
    fi

    repo_root="$(git rev-parse --show-toplevel 2>/dev/null)";
    if [ ! -x "${repo_root}/vendor/bin/phpstan" ]; then
        echo "could not execute phpstan from '${repo_root}/vendor/bin/phpstan'" >&2;
        return 11;
    fi

    cd "${repo_root}" && sh -c "./vendor/bin/phpstan analyse -vvv$([ -f ./phpstan.neon ] && echo ' -c phpstan.neon')";
)

#
# Executes phpcs from any directory within a repository.
#
phpcs()
(
    if ! git remote >/dev/null 2>&1; then
        echo 'not a git repository' >&2;
        return 9;
    fi

    repo_root="$(git rev-parse --show-toplevel 2>/dev/null)";
    if [ ! -x "${repo_root}/vendor/bin/phpcs" ]; then
        echo 'cannot locate phpcs' >&2;
        return 11;
    fi

    cd "${repo_root}" &&  sh -c './vendor/bin/phpcs';
)

#
# Starts a SSH agent.
#
sha()
(
    if [ ! -x "$(command -v ssh-add)" ]; then
        echo 'dependency not found: ssh-add' >&2;
        return 2;
    fi

    if [ ! -x "$(command -v ssh-agent)" ]; then
        echo 'dependency not found: ssh-agent' >&2;
        return 2;
    fi

    case "$(ssh-add -l >/dev/null 2>&1; echo $?)" in
        0) echo 'SSH agent already running' >&2; return 3 ;;
        2) eval "$(ssh-agent -s)" >/dev/null 2>&1         ;;
    esac

    ssh-add >/dev/null || return 4;
    [ -n "${SSH_AGENT_PID}" ] && echo "SSH agent running under pid ${SSH_AGENT_PID}" || echo 'SSH agent running';
)

#
# Slugifies all parameters in a single slugged string.
#
# slug <param1> [<params2>] [...]
#
slug()
(
    slugged="$(echo "$@" | xargs | tr '[A-Z]' '[a-z]' | sed 's/[ _]/-/g; s/[^0-9a-z-]//g; s/\-\{2,\}/-/g')";
    [ -n "${slugged}" ] && echo "${slugged}";
)

#
# Manages dotfiles.
#
# dfs [edit|update|env|reload|nav]
#
# dfs env      Show relevant variables
# dfs install  (Re)installs dotfiles and applies defaults
# dfs nav      Navigates to the dotfiles repo
# dfs reload   Reloads configuration
# dfs update   Updates dotfiles
#
dfs()
{
    case "${1:-nav}" in
        nav)     cd "${DF_ROOT_DIR}" && pwd                                          ;;
        install) . "${DF_ROOT_DIR}/setup/install.sh"                                 ;;
        reload)  . "${DF_ROOT_DIR}/shells/$(ps -p $$ -o args= | sed 's/^-//')/rc.sh" ;;
        env)
            (
                all_vars="$(grep '# export ' "${DF_ROOT_DIR}/setup/config.sh")";
                used_vars="$(env | grep '^DF_')";

                echo 'defined vars:';
                echo "${used_vars}" | cut -d'=' -f1 | while read -r var_name; do all_vars="$(echo "${all_vars}" | grep -v "${var_name}=")"; done;
                [ -n "${used_vars}" ] && echo "${used_vars}";
                if [ -n "${all_vars}" ]; then
                    echo '';
                    echo 'supported vars:';
                    echo "${all_vars}" | sed 's/export //';
                fi

                git_vars="$(git config --local --list 2>/dev/null | grep '^dotfiles.')";
                if [ -n "${git_vars}" ]; then
                    echo '';
                    echo 'Local repository git vars:';
                    echo "${git_vars}";
                fi
            )

            ;;
        update)
            (
                cd "${DF_ROOT_DIR}" || return 1;
                g_remote="$(git remote -v)";
                hostname="$(echo "${g_remote}" | grep -o '[a-zA-Z0-9]\+\.[a-z]\+/' | sort | uniq | sed 's#/$##')";
                remote="$(echo "${g_remote}" | grep '(fetch)' | grep -E 'git(hu|la)b.com' | cut -f1)";
                branch="$(git symbolic-ref --short HEAD 2>/dev/null)";
                old_commit="$(git rev-parse --verify HEAD)";

                echo "updating dotfiles for ${remote:-origin}/${branch:-master} from ${hostname}...";
                git pull -q --ff-only "${remote:-origin}" "${branch:-master}" || return 3;
                new_commit="$(git rev-parse --verify HEAD)";

                if [ "${old_commit}" = "${new_commit}" ]; then
                    echo '  -> dotfiles already up to date';
                    "${DF_ROOT_DIR}/setup/plugins.sh";

                    return "${?}";
                fi

                echo "  -> updated to ${new_commit}";
                echo && echo 'diffstat:';
                git diff --stat HEAD^..HEAD;

                echo && echo 'changelog:';
                git log --format="  -> %s" --no-merges "${old_commit}"..HEAD;

                return 4;
            );

            exit_code="${?}";
            [ "${exit_code}" -eq 4 ] && dfs install && return 0;

            return "${exit_code}" ;;

        *)
            echo "command not recognized: '${1}', expecting one of 'env', 'install', 'nav', 'reload' or 'update'" >&2;
            return 8;
        ;;
    esac
}

#
# Chooses a line being piped into this function.
#
# choose [<line-number>]
#
choose()
(
    input="$(cat)";
    [ "${input}" = '' ] && return 11;

    lines="$(echo "${input}" | wc -l)";
    if  [ "${lines}" -lt 2 ]; then
        echo "${input}";
        return 0;
    fi

    line_number="${1}";
    if [ -z  "${line_number}" ]; then
        echo "${input}" | awk '{print NR ": " $0}';
        return 0;
    fi

    if ! echo "${input}" | sed -n "${line_number} p"; then
        echo "index not numeric '${line_number}'" >&2;
        return 11;
    fi
)
