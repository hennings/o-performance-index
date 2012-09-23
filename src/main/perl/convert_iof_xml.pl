#!/usr/bin/perl

use YAML;
use Data::Dumper;
use lib 'src/main/perl';


use TimeLib;

use strict;

use XML::LibXML;

my $f = shift;

my $parser = XML::LibXML->new();
my $tree = $parser->parse_file($f);
my $root = $tree->getDocumentElement;

my $event_name = $root->findvalue("//Event/Name");

my @classes = $root->findnodes("ClassResult");

my @all;

foreach my $classn ( @classes ) {
	my $classname = $classn->findvalue("ClassShortName");

	my $filename=$event_name."-".$classname;

	$filename=~ s%[/\.\\]%_%g;
	$filename=~ s%__%_%g;

	print STDERR "# ** $classname ********** \n";

	my @persons = $classn->findnodes("PersonResult");
	my @parsed_persons;

	my %splits;
	my @splits_q25;

	foreach my $pn (@persons) {
		print STDERR "--new\n";

	        my %person;
		my $fn = $pn->findvalue("Person/PersonName/Family");
		my $gn = $pn->findvalue("Person/PersonName/Given");
		my $club = $pn->findvalue("Club/Name");

		
		my $starttime = $pn->findvalue("Result/StartTime/Clock");
		my $result = $pn->findvalue("Result/Time/Clock");
		my $position = $pn->findvalue("Result/ResultPosition");
		my $status = $pn->findvalue("Result/CompetitorStatus/\@value");
		my $cl = $pn->findvalue("Result/CourseLength");
		next unless ($status eq "OK");

		my @splits = $pn->findnodes("Result/SplitTime");

		my @ps = ();
		my $cur = 0;my $prev = 0;
		my $leg = 0;
		my $tot = 0;
		my $result_s = TimeLib::hms2sec($result);

		foreach my $spln (@splits) {
  		        $leg++;
			my $time = $spln->findvalue("Time");
			next unless ($time);
			$cur = TimeLib::hms2sec($time);
			my $diff = $cur - $prev;
			if ($diff<0) {
			  die "*** Negative split!!! $diff - $leg / $fn $gn\n";
			}
			$tot += $diff;
			push (@ps, $diff);
			$prev = $cur;
			push @{$splits{$leg}}, $diff;
		}
		if ($tot < $result_s) {
		        print STDERR "** Adding the last leg\n";
		        my $diff = $result_s - $tot;
			push (@ps, $diff);
			push @{$splits{1+$leg}}, $diff;
		} elsif ($tot > $result_s) {
		        die "Strange data! $tot > $result_s\n";
		}

		  
		print STDERR "$gn $fn - ".scalar(@ps)."\n";
		
		$person{FamilyName} = $fn;
		$person{GivenName} = $gn;
		$person{Name} = "$fn $gn";
		$person{Club} = $club;
		$person{Starttime} = $starttime;
		$person{Result} = $result;
		$person{ResultTime} = $result_s;
		$person{Position} = $position;
		$person{Status} = $status;
		$person{Splits} = \@ps;

		push @parsed_persons, \%person;

	}		
	print STDERR "** LegName\n";
	foreach my $legname (sort {$a<=>$b} keys %splits) {
	  print STDERR "Leg $legname\n";
	  my ($best, $avg25, $avg50, $avg) = find25avg($splits{$legname});
	  print STDERR "$best - $avg25 - $avg50, $avg\n";
	  push @splits_q25, $avg25;
	}


	foreach my $p (@parsed_persons) {
	    my $pip;
	    $pip->{Name} = $p->{Name};
	    $pip->{ResultTime} = $p->{ResultTime};

	    print STDERR "$p->{Name} / $p->{ResultTime}\n";
	    my @sp = @{$p->{Splits}};
	    my $partperf = 0.0;
	    for (my $i = 0; $i<scalar(@sp); $i++) {
	        my $pi = $splits_q25[$i]/$sp[$i];
		printf STDERR ("%d - %.2f \t=> %3.1f %\n", $sp[$i],$splits_q25[$i],
			100.0 * $pi );
		push @{$p->{PerfIndexList}}, $pi;
		$partperf += ($sp[$i] / $p->{ResultTime}) * $pi;
		push @{$p->{PerfIndexTuple}}, [$sp[$i], $pi]  ;
	    }
	    $p->{PerfIndex} = $partperf;
	    $pip->{Race} = $filename;
	    $pip->{PerfIndex} = $partperf;
	    $pip->{PerfIndexList} = $p->{PerfIndexList};
	    $pip->{Splits} = $p->{Splits};
	    #	    push @all, $pip;
	    printf ("%s;%s;%s;%d;%.5f;%s;%s;%d;%d\n",
		    $pip->{Name},
		    $pip->{Race},
		    $p->{Club},
		    $pip->{ResultTime},
		    $pip->{PerfIndex},
		    join(",", @{$pip->{Splits}}),
		    join(",", @{$pip->{PerfIndexList}}),
		    scalar(@{$pip->{Splits}}),
		    scalar(@{$pip->{PerfIndexList}})
		   );

	    print STDERR "Total PerfIndex = $partperf\n";
	}


}

#print YAML::Dump(@all);


sub find25avg {
  my ($inp) = @_;
  my @splits =  sort {$a<=>$b}  @{$inp};
  my $nq1 = int(0.99 + scalar(@splits)/4);
  my $nq2 = int(0.5 + scalar(@splits)/2);
  my $best = $splits[0];
  my $sum = 0;
  my $cnt = 0;
  my $q1; my $q2;
  foreach my $s (@splits) {
    $cnt++;
    $sum += $s;
    $q1 = $sum/$cnt if ($cnt==$nq1);
    $q2 = $sum/$cnt if ($cnt==$nq2);
  }
  return ($best, $q1, $q2, $sum/$cnt);
}
