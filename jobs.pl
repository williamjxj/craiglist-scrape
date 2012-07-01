#! /cygdrive/c/Perl/bin/perl.exe
# $Id$
# $0 -c vancouver -i jobs
# http://www.tutorialspoint.com/mysql/mysql-handling-duplicates.htm
# Issues:
# 1. follow_link(): html doesn't exists.
# 2. incremently scraping test.

use lib qw(../lib/);
use craig_config;
use craig;
use db;

use warnings;
use strict;
use Data::Dumper;
use FileHandle;
use WWW::Mechanize;
use DBI;
use Getopt::Long;
our $dbh;

local($|) = 1; 
undef $/;

#-----------------------------------
# 0. initialize:
#-----------------------------------
our ($num, $start_time, $end_time) = (0,0,0);
our ($html, $page_url, $today) = (undef, undef, []);
my ($mech, $sth) = (undef, undef);

my ($host, $user, $pass, $dsn) = (HOST, USER, PASS, DSN);
$dsn .= ":hostname=$host";
my $db = new db($user, $pass, $dsn);
$dbh = $db->{dbh};

my $craig = new craig(CRAIG) or die;
my $log = $craig->get_filename(__FILE__);
$craig->set_log($log);
$start_time = time;

my	$end_date = $craig->get_end_date($todate);

my $start_url = URL4;

my ($city,$item) = (DEFAULT_CITY, DEFAULT_CATEGORY);
my ($help,$keywords,$email,$version,$todate)
	=(undef,undef,undef,undef,undef);

usage() unless (GetOptions(
	'first' => \$first,
	'date=s' => \$date,
	'city=s' => \$city,
	'item=s' => \$item,
	'keywords=s' => \$keywords,
	'email=s' => \$email,
	'help|?' => \$help,
	'version' => \$version
));

$help && usage();

if ($version) {
	print <<EOF;

$0:  Version 1.0
EOF
	exit 1;
}

if ($first) {
	my $ca1 = $craig->select_ca_cities();
	foreach my $ca2 (@$ca1) {
		foreach my $ca3 (@{$ca2}) {
			print $ca3 . "\n";
		}
	}
	exit 2;
}

if ($city && $item) {
	my ($r1, $r2) = ('', '');

	$r1 = select_city($city);
	if ($r1) {
		print "City: <".$r1.">...\n";
		$craig->write_log("City: <".$r1.">.");
	}
	else {
		die "No such city: <".$city.">, $0 quit.";
	}

	$r2 = select_category($item);
	if ($r2) {
		print "Category: <".$r2.">...\n";
		$craig->write_log("Category: <".$r2.">.");
	}
	else {
		die "No such category: <".$item.">, $0 quit.";
	}
	$start_url = $r1 . $r2 if ($city && $item);
	$craig->write_log("URL: <".$start_url.">.");
	print $start_url . "\n";
}
if ($keywords && $email) {
	select_keywords_email($keywords, $email);
}
elsif ($keywords) {
	select_keywords($keywords);
}
elsif ($email) {
	select_email($email);
}

$craig->write_log("[".$log."]: start at: [".localtime() . "].");

$mech = WWW::Mechanize->new( autocheck => 0 );


$mech->get($start_url);
$mech->success or die $mech->response->status_line; 
$page_url = parse_cgi_page($mech->content);

LOOP:
$mech->follow_link(url => $page_url);
$mech->success or die $mech->response->status_line; 
$html = $mech->content;

my $todates = parse_date($todate, $mech->content);
unless ($todates->[1]) {
	print "No Data can be extracted.\n";
	exit;
}
my $aoh = parse_jobs($todates->[1]);

$page_url = parse_next_page($mech->content);

foreach my $t (@{$aoh})
{
	my $url = $t->[0];

	$mech->follow_link(url => $url);
	$mech->success or next; # $mech->success or die $mech->response->status_line;

	my ($pdt,$pemail,$phone,$web,$relevant) = parse_jobs2($mech->content);
	if (defined $pemail) 
	{
		my ($t0, $t1, $t2, $t3, $t4, $t5) = @{$t};
		$t0 = $dbh->quote($t->[0]);
		$t1 = $dbh->quote($t->[1]);
		$t2 = $dbh->quote($t->[2]);
		$t3 = $dbh->quote($t->[3]);
		$t4 = $dbh->quote($t->[4]);
		$pdt = ' ' unless ($pdt);
		# phone
		$phone = $dbh->quote($phone);
		# web
		$web = $dbh->quote($web);
		$relevant = $dbh->quote($relevant);

		my $c1 = $dbh->quote($city); # st john's,NL
		$craig->write_log("No: ".(++$num)." -- [".$t0.", ".$t1.", ".$t2.", ".$t3.", ".$t4.", ".$pdt.", ".$pemail.", ".$phone.", ".$web.", ".$c1.", ".$item."]\n");

		$sth = $dbh->do(qq{ insert ignore into }.TOPIC.qq{
		(url,keywords,relevant,location,item_url,item,post_time,email,phone,
		web,city,category,date)
		values($t0,$t1,$relevant,$t2,$t3,$t4,'$pdt','$pemail',
		$phone, $web, $c1,'$item',now())});

	}
 
	$mech->back();
}

goto LOOP if ($page_url);



$dbh->disconnect();
# $fd->close() if ($fd);

$end_time = time;
$craig->write_log( "There are total [ $num ] records was processed succesfully!\n");

# $craig->write_log("<$todates->[0]>: Finally, there are total [ " . ($end_time - $start_time) . " ] seconds used.\n");

$craig->write_log("Finally, there are total [ " . ($end_time-$start_time) . " ] seconds used.\n");
$craig->close_log();

exit;


sub usage
{
print <<HELP;
Uage:
      $0 [-d]
     or:
      $0 -c city -i category
     or:
      $0 -k keyword -e email
     or:
      $0 -h  [-v]
Description:
  -c city, which city to scrape?
  -i category/item, which category/item to scrape?
  -k search by keywords, what keyword to search?
  -e search by email, what email to search
  -h this help
  -v version

Examples:
     (1) $0     # use default
     (2) $0 -d  # such as `date +'%a %d %b' -d "2 day ago"`
     (3) $0 -c vancouver -i jobs       # scrape vancouver's jobs
     (4) $0 -c calgory -i 'software / qa / dba'
     (5) $0 -k 'php develper' -e 'email\@dummy.com' # seach keywords & email
     (6) $0 -k 'php develper'          # seach keywords
     (7) $0 -e 'email\@dummy.com'      # seach email
     (8) $0 -h  # get help
     (9) $0 -v  # get version

HELP
exit 1;
}

sub init_env
{
	$SIG{'INT'}  = 'IGNORE';
	$SIG{'QUIT'} = 'IGNORE';
	$SIG{'TERM'} = 'IGNORE';
	$SIG{'PIPE'} = 'IGNORE';
	$SIG{'CHLD'} = 'IGNORE';

	my $pid = fork();
	die "$!" unless defined $pid; exit 4 if $pid;

	select(STDOUT);
	$| = 1;
}

sub BEGIN {
	$ENV{'PATH'} = '/usr/bin/:/bin/:.';
}
