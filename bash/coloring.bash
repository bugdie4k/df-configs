# -*- mode: shell-script -*-

# This file is to be sourced

# commands are
#  colors
#  colorsfilter # same as 'colors -fo'
#  colorname
#  colornames
#  colornamesfilter # same as 'colornames -fo'
#  echo-color
#  setcolor
#  resetcolor
#  color-info
#  nearest-color
#  rgb2n
#  n2rgb
#
#  colorlist # for parsing

source ${CONFIGS}/bash/coloring.data.bash

__general_coloring_help(){
    echo
    echo
    echo "GENERAL COLORING INFO:"
    echo "  Use 'colornames' command to see available colornames"
    echo "  Use 'colors' to have a better look at all colors"
    echo "  To filter colors by part of a color name use one of the following:"
    echo "   - 'colors -fo' or 'colorsfilter' "
    echo "   - 'colors -f'"
    echo "   - 'colornames -fo' or 'colornamesfilter'"
    echo "   - 'colornames -f"
    echo "  Use 'echo-color' to echo with color"
    echo "  Also see 'setcolor', 'resetcolor', 'color-info' and 'nearest-color'"
}

__colors_help(){
    echo 'USAGE:'
    echo '  colors [-n|--number <number>] [[-f|--filter] <name>] [-fo|--filtered-only <name>] [-h|--help]'
    echo
    echo '  -n  <number>=1..256 - number of colors to print. By default prints all.'
    echo "  -f  <name>=string   - a part of color name to filter list by. To see all color names call 'colornames'."
    echo "  -fo  Same as -f but prints colors in one column one by one."
    echo
    echo "  When given an arg without an option assumes it is <name> for filter."
    __general_coloring_help
}

__colors_print_color(){
    local num="$1"
    local filter="$2"
    if [[ ${COLORNAMES[$num]} =~ ^.*$filter.*$ ]]; then
        printf "$(tput setaf $1)%3d $(tput setab $1)   \e[0m" $num
    else
        printf "%7s" ""
    fi
}

colorsfilter(){
    local filter="$1"
    local colorname
    if [ -z $filter ]; then
        colors
    else
        local count=1
        declare -i count
        for ((i=0; i<256; i++)); do
            colorname=${COLORNAMES[$i]}
            if [[ $colorname =~ ^.*$filter.*$ ]]; then
                __colors_print_color $i $colorname
                [ ! $((count % 6)) -eq 0 ] && printf '  ' || echo
                count+=1
            fi
        done
        echo
    fi
}

colors(){
    : prints all colors of the terminal

    local filter colors_number
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) __colors_help; return 0 ;;
            -f|--filter) filter="$2"; shift ;;
            -fo|--filtered-only) colorsfilter "$2"; return 0 ;;
            -n|--number) colors_number="$2"; shift ;;
            *) local filter="$1" ;;
        esac
        shift
    done

    [[ ! $colors_number =~ ^[0-9]+$ ]] && colors_number=256

    printf "0-15:\n"
    for ((i=0; i<16; i++)); do
        [ $i -eq $colors_number ] && echo && return 0 ||
                __colors_print_color $i $filter
        [ ! $(((i + 1) % 8)) -eq 0 ] && printf '  ' || echo
    done

    [ $colors_number -eq 16 ] && echo && return 0

    local num num2 range1 range2
    local hit_the_limit=0
    for ((i=0; i<3; i++)); do

        num=$((16 + (i * 72)))
        range1="$num-$((num + 35)):"
        num2=$((num + 36))
        [ $num2 -ge $colors_number ] && range2='' || range2="$num2-$((num2 + 35)):"

        printf "\n%-56s%-56s\n" $range1 $range2
        for ((j=0; j<6; j++)); do
            for ((k=0; k<6; k++)); do
                num=$((16 + (i * 72) + (j * 6) + k))
                [ $num -eq $colors_number ] && echo && return 0 ||
                        __colors_print_color $num $filter
                printf '  '
            done

            printf '  '

            for ((k=0; k<6; k++)); do
                num=$((16 + (i * 72) + (j * 6) + k + 36))
                [ $num -ge $colors_number ] && printf '%7s' '' && hit_the_limit=1 ||
                        __colors_print_color $num $filter
                printf '  '
            done
            echo
        done

        [ $hit_the_limit -eq 1 ] && return 0
    done

    printf "\n232-255:\n"
    for((i=232; i<256; i++)); do
        __colors_print_color $i $filter
        [ $((i + 1)) -eq $colors_number ] && echo && return 0
        [ ! $((($i - 15) % 6)) -eq 0 ] && printf '  ' || printf '\n'
    done
}

