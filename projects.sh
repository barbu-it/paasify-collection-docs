#!/bin/bash


set -eu

# Usage
main_usage ()
{
  cat - <<EOF
Usage:
  ${0##/} [rev] CMD

CMD:
  usage         Show this help
  clone         Clone collections from repos.txt
  docs          Generate static documentation
  status        Show git status
  info          List of managed repos
  CMD           Forward command to be executed in each dir
EOF
}

# Reverse a list of words
reverse ()
{
  echo "${@-}" |tr ' ' '\n'|tac|tr '\n' ' '
}

prj_st ()
{
  git status -sb | grep -v '??'
}

prj_clone ()
{
  local repos=$(cat repos.txt)

  for repo in $repos; do

    name=${repo##*/}
    name=${name%.git}

    if [[ -d "$name" ]]; then
      >&2 echo "Updating repo $name ..."
      git -C "$name" fetch -a
      git -C "$name" pull
    else
      git clone "$repo" "$name"
    fi

  done
}

targets ()
{
  local repos=$(cat repos.txt)

  for repo in $repos; do
    name=${repo##*/}
    name=${name%.git}
    echo "$name"
  done
}


gen_docs ()
{
  rm -rf src/collections/
  for target in $(targets); do
    paasify document_collection $target --out src/collections/$target
  done
  echo "Documentation generated in: src/collections"
}

serve_docs ()
{
  local listen=${1:-127.0.0.1:8001}
  mkdocs serve -a $listen

}


main ()
{
  #local tests="barbu barbu_auth barbu_hr barbu_internal_prod barbu_public_prod"
  #local tests="jez jez_auth jez_beta jez_infra jez_monitoring jez_private"
  local tests=$(find . -maxdepth 1 -type d -name "barbu*")

  # Reverse if `rev` is first word ?
  if [[ "${1-}" == "rev" ]]; then
    >&2 echo "INFO: Reversing execution order"
    tests=$(reverse "$tests")
    shift || true
  fi

  # Get command
  local cmd=${1:-usage}
  shift || true || true
  local args=${@-}

  for i in $tests; do

    # Select command shortcuts
    case "$cmd" in
      clone|update)
        shift || true
        prj_clone
        return
        ;;
      doc|gen_doc*)
        shift || true
        gen_docs
        return
        ;;
      serve|serve_doc*)
        shift || true
        serve_docs $args
        return
        ;;

      st|status)
        shift || true
        cmd=prj_st
        ;;
      info)
        echo "INFO:   Normal order: $tests"
        echo "INFO: Reversed order: $(reverse $tests)"
        exit 
        ;;
      help|h|--help|-h|usage)
        main_usage
        exit 
        ;;
    esac

    >&2 echo ""
    >&2 echo ""
    >&2 echo ""
    >&2 echo "INFO: ==== Project: $i"
    >&2 echo "INFO: =================================="
    >&2 echo "INFO:"

    # Run in each dirs
    (
      >&2 echo "INFO: Running command in $i: $cmd $args"
      cd $i && $cmd $args || {
        >&2 echo "ERROR: Command returned rc=$?, for $i with $cmd $args"
        # And we continue
      }
    )

  done

  echo "INFO: Done!"
}


main $@

