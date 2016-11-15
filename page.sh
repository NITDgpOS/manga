#Gets the index page of mangareader.net

wget -O index.html www.mangareader.net

#Open the index page on Firefox or Chrome as per user choice
echo -e "Open using\n(1)Chrome\n(2)Firefox\n"
echo -e "Enter choice:(1/2)"
read num
if [ $num == 1 ]
	then 	
		google-chrome-stable index.html
elif [ $num == 2 ]
	then 
		firefox index.html
else
	echo "invalid choice"
fi
