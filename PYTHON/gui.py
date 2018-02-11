from tkinter import *
import requests
from bs4 import BeautifulSoup
import os
import shutil
import pathlib
from tkinter import filedialog,ttk
import tkinter.messagebox
import tkSimpleDialog
import time
import sys
import tkinter as tk

root = Tk()
root.state('normal')
root.title("Manga Downloader")
RWidth=root.winfo_screenwidth()
RHeight=root.winfo_screenheight()
root.geometry(("%dx%d")%(RWidth,RHeight))

def cd(dir):
    """
    Intelligently change directory
    """
    if not os.path.exists(dir):  # check for an existing path
        os.mkdir(dir)  # make directory if it doesn't exist
    elif not pathlib.Path(dir).is_dir():  # else check for a clashing filename
        print("Error: A file already exists with '" + dir + "' filename")
    os.chdir(dir)

def get_html(url):
    """
    Gets html text for the given url
    """
    response = requests.get(url)
    return response.text  # Converts the response into text and return it

# **** DOWNLOAD MANGA *****  (TO-DO - needs enhancement)
manga_name = 0
manga = 0
def mngaa(mnga):
    manga_name = mnga.get()
    dest = "Downloads"
    cd(dest)
    cd(str(manga))
    for chap in range(chaps, chape+1):
        cd(str(chap))
        url = "http://www.mangareader.net/"+manga+"/"+str(chap)
        html = get_html(url)  # HTML page of the url
        if "not released yet" in html:  # Checks for this string
            print ("Chapter "+str(chap)+" of "+manga+" is not available at www.mangareader.net")
            os.chdir("..")  # Goes one directory ahead
            shutil.rmtree(str(chap))
            break
        i = 1
        while True:  # an infinte while loop
            try:
                print ("Downloading page "+str(i)+" of chapter "+str(chap)+".....")
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
        print ("Converting to pdf...")
        chapno = "0000"+str(chap)
        chapno = chapno[len(chapno) - 4:]
        pdf_name = "chap"+chapno+".pdf"
        pdf_command = "convert *.jpg ../"+pdf_name
        os.system(pdf_command)
        print ("Cleaning up.....")
        path = os.getcwd()
        print ("Your downloaded file is in this path:\n"+path)
        os.chdir("..")
        open_command = "gnome-open "+pdf_name
        os.system(open_command)
        shutil.rmtree(str(chap))

def download(): # ***** TO-DO *******
    downloads = Tk()
    downloads.title('Download Manga')
    downloads.state('normal')
    mnga = StringVar(downloads)
    label0 = Label(downloads, text = "Enter Manga name: ").grid(row = 0, column = 0)
    entry1 = Entry(downloads, textvariable=mnga).grid(row = 0, column = 1)
    b = Button(downloads, text = 'Enter', command = lambda: mngaa(mnga)).grid(row = 2, column = 1)
    label1 = Label(downloads, text = "Enter the chapter range: ").grid(row = 3, column = 0)
    label2 = Label(downloads, text = "Start").grid(row = 4, sticky = E )
    label3 = Label(downloads, text = "End").grid(row = 5, sticky = E)
    chaps1 = Entry(downloads).grid(row =4, column = 1 )
    chape2 = Entry(downloads).grid(row =5, column = 1 )
    manga = str(manga_name)
    #manga = tkSimpleDialog.askstring("Manga", "Enter manga name")
    # label1 = Label(text = "Enter manga name: ").grid(row = 10, column = 0)
    # manga = Entry().grid(row = 0, column = 1)
    manga = str(manga)
    manga = manga.strip()  # Remove extra whitespaces from the start and end of the string
    manga = manga.lower()  # Change the manga name into lowercase
    manga = manga.replace(' ', '-') #Replace the whitespaces with a hyphen (-)

    #print ("Enter the chapter range :")
    #chaps = int(input("Start : "))
    #chape = int(input("End : "))
    downloads.mainloop()

def check(manga):
    manga = manga.strip()  # Remove extra whitespaces from the start and end of the string
    manga = manga.lower()  # Change the manga name into lowercase
    # Replace the whitespaces with a hyphen (-)
    manga = manga.replace(' ', '-')
    url = "http://www.mangareader.net/"+manga
    html = get_html(url)  # HTML page of the url

    if "404 Not Found" in html:  # Checks for this string
        print ("Manga name you entered is not valid")
    else:
        with open(".fav", "r+") as file:
            for line in file:
                if manga in line:
                    print ("Already added to favourites")
                    break
            else: # not found, we are at the eof
                file.write(manga + '\n') # append missing data

# ***** ADD FAV *******

