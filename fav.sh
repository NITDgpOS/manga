echo "Enter the name of the manga to add to fav. list"
read manga
echo $manga >> .fav
while true
do
  echo "Do you want to add more?[y/n]"
  read tmp
  case $tmp in
    [Yy]*)
      echo "Enter the name of the manga to add to fav. list"
      read manga
      echo $manga  >> .fav
      ;;
    [Nn]*)
      break
      ;;
  esac
done
sort -u -o .fav .fav
