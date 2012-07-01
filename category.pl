#! /cygdrive/c/Perl/bin/perl.exe
##!/usr/bin/perl -w
# $Id$

use lib qw(./);
use config;
use common;
# use parse;

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
our ($html, $aohoa) = ('', []);
our ($num1, $num2, $start_time, $end_time) = (0,0,0,0);
my ($mech, $dbh, $sth, @row) = (undef, undef, undef, ());

my $comm = new common() or die;
my $log = $comm->get_filename(__FILE__) . '_' . $comm->get_time(1);
$comm->set_log($log);
$comm->write_log("\n[".$log."]: start at: [".localtime() . "].");

$start_time = time;

$mech = WWW::Mechanize->new( autocheck => 1 );

my ($host, $user, $pass, $dsn) = (HOST, USER, PASS, DSN);
$dsn .= ":hostname=$host";
$dbh = DBI->connect($dsn, $user, $pass, { RaiseError=>1 });

#-----------------------------------
# 1. scrape:
#-----------------------------------
my @ary = ();

#. Option A:
$mech->get (URL2);
die "Can't even get [" . URL2 . "] page: ",
$mech->response->status_line unless $mech->success;
$html = $mech->content;

=comment
#. Option B:
my $fd = new FileHandle(CHTML."category.html") or die;
($html) = (<$fd>);
# $aohoa = $comm->get_category();
=cut

#-----------------------------------
# 2. parse.
#-----------------------------------
# <div id="main">...enlish |
my $h0 = trunc_category($html);

# parse 8 category.
my $h1 = parse_category($h0);

# parse personals.
my $h2 = parse_category_personals($h0);

# put all 9 cateogry into array.
$aohoa = [$h1, $h2];

# $comm->write_log($aohoa, 'category');

#-----------------------------------
# 3. insert tables.
#-----------------------------------
my $category = 'dummy';
foreach my $item (@{$aohoa}) {
	foreach my $key (keys %$item) {
		foreach my $t (@{$item->{$key}}) {
			my ($t1,$t2,$t3) = ($dbh->quote($t->[0]),$t->[1],$t->[2]);
			$comm->write_log("[".$t1.", ".$t2.", ".$t3."]\n");
			if ($t3 eq 'c') {
				$category = $t1;
				++ $num1; 
				$sth=$dbh->do(qq{insert into } . CATEGORY . qq{(cname,curl,cdate) values($t1,'$t2',now())});
			}
			if ($t3 eq 's') {
				++ $num2; 
				$sth=$dbh->do(qq{insert into } . ITEM . qq{(iname,iurl,category,idate) values($t1,'$t2',$category,now())});
			}
		}
	}
}

#-----------------------------------
# 4. double check data is stored.
#-----------------------------------
# select_category();
show_results('select * from ' . CATEGORY . ' order by cname');
show_results('select * from ' . ITEM . ' order by iname');

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

sub trunc_category
{
	my ($text) = @_;
	($html) = $text =~ m!
		<table\ssummary="main"\sid="main">
		(.*)
		english\s+\|
	!xsig;

	return $html;
}
	 
sub parse_category
{
	my ($html) = @_;
	my $href = {};

	while ($html =~ m{
		<h4>
		(?:(?:&nbsp;)+?)
		<a\s+href="(.*?)">
		(.*?)
		</a>
		(?:.*?)
		<div\s+class=(?:.*?)>
		(.*?)
		</div>
		(?:.*?)
	}sgix) {
		my ($t1,$t2,$t3) = ($1, $2, $3);
		parse_sub_category($t3);
		$t1 =~ s/&amp;/&/g if ($t1 =~ m/&amp;/); #/cgi-bin/jobs.cgi?&amp;category=trd/
		my $t = [ $t2, $t1, 'c' ];
		unshift (@ary, $t);

		$href->{$t2} = [ @ary ];
		undef (@ary);
	}
	return $href;
}

sub parse_sub_category
{
	my ($html) = @_;
	my $aref = [];
	while ($html =~ m{
		<li>
		<a\s+href="(.*?)">
		(.*?)
		</a>
		(?:.*?)
		}sgix) {
		my ($t1, $t2) = ($1, $2);
		$t1 =~ s/&amp;/&/g if ($t1 =~ m/&amp;/);
		# $t2 =~ s/'/\'/g if ($t2 =~ m/'/);	# 'skill\'d trade',
		push(@ary, [ $t2, $t1, 's' ]);
	}
}

sub parse_category_personals
{
	my ($html) = @_;
	my $href = {};

	while ($html =~ m{
		<h4>
		(?:&nbsp;){1,}
		(\w+)
		(?:&nbsp;){1,}
		</h4>
		(?:.*?)
		<div\s+class=(?:.*?)>
		(.*?)
		</div>
		(?:.*?)
	}sgix) {
		my ($t1,$t2) = ($1, $2);
		my $aref = parse_sub_category($t2);
		my $t = [ $t1, '', 'c' ];
		unshift (@ary, $t);

		$href->{$t1} = [ @ary ];
		undef (@ary);
	}

	return $href;
}

# deprecated, use show_results instead.
sub select_category
{
	$sth = $dbh->prepare(qq{select * from } . CATEGORY);
	$sth->execute();
	while (@row = $sth->fetchrow_array()) {
		print Dumper (@row);
	}
}

sub show_results
{
	my $sql = shift;
	my $count = 0;  # number of entries printed so far
	my @label = (); # column label array
	my $label_width = 0;

	$sth = $dbh->prepare ($sql);
	$sth->execute();

	# get column names to use for labels and
	# determine max column name width for formatting
	@label = @{$sth->{NAME}};
	foreach my $label (@label) {
		$label_width = length ($label) if $label_width < length ($label);
	}

	while (@row = $sth->fetchrow_array ()) {
		# print newline before 2nd and subsequent entries
		print "\n" if ++$count > 1;
		foreach (my $i = 0; $i < $sth->{NUM_OF_FIELDS}; $i++)
		{
			printf "%-*s", $label_width+1, $label[$i] . ":";
			print " ", $row[$i] if defined ($row[$i]);
			print "\n";
		}
	} 
	print "Total columns: [" . $sth->{NUM_OF_FIELDS} . "]\n";
	$sth->finish();
}
