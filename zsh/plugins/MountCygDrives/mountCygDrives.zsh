
if [[ $IS_CYGWIN ]]; then
    # Make the directories
    #if [ ! -d /c ]; then
        #mkdir /c
    #fi
    #if [ ! -d /d ] && [[ -d /cygdrive/d ]]; then
        #mkdir /d
    #fi
    mkdir -p /c
    mkdir -p /d

    # Tell cygwin to look on / for mounted drives instead of /cygdrive/
    mount -c /

    # Mount Directories
    if [ -d /c ] && ! mount | grep 'on /c type' > /dev/null; then
        mount -o noacl,binary,posix=0,user 'C:' /c
    fi
    if [ -d /d ] && ! mount | grep 'on /d type' > /dev/null; then
        mount -o noacl,binary,posix=0,user 'D:' /d
    fi

    if [[ $(pwd) =~ 'cygdrive' ]]; then
        DIR=`echo $(pwd) | sed s,/cygdrive,,g`
        cd "$DIR"
    fi
fi
