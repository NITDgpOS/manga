#!/usr/bin/env python

import requests
from bs4 import BeautifulSoup
import os
import shutil


def get_html(url):
    response = requests.get(url)
    return response.text  # Converts the response into text and return it

if __name__ == "__main__":

    manga = raw_input("Enter Manga name : ")
    manga = manga.strip()  # Remove extra whitespaces from the start and end of the string
    manga = manga.lower()  # Change the manga name into lowercase
    # Replace the whitespaces with a hyphen (-)
    manga = manga.replace(' ', '-')
    print "Enter the chapter range :"
    chaps = input("Start : ")
    chape = input("End : ")
    dest = "Downloads"

    if not os.path.exists(dest):  # Checks if Downloads folder exists or not
        os.mkdir(dest)
    os.chdir(dest)

    if not os.path.exists(manga):  # Checks if Manga folder exists or not
        os.mkdir(manga)
    os.chdir(manga)

    for chap in range(chaps, chape+1):
        if not os.path.exists(str(chap)):  # Checks if the folder exists previously
            os.mkdir(str(chap))
        os.chdir(str(chap))
        url = "http://www.mangareader.net/"+manga+"/"+str(chap)
        html = get_html(url)  # HTML page of the url

        if "not released yet" in html:  # Checks for this string
            print "Chapter "+str(chap)+" of "+manga+" is not available at www.mangareader.net"
            os.chdir("..")  # Goes one directory ahead
            shutil.rmtree(str(chap))
            break

        i = 1
        while True:  # an infinte while loop
            try:
                print "Downloading page "+str(i)+" of chapter "+str(chap)+"....."
                url = "http://www.mangareader.net/" + \
                    manga+"/"+str(chap)+"/"+str(i)
                html = get_html(url)  # HTML page of the url
                # Parses the html with lxml parser
                soup = BeautifulSoup(html, "lxml")
                # Selects the suitable image tag with the link
                ans = soup.select("#imgholder img")
                img_link = ans[0]['src']  # Gets the image url
                imagename = "0000"+str(i)+".jpg"
                download_command = "wget -O "+imagename + \
                    " -o log.txt -c "+str(img_link)
                os.system(download_command)
                i = i + 1
            except:
                break

        print "Converting to pdf..."
        chapno = "0000"+str(chap)
        chapno = chapno[len(chapno) - 4:]
        pdf_name = "chap"+chapno+".pdf"
        pdf_command = "convert *.jpg ../"+pdf_name
        os.system(pdf_command)
        print "Cleaning up....."
        path = os.getcwd()
        print "Your downloaded file is in this path:\n"+path
        os.chdir("..")
        open_command = "gnome-open "+pdf_name
        os.system(open_command)
        shutil.rmtree(str(chap))
