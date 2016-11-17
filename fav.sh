check () {
  m=$1
  m=${m,,} # Converting it to lower case
  m=${m// /-} # Removing spaces and adding - in their places
  if curl -s --head http://www.mangareader.net/$m | grep "200 OK" > /dev/null
  then
    echo $m >> .fav
  else
    echo "Manga name you entered is not valid"
  fi
}

echo "Enter the name of the manga to add to fav. list"
read manga
check "$manga"
while true
do
  echo "Do you want to add more?[y/n]"
  read tmp
  case $tmp in
    [Yy]*)
      echo "Enter the name of the manga to add to fav. list"
      read manga
      check "$manga"
      ;;
    [Nn]*)
      break
      ;;
  esac
done
sort -u -o .fav .fav
