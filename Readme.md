Manga Downloader
================

A bash script to download the manga chapters of your choice and convert them to pdf format to read for later.

Usage
=====

All are bash commands, `bash <filename>` to run the particular script.
 * `downloader.sh`
  * Downloads the manga chapters in the range given.
 * `fav.sh`
  * Stores favourites to a file.
 * `newsteller.sh`
  * Displays the newly added manga chapters.
 * `page.sh`
  * Opens the main page in chrome browser.

Things to work on
=================

Feel free to contribute to the script. Here are a few things you can work on:

* Adding install script to add the execution in /usr/bin
* Adding options like:
  * `-o` to specify if the file should open after download or not
  * `-m [manga name] -c [chapter start] [chapter end]` for single line execution
  * `-h [host]` to switch between manga hosts used
