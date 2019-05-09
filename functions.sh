function repo-search()
{
    echo -n 'Searching for repositories, please hold...';
    find / -type d -name ".git" -and -not -wholename "*/vendor/*" -print0 2> /dev/null | xargs -r0n1 dirname > '/tmp/repolist-new' 2> /dev/null;

    grep -v '/opt/httpd/' '/tmp/repolist-new' > "${DOTFILES_DIR}/.repos";
    rm '/tmp/repolist-new' 2> /dev/null;

    echo ' Done';
}

function cds()
{
    if [[ ! -f "${DOTFILES_DIR}/.repos" ]]; then
        echo 'No repository list found; please run repo-search and try again' >&2;
        return 1;
    fi

    if [[ -z "${1}" ]]; then
        cat "${DOTFILES_DIR}/.repos";
        return 0;
    fi

    local match=$(grep -ie "/[^/]*${1}[^/]*$" "${DOTFILES_DIR}/.repos");
    if [[ -z "${match}" ]]; then
        echo 'No match found' >&2;
        return 2;
    fi

    if [[ -d "${match}" ]]; then
        cd "${match}";
        return 0;
    fi

    local end_match=$(grep -ie "/[^/]*${1}$" "${DOTFILES_DIR}/.repos");
    if [[ -d "${end_match}" ]]; then
        cd "${end_match}";
        return 0;
    fi

    echo -e "More than 1 match was found. Please be more specific:\n${match}" >&2;
    return 3;
}

function sha()
{
    case $(ssh-add -l >/dev/null 2>&1; echo $?) in
        2)
            eval $(ssh-agent -s) >/dev/null 2>&1;
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

function shq()
{
    local pid_list=$(ps waux | grep 'ssh-agent -s' | grep -v grep | awk '{print $2}' | uniq);
    [[ -z "${pid_list}" ]] && return 0;

    echo "${pid_list}" | xargs -I '{}' echo "Killing {}";
    echo "${pid_list}" | xargs kill;
}

function repo-root()
{
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null);
    if [[ -z "${repo_root}" ]]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    [[ "${1}" == '-o' ]] && echo "${repo_root}" || cd "${repo_root}";
}

function gitt()
{
    if [[ ! $(git remote 2>/dev/null) ]]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local check_line_endings="1";
    local check_fork="1";

    while getopts "ef" arg; do
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

    if [[ $(git symbolic-ref --short HEAD 2>/dev/null) == 'master' ]]; then
        echo 'Not commiting in master' >&2;
        return 3;
    fi

    if [[ "${check_fork}" == "1" && ! $(git remote | grep upstream 2>/dev/null) ]]; then
        echo 'Not in your fork' >&2;
        return 4;
    fi

    local git_status=$(git status --porcelain 2>/dev/null);
    if [[ -z "${git_status}" ]]; then
        echo 'No staged changes' >&2;
        return 5;
    fi

    [[ "${check_line_endings}" == "1" && $(echo "${git_status}" | awk '{print $2}' | xargs -n 1 file | grep 'CRLF' | awk -F ':' '{ print $1 " has dos line endings" }' | tee /dev/stderr) ]] && return 6;

    local untracked_files=$(git status --porcelain | grep '??' | awk '{print $2}');
    if [[ ! -z $(git status --porcelain | grep '??') ]]; then
        echo -e "There are untracked files:\n${untracked_files}\n(Ctrl+C to cancel)\n";
        local dummy;
        read -t 2 dummy;
    fi

    git commit -m "${commit_message}";
}

function gitl()
{
    if [[ ! $(git remote 2>/dev/null) ]]; then
        echo 'Not in a git repository' >&2;
        return 1;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null);
    local remotes=$(git remote);
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

function gith()
{
    local remotes=$(git remote 2> /dev/null);
    if [[ -z "${remotes}" ]]; then
        echo "Not in a git repository" >&2;
        return 1;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null);
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

    local cur_dir=$(pwd);
    [[ "${cur_dir}" = "${repo_dir}" ]] || cd "${repo_root}";

    "./vendor/phpunit/phpunit/phpunit";
    local ret_val="${?}";

    [[ "${cur_dir}" = "${repo_dir}" ]] || cd "${cur_dir}";
    return "${ret_val}";
}

function line()
{
    if [[ -z "${1}" ]]; then
        echo 'No linenumber given' >&2;
        return 1;
    fi

    if [[ -z "${2}" ]]; then
        echo 'No filename given' >&2;
        return 2;
    fi

    if [[ ! -f "${2}" ]]; then
        echo 'Filename does not exist' >&2;
        return 3;
    fi

    sed "${1}! d" "${2}";
}

