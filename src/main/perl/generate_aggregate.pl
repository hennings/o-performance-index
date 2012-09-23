#!/usr/bin/perl

my $gl_name;
my @races;

my %histo;
my $total0 = 0; my $total1=0;
my $psum = 0;

while (<>) {
  chop;
  my ($name,$race,$club,$time,$total_pi, $splits, $pis,$nrs,$nrp) = split /;/;
  $gl_name = $name;
  push @races, $race;
  my @splits = split /,/, $splits;
  my @pis = split /,/, $pis;
  for (my $i = 0; $i<scalar(@splits); $i++) {
    my $pi = int(100*$pis[$i]);
    $histo{$pi}+=$splits[$i];
    $total0 += $splits[$i];
    $psum += $splits[$i]*$pis[$i];
#    print STDERR "$i\t$splits[$i]\t$pis[$i]\t($psum, $total0, $pi)\n";
  }
  $total1+=$time;
  
}

die "No input! " if ($total1==0);

my $sum = 0;

for (my $i = 0; $i<110; $i++) {

  $sum += 0+$histo{$i};
  if ($i%5==0) {
    printf "%3d\t%6d\n", $i, $sum;
    $sum = 0;
  }

}

# Weighted average
printf "# Totals: %d / %d for %s (%.2f)\n",$total0, $total1, $gl_name,($psum/$total0);
