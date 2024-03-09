
function crop_once () {
    W=`identify ./$1 | cut -f 3 -d " " | sed s/x.*//` #width
    H=`identify ./$1 | cut -f 3 -d " " | sed s/.*x//` #height

    offset_top=32
    offset_bottom=16

    # echo "size: ${W}x${H}"

    H=$[H-offset_bottom-offset_top]

    # echo "new size: ${W}x${H}"

    convert "$1" -crop "${W}x${H}+0+${offset_top}" "$1"
}

if [ $# -gt 1 ]
then
    for image in $@
    do
        crop_once $image
    done
else
    crop_once $image
fi