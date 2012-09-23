#!/bin/sh

grep -h Ekeberg src/main/parsed/*2012*csv > src/main/persons/Ekeberg_Bjorn.csv
grep -h Wigemyr src/main/parsed/*2012*csv > src/main/persons/Wigemyr_Tone.csv
grep -h Margrethe src/main/parsed/*2012*csv > src/main/persons/Nordberg_AnneM.csv
grep -h Nordberg src/main/parsed/*2012*csv | grep Anders > src/main/persons/Nordberg_Anders.csv
grep -h Kyburz src/main/parsed/*2012*csv | grep Matth > src/main/persons/Kyburz_Matthias.csv
grep -h Lundanes src/main/parsed/*2012*csv > src/main/persons/Lundanes_Olav.csv
grep -h Omdal src/main/parsed/*2012*csv > src/main/persons/Omdal_HansGunnar.csv
grep -h Kvaal src/main/parsed/*2012*csv > src/main/persons/Osterbo_OysteinK.csv
grep -h Indgaard src/main/parsed/*2012*csv > src/main/persons/Indgaard_UlfF.csv
grep -h Kinneberg src/main/parsed/*2012*csv > src/main/persons/Kinneberg_E.csv
grep -h Magne src/main/parsed/*2012*csv > src/main/persons/Dahli_M.csv
grep -h Tiltnes src/main/parsed/*2012*csv > src/main/persons/Tiltnes_A.csv
grep -h Jahren src/main/parsed/*2012*csv > src/main/persons/Jahren_S.csv
grep -h Fasting src/main/parsed/*2012*csv > src/main/persons/Fasting_M.csv
grep -h Myhre src/main/parsed/*2012*csv > src/main/persons/Myhre_I.csv
grep -h Bagstevold src/main/parsed/*2012*csv > src/main/persons/Bagstevold_H.csv
grep -h Steiwer src/main/parsed/*2012*csv > src/main/persons/Steiwer_K.csv
grep -h Sund src/main/parsed/*2012*csv > src/main/persons/Sund_GR.csv
grep -h Kaas src/main/parsed/*2012*csv > src/main/persons/Kaas_CW.csv
grep -h Weltzien src/main/parsed/*2012*csv > src/main/persons/Weltzien_A.csv
grep -h Skjeset src/main/parsed/*2012*csv > src/main/persons/Skjeset_L.csv
grep -h Bjorgul src/main/parsed/*2012*csv > src/main/persons/Bjorgul_I.csv


persons="Ekeberg_Bjorn  Wigemyr_Tone  Nordberg_AnneM  Nordberg_Anders  Kyburz_Matthias  Lundanes_Olav  Omdal_HansGunnar  Osterbo_OysteinK  Indgaard_UlfF  Kinneberg_E  Dahli_M   Tiltnes_A   Jahren_S   Fasting_M   Myhre_I   Bagstevold_H  Steiwer_K   Sund_GR   Kaas_CW   Weltzien_A  Skjeset_L   Bjorgul_I";

for p in $persons; do
 f="$p.dat"
 echo "$p / $f"
 grep -vi Sprint src/main/persons/$p.csv | perl src/main/perl/generate_aggregate.pl  > output/forest/$f
 grep -i Sprint src/main/persons/$p.csv | perl src/main/perl/generate_aggregate.pl  > output/sprint/$f
 cat src/main/persons/$p.csv | perl src/main/perl/generate_aggregate.pl  > output/total/$f
done



#for p in $persons; do
#  echo "<img src='$p-Total.png'> <img src='$p-Sprint.png'> <img src='$p-Forest.png'>"
#done

for p in $persons; do
  sh src/main/scripts/gnuplot.sh output/tmp/$p output/total/$p.dat "$p" Total
  sh src/main/scripts/gnuplot.sh output/tmp/$p output/sprint/$p.dat "$p" Sprint
  sh src/main/scripts/gnuplot.sh output/tmp/$p output/forest/$p.dat "$p" Forest
done

