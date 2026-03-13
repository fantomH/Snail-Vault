# ------------------------------------------------------------------------ INFO
# [/Snail-Vault/list-files.sh]
# author        : Pascal Malouin (https://github.com/fantomH)
# created       : 2026-03-12 18:59:46 UTC
# updated       : 2026-03-13 12:55:00 UTC
# description   : List regular files from given paths.

list_files() {

    usage() {
        cat <<EOF
================================================================================
[+] list_files - List regular files from given paths.
================================================================================
Usage: list_files --out VAR [OPTIONS] [--] [PATH...]

Collects regular files from the specified PATH arguments. If a PATH is a
directory, all regular files inside that directory are added to the output
array. If a PATH is a file, it is added directly.

The output is written to the Bash variable specified with --out.

OPTIONS:
    --out VAR
        Name of the variable that will receive the resulting array.

    --help, --usage
        Display this help message.

OPERANDS:
    PATH...
        One or more paths to inspect. If a path is a directory, its files
        are listed. If a path is a file, it is added directly.

        If no PATH is provided, the current directory (.) is used.

    --
        Explicitly marks the end of options. Useful if a PATH starts with "-".

OUTPUT:
    The variable specified with --out will contain a Bash array of files.

EXAMPLES:
    list_files --out files (<- Only works if the "paths" argument is empty.)
    list_files --out files -- .
    list_files --out files -- /etc /var/log file.txt
    list_files --out files -- ./-weird-name

    printf '%s\n' "\${files[@]}"

================================================================================
EOF
    }

    local out_var=""

    while (($#)); do
        case "$1" in
            --out)
                [[ $# -ge 2 ]] || {
                    printf '[!] list_files: --out requires a variable name.\n' >&2
                    usage
                    return 1
                }
                out_var="$2"
                shift 2
                ;;
            --help|--usage)
                usage
                return
                ;;
            --)
                shift
                break
                ;;
            *)
                printf '%s\n' "[!] list_files: unknown argument: ${1}" >&2
                printf '%s\n' "[!] '--' is required before paths." >&2
                usage
                return 1
                ;;
        esac
    done

    [[ -n "$out_var" ]] || {
        printf '%s\n' '[!] list_files: --out is required.\n' >&2
        usage
        return 1
    }

    [[ "$out_var" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || {
        printf '%s\n' "[!] list_files: invalid variable name: ${out_var}" >&2
        usage
        return 1
    }

    local -n out_ref="$out_var"
    local old_nullglob
    local i f

    old_nullglob=$(shopt -p nullglob)
    shopt -s nullglob

    out_ref=()

    for i in "${@:-.}"; do
        if [[ -d "$i" ]]; then
            for f in "$i"/*; do
                [[ -f "$f" ]] || continue
                out_ref+=("$f")
            done
        else
            [[ -f "$i" ]] || continue
            out_ref+=("$i")
        fi
    done

    eval "$old_nullglob"
}
