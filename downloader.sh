mkdir hajime
cd hajime
for i in {1114..1116}
do
	mkdir $i
	cd $i
	for j in {1..20}
	do
		wget www.mangareader.net/hajime-no-ippo/$i/$j
	done
	cd ..
done
