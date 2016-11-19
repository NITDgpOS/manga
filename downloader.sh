a="$#"
declare -i m=0,c=0
#checking for existence of -t , -chap in argument
for (( i=1; i<=a; i++))
do
	if [ "${!i}" = "-t" ]; then
		m=$i
	fi
	if [ "${!i}" = "-chap" ]; then
		c=$i
		d1=$((c+1))
		d2=$((c+2))
	fi
done

chaps="${!d1}"
chape="${!d2}"

if [ "$m" -ne 0 -a "$c" -ne 0 ]; then #both title and chap are present

	if [ "$m" -lt "$c" ]; then
		for (( i=m+1; i<c; i++))
		do
				manga+="${!i}";
				manga+="-";
		done	
	else
		for (( i=m+1; i<=a; i++))
		do
			manga+="${!i}";
			manga+="-";
		done
	fi
	manga=${manga::-1} #removing terminal '-'

elif [ "$m" -eq 0 -a "$c" -ne 0 ]; then #only chap range is present
	echo "Enter Manga name:"
	read manga	
	manga=${manga,,} # Converting it to lower case
	manga=${manga// /-}
elif [ "$m" -ne 0 -a "$c" -eq 0 ]; then #only manga name is present
	echo "Enter the chapter range."
	echo "Start:"
	read chaps
	echo "End:"
	read chape
	#getting manga name
	for (( i=m+1; i<=a; i++))
		do
				manga+="${!i}";
				manga+="-";
		done
	manga=${manga::-1} #removing terminal '-'
else							   #no argument is present
	echo "Enter Manga name:"
	read manga
	manga=${manga,,} # Converting it to lower case
	manga=${manga// /-} #removing spaces, adding '-'
	echo "Enter the chapter range."
	echo "Start:"
	read chaps
	echo "End:"
	read chape
fi

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
	gnome-open chap$chapno.pdf
	rm -rf $chap
done
