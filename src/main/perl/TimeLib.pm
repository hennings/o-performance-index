package TimeLib;

sub hms2sec {
  return hms(@_);
}

sub hms {
  my ($t)=@_;
  if ($t=~ /(\d+):(\d+):(\d+)$/) {
    return $1*60*60+$2*60+$3;
  }
  if ($t=~ /(\d+):(\d+)$/) {
    return $1*60+$2;
  }
  die "Cannot parse ,$t,\n";
}

sub trim {
  $_[0]=~ s/^\s+|\s+$//;
  return $_[0];
}

sub sec2hms {
  my ($s)=@_;
  return sprintf  ("%02d:%02d:%02d", int($s/3600),
		  int(($s/60)%60), $s%60);
}
sub sec2hm {
  my ($s)=@_;
  return sprintf  ("%02d:%02d", int($s/3600),
		  int(($s/60)%60));
}


sub sec2ms {
  my ($s)=@_;
  return sprintf  ("%02d:%02d", 
		  int(($s/60)%60), $s%60);
}

1;