export __COLORNAMES_DEFAULT_COLUMNS=6

__colornames_help(){
    echo "USAGE:"
    echo "  colornames [-c|--columns <number>] [[-f|--filter] <name>] [-fo|--filtered-only <name>] [-h|--help]"
    echo
    echo "  -c   <number>=1..255 - number of columns to print, default is __COLORNAMES_DEFAULT_COLUMNS=$__COLORNAMES_DEFAULT_COLUMNS"
    echo "  -f   <name>=string - a part of color name to filter list by. Would print colornames that has <name> inside"
    echo "  -fo  Same as -f but prints colors in one column one by one"
    echo
    echo "  When given an arg without an option assumes it is <name> for filter."
    __general_coloring_help
}

__colornames_print_colorname(){
    if [ $# -eq 0 ]; then
        printf "  %-3s %-20s " " " " "
        return 0
    fi

    local nocolors="$1"
    local num="$2"
    local colorname="$3"
    local sharp='#'
    if [ "$nocolors" = "0" ]; then
        [[ $num =~ ^[0-9]+$ ]] && sharp="$(tput setaf $num)$sharp$(tput sgr0)" || sharp=' '
    fi

    printf "$sharp %-3s %-20s " "$num" "$colorname"
}

colornamesfilter(){
    local filter="$1"
    local colorname
    if [ -z $filter ]; then
        colornames
    else
        for i in {0..255}; do
            colorname=${COLORNAMES[$i]}
            [[ $colorname =~ ^.*$filter.*$ ]] && __colornames_print_colorname 0 $i $colorname && echo
        done
    fi
}

colorname(){
    if [ $# -eq 0 ]; then
        echo colorname: Specify color number && return 1
    fi

    local -i nonewline=0
    local num
    while [ $# -gt 0 ]; do
        case "$1" in
            blank) __colornames_print_colorname; return 0 ;;
            -n) nonewline=1 ;;
            --num) num="$2"; shift ;;
            *) num="$1" ;;
        esac
        shift
    done

    if [ "$(__get_color_name_by_number $num)" != "-1" ]; then
        __colornames_print_colorname 0 $num ${COLORNAMES[$num]}
        [ $nonewline -eq 0 ] && echo
    else
        echo colorname: $num is a wrong color number
    fi
}

colornames(){
    local columns filter
    local -i nocolors=0
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) __colornames_help; return 0 ;;
            -f|--filter) filter="$2"; shift ;;
            -fo|--filtered-only) colornamesfilter "$2"; return 0 ;;
            -c|--columns) columns="$2"; shift ;;
            --no-colors|-n) nocolors=1 ;;
            *) filter="$1" ;;
        esac
        shift
    done

    [[ ! $columns =~ ^[0-9]+$ ]] && columns=$__COLORNAMES_DEFAULT_COLUMNS

    [ $columns -gt 256 ] && echo $(tput setaf 1)UMADBRO$(tput sgr0) && return 1

    local column_length=$((256 / columns))
    local left=$((256 - (column_length * columns)))
    [ $left -gt 0 ] && column_length=$((column_length + 1))

    local num left_modifier color
    for ((i=0; i<$column_length; i++)); do
        for ((j=0; j<$columns; j++)); do
            [ $j -eq 0 ] && left_modifier=0 || left_modifier=1
            num=$((i + (j * column_length)))
            color=${COLORNAMES[$num]}
            if [ $num -lt 256 ]; then
                if [[ $color =~ ^.*$filter.*$ ]]; then
                    __colornames_print_colorname $nocolors $num $color
                else
                    __colornames_print_colorname
                fi
            fi
        done
        echo
    done
}

__is_color_number(){
    [[ $1 =~ ^[0-9]+$ ]] && [ $1 -le 255 ] && return 0 || return 1
}

__get_color_number_by_name () {
    if __is_color_number $1; then
        echo -n $1 && return 0
    else
        for i in {0..255}; do
            [ "${COLORNAMES[$i]}" = "$1" ] || [ "${SIMPLER_COLORNAMES[$i]}" = "$1" ] && echo -n $i && return 0
        done
    fi
    echo -n "-1" && return 1
}

