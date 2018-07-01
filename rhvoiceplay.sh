#!/bin/sh

fhlp="false"
tspeaker="aleksandr"
tln=0
while getopts ":l:s:h" opt
do
    case $opt in
        l) tln="$OPTARG"
            ;;
        s) tspeaker="$OPTARG"
            ;;
        h) fhlp="true"
            ;;
        *) echo "Unknown option -$OPTARG"
            exit 1
            ;;
    esac
done
shift "$(($OPTIND - 1))"
text="$1"
if [ "x$text" = "x" -o "x$fhlp" = "xtrue" ]
then
    echo "Usage:"
    echo "$0 [options] book.txt"
    echo "Options:"
    echo "    -l N    line begin [N=0-100] (default = 0)"
    echo "    -s str  RHVoice speaker (default = aleksandr)"
    echo "    -h      help"
    exit 0
fi

if [ ! "$(command -v RHVoice)" -a ! "$(command -v RHVoice-client)" ]
then
    echo "WARNING! RHVoice not found"
    exit 1
fi

text="$1"
textsize=$(zcat "$text" | sed -e 's/[\.\?\!\…]/&\n/g' | sed -e '/^$/d' | wc -l)
echo "$text: $textsize"
tln=$(($tln*$textsize/100))
i=$tln
if [ "$(command -v RHVoice)" ]
then
    zcat "$text" | sed -e 's/[\.\?\!\…]/&\n/g' | sed -e '/^$/d' | sed -e "1,${tln}d" | while read tline; do p=$((10000*$i/$textsize)); p1=$(($p/100)); p2=$(($p-$p1*100)); printf "%02d.%02d: " $p1 $p2; echo "$tline"; echo "$tline" | RHVoice | aplay - 2>/dev/null; (( i++ )); done
else
    zcat "$text" | sed -e 's/[\.\?\!\…]/&\n/g' | sed -e '/^$/d' | sed -e "1,${tln}d" | while read tline; do p=$((10000*$i/$textsize)); p1=$(($p/100)); p2=$(($p-$p1*100)); printf "%02d.%02d: " $p1 $p2; echo "$tline"; echo "$tline" | RHVoice-client -s "$tspeaker" | aplay - 2>/dev/null; (( i++ )); done
fi
