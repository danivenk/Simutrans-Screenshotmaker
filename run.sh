#!/bin/bash

convert -list resource

function run_once () {
    # 1 - simutrans exe
    # 2 - pakset
    # 3 - savefile
    # 4,5 - x,y position
    # 6 - screenshot directory

    printf "make screenshot at $4,$5\n"

    unset -v latest
    for file in "$6"/*; do
    [[ $file -nt $latestb ]] && latestb=$file
    done

    latest="$latestb"

    "$1" -fullscreen -objects $2 -load $3 -mute -pause -nomidi -snapshot "$4,$5,2,3" > /dev/null &

    while [ "$latest" == "$latestb" ]
    do
        unset -v latest
        for file in "$6"/*; do
        [[ $file -nt $latest ]] && latest=$file
        done
    done

    extension="${latest##*.}"

    if [ -z $7 ]
    then
        mv -f "$latest" "$outfolder/doit/$4-$5.$extension"
    else
        mv -f "$latest" "$outfolder/doit/$7.$extension"
    fi
    cd "$outfolder/doit"

    unset -v latest
    for file in ./*; do
    [[ $file -nt $latest ]] && latest=$file
    done

    W=`identify ./$latest | cut -f 3 -d " " | sed s/x.*//` #width
    H=`identify ./$latest | cut -f 3 -d " " | sed s/.*x//` #height

    offset_top=32
    offset_bottom=16

    H=$[H-offset_bottom-offset_top]

    echo "new size: ${W}x${H}"

    convert "$latest" -crop "${W}x${H}+0+${offset_top}" "$latest"
}

# 1 = /mnt/c/Program\ Files\ \(x86\)/Simutrans/sim-OTRP.exe
# 2 = pak192.comic-serverset-nightly
# 3 = MapMP-day_14-1
# 4, 5 = (x1,y1) (x2,y2) || (2314,116)
# 6 = /mnt/c/Users/danivenk/OneDrive/Documents/simutrans/screenshot
# 7 = 192
# 8 = Tröndel-Hbf
#
# example ./run.sh /mnt/c/Program\ Files\ \(x86\)/Simutrans/sim-OTRP.exe pak192.comic-serverset-nightly MapMP-day_32-1 2314,116 2314,116 /mnt/c/Users/danivenk/OneDrive/Documents/simutrans/screenshot Tröndel-Hbf

outfolder=$(pwd)
padding=5

if [ -z "$*" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
    printf "usage: ./run.sh <PATH EXE> <PAKSET NAME> <SAVEFILE> <POS1> <POS2>\n"
    printf "   PATH EXE\t - path to simutrans exe\n"
    printf "   PAKSET NAME\t - name of pakset\n"
    printf "   SAVEFILE\t - name of savefile\n"
    exit 1
fi

echo "heading to $6"
cd "$6"

IFS=',' read -ra pos1 <<< "$4"
IFS=',' read -ra pos2 <<< "$5"

if [ ${pos1[0]} -ge ${pos2[0]} ]
then
    x1=${pos2[0]}; x2=${pos1[0]}
    y1=${pos2[1]}; y2=${pos1[1]}
else
    x1=${pos1[0]}; x2=${pos2[0]}
    y1=${pos1[1]}; y2=${pos2[1]}
fi

# x1=$[x1 - padding]; x2=$[x2 + padding]; y1=$[y1 - padding]; y2=$[y2 + padding];

xcenter=$[x1 + (x2-x1)/2]; ycenter=$[y1 + (y2-y1)/2]

run_once "$1" "$2" "$3" "$xcenter" "$ycenter" "$6" "center"

Width=`identify ./center.png | cut -f 3 -d " " | sed s/x.*//` #width
Height=`identify ./center.png | cut -f 3 -d " " | sed s/.*x//` #height

angle=$(awk 'BEGIN{print atan2(96, 192)}')
step_w=$[$7]; step_h=$(awk -v x=$angle -v A=$7 'BEGIN{printf "%.0f\n", int(A*sin(x)/cos(x) + 0.5)}')

tiles_w=$[(Width)/(step_w)]; tiles_h=$[(Height)/(step_h)]

xsize=$[x2-x1]; ysize=$[y2-y1]


total_w=$(awk -v x=$angle -v A=$xsize -v B=$ysize 'BEGIN{printf "%.0f\n", int(B*cos(x) + A*cos(x) + 0.5)}')
total_h=$(awk -v x=$angle -v A=$xsize -v B=$ysize 'BEGIN{printf "%.0f\n", int(B*sin(x) + A*sin(x) + 0.5)}')

# if [ $xsize -ge $ysize ]
# then
#     total_w=$xsize
#     total_h=$xsize
# else
#     total_w=$ysize
#     total_h=$ysize
# fi

screen_w=$[(total_w+tiles_w-1)/(tiles_w)]; screen_h=$[(total_h+tiles_h-1)/(tiles_h)]

echo "step in px: ${step_h}x${step_w}, single screen in tiles: $[tiles_h]x$[tiles_w]"
echo "total tiles: ${xsize}x${ysize}"
echo "total no of tiles: ${total_h}x${total_w}, no of screens: ${screen_h}x${screen_w}"

echo "total screenshots $[screen_w*screen_h]"

offset=$(awk -v x=$angle -v A=$[tiles_w*step_w] -v w=$step_w -v h=$step_h 'BEGIN{printf "%.0f\n", A/(cos(x)*sqrt(w^2+h^2))}')
# xcenter=$[x1 + xsize/2]; ycenter=$[y1 + ysize/2]

echo "offset $offset"
echo "Center at ($xcenter, $ycenter)"

x_start=$[xcenter-screen_w/2*offset]; y_start=$[ycenter+screen_h/2*offset];
if [ $[screen_w % 2] -eq 0 ]
then
    x_start=$[x_start - offset/2]
fi
if [ $[screen_h % 2] -eq 0 ]
then
    y_start=$[y_start + offset/2]
fi

for ((i=0; i<screen_h; i++))
do
    for ((j=0; j<screen_w; j++))
    do
        x=$[x_start+(i+j)*offset]; y=$[y_start-(j-i)*offset]
        echo "Screenshot no: $i-$j"
        run_once "$1" "$2" "$3" "$x" "$y" "$6" "$i-$j"
    done

    convert $i-*.png +smush -0 out-$i.png

    rm -f $i-*.png
done

convert out-*.png -smush -$[step_h*3/4] $8.png
rm -f out-*.png