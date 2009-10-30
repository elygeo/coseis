#!/bin/bash -e

if mpich2version &> /dev/null && ! mpdtrace &> /dev/null; then
if [ ! -e $HOME/.mpd.conf ]; then
    c=( a b c d e f g h i j k l m n o p q r s t u v w x y z \
        A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
        0 1 2 3 4 5 6 7 8 9 ! @ \# $ ^ \& )
    n=${#c[@]}
    for (( i=1; i<=16; i++ )); do pw="$pw${c[$RANDOM%n]}"; done
    echo "secretword=$pw" > $HOME/.mpd.conf
    chmod 600 $HOME/.mpd.conf
fi
mpd --daemon
fi

