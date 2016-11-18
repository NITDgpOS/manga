#Gets the index page of mangareader.net

wget -O index.html www.mangareader.net

<<<<<<< HEAD
#Open the index page on Google Chrome or Firefox according to the users choice

if [ "$1" = "-f" ]; then
	firefox index.html
else
	google-chrome-stable index.html
fi

>>>>>>> 626fae9fcb1ff62d142bdca52de7bb678f97b006
