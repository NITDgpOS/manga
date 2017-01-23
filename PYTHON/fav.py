#!/usr/bin/env python

import requests
import os

def get_html (url) :
    response = requests.get(url)
    return response.text    #Converts the response into text and return it
                
def check (manga) : 
    manga = manga.strip() #Remove extra whitespaces from the start and end of the string
    manga = manga.lower() #Change the manga name into lowercase
    manga = manga.replace(' ','-')    #Replace the whitespaces with a hyphen (-)
    url = "http://www.mangareader.net/"+manga
    html = get_html (url)      #HTML page of the url
    
    if "404 Not Found" in html :     #Checks for this string
        print "Manga name you entered is not valid"
    else :
        try :
            f_r = open('.fav','r')
            favs = f_r.readlines()      #Make a list of favourite mangas
            if manga+"\n" in favs :
                print "Already added to favourites"
                f_r.close()   #Closes the file 'f_r'
        except :
            f_a = open('.fav', 'a')   #Open .fav in append mode
            f_a.write(manga+"\n")  #Write the manga into the .fav
            f_a.close()   #Closes the file 'f_a'
            
                
if __name__ == "__main__" :
    manga = raw_input("Enter the name of the manga to add to the favourites : ")
    check (manga)    #Check the validity of the manga
    while True :
        choice = raw_input("Do you want to add more?[Y/N] ")
        if choice == 'Y' or choice == 'y' :
            manga = raw_input("Enter the name of the manga to add to the favourites : ")
            check ( manga )
        elif choice == 'N' or choice == 'n' :
            break
        else :
            print "Invalid choice. Try again!"
    os.system("sort -u -o .fav .fav")
 
