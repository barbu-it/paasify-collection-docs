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
  validate      Validate each projects
  status        Show git status
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


#set -x
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
      st|status)
        shift || true
        cmd=prj_st
        ;;
      show)
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

