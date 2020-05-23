#!/bin/bash
#rhvoiceplay.sh
#Depends: bash, sed, gzip, rhvoice, aplay | sox

sname="RHVoicePlay"
sversion="0.20200523"

echo "$sname $sversion" >&2

tnocomp=""
tcomp="sed"
[ ! "$(which $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="gzip"
[ ! "$(which $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="RHVoice"
tcompa="RHVoice-test"
[ ! "$(which $tcomp)" -a ! "$(which $tcompa)" ] && tnocomp="$tnocomp $tcomp|$tcompa"
tcomp="aplay"
tcompa="play"
[ ! "$(which $tcomp)" -a ! "$(which $tcompa)" ] && tnocomp="$tnocomp $tcomp|$tcompa"
if [ "x$tnocomp" != "x" ]
then
    echo "Not found:${tnocomp}!" >&2
    echo "" >&2
    exit 1
fi

tstdout="/dev/stdout"
tstdin="/dev/stdin"

tln=0
tspeaker="elena"
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
    echo "    -l N    line begin [N=0-1000] (only .txt, default = 0)"
    echo "    -s str  RHVoice speaker (RHVoice >=0.5, default = elena)"
    echo "    -h      help"
    exit 0
fi

trhvoice="RHVoice"
[ ! "$(which $trhvoice)" ] && trhvoice="RHVoice-test -p $tspeaker -o $tstdout"
tplay="aplay $tstdin"
[ ! "$(which $tplay)" ] && tplay="play -q $tstdin"

if [ -f "$text" ]
then
    textsize=$(gzip -dcf "$text" | sed -e 's/[\.\?\!\…] /&\n/g' | sed -e '/^$/d' | wc -l)
    echo "$text: $textsize" >&2
    tln=$(($tln*$textsize/1000))
    i=$tln
    gzip -dcf "$text" | sed -e 's/[\.\?\!\…] /&\n/g' | sed -e '/^$/d' | sed -e "1,${tln}d" | while read tline; do p=$((10000*$i/$textsize)); p1=$(($p/10)); p2=$(($p-$p1*10)); printf "%03d.%01d: " $p1 $p2; echo "$tline"; echo "$tline" | $trhvoice 2>/dev/null | $tplay 2>/dev/null; i=$(($i+1)); done
elif [ "x$text" = "x-" ]
then
    while read tline; do printf ": "; echo "$tline"; echo "$tline" | $trhvoice 2>/dev/null | $tplay 2>/dev/null; done
else
    echo "$text"
    echo "$text" | $trhvoice 2>/dev/null | $tplay 2>/dev/null
fi
