#!/bin/sh
#rhvoiceplay.sh
#Depends: dash, sed, gzip | zutils, rhvoice, aplay | sox

sname="RHVoicePlay"
sversion="0.20190517"

echo "$sname $sversion" >&2

tnocomp=""
tcomp="sed"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="zcat"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="RHVoice"
tcompa="RHVoice-test"
[ ! "$(command -v $tcomp)" -a ! "$(command -v $tcompa)" ] && tnocomp="$tnocomp $tcomp|$tcompa"
tcomp="aplay"
tcompa="play"
[ ! "$(command -v $tcomp)" -a ! "$(command -v $tcompa)" ] && tnocomp="$tnocomp $tcomp|$tcompa"
if [ "x$tnocomp" != "x" ]
then
    echo "Not found:${tnocomp}!" >&2
    echo "" >&2
    exit 1
fi

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

trhvoice="RHVoice"
[ ! "$(command -v $trhvoice)" ] && trhvoice="RHVoice-test -p $tspeaker"
tplay="aplay"
[ ! "$(command -v $tplay)" ] && tplay="play -q"

if [ -f "$text" ]
then
    textsize=$(zcat "$text" | sed -e 's/[\.\?\!\…] /&\n/g' | sed -e '/^$/d' | wc -l)
    echo "$text: $textsize" >&2
    tln=$(($tln*$textsize/100))
    i=$tln
    zcat "$text" | sed -e 's/[\.\?\!\…] /&\n/g' | sed -e '/^$/d' | sed -e "1,${tln}d" | while read tline; do p=$((10000*$i/$textsize)); p1=$(($p/100)); p2=$(($p-$p1*100)); printf "%02d.%02d: " $p1 $p2; echo "$tline"; echo "$tline" | $trhvoice 2>/dev/null | $tplay - 2>/dev/null; i=$(($i+1)); done
elif [ "x$text" = "x-" ]
then
    while read tline; do printf ": "; echo "$tline"; echo "$tline" | $trhvoice 2>/dev/null | $tplay - 2>/dev/null; done
else
    echo "$text"
    echo "$text" | $trhvoice 2>/dev/null | $tplay - 2>/dev/null
fi
