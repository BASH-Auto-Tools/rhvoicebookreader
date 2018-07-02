#!/bin/sh
#rhvoiceplay.sh
#Depends: dash, rhvoice, aplay

sname="RHVoicePlay"
sversion="0.20180702"

echo "$sname $sversion" >&2

tln=0
tspeaker="aleksandr"
fhlp="false"
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
    echo "$0 [options] book.txt|-|string"
    echo "Options:"
    echo "    -l N    line begin [N=0-100] (only .txt, default = 0)"
    echo "    -s str  RHVoice speaker (RHVoice >=0.5, default = aleksandr)"
    echo "    -h      help"
    exit 0
fi

if [ ! "$(command -v RHVoice)" -a ! "$(command -v RHVoice-client)" ]
then
    echo "WARNING! RHVoice not found" >&2
    exit 1
fi

if [ ! "$(command -v aplay)" ]
then
    echo "WARNING! aplay not found" >&2
    exit 1
fi

if [ -f "$text" ]
then
    textsize=$(zcat "$text" | sed -e 's/[\.\?\!\…]/&\n/g' | sed -e '/^$/d' | wc -l)
    echo "$text: $textsize" >&2
    tln=$(($tln*$textsize/100))
    i=$tln
    if [ "$(command -v RHVoice)" ]
    then
        zcat "$text" | sed -e 's/[\.\?\!\…]/&\n/g' | sed -e '/^$/d' | sed -e "1,${tln}d" | while read tline; do p=$((10000*$i/$textsize)); p1=$(($p/100)); p2=$(($p-$p1*100)); printf "%02d.%02d: " $p1 $p2; echo "$tline"; echo "$tline" | RHVoice | aplay - 2>/dev/null; (( i++ )); done
    else
        zcat "$text" | sed -e 's/[\.\?\!\…]/&\n/g' | sed -e '/^$/d' | sed -e "1,${tln}d" | while read tline; do p=$((10000*$i/$textsize)); p1=$(($p/100)); p2=$(($p-$p1*100)); printf "%02d.%02d: " $p1 $p2; echo "$tline"; echo "$tline" | RHVoice-client -s "$tspeaker" | aplay - 2>/dev/null; (( i++ )); done
    fi
elif [ "x$text" = "x-" ]
then
    if [ "$(command -v RHVoice)" ]
    then
        while read tline; do printf ": "; echo "$tline"; echo "$tline" | RHVoice | aplay - 2>/dev/null; done
    else
        while read tline; do printf ": "; echo "$tline"; echo "$tline" | RHVoice-client -s "$tspeaker" | aplay - 2>/dev/null; done
    fi
else
    if [ "$(command -v RHVoice)" ]
    then
        echo "$text"
        echo "$text" | RHVoice | aplay - 2>/dev/null
    else
        echo "$text"
        echo "$text" | RHVoice-client -s "$tspeaker" | aplay - 2>/dev/null
    fi
fi
