APPS=$(cat store-apps.txt | grep -wo '[0-9]*')
for LINE in $APPS; do
  echo hello something $LINE
done
