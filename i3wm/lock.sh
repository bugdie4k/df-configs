#!/usr/bin/env bash

# requirements;
# timew - https://taskwarrior.org/docs/timewarrior/
# jq - lightweight and flexible command-line JSON processor

export LCKSH_WORKING_STATE_TAG=W
export LCKSH_AFK_STATE_TAG=AFK

export LCKSH_LOCKFILE="/tmp/${0##*/}.lockfile"
export LCKSH_MINS_BEFORE_STOP=5
export LCKSH_AFK_HOURS_LIMIT=2

if [ ! -e $LCKSH_LOCKFILE ]; then

    function lcksh_stop_work(){
        timew stop $LCKSH_WORKING_STATE_TAG
    }

    function lcksh_shorten_last(){
        timew shorten @1 ${LCKSH_MINS_BEFORE_STOP}min
    }

    function lcksh_start_afk_right_after_last(){
        timew start $(timew get dom.tracked.1.end) "$LCKSH_AFK_STATE_TAG"
    }

    function lcksh_stop_work_after_minutes(){
        sleep ${LCKSH_MINS_BEFORE_STOP}m &&
            if [ -e $LCKSH_LOCKFILE ]; then
                lcksh_stop_work &&
                    lcksh_shorten_last &&
                    lcksh_start_afk_right_after_last
            fi
    }

    function lcksh_on_locking(){
        echo $(date +%s) > $LCKSH_LOCKFILE

        notify-send "${LCKSH_MINS_BEFORE_STOP} MINUTES BEFORE WORK IS STOPPED"
        lcksh_stop_work_after_minutes &
    }

    function lcksh_date_diff(){
        local -r date=$(date -u --date=@$(($(date +%s) - $(cat $LCKSH_LOCKFILE))) +%d/%T)
        local -ri day=${date%/*} # cut end
        local -r time=${date#*/} # cut start
        echo $((day - 1))/$time
    }

    function lcksh_get_hours_of(){
        local -ri num=${1:-1}

        # ISO 8601 for durations
        local -r duration=$(timew get dom.tracked.${num}.duration)

        # if duration even has hours in it
        if grep -q H <<< "$duration"; then
            # see if there are days
            local days=${duration#P}
            days=${days%T*}

            if [ -z "$days" ]; then
                local -r  hours_tmp=${duration#P*T} # cut start
                local -ri hours=${hours_tmp%H*} # cut end
                # local -ri hours=$(sed 's/P.*T\([0-9]\+\)H.*/\1/' <<< "$duration") # <- sed looks ugly
            else
                local -ri hours=$LCKSH_AFK_HOURS_LIMIT # NOTE: supposed to be compared with >=
            fi
        else
            local -ri hours=0
        fi

        echo $hours
    }

    function lcksh_return_to_work_from_afk(){
        local -i hours=$(lcksh_get_hours_of 1)

        # delete if AFKing for too long
        if [ $hours -ge $LCKSH_AFK_HOURS_LIMIT ]; then

            timew delete @1
        fi

        timew start $LCKSH_WORKING_STATE_TAG
    }

    function lcksh_on_unlocking(){
        local -r tag1=$(timew get dom.tracked.1.json | jq ".tags[0]" -M -r)
        if [ "$tag1" = "$LCKSH_WORKING_STATE_TAG" ]; then
            timew continue
        elif [ "$tag1" = "$LCKSH_AFK_STATE_TAG" ]; then
            timew stop
            lcksh_return_to_work_from_afk
        fi

        notify-send "AWAY FOR" "$(lcksh_date_diff)" -t 7000
        rm $LCKSH_LOCKFILE
    }

    function lcksh_i3lock(){
        local -r blank="#00000000"
        local -r main="#dd1fffcc"
        local -r active="#771fffcc"
        local -r dim="#00000099"
        local -r wrong="#ff0000cc"

        local -r timestr="%H:%M"
        local -r datestr="%A %d.%m.%y"

        local -r font=monospace
        local -r vertxt="HM..."
        local -r wrongtxt="NOPE"

        i3lock \
            -i ~/Pictures/wallpapers/road-with-palms-"$DF_THIS_MACHINE".png \
            -t \
            --ringcolor="$main" \
            --keyhlcolor="$active" \
            --insidecolor="$dim" \
            --linecolor="$blank" \
            --separatorcolor="$blank" \
            \
            --veriftext="$vertext" \
            --insidevercolor="$dim" \
            --ringvercolor="$active" \
            --textcolor="$main" \
            \
            --wrongtext="$wrongtxt" \
            --insidewrongcolor="$dim" \
            --ringwrongcolor="$wrong" \
            \
            --timestr="$timestr" \
            --datestr="$datestr" \
            --timefont="$font" \
            --datefont="$font" \
            --timecolor="$main" \
            --clock \
            \
            --indicator \
            --show-failed-attempts \
            \
            --nofork
    }

    if [ "$DF_THIS_MACHINE" = "work" ]; then
        lcksh_on_locking && lcksh_i3lock && lcksh_on_unlocking
    else
        lcksh_i3lock
    fi
fi
