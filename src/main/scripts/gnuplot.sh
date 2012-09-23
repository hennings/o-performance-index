#!/bin/sh

a="$1"
f=$2

echo "* Gnuplot of $1 for $3 - $4"

cat <<EOF > "$a.gp"
set terminal png  font "arial" 10
set terminal png  font "arial" 10 size 950,500
set out '$a-$4.png'
set xrange [0:110]
set yrange [0:]
set style fill solid border -1
set xlabel 'Performance index'
set ylabel 'secs'
set title '$3 - $4'
plot '$f' with boxes notitle
exit
EOF

echo "Running gnuplot on $a.gp"
/cygdrive/c/Program\ Files\ \(x86\)/gnuplot/bin/gnuplot "$a.gp"
rm "$a.gp"