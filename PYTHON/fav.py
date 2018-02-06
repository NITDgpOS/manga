#!/usr/bin/env python

import requests
import os


def get_html(url):
    response = requests.get(url)
    return response.text  # Converts the response into text and return it


def check(manga):
    manga = manga.strip()  # Remove extra whitespaces from the start and end of the string
    manga = manga.lower()  # Change the manga name into lowercase
    # Replace the whitespaces with a hyphen (-)
    manga = manga.replace(' ', '-')
    url = "http://www.mangareader.net/"+manga
    html = get_html(url)  # HTML page of the url

    if "404 Not Found" in html:  # Checks for this string
        print "Manga name you entered is not valid"
    else:
        with open(".fav", "r+") as file:
            for line in file:
                if manga in line:
                    print ("Already added to favourites")
                    break
            else: # not found, we are at the eof
                file.write(manga + '\n') # append missing data


if __name__ == "__main__":
    manga = raw_input(
        "Enter the name of the manga to add to the favourites : ")
    check(manga)  # Check the validity of the manga
    while True:
        choice = raw_input("Do you want to add more?[Y/N] ")
        if choice == 'Y' or choice == 'y':
            manga = raw_input(
                "Enter the name of the manga to add to the favourites : ")
            check(manga)
        elif choice == 'N' or choice == 'n':
            break
        else:
            print "Invalid choice. Try again!"
    os.system("sort -u -o .fav .fav")
