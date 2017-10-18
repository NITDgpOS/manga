getLatestInfo () {
  manga=$1
  #Gets the manga's html page
  wget -O temp.html -q www.mangareader.net/$manga
  #Finds the string between the patterns '<a href="/manga/" and '</a>' at first occurence
  latest=$(grep -m1 -oP "(?<=a href=\"/${manga}/).*(?=</a>)" temp.html)
  #remove all characters before '>' in string latest including '>'
  chapl=$(echo $latest | sed -e 's/.*>//g')
  #gets the line number of last occurence of string chapl
  lnum=$(cat -n temp.html | grep "$chapl" | tail -1 |  cut -f 1)
  #increment lnum by 1
  ((lnum++))
  #get the content in the line lnum
  date=$(sed "${lnum}q;d" temp.html)
  #remove the first four and last 5 characters from string date
  date=${date:4:-5}
  #delete temp.html
  rm temp.html
  chap="${chapl##* }"
  title="${chapl% *}"
  printf "%-25s %35s %18s\n" "$title" "$chap" "$date"
}

if [ "$1" = "-f" ]; then
  echo "Fetching the status of your fav. list"
  echo "Status will be displayed in the format:"
  t="Title"
  l="Latest Chapter Released"
  d="Date of Release"
  printf "%-25s %35s %18s\n" "$t" "$l" "$d"
  while IFS= read -r line; do
    getLatestInfo "$line"
  done <.fav
else
  wget -o jump.txt  -O index.html www.mangareader.net
  grep 'chaptersrec' index.html > jump.txt
  while read p;do
    starti="$(echo $p | grep -aob '>' | grep -oE '[0-9]+' | sed "1q;d")"
    endi="$(echo $p | grep -aob '<' | grep -oE '[0-9]+' | sed "2q;d")"
    length=$((endi-starti))
    newchap=${p:$((starti+1)):$((length-1))}
    echo $newchap
  done < jump.txt
fi
