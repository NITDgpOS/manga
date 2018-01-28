# Gets the index of i-th double quotes(")
index(){
	echo "$(echo $@ | grep -aob '"' | grep -oE '[0-9]+' | sed "${!#};d")"
}

sizeOfArguments="$#"

#Checking position of chapter or title argument

declare -i titleIndex=0,chapterIndex=0
for((i=1; i<=sizeOfArguments; i++))
do
	if [ "${!i}"="--title" ] || [ "${!i}"="-t" ]; then
		titleIndex=$i
	fi
	if [ "${!i}"="--chap" ] || [ "${!i}"="-c" ]; then
		chapterIndex=$i
	fi
done

# Get values of manga name, start Index and end Index
if [ "$titleIndex" -ne 0 ]; then
	declare -i endTitleArgument=0
	if [ "$chapterIndex" -gt "$titleIndex" ]; then
		endTitleArgument=c-1
	else
		endTitleArgument=a
	fi
	for (( i=t+1;i<=endTitleArgument;i++ ))
	do
		manga+="${!i}";
		manga+="-";
	done
	manga=${manga::-1} #removing terminal '-'
else
	echo -n "Enter Manga name: "
	read manga
	manga=${manga,,} # Converting it to lower case
	manga=${manga// /-} #Removing spaces and adding '-'
fi

# Get start and end chapter index
declare -i chapStart=0,chapEnd=0,d1=0,d2=0
if [ "$chapterIndex" -ne "0" ]; then
	d1=$((chapterIndex+1))
	d2=$((chapterIndex+2))
	chapStart=${!d1}
	chapEnd=${!d2}
else
	echo "Enter the chapter range."
	echo "Start:"
	read chapStart
	echo "End:"
	read chapEnd
fi

cd ..

# Create required folders to save the manga
if [ ! -d "Downloads" ]; then
	mkdir Downloads
fi
cd Downloads
if [ ! -d "$manga" ]; then
	mkdir $manga
fi

cd $manga

# Main downloader part
for chap in $(seq $chapStart $chapEnd);
do
	mkdir $chap
	cd $chap
	# Download the first page of manga
	wget -O index.html -q www.mangareader.net/$manga/$chap
	# Jump out on non-existance of chapter
	if grep -q "not released yet" index.html; then
		echo "Chapter $chap of $manga  is not available at www.mangareader.net"
		cd ..
		rm -rf $chap
		break
	fi
	rm index.html
	declare -i pageNumber=1
	while true  #an infinte while loop
	do
		echo "Downloading page $i of chapter $chap....."
		wget -q -O $pageNumber.html -c www.mangareader.net/$manga/$chap/$pageNumber # Downloads the main webpage
		grep 'src=\"http' $pageNumber.html | grep 'mangareader' > jump.txt # Gets the list of image links
		link=$(head -n 1 jump.txt)
		starti=$(index $link "11q")
		endi=$(index $link "12q")
		# Workaround for two page images, which are displayed as large images.
		if grep -q "Larger Image" $pageNumber.html; then
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
		pageNumber=$((pageNumber+1))
	done
	echo "Converting to pdf..."
	chapno=0000$chap # Fit the chapter number into 4 digits
	chapno=${chapno: -4}
	convert *.jpg ../chap$chapno.pdf
	echo "Cleaning up....."
	path=$(pwd)
	echo -e "Your downloaded file is in this path:\n" $path
	cd ..
	xdg-open chap$chapno.pdf
	rm -rf $chap
done
