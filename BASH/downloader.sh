index() {
	echo "$(echo $@ | grep -aob '"' | grep -oE '[0-9]+' | sed "${!#};d")"
}

issuesPage="https://github.com/NIT-dgp/manga/issues/new"

os=$(uname)
if [ "$os" = "Linux" -o "$os" = "FreeBSD" ]; then
	openWith="$(which xdg-open 2> /dev/null)"
elif [ "$os" = "Darwin" ]; then
	openWith="$(which open 2> /dev/null)"
else
	echo "Platform '$os' not listed"
	echo "PDF will not be automatically opened for you"
	echo "Please raise an issue on $issuesPage"
fi

a="$#"
declare -i chaps=0,chape=0,t=0,c=0,end_loop=0,d1=0,d2=0
#checking for existence of -t , --chap in argument
for (( i=1; i<=a; i++))
do
	if [ "${!i}" = "--title" ] || [ "${!i}" = "-t" ]; then
		t=$i
	fi
	if [ "${!i}" = "--chap" ] || [ "${!i}" = "-c" ]; then
		c=$i
	fi
	if [ "${!i}" = "-fo" ]; then
		x=$i
	fi
done
if [ "$t" -ne 0 ]; then
	if [ "$c" -gt "$t" ]; then
		end_loop=c-1
	else
		end_loop=a
	fi
	for (( i=t+1;i<=end_loop;i++ ))
	do
		manga+="${!i}";
		manga+="-";
	done
	manga=${manga::-1} #removing terminal '-'
else
	echo "Enter Manga name:"
	read manga
	manga=${manga,,} # Converting it to lower case
	manga=${manga// /-} #Removing spaces and adding '-'
fi
if [ "$c" -ne 0 ]; then
	d1=$((c+1))
	d2=$((c+2))
	chaps=${!d1}
	chape=${!d2}
else
	echo "Enter the chapter range."
	echo "Start:"
	read chaps
	echo "End:"
	read chape
fi

cd ..

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
	wget -O index.html -q www.mangareader.net/$manga/$chap
	if grep -q "not released yet" index.html; then
		echo "Chapter $chap of $manga  is not available at www.mangareader.net"
		cd ..
		rm -rf $chap
		break
	fi
	rm index.html
	declare -i i=1
	while true  #an infinite while loop
	do
		echo "Downloading page $i of chapter $chap....."
		wget -q -O $i.html -c www.mangareader.net/$manga/$chap/$i # Downloads the main webpage
		grep 'src=\"http' $i.html | grep 'mangareader' > jump.txt # Gets the list of image links
		link=$(head -n 1 jump.txt)
		starti=$(index $link "11q")
		endi=$(index $link "12q")
		# Workaround for two page images, which are displayed as large images.
		if grep -q "Larger Image" $i.html; then
			starti=$(index $link "9q")
			endi=$(index $link "10q")
		fi
		length=$((endi-starti))
		image=${link:$((starti+1)):$((length-1))}
		length=${#image}
		if [[ "$length" -eq 0 ]]; then
			break
		fi
		imagename=0000$i
		wget -O ${imagename: -4}.jpg -q -c $image
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
	if [ "$x" != "" ]; then
		nautilus $path
	else
		if [ -n "$openWith" ]; then
			$openWith chap$chapno.pdf
		fi
		rm -rf $chap
	fi
done
