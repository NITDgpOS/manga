#!/usr/bin/env python

from bs4 import BeautifulSoup
import requests
import sys

# makes soup, that is basically parsing the html document


def make_soup(url):
    response = requests.get(url)
    html = response.text  # Converts the response into text
    return BeautifulSoup(html, "lxml")  # Parses the html with lxml parser


def get_status(manga_name, url):
    """
    scrape status from /<manga-name>
    """
    soup = make_soup(url)
    # this makes a list of bs4 element tags
    rows = soup.select("#chapterlist tr")
    row_nos = len(rows)  # Total number of chapters

    if row_nos > 1:  # When minimum of 1 chapter is present
        last_chap = rows[row_nos-1]  # Taking the latest release
        data = last_chap.select("td")
        # strip extra whitespaces from the start and end of the string
        chap_name = data[0].get_text().strip()
        chap_date = data[1].get_text().strip()
        result = chap_name.ljust(80) + chap_date
<<<<<<< HEAD
        print (result)

    else:
        print ("No releases for "+manga_name.strip()+" found !")
=======
        print result

    else:
        print "No releases for "+manga_name.strip()+" found !"
>>>>>>> a91e55a3c74fba8c6c6bbe5a1065e4d6ceaa0788

if __name__ == "__main__":
    if '-f' in sys.argv:
        try:
<<<<<<< HEAD
            print ("Fetching the status of your favourite mangas...\n")
=======
            print "Fetching the status of your favourite mangas...\n"
>>>>>>> a91e55a3c74fba8c6c6bbe5a1065e4d6ceaa0788
            with open('.fav') as f:
                mangas = f.readlines()  # Make a list of favourite mangas
            f.close()  # closes the file
            result_format = "Title with latest chapter".ljust(
                80) + "Date of release (MM/DD/YYYY)\n"
<<<<<<< HEAD
            print (result_format)
=======
            print result_format
>>>>>>> a91e55a3c74fba8c6c6bbe5a1065e4d6ceaa0788
            for manga in mangas:  # Iterating each favourite manga
                manga_name = manga
                manga = manga.strip()  # Remove extra whitespaces from the start and end of the string
                manga = manga.lower()  # Change the manga name into lowercase
                # Replace the whitespaces with a hyphen (-)
                manga = manga.replace(' ', '-')
                url = "http://www.mangareader.net/"+manga
                get_status(manga_name, url)
        except:
<<<<<<< HEAD
            print ("No favourites added yet !")
=======
            print "No favourites added yet !"
>>>>>>> a91e55a3c74fba8c6c6bbe5a1065e4d6ceaa0788

    else:
        soup = make_soup("http://www.mangareader.net")
        # this makes a list of bs4 element tags
        mangas = soup.select('.chaptersrec')
        for i in range(0, len(mangas)):
<<<<<<< HEAD
            print (mangas[i].get_text())
=======
            print mangas[i].get_text()
>>>>>>> a91e55a3c74fba8c6c6bbe5a1065e4d6ceaa0788