__get_color_name_by_number(){
    if __is_color_number $1; then
        echo -n "${COLORNAMES[$1]}"
    else
        echo -n "-1" && return 1
    fi
}

__setcolor_help(){
    echo 'USAGE:'
    echo '  setcolor [-f|--foreground <color>] [-b|--background <color>] [-h|--help] [--colors] [--colornames|--names] [--quiet|-q]'
    echo
    echo '  <color>=0..255'
    echo
    echo '  if arg passed with no preceding option, assumes it is foreground'
    echo '  --quiet option suppresses error message and does nothing when colors are wrong returning 0'
    echo
    echo 'EXAMPLES:'
    echo '  $ echo "$(setcolor red)[ERROR] ВСЁ ПРОПАЛО, ПОЦОНЫ" '
    echo '  $ echo "$(setcolor -b black -f green)[NORMAS] ТАЩЕМТА ВСЁ НОРМАС, ПОЦОНЫ" '
    echo '  $ setcolor purple-1b && echo -n "this is purple text. " && setcolor -b orange-1 && echo "now it has orange background" && setcolor -b black'
    echo
    echo "  Note how the following command doesn't output the \"MESSAGE\" word but outputs error message"
    echo '  $ setcolor worngcolor && echo MESSAGE'
    __general_coloring_help
}

setcolor () {
    if [ "$1" == "normal" ]; then
        resetcolor
    else
        local quiet=0
        local -i err=0
        while [[ $# -gt 0 ]]
        do
            local key="$1"
            case $key in
                -q|--quiet)
                    quiet=1 ;;
                -f|--foreground)
                    local fg="$(__get_color_number_by_name $2)"
                    shift # past argument
                    ;;
                -b|--background)
                    local bg="$(__get_color_number_by_name $2)"
                    shift # past argument
                    ;;
                -h|--help)
                    __setcolor_help
                    return 0
                    ;;
                --colors)
                    colors
                    return 0
                    ;;
                --colornames|--names)
                    colornames
                    return 0
                    ;;
                *)
                    # if arg passed with no preceding option -
                    # assume it is foreground
                    local fg="$(__get_color_number_by_name $1)"
                    ;;
            esac
            shift # past argument or value
        done

        if [ "$fg" = "-1" ]; then
            if [ $quiet -eq 0 ]; then
                err=1
                echo "!!! setcolor: Wrong foreground color !!!"
            fi
        else
            if [ "${fg:+x}" = "x" ]; then
                tput setaf $fg
            fi
        fi

        if [ "$bg" = "-1" ]; then
            if [ $quiet -eq 0 ]; then
                err=1
                echo "!!! setcolor: Wrong background color !!!"
            fi
        else
            if [ "${bg:+x}" = "x" ]; then
                tput setab $bg
            fi
        fi

        return $err
    fi
}

resetcolor(){
    echo -n $(tput sgr0)
}

__echo-color_help(){
    echo 'USAGE:'
    echo '  echo-color [-f|--foreground <color>] [-b|--background <color>] [-t|--text <text>] [-n|--no-newline] [-h|--help] [--colors] [--colornames|--names] [-q|--quiet]'
    echo
    echo '  <color>=0..255'
    echo '  <text>=string'
    echo
    echo '  if arg is passed with no preceding option, assumes it is text to be printed'
    echo '  --help option overrides all others and just prints help when combined with other options'
    echo '  --quiet option suppresses error message and does echo when colors are wrong returning 0'
    echo
    echo 'EXAMPLES:'
    echo '  $ echo-color -f red -b green -t "hehe" '
    echo '  $ echo-color -f purple -b 67 "hehe, no -t option" '
    __general_coloring_help
}

