from bs4 import BeautifulSoup
import requests

#makes soup, that is basically parsing the html document
def make_soup(url):
    response = requests.get(url)
    html = response.text    #Converts the response into text
    return BeautifulSoup(html, "lxml")  #Parses the html with lxml parser


#scrape status from /<manga-name>
def get_status(manga_name,url):
    soup = make_soup(url) 
    rows = soup.select("#chapterlist tr")       #this makes a list of bs4 element tags  
    row_nos = len(rows)       #Total number of chapters
    
    if row_nos > 1 :    #When minimum of 1 chapter is present
        last_chap = rows[row_nos-1]   #Taking the latest release
        data = last_chap.select("td")
        result = data[0].get_text()+" released on "+data[1].get_text()+" (MM/DD/YYYY)"
        result = result.strip()     #remove extra whitespaces from the start and end of the string
        print result
    
    else :
        print "No releases for "+manga_name.strip()+" found !"
    
if __name__ == "__main__":
    with open('.fav') as f:     
        mangas = f.readlines()      #Make a list of favourite mangas
    for manga in mangas:    #Iterating each favourite manga
        manga_name = manga
        manga = manga.strip() #Remove extra whitespaces from the start and end of the string
        manga = manga.lower() #Change the manga name into lowercase
        manga = manga.replace(' ','-')    #Replace the whitespaces with a hyphen (-)
        url = "http://www.mangareader.net/"+manga
        get_status(manga_name,url)