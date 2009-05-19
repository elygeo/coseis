#!/bin/bash
j=293
for (( k=120; k<=160; k=k+1 )); do
    curl -o v1-$j-$k "http://scec.usc.edu/websims/tdownload/v1_t?ids=elsinore-cvm&j=0,$j,$k,1"
    curl -o v2-$j-$k "http://scec.usc.edu/websims/tdownload/v2_t?ids=elsinore-cvm&j=0,$j,$k,1"
    curl -o v3-$j-$k "http://scec.usc.edu/websims/tdownload/v3_t?ids=elsinore-cvm&j=0,$j,$k,1"
done

for (( j=50; j<=51; j=j+1 )); do
    curl -o movie-$j.png "http://scec.usc.edu/websims/xplot?ids=elsinore-cvm&t=$j&decimate=1"
done

