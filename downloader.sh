manga='the-gamer'
chap='107'
mkdir $manga
cd $manga
for i in {1..21}
do
	echo "Downloading $i page....."
	wget -o log.txt -O $i.html www.mangareader.net/$manga/$chap/$i
	#grep src=\"http://i999.mangareader.net/the-gamer/ $i.html > jump.txt
	grep '<div id=\"imgholder\"><a href=' $i.html > jump.txt
	link=$(head -n 1 jump.txt)
	starti="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "11q;d")"
	endi="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "12q;d")"
	#$link | grep -aob '"' | grep -oE '[0-9]+' | sed "12q;d"
	#starti=$(expr index "$link" \")
	length=$((endi-starti))
	image=${link:$((starti+1)):$((length-1))}
	wget -O $i.jpg -o log.txt -c $image
	rm $i.html
done
echo "Converting to pdf..."
convert *.jpg chap.pdf
echo "Cleaning up....."
rm jump.txt
rm log.txt