echo-color () {
    local quiet=0
    local -i err=0
    while [ $# -gt 0 ]
    do
        local key="$1"
        case $key in
            -q|--quiet)
                local quiet=1 ;;
            -f|--foreground)
                local fg0="$2"
                local fg="$(__get_color_number_by_name $2)"
                shift # past argument
                ;;
            -b|--background)
                local bg0="$2"
                local bg="$(__get_color_number_by_name $2)"
                shift # past argument
                ;;
            -t|--text)
                local txt=$2
                shift
                ;;
            -n|--no-newline)
                local nonewline="" # it is now set
                ;;
            -h|--help)
                __echo-color_help
                return 0
                ;;
            --colors)
                colors
                return 0
                ;;
            --colornames|--names)
                colornames
                return 0
                ;;
            *)
                # if arg passed with no preceding option -
                # assume it is text
                local txt="$@"
                break
                ;;
        esac
        shift # past argument or value
    done

    if [ "$fg" = "-1" ]; then
        if [ $quiet -eq 0 ]; then
            err=1
            echo "echo-color: Wrong foreground color: $fg0"
        fi
    else
        if [ "${fg:+x}" = "x" ]; then
            tput setaf $fg
        fi
    fi

    if [ "$bg" = "-1" ]; then
        if [ $quiet -eq 0 ]; then
            err=1
            echo "echo-color: Wrong background color: $bg0"
        fi
    else
        if [ "${bg:+x}" = "x" ]; then
            tput setab $bg
        fi
    fi

    echo -en "${txt-}\e[1;m${nonewline-${txt+\n}}"

    return $err
}

__color-info_print_info(){
    local colnum=$1
    local colname=$(__get_color_name_by_number $colnum)
    local str1=$(printf "%-3s %-20s" $colnum $colname)
    local altname=${SIMPLER_COLORNAMES[$colnum]}

    echo-color -b grey-0 -f $colnum -t " $str1 " -n
    echo -n " │ "
    echo-color -b $colnum -f grey-0 -t " $str1 " -n
    echo -n " │ "
    echo-color -b grey-100 -f $colnum -t " $str1 " -n
    echo -n " │ "
    echo-color -b $colnum -f grey-100 -t " $str1 " -n
    echo -n " │ "

    printf "%-7s" "${COLORHEXCODES[$colnum]}"
    [ $colnum -lt 16 ] && echo -n " (но это не точно)"
    [ -n "$altname" ] && echo -n "  $altname"

    echo
}

__color-info_help(){
    echo 'USAGE:'
    echo '  color-info [-h|--help] COLOR'
    echo
    echo "  COLOR - should be a valid color number or a valid color name"
    echo "          or part of a valid color name or a pattern of a part "
    echo "          of a valid color name."
    __general_coloring_help
}

