#!/usr/local/bin/perl -w
$|++;
use strict;
BEGIN { unshift @INC, '/htdocs/a/my_lib' }
my @formats = qw(CSV Pipe Tab Fixed Paragraph ARRAY);
eval {
  require AnyData;
};
die "Use must download and install AnyData before you can install DBD::AnyData!" if $@;

=pod

undef $@;
eval {
  require XML::Parser;
  require XML::Twig;
};
unshift @formats,'XML' unless $@;
undef $@;
eval {
  require HTML::Parser;
  require HTML::TableExtract;
  require CGI;
};
push @formats,'HTMLtable' unless $@;

=cut

for my $driver('DBD::AnyData') {
  print "\n$driver\n";
  for my $format(@formats) {
      printf  "  %10s ... ", $format;
      printf "%s!\n" , test($driver,$format);
  }
}

sub test {
    my($driver,$format)=@_;
    return $driver =~ /dbd/i
        ? test_dbd($format)
        : test_ad($format);
}

sub test_ad {}

sub test_dbd {
  my $format = shift;
  use DBI;
  my $dbh=DBI->connect("dbi:AnyData:(RaiseError=>1):");
  my $file = 'AnyData_test_db';
  unlink $file if -e $file;
  my $flags = {pattern=>'A5 A8 A3'};

  $dbh->func('test',$format,$file,$flags,'ad_catalog')
       unless $format =~ /XML|HTMLtable|ARRAY/;

  # CREATE A TEMPORARY TABLE FROM DBI/SQL COMMANDS
  # INSERT, UPDATE, and DELETE ROWS
  #

  $dbh->do("CREATE TABLE test (name TEXT, country TEXT,sex TEXT)");
  $dbh->do("INSERT INTO test VALUES ('Sue','fr','f')");
  $dbh->do("INSERT INTO test VALUES ('Tom','fr','f')");
  $dbh->do("INSERT INTO test VALUES ('Bev','en','f')");
  $dbh->do("UPDATE test SET sex='m' WHERE name = 'Tom'");
  $dbh->do("DELETE FROM test WHERE name = 'Bev'");
#  print $dbh->func('SELECT * FROM test','ad_dump');
  if ($format ne 'ARRAY') {
    if ($format =~ /XML|HTMLtable/) {
     $dbh->func('test',$format,$file,$flags,'ad_export');      # save to disk
    }
     $dbh->func('test','ad_clear');                       # clear from memory
     $dbh->func('test',$format,$file,$flags,'ad_import');    # read from disk
  }
 my %val;
 $val{single_select} =
     $dbh->selectrow_array(                          # display single value
         qq/SELECT sex FROM test WHERE name = 'Sue'/
     );
 return "Failed single select" unless 'f' eq $val{single_select};
 my $sth = $dbh->prepare(                              # display multiple rows
    qq/SELECT name FROM test WHERE country = ?/
 );
 $sth->execute('fr');
 while (my ($name)=$sth->fetchrow) {
     $val{select_multiple} .= $name;
 }
 return "Failed multiple select" unless "SueTom" eq $val{select_multiple};
 $sth = $dbh->prepare('SELECT * FROM test');           # display column names
 $sth->execute();
 $val{names} = join ',',@{$sth->{NAME_lc}};
 return "Failed names" unless "name,country,sex" eq $val{names};
 $val{rows}  = $sth->rows;                             # display number of rows
 return "Failed rows" unless 2 == $val{rows};
  if ($format ne 'ARRAY') {
 my $str = $dbh->func(                                     # convert to
    'ARRAY',[["a","b"],[1,2]],$format,undef,undef,$flags,'ad_convert'
 );
 $str =~ s/\s+/,/ if $format eq 'Fixed';
 my $ary = $dbh->func(                                     # convert from
    $format,[$str],'ARRAY',undef,$flags,'ad_convert');
 return "Failed converting" unless 'a' eq $ary->[0]->[0];
  }
 return "ok";
}
__END__
