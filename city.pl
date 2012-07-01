#! /cygdrive/c/Perl/bin/perl.exe
##/usr/bin/perl -w
# $Id$
#Bug: manitoba,n brunswick, newf &lab, nova scotia, pei, territories

use lib qw(../lib/);
use craig_config;
use common;

use warnings;
use strict;
use Data::Dumper;
use FileHandle;
use WWW::Mechanize;
use DBI;

local($|) = 1; 
undef $/;

#-----------------------------------
# 0. initialize:
#-----------------------------------
our @all = ('united states', 'canada', 'asia', 'americas', 'au/nz', 'africa', 'europe');
#our @all = ('canada');
our ($html, $aohoa) = ('', []);
our ($num1, $num2, $start_time, $end_time) = (0,0,0,0);
my ($mech, $dbh, $sth, @row) = (undef, undef, undef, ());

my $comm = new common() or die;
my $log = $comm->get_filename(__FILE__) . '_'. $comm->get_time(1);
$comm->set_log($log);
$comm->write_log("\n[".$log."]: start at: [".localtime() . "].");
$start_time = time;

$mech = WWW::Mechanize->new( autocheck => 0 );

my ($host, $user, $pass, $dsn) = (HOST, USER, PASS, DSN);
$dsn .= ":hostname=$host";
$dbh = DBI->connect($dsn, $user, $pass, { RaiseError=>1 });

#-----------------------------------
# 1. scrape:
#-----------------------------------
my $aref = [];

#  Option A: 
$mech->get (URL1);
die "Can't even get the home page: ",
$mech->response->status_line unless $mech->success;
$html = $mech->content;

=comment
#  Option B: 
my $fd = new FileHandle(CHTML."country.html") or die;
($html) = (<$fd>);
=cut

#-----------------------------------
# 2. parse.
#-----------------------------------
my ($h) = (undef);
foreach my $c (@all) {
	if ($c eq 'united states') {
		$h = trunc_us($html);
	}
	elsif ($c eq 'canada') {
		$h = trunc_canada($html);
	}
	elsif ($c eq 'asia') {
		$h = trunc_asia($html);
	}
	elsif ($c eq 'americas') {
		$h = trunc_americas($html);
	}
	elsif ($c eq 'au/nz') {
		$h = trunc_aunz($html);
	}
	elsif ($c eq 'africa') {
		$h = trunc_africa($html);
	}
	elsif ($c eq 'europe') {
		$h = trunc_europe($html);
	}
	else {
		die "exit from " . __LINE__ . "\n";
	}

	$aref = parse_country($c, $h);
	foreach my $a (@{$aref}) {
		# $comm->write_log($a, "${c}:");
		my $a1 = $dbh->quote($a->[1]);
		$comm->write_log("[".$a->[0].", ".$a1.", ".$a->[2]."]\n");
		++ $num1;

		$sth=$dbh->do(qq{insert ignore into } . COUNTRY_STATE . qq{(sname,surl,area,sdate) values('$a->[0]',$a1,'$a->[2]',now()) });
	}

	foreach my $t (@{$aref}) {
		my ($t1, $t2) = @$t;

		# bug: 2 'new york' in the screen.  # $mech->follow_link(text => $t1);
		# $mech->follow_link(url => $t2);
		# $mech->success or die $mech->response->status_line; 

		$mech->get($t2);

		my $aoh = parse_html($c, $t1, $mech->content);
		my $aoh1 = [];

		# Here bugs: no single city parsed, such as newf&lab->st john's,NL
		# will fix later.
		foreach my $m (@{$aoh}) {
			my ($m1, $m2) = @$m;
			if ($m1 =~ m/(craigslist|or suggest a new one)/) {
				next;
			}
			if ($m2 =~ m/(forums|wiki)/) {
				next;
			}
			push (@{$aoh1}, $m);
		}
	
		# $comm->write_log($aoh1, "${c} -> ${m1}:");
		# print Dumper($aoh1);

		foreach my $a (@{$aoh1}) {
			my $a0 = $dbh->quote($a->[0]);
			my $a1 = $dbh->quote($a->[1]);
		 	$comm->write_log("[".$a0.", ".$a1.", ".$a->[2].", ".$a->[3]."]\n");
			++ $num2;

			$sth=$dbh->do(qq{ insert ignore into } . CITY . qq{(cname,curl,area1,area2,cdate) values($a0,$a1,'$a->[2]','$a->[3]',now()) });
		}
	
		$mech->back();
	}
}

#-----------------------------------
# 4. double check data is stored.
#-----------------------------------
show_results('select * from '.COUNTRY_STATE.' order by area');
show_results('select * from '.CITY. ' order by area2, area1');

#-----------------------------------
# 5. clear up.
#-----------------------------------
$dbh->disconnect();
# $fd->close() if ($fd);

