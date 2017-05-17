echo "Enter Manga name:"
read manga
manga=${manga,,} # Converting it to lower case
manga=${manga// /-} # Removing spaces and adding - in their places
echo "Enter the chapter range."
echo "Start:"
read chaps
echo "End:"
read chape
echo $manga >> .gitignore
sort -u -o .gitignore .gitignore
if [ ! -d "$manga" ]; then
	mkdir $manga
fi
cd $manga
for chap in $(seq $chaps $chape);
do
	mkdir $chap
	cd $chap
	aria2c -o index.html -q -l log.txt -x 4 http://www.mangareader.net/$manga/$chap
	if grep -q "not released yet" index.html; then
		echo "Chapter $chap of $manga is not released yet"
		cd ..
		rm -rf $chap
		break
	fi
	rm index.html
    # if our hero(you) has some bg jobs
    jc=`jobs | wc -l` # this will keep track of it
	for i in {1..100}
	do
        j=$((i+1))
        k=$((i+2))
        l=$((i+3))
		echo "Downloading 4 pages from $i,$j,$k,$l of chapter $chap....."
		aria2c -x 4 -q -l log.txt -o $i.html  http://www.mangapanda.com/$manga/$chap/$i & # Downloads the main webpage
        aria2c -x 4 -q -l log.txt -o $j.html  http://www.mangapanda.com/$manga/$chap/$j & # Downloads the main webpage
        aria2c -x 4 -q -l log.txt -o $k.html  http://www.mangapanda.com/$manga/$chap/$k & # Downloads the main webpage
        aria2c -x 4 -q -l log.txt -o $l.html  http://www.mangapanda.com/$manga/$chap/$l & # Downloads the main webpage
        ################
        var=`jobs | wc -l`
        while [ $var -ne $jc ]; do
            sleep 0.1
            var=`jobs | wc -l`
        done
        ###############
		grep 'src=\"http' $i.html | grep 'mangapanda' > jump.txt  &  # Gets the list of image links
        grep 'src=\"http' $j.html | grep 'mangapanda' > sit.txt   &  # Gets the list of image links
        grep 'src=\"http' $k.html | grep 'mangapanda' > stand.txt &  # Gets the list of image links
        grep 'src=\"http' $l.html | grep 'mangapanda' > sleep.txt &  # Gets the list of image links
        ################
        var=`jobs | wc -l`
        while [ $var -ne $jc ]; do
            sleep 0.1
            var=`jobs | wc -l`
        done
        ###############
		linki=$(head -n 1 jump.txt)  &
        linkj=$(head -n 1 sit.txt)   &
        linkk=$(head -n 1 stand.txt) &
        linkl=$(head -n 1 sleep.txt) &
        ################
        var=`jobs | wc -l`
        while [ $var -ne $jc ]; do
            sleep 0.1
            var=`jobs | wc -l`
        done
        ###############
		starti="$(echo $linki | grep -aob '"' | grep -oE '[0-9]+' | sed "11q;d")" &
		endi="$(echo $linki | grep -aob '"' | grep -oE '[0-9]+' | sed "12q;d")"   &
        startj="$(echo $linkj | grep -aob '"' | grep -oE '[0-9]+' | sed "11q;d")" &
		endj="$(echo $linkj | grep -aob '"' | grep -oE '[0-9]+' | sed "12q;d")"   &
        startk="$(echo $linkk | grep -aob '"' | grep -oE '[0-9]+' | sed "11q;d")" &
		endk="$(echo $linkk | grep -aob '"' | grep -oE '[0-9]+' | sed "12q;d")"   &
        startl="$(echo $linkl | grep -aob '"' | grep -oE '[0-9]+' | sed "11q;d")" &
		endl="$(echo $linkl | grep -aob '"' | grep -oE '[0-9]+' | sed "12q;d")"   &
        ################
        var=`jobs | wc -l`
        while [ $var -ne $jc ]; do
            sleep 0.1
            var=`jobs | wc -l`
        done
        ###############
		# Workaround for two page images, which are displayed as large images.
        # Can't use ampersand blindly here let this be serial.
		if grep -q "Larger Image" $i.html; then
			starti="$(echo $linki | grep -aob '"' | grep -oE '[0-9]+' | sed "9q;d")"
			endi="$(echo $linki | grep -aob '"' | grep -oE '[0-9]+' | sed "10q;d")"
		fi
        if grep -q "Larger Image" $j.html; then
			starti="$(echo $linkj | grep -aob '"' | grep -oE '[0-9]+' | sed "9q;d")"
			endi="$(echo $linkj | grep -aob '"' | grep -oE '[0-9]+' | sed "10q;d")"
		fi
        if grep -q "Larger Image" $k.html; then
			starti="$(echo $linkk | grep -aob '"' | grep -oE '[0-9]+' | sed "9q;d")"
			endi="$(echo $linkk | grep -aob '"' | grep -oE '[0-9]+' | sed "10q;d")"
		fi
        if grep -q "Larger Image" $l.html; then
			starti="$(echo $linkl | grep -aob '"' | grep -oE '[0-9]+' | sed "9q;d")"
			endi="$(echo $linkl | grep -aob '"' | grep -oE '[0-9]+' | sed "10q;d")"
		fi
        ################
        # These are just small operations so serial.
		lengthi=$((endi-starti))
        lengthj=$((endj-startj))
        lengthk=$((endk-startk))
        lengthl=$((endl-startl))
		imagei=${linki:$((starti+1)):$((lengthi-1))}
        imagej=${linkj:$((startj+1)):$((lengthj-1))}
        imagek=${linkk:$((startk+1)):$((lengthk-1))}
        imagel=${linkl:$((startl+1)):$((lengthl-1))}
		lengthi=${#imagei}
        lengthj=${#imagej}
        lengthk=${#imagek}
        lengthl=${#imagel}
        #################
        # You can choose to make the above code parallel
        # But you can't make this below code parallel..
        # That would be cutting your legs with axe.
		if [[ "$lengthi" -eq 0 ]]; then
			break
		fi
		imagename=0000$i
		aria2c -o ${imagename: -4}.jpg -q -l log.txt -x 4  $imagei &
        #
        if [[ "$lengthj" -eq 0 ]]; then
            break
        fi
        imagename=0000$j
        aria2c -o ${imagename: -4}.jpg -q -l log.txt -x 4  $imagej &
        #
        if [[ "$lengthk" -eq 0 ]]; then
            break
        fi
        imagename=0000$k
        aria2c -o ${imagename: -4}.jpg -q -l log.txt -x 4  $imagek &
        #
        if [[ "$lengthl" -eq 0 ]]; then
            break
        fi
        imagename=0000$l
        aria2c -o ${imagename: -4}.jpg -q -l log.txt -x 4  $imagel &
        ###############
        var=`jobs | wc -l`
        while [ $var -ne $jc ]; do
            sleep 0.1
            var=`jobs | wc -l`
        done
        ###############
	done
	echo "Converting to pdf..."
	chapno=0000$chap
	chapno=${chapno: -4}
	convert *.jpg ../chap$chapno.pdf
	echo "Cleaning up....."
	cd ..
#	gnome-open chap$chapno.pdf
	rm -rf $chap
done
