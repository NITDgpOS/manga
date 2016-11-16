#Gets the index page of mangareader.net

wget -O index.html www.mangareader.net

#Open the index page on Google Chrome or Firefox according to the users choice

if [ "$1" = "-f" ]; then
	firefox index.html
else
	google-chrome-stable index.html
fi