$end_time = time;
$comm->write_log( "There are total [ $num1 ], [ $num2 ] records was processed succesfully!\n");
$comm->write_log("Finally, there are total [ " . ($end_time - $start_time) . " ] s were used.\n");
$comm->close_log();

exit;


#######################################

sub trunc_us
{
	my ($text) = @_;
	my $extract_html = '';
	($extract_html) = $text =~ m!
		wash\sdc</a>
		(.*)
		alberta
	!xsig;
	return $extract_html;
}
sub trunc_canada
{
	my ($text) = @_;
	my $extract_html = '';
	($extract_html) = $text =~ m!
		wyoming</a>
		(.*)
		ca\scities
	!xsig;
	return $extract_html;
}
sub trunc_canada_1
{
	my ($text) = @_;
	my $extract_html = '';
	($extract_html) = $text =~ m!
		wyoming</a>
		(.*)
		bangladesh
	!xsig;
	return $extract_html;
}
sub trunc_asia
{
	my ($text) = @_;
	my $extract_html = '';
	($extract_html) = $text =~ m!
		more\s..</a>
		(.*)
		au/nz
	!xsig;
	return $extract_html;
}
sub trunc_aunz
{
	my ($text) = @_;
	my $extract_html = '';
	($extract_html) = $text =~ m!
		au/nz</a>
		(.*)
		argentina
	!xsig;
	return $extract_html;
}
sub trunc_americas
{
	my ($text) = @_;
	my $extract_html = '';
	($extract_html) = $text =~ m!
		new\szealand</a>
		(.*)
		africa
	!xsig;
	return $extract_html;
}
sub trunc_africa
{
	my ($text) = @_;
	my $extract_html = '';
	($extract_html) = $text =~ m!
		africa
		(.*)
		austria
	!xsig;
	return $extract_html;
}
sub trunc_europe
{
	my ($text) = @_;
	my $extract_html = '';
	($extract_html) = $text =~ m!
		tunisia</a>
		(.*)
		amsterdam
	!xsig;
	return $extract_html;
}
sub parse_country
{
	my ($c, $text) = @_;
	my $aref = [];

	while ($text =~ m{
		<a\s+href="(.*?)">
		(.*?)
		</a>
		(?:.*?)
	}sgix) {
		my ($t1,$t2) = ($1, $2);
		$t1 =~ s/&amp;/&/g if ($t1 =~ m/&amp;/);
		$t2 =~ s/&amp;/&/g if ($t2 =~ m/&amp;/);
		push (@{$aref}, [ $t2, $t1, $c ]);
	}
	return $aref;
}

sub parse_html
{
	my ($c, $s, $text) = @_;
	my $aref = [];

	# this parse is only used by about/sites and its following for city/country.
	return [] if ($text=~m#href="cal/">event calendar</a>#);
	return [] if ($text=~m#Ereigniskalender#); #austria

	while ($text =~ m{
		<a\s+href="(.*?)">
		(.*?)
		</a>
		(?:.*?)
	}sgix) {
		# 'newf &amp; lab' => 'geo.craigslist.org/iso/ca/nl'
		my ($t1,$t2) = ($1, $2);
		$t1 =~ s/&amp;/&/g if ($t1 =~ m/&amp;/);
		$t2 =~ s/&amp;/&/g if ($t2 =~ m/&amp;/);
		if ($t2 =~ m/<b>/) {
			$t2 =~ s/<b>//g;
			$t2 =~ s/<\/b>//g;
		}
		push (@{$aref}, [$t2,$t1,$s,$c]);
	}
	return $aref;
}

sub select_country_state
{
	my @row = ();
	$sth = $dbh->prepare(qq{select * from } . COUNTRY_STATE . qq{ order by area});
	$sth->execute();
	while (@row = $sth->fetchrow_array()) {
		print Dumper (@row);
	}
}

sub select_city
{
	my @row = ();
	$sth = $dbh->prepare(qq{select * from }.CITY);
	$sth->execute();
	while (@row = $sth->fetchrow_array()) {
		print Dumper (@row);
	}
}

sub show_results
{
	my $sql = shift;
	my $count = 0;
	my @label = ();
	my $label_width = 0;

	$sth = $dbh->prepare ($sql);
	$sth->execute ();

	# get column names to use for labels and
	# determine max column name width for formatting
	@label = @{$sth->{NAME}};
	foreach my $label (@label) {
		$label_width = length ($label) if $label_width < length ($label);
	}

	while (my @ary = $sth->fetchrow_array ()) {
		# print newline before 2nd and subsequent entries
		print "\n" if ++$count > 1;
		foreach (my $i = 0; $i < $sth->{NUM_OF_FIELDS}; $i++)
		{
			printf "%-*s", $label_width+1, $label[$i] . ":";
			print " ", $ary[$i] if defined ($ary[$i]);
			print "\n";
		}
	}
	print "Total columns: [" . $sth->{NUM_OF_FIELDS} . "]\n";
	$sth->finish ();
}
