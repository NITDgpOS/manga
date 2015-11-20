wget -o jump.txt  -O index.html www.mangareader.net
grep 'chaptersrec' index.html > jump.txt
while read p;do
  starti="$(echo $p | grep -aob '>' | grep -oE '[0-9]+' | sed "1q;d")"
  endi="$(echo $p | grep -aob '<' | grep -oE '[0-9]+' | sed "2q;d")"
  length=$((endi-starti))
  newchap=${p:$((starti+1)):$((length-1))}
  echo $newchap
done < jump.txt