color-info(){
    [ $# -eq 0 ] && echo "color-info: You have to pass number or name of a color. Use -h for help." && return 1
    [ "$1" = "-h" ] || [ "$1" = "--help" ] && __color-info_help && return 0

    if __is_color_number $1; then
        __color-info_print_info $1 && return 0
    fi

    local colnum=$(__get_color_number_by_name $1)
    if [ "$colnum" != "-1" ]; then
        __color-info_print_info $colnum
    else
        local ok=0
        for i in {0..255}; do
            colorname=${COLORNAMES[$i]}
            [[ $colorname =~ ^.*$1.*$ ]] && __color-info_print_info $i && ok=1
        done
        [ $ok -eq 0 ] && echo "color-info: Provide a valid color number or a valid color name or part of a valid color name or a pattern of a part of a valid color name." && return 1
    fi
}

# nearest color

__nc_help(){
    echo "DESCRIPTION:"
    echo "  Finds the nearest color to the given hex in 256 palette."
    echo
    echo "USAGE:"
    echo "  nearest-color [[-c|--code] CODE] [-s|--scale SCALE] [-h|--help]"
    echo
    echo "  CODE  - hex color code in format RRGGBB or #RRGGBB"
    echo "  SCALE - the number of digits after floating point that is used"
    echo "        to calculate ratiodistance"
    __general_coloring_help
}

__nc_rgb_hex_distances(){
    local scale hex1 hex2 r1 g1 b1 r2 g2 b2
    hex1=${1#\#}; hex2=${2#\#}
    scale=$3
    r1=$((16#${hex1:0:2})); g1=$((16#${hex1:2:2})); b1=$((16#${hex1:4:2})); r2=$((16#${hex2:0:2})) g2=$((16#${hex2:2:2})); b2=$((16#${hex2:4:2}))
    echo "scale=0;
dr=$r1-$r2; dg=$g1-$g2; db=$b1-$b2;
dist=dr^2 + dg^2 + db^2;

scale=$scale;
if ($g1 == 0) g1=0.1 else g1=$g1
rg1=$r1/g1; bg1=$b1/g1; g1=$g1
if ($b1 == 0) b1=0.1 else b1=$b1
gb1=$g1/b1; rb1=$r1/b1; b1=$b1
if ($r1 == 0) r1=0.1 else r1=$r1
gr1=$g1/r1; br1=$b1/r1; r1=$r1

if ($g2 == 0) g2=2 else g2=$g2
rg2=$r2/g2; bg2=$b2/g2; g2=$g2
if ($b2 == 0) b2=2 else b2=$b2
gb2=$g2/b2; rb2=$r2/b2; b2=$b2
if ($r2 == 0) r2=2 else r2=$r2
gr2=$g2/r2; br2=$b2/r2; r2=$r2

drg=rg1-rg2; dgb=gb1-gb2; drb=rb1-rb2;
dgr=gr1-gr2; dbg=bg1-bg2; dbr=br1-br2;

ratiodist=(drg^2 + dgb^2 + drb^2 + dgr^2 + dbg^2 + dbr^2) * 10^$scale;
scale=0;
print dist, \"&&\", ratiodist / 1;
" | bc -l
}

nearest-color(){
    local scale hex1 numd dists dist mindist numrd minratiodist ratiodist

    [ $# -eq 0 ] && echo "nearest-color: You have to pass arguments. Use -h for help." && return 1
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) __nc_help && return 0 ;;
            -c|--code) hex1=${2#\#}; shift ;;
            -s|--scale) scale=$2; shift ;;
            *) hex1=${1#\#} ;;
        esac
        shift
    done
    [ "$hex1" = "" ] && echo "nearest-color: You have to enter hex code." && return 1

    scale=${scale:-2}

    dists=$(__nc_rgb_hex_distances $hex1 000000 $scale); mindist=${dists%&&*}; minratiodist=${dists#*&&}
    numd=0; numrd=0;

    if [ ! $mindist -eq 0 ]; then
        for i in {1..255}; do
            dists=$(__nc_rgb_hex_distances $hex1 ${COLORHEXCODES[$i]} $scale); dist=${dists%&&*}; ratiodist=${dists#*&&}
            [ $dist -eq 0 ] && numd=$i && mindist=$dist && numrd=$i && minratiodist=0 && break
            [ $dist -lt $mindist ] && mindist=$dist && numd=$i
            [ $ratiodist -lt $minratiodist ] && minratiodist=$ratiodist && numrd=$i
        done
    fi

    echo "By distance ($mindist)"
    color-info $numd

    echo "Scale is $scale"
    echo "By ratiodistance ($minratiodist)"
    color-info $numrd
}

rgb2n(){
    : input is an rgb which is a base 6 number
    echo $((6#$1 + 16))
}

n2rgb(){
    if [ $1 -lt 16 ] || [ $1 -gt 231 ]; then
        echo "n2rgb: number must be in range [16; 231]" && return 1
    else
        local res=$(echo "ibase=10; obase=6; $1 - 16" | bc)
        if [ ${#res} -eq 1 ]; then
            echo "00$res"
        elif [ ${#res} -eq 2 ]; then
            echo "0$res"
        else
            echo $res
        fi
    fi
}

colorpathlist(){
    local c1=$1
    local c2=$2
    local rgb1=$(n2rgb $c1)
    local rgb2=$(n2rgb $c2)
    local r1=${rgb1:0:1}
    local g1=${rgb1:1:1}
    local b1=${rgb1:2:1}
    local r2=${rgb2:0:1}
    local g2=${rgb2:1:1}
    local b2=${rgb2:2:1}

    local dr dg db
    [ $r2 -gt $r1 ] && dr=1 || dr=-1
    [ $g2 -gt $g1 ] && dg=1 || dg=-1
    [ $b2 -gt $b1 ] && db=1 || db=-1

    for ((r=$r1; r!=$r2; r+=$dr)); do
        echo $(rgb2n "${r}${g1}${b1}")
    done

    for ((g=$g1; g!=$g2; g+=$dg)); do
        echo $(rgb2n "${r}${g}${b1}")
    done

    for ((b=$b1; b!=$b2; b+=$db)); do
        echo $(rgb2n "${r}${g}${b}")
    done
    echo $(rgb2n "${r}${g}${b}")
}

colorpathlist_demo(){
    for c in $(colorpathlist $1 $2); do echo-color -n -f $c -t "${3:-@}"; done
}

# plumbing
colorlist(){
    if [ "$1" == "-n" ] || [ "$1" == "--names" ]; then
        for name in ${COLORNAMES[*]}; do
            echo $name
        done
    else
        for i in {0..255}; do
            echo $i ${COLORNAMES[$i]}
        done
    fi
}