def fav():
    manga = input("Enter the name of the manga to add to the favourites : ")
    check(manga)  # Check the validity of the manga
    while True:
        choice = input("Do you want to add more?[Y/N] ")
        if choice == 'Y' or choice == 'y':
            #manga = input("Enter the name of the manga to add to the favourites : ")
            fav()
            #check(manga)
        elif choice == 'N' or choice == 'n':
            main_menu()
        else:
            print ("Invalid choice. Try again!")
    os.system("sort -u -o .fav .fav")

# ***** SHOW FAV *******

def show_fav():
    print("Here's your list of favourites: \n")
    with open(".fav", 'r') as fin:
        fin.seek(0)
        f_char = fin.read(1)
        if not f_char:
          print(" <Empty> \n")
        else:
          fin.seek(0)
          print(fin.read())

# ***** DELETE FAV *******
def del_fav():
    delt = str(input("Enter the name of the manga you wish to delete from your favourites: "))
    delt = delt.lower()
    with open(".fav", 'r+') as f:
        new_f = f.readlines()
        if delt+'\n' not in new_f:
          print(str(delt) + " Not present in your favourites. " )
        else:
          f.seek(0)
          for line in new_f:
              if str(delt) not in line:
                  f.write(line)
          f.truncate()
          print(delt + " Deleted Succesfully from favourites. ")

def exit_manga():
    sys.exit()


# ***** NEWSTELLER *******
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
        print (result)

    else:
        print ("No releases for "+manga_name.strip()+" found !")

def newsteller():
    if '-f' in sys.argv:
        try:
            print ("Fetching the status of your favourite mangas...\n")
            with open('.fav') as f:
                mangas = f.readlines()  # Make a list of favourite mangas
            f.close()  # closes the file
            result_format = "Title with latest chapter".ljust(
                80) + "Date of release (MM/DD/YYYY)\n"
            print (result_format)
            for manga in mangas:  # Iterating each favourite manga
                manga_name = manga
                manga = manga.strip()  # Remove extra whitespaces from the start and end of the string
                manga = manga.lower()  # Change the manga name into lowercase
                # Replace the whitespaces with a hyphen (-)
                manga = manga.replace(' ', '-')
                url = "http://www.mangareader.net/"+manga
                get_status(manga_name, url)
        except:
            print ("No favourites added yet !")

    else:
        soup = make_soup("http://www.mangareader.net")
        # this makes a list of bs4 element tags
        mangas = soup.select('.chaptersrec')
        for i in range(0, len(mangas)):
            print (mangas[i].get_text())

#****** DIRECTORY ******  ## TO-DO ********


class dir_tree(object):
    def __init__(self, master, path):
        self.nodes = dict()
        notebook = ttk.Notebook(master, width = 2000)
        self.tree = ttk.Treeview(notebook)
        ysb = ttk.Scrollbar(notebook, orient='vertical', command=self.tree.yview)
        xsb = ttk.Scrollbar(notebook, orient='horizontal',command=self.tree.xview)
        self.tree.configure(yscrollcommand=ysb.set, xscrollcommand=xsb.set)
        self.tree.heading('#0', text='Manga Directory', anchor='w')
        xsb.pack(side=tk.BOTTOM, fill=tk.X)
        ysb.pack(side=tk.RIGHT, fill=tk.Y)
        notebook.pack(side = LEFT,fill = tk.Y)
        self.tree.pack(side = LEFT, fill = tk.BOTH, expand = True)
        abspath = os.path.abspath('/home/user/Desktop/')
        self.insert_node('', abspath, abspath)
        self.tree.bind('<<TreeviewOpen>>', self.open_node)
    def insert_node(self, parent, text, abspath):
        node = self.tree.insert(parent, 'end', text=text, open=False)
        if os.path.isdir(abspath):
            self.nodes[node] = abspath
            self.tree.insert(node, 'end')

    def open_node(self, event):
        node = self.tree.focus()
        abspath = self.nodes.pop(node, None)
        if abspath:
            self.tree.delete(self.tree.get_children(node))
            for p in os.listdir(abspath):
                self.insert_node(node, p, os.path.join(abspath, p))

if __name__ == "__main__":
    dirr = dir_tree(root, path='/home/user/Desktop/') # Path to Downloads 

# ********* MENU ************

menu = Menu(root)
root.config(menu=menu)

mangaMenu = Menu(menu)
menu.add_cascade(label="Manga", menu=mangaMenu)
mangaMenu.add_command(label = "Download manga", command =download)
mangaMenu.add_separator()
mangaMenu.add_command(label = "Exit", command = exit_manga)

favMenu = Menu(menu)
menu.add_cascade(label="Favourites", menu=favMenu)
favMenu.add_command(label = "Display favourites", command = show_fav)
favMenu.add_command(label = "Add favourites", command = fav)
favMenu.add_command(label = "Delete favourites", command = del_fav)

newsteller = Menu(menu)
menu.add_cascade(label= "Newsteller", menu = newsteller)
newsteller.add_command(label = "What's new", command = newsteller)

root.mainloop()
