Manga Downloader
================

A bash script to download the manga chapters of your choice from mangareader and convert them to pdf format to read for later.

Structure
=========

- BashC
 - downloader, fav, newsteller, page : Scripts written in BASH
 - Cgui: Contains GTK gui implementation

- Python
 - downloader, fav, newsteller, page: Scripts written in Python

- Downloads : Folder with all downloaded content

Usage
=====

All are bash commands, `bash <filename>` to run the particular script.
 * `downloader.sh`
  * Downloads the manga chapters in the range given.
  * -t,--title : To specify manga title name in command line
  * -c, --chsp : To specify start and end chapter
 * `fav.sh`
  * Stores favourites to a file.
 * `newsteller.sh`
  * Displays the newly added manga chapters.
  * -f : Displays the status of the favourite manga
 * `page.sh`
  * Opens the main page in chrome browser.
  * -f : To open in firefox browser

Things you can work on
======================

Feel free to contribute to the scripts.

You can check out the things you can contribute to at: https://github.com/NIT-dgp/manga/issues
