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

foreach my $classn ( @classes ) {
	my $classname = $classn->findvalue("ClassShortName");

	my $filename=$event_name."-".$classname;

	$filename=~ s%[/\.\\]%_%g;
	$filename=~ s%__%_%g;

	print STDERR "# ** $classname ********** \n";

	my @persons = $classn->findnodes("PersonResult");
	my @parsed_persons;

	my %splits;

	foreach my $pn (@persons) {
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
		foreach my $spln (@splits) {
  		        $leg++;
			$cur = TimeLib::hms2sec($spln->findvalue("Time"));
			my $diff = $cur - $prev;
			push (@ps, $diff);
			$prev = $cur;
			push @{$splits{$leg}}, $diff;
		}
		  
		print STDERR "$gn - ".scalar(@ps)."\n";
		
		$person{FamilyName} = $fn;
		$person{GivenName} = $gn;
		$person{Club} = $club;
		$person{Starttime} = $starttime;
		$person{Result} = $result;
		$person{ResultTime} = TimeLib::hms2sec($result);
		$person{Position} = $position;
		$person{Status} = $status;
		$person{Splits} = \@ps;

		print "*** Record ***\n". YAML::Dump(\%person);

		push @parsed_persons, \%person;

	}		
	print "** LegName\n";
	foreach my $legname (sort {$a<=>$b} keys %splits) {
	  print "Leg $legname\n";
	  my ($best, $avg25, $avg50, $avg) = find25avg($splits{$legname});
	  print "$best - $avg25 - $avg50, $avg\n";
	}
	exit;
}

sub find25avg {
  my ($inp) = @_;
  my @splits =  sort {$a<=>$b}  @{$inp};
  my $nq1 = int(scalar(@splits)/4);
  my $nq2 = int(scalar(@splits)/2);
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
