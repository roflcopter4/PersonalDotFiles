#!/bin/sh

ShowUsage() {
    [ "$1" ] && out=2 || out=1
    echo "Usage: $0 -[ha] <source> <target>" >&$out
    [ $out -eq 1 ] && echo -- "-a prepends the source to the output for testing."
    exit "${1:-0}"
}
[ $# -eq 0 ] && ShowUsage 1

pre=
while getopts 'ha' ARG; do
    case "$ARG" in
        'h') ShowUsage ;;
        'a') pre='YES' ;;
        '?') echo 'Invalid argument' >&2 && ShowUsage 1 ;;
    esac
done
shift $((OPTIND -1))
{ [ $# -eq 0 ] || [ $# -gt 2 ]
    } && echo "Error: either 1 or 2 paramaters expected." >&2 && ShowUsage 1

# =============================================================================




#short_relative_path() {
#    us="$(realpath "$1")"
#    them="$(realpath "$2")"
#    rp=
#    [ "$us" = "$them" ] && echo '.' && return
#    while app="${them#"${us}/"}" 
#          [ "$us"  != '/'     ] &&
#          [ "$app"  = "$them" ] &&
#          [ "$app" != "$us"   ]
#    do
#        us="${us%/*}" 
#        rp="${rp}${rp:+/}.." 
#    done
#    [ "$us" != "$app" ] && rp="${rp}${rp:+${app:+/}}${app}"
#    echo "${rp#/}"
#}


short_relative_path() {
    us=$(realpath "$1") them=$(realpath "$2") rp=
    [ "$us" = "$them" ] && echo '.' && return
    while app="${them#"${us}/"}" 
          [ "$us"  != '/' ] && [ "$app"  = "$them" ] && [ "$app" != "$us" ]; do
        us="${us%/*}" 
        rp="${rp}${rp:+/}.." 
    done
    [ "$us" != "$app" ] && rp="${rp}${rp:+${app:+/}}${app}"
    echo "${rp#/}"
}





if [ ".${pre}" = '.YES' ]; then

    if [ $# -eq 2 ]; then
        this=$(realpath "$1")
        target=$(realpath "$2")
    else
        this=$(pwd)
        target=$(realpath "$1")
    fi
    pre="${pre:+${this}/}"
    rpath=

    [ "${this}" = "${target}" ] && echo "${pre}." && exit

    while appendix="${target#"${this}/"}" 
          [ "${this}"     != '/'         ] &&
          [ "${appendix}"  = "${target}" ] &&
          [ "${appendix}" != "${this}"   ]
    do
        this="${this%/*}" 
        rpath="${rpath}${rpath:+/}.." 
    done

    # Unnecessary '#/' to make 100% sure that there is never a leading '/'.
    if [ "${this}" = "${appendix}" ]; then
        echo "${pre}${rpath#/}"
    else
        rpath="${rpath}${rpath:+${appendix:+/}}${appendix}" 
        echo "${pre}${rpath#/}"
    fi

else

    if [ $# -eq 2 ]; then
        us=$(realpath "$1")
        them=$(realpath "$2")
    else
        us=$(pwd)
        them=$(realpath "$1")
    fi
#    rp=
    short_relative_path "$us" "$them"
#
#    # Just in case.
#    [ "$us" = "$them" ] && echo '.' && return
#
#    #i=1
#    #len="${#us}"
#    #echo -e "US: ${us}\t\tTHEM:  ${them}"
#
#    #
#    # app(endix) is the part of the target path that comes after the shared common root.
#    # That root could be '/' itself, or anything else, and it is stripped from
#    # the name. eg. for /usr/bin to /usr/share, the root is /usr and in this
#    # case the app is 'share', giving '../share'.
#    #
#    while app="${them#"${us}/"}" 
#          [ "$us"  != '/'     ] &&   # We've gotten to root, break
#          [ "$app"  = "$them" ] &&   # We've found the common stem - equiv to reaching '/'
#          [ "$app" != "$us"   ]      # They were behind us in the path.
#    do
#        # Strip the trailing filename from 'us'.
#        us="${us%/*}" 
#        # Add '/..' to the end of our output, but only add the initial slash
#        # if the variable is not empty, else it would start with '/'.
#        rp="${rp}${rp:+/}.." 
#
#        #printf 'Run no %2d, us:  %-*s  rp:  %-10s  app: %s\n' $i "$len" "$us" "$rp" "$app"
#        #i=$((i + 1))
#    done
#
#    #printf 'Run FINAL, us:  %-*s  rp:  %-10s  app: %s\n' "$len" "$us" "$rp" "$app"
#
#    if [ "$us" = "$app" ]; then
#        # The target was somewhere directly before up in path, the output
#        # therefore consists only of '..'s.
#        echo "${rp#/}"
#
#    elif [ -z "$rp" ]; then
#        # It's just a subdirectory. Nothing to see here, folks.
#        echo "${app#/}"
#
#    elif [ "$app" ]; then
#        # We found the common root, now just add the rest of the path to the
#        # series of '..'s.
#        rp="${rp}/${app}"
#        echo "${rp#/}"
#
#    else
#        # Should be impossible to reach.
#        echo "${rp#/}"
#
#    fi

fi

#${rp}${rp:+${app:+/}}${app}


#relative_path() {
#    us="$(realpath "$1")"
#    them="$(realpath "$2")"
#    rp=

#    # Just in case.
#    [ "$us" = "$them" ] && echo '.' && return

#    #
#    # app(endix) is the part of the target path that comes after the shared common root.
#    # That root could be '/' itself, or anything else, and it is stripped from
#    # the name. eg. for /usr/bin to /usr/share, the root is /usr and in this
#    # case the app is 'share', giving '../share'.
#    #
#    while app="${them#"${us}/"}" 
#          [ "$us"  != '/'     ] &&   # We've gotten to root, break
#          [ "$app"  = "$them" ] &&   # We've found the common stem - equiv to reaching '/'
#          [ "$app" != "$us"   ]      # They were behind us in the path.
#    do
#        # Strip the trailing filename from 'us'.
#        us="${us%/*}" 
#        # Add '/..' to the end of our output, but only add the initial slash
#        # if the variable is not empty, else it would start with '/'.
#        rp="${rp}${rp:+/}.." 
#    done

#    if [ "$us" = "$app" ]; then
#        # The target was somewhere directly before up in path, the output
#        # therefore consists only of '..'s.
#        echo "${rp#/}"

#    elif [ -z "$rp" ]; then
#        # It's just a subdirectory. Nothing to see here, folks.
#        echo "${app#/}"

#    elif [ "$app" ]; then
#        # We found the common root, now just add the rest of the path to the
#        # series of '..'s.
#        rp="${rp}/${app}"
#        echo "${rp#/}"

#    else
#        # Should be impossible to reach.
#        echo "${rp#/}"

#    fi
#}



