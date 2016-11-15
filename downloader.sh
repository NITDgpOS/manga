echo "Enter Manga name:"
read manga
manga=${manga,,} # Converting it to lower case
manga=${manga// /-} # Removing spaces and adding - in their places
echo "Enter the chapter range."
echo "Start:"
read chaps
echo "End:"
read chape
if [ ! -d "Downloads" ]; then
	mkdir Downloads
fi
cd Downloads

if [ ! -d "$manga" ]; then
	mkdir $manga
fi
cd $manga
for chap in $(seq $chaps $chape);
do
	mkdir $chap
	cd $chap
	wget -O index.html -o log.txt www.mangareader.net/$manga/$chap
	if grep -q "not released yet" index.html; then
		echo "Chapter $chap of $manga  is not available at www.mangareader.net"
		cd ..
		rm -rf $chap
		break
	fi
	rm index.html
	declare -i i=1
	while true  #an infinte while loop 
	do
		echo "Downloading page $i of chapter $chap....."
		wget -o log.txt -O $i.html -c www.mangapanda.com/$manga/$chap/$i # Downloads the main webpage
		grep 'src=\"http' $i.html | grep 'mangapanda' > jump.txt # Gets the list of image links
		link=$(head -n 1 jump.txt)
		starti="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "11q;d")"
		endi="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "12q;d")"
		# Workaround for two page images, which are displayed as large images.
		if grep -q "Larger Image" $i.html; then
			starti="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "9q;d")"
			endi="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "10q;d")"
		fi
		length=$((endi-starti))
		image=${link:$((starti+1)):$((length-1))}
		length=${#image}
		if [[ "$length" -eq 0 ]]; then
			break
		fi
		imagename=0000$i
		wget -O ${imagename: -4}.jpg -o log.txt -c $image
		i=i+1
	done
	echo "Converting to pdf..."
	chapno=0000$chap
	chapno=${chapno: -4}
	convert *.jpg ../chap$chapno.pdf
	echo "Cleaning up....."
	path=$(pwd)
	echo -e "Your downloaded file is in this path:\n" $path
	cd ..
	if [ "$1" = "-o" ]; then
		gnome-open chap$chapno.pdf
	fi
	rm -rf $chap
done
