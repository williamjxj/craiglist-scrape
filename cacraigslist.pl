#! /cygdrive/c/Perl/bin/perl.exe

use lib qw(../lib/);
use craig_config;
use db;
use craig;

use warnings;
use strict;
use Data::Dumper;
use FileHandle;
use WWW::Mechanize;
use DBI;
use Getopt::Long;

local ($|) = 1;
undef $/;

#-----------------------------------
# 0. initialize:
#-----------------------------------
our ( $num,       $start_time, $end_time, $end_date ) = ( 0,     0,     0, '' );
our ( $start_url, $page_url,   $todate )   = ( undef, undef, INTERVAL_DATE );
our ( $mech, $db, $craig, $log ) = ( undef, undef );
our ( $dbh, $sth );

$start_time = time;

my ( $host, $user, $pass, $dsn ) = ( HOST, USER, PASS, DSN );
$dsn .= ":hostname=$host";
$db = new db( $user, $pass, $dsn );
$dbh = $db->{dbh};

$craig = new craig( $db->{dbh} ) or die;

$log = $craig->get_filename(__FILE__);
$craig->set_log($log);
$craig->write_log( "[" . $log . "]: start at: [" . localtime() . "]." );

my ( $city, $item, $keywords, $email ) = ( undef, undef, undef, undef );
my ( $jobs, $first, $help, $version, $list ) = ( 'jobs', undef, undef, undef );

usage()
  unless (
	GetOptions(
		'jobs=s'     => \$jobs,
		'first'      => \$first,
		'list'       => \$list,
		'todate=s'   => \$todate,
		'city=s'     => \$city,
		'item=s'     => \$item,
		'keywords=s' => \$keywords,
		'email=s'    => \$email,
		'help|?'     => \$help,
		'version'    => \$version
	)
  );

$help && usage();

# print $jobs . "\n"; print $db_name . "\n";

if ($first) {
	my $ca1 = $craig->select_ca_cities();
	foreach my $ca2 (@$ca1) {
		print $ca2->[0] . "\n";
	}
	exit 1;
}

my $db_name;
if ( $jobs eq 'jobs' ) {
   $db_name = 'craigslist_cajobs';
}
else {
	$jobs = 'jobs';
   $db_name = 'craigslist_cajobs';
	# die "There is no suitable job selected.";
}

if ($list) {
	my $list1 = $craig->select_items($jobs);
	foreach my $list2 (@$list1) {
		print $list2->[0] . "\n";
	}
	exit 2;
}
if ($version) {
	print <<EOF;

$0:  Version 2.0
EOF
	exit 2;
}

# date +'%a %d %b' -d "2 day ago"
if ($todate) {
	$end_date = $craig->get_end_date($todate);
}
if ( $city && $item ) {
	my ( $r1, $r2 ) = ( '', '' );

	$r1 = $craig->select_city($city);
	die "No such city: <" . $city . ">, $0 quit." unless ($r1);

	if (($jobs eq 'resumes') && ($item eq 'resumes')) {
		$r2 = 'res/';
	}
	else {
		$r2 = $craig->select_category($item, $jobs);
		die "No such category: <" . $item . ">, $0 quit." unless ($r2);
	}

	$start_url = $r1 . $r2 if ( $city && $item );
	$craig->write_log( "URL: <" . $start_url . ">." );
}

$mech = WWW::Mechanize->new( autocheck => 0 );
if ( $start_url =~ m/cgi-bin/ ) {
	$mech->get($start_url);
	$mech->success or die $mech->response->status_line;
	$page_url = $craig->parse_cgi_page( $mech->content );
}
else {
	$page_url = $start_url;
}

LOOP:
$mech->get($page_url);
$mech->success or die $mech->response->status_line;
my $html = $mech->content;

# Only parse data before $end_date.
my $ht = $craig->parse_date( $end_date, $html );
unless ($ht) {
	$dbh->disconnect();
	$end_time = time;
	$craig->write_log( "Terminated: Total [$todate] days' data (end at: $end_date): [ " . ( $end_time - $start_time ) . " ] seconds used.\n" );
	$craig->write_log( "[$jobs],[$city],[$item]: There are total [ $num ] records was processed succesfully!\n");
	$craig->write_log("==============================================\n");
	$craig->close_log();
	exit 6;
}

$page_url = $craig->parse_next_page($ht);

my $aoh = $craig->parse_item_main($ht);

my ( $pdt, $pemail, $phone, $web, $relevant, $email1 ) = ('', '', '', '', '');
my ( $t0, $t1, $t2, $t3 , $ttt );
foreach my $t ( @{$aoh} ) {
	my $url = $t->[0];

	if ( $t->[2] eq 'img' ) {
		$t->[2] = '';    # t->[]2]=location
	}
	$t->[2] =~ s/\).*$//s if ( $t->[2] =~ m/\)/ );

	$num++;
	$mech->follow_link( url => $url );
	$mech->success
	  or next;           # $mech->success or die $mech->response->status_line;

	if (($jobs eq 'resumes') && ($item eq 'resumes')) {
		( $pdt, $pemail, $phone, $web, $relevant ) = $craig->parse_detail_resumes( $mech->content );
	}
	else {
		( $pdt, $pemail, $phone, $web, $relevant, $email1 ) = $craig->parse_detail( $mech->content );
	}

	$pemail = '' unless ( defined $pemail );
	$pemail = '' unless ($pemail);

	if( $pemail && ! $email1 ) {
		$email1  = $pemail;
	}
	elsif ($pemail && ($pemail !~ m/\@craigslist.org/)) {
		if ($email1) {
			my $ex = $pemail;
			$pemail = $email1;
			$email1 = $ex;
		}
	}
	$pemail  = $dbh->quote( $pemail );
	$email1  = $dbh->quote( $email1 );

	( $t0, $t1, $t2, $t3 ) = @{$t};
	$t0  = $dbh->quote( $t->[0] );
	$t1  = $dbh->quote( $t->[1] );
	$t2  = $dbh->quote( $t->[2] );
	$pdt = ' ' unless ($pdt);

	$phone    = $dbh->quote($phone);
	$web      = $dbh->quote($web);
	$relevant = $dbh->quote($relevant);

	my $c1 = $dbh->quote($city);    # st john's,NL

	# $craig->write_log( "No: " . ($num) . " -- [" . $t0 . ", " . $t1 . ", " . $t2 . ", " . $item . ", " . $pdt . ", " . $pemail . ", " . $phone . ", " . $web . ", " . $c1 . ", " . $email1 . "]\n" );
	# $craig->write_log( "No: " . $url . ", " . $num . " -- [" . $pemail . ", " . $email1 . "]\n" );

	# add column email1 to craigslist_usjobs on July 15, 2010.
	if ($jobs eq 'jobs') {
		$sth = $dbh->do(
			qq{ insert ignore into } . $db_name . qq{
				(url,keywords,relevant,location,item,post_time,email,phone,
				web,city,category,date, email1)
			values($t0,$t1,$relevant,$t2,'$item','$pdt',$email1,
				$phone, $web, $c1,'$jobs',now(), $pemail) }
		);
	}
	else {
		$sth = $dbh->do(
			qq{ insert ignore into } . $db_name . qq{
				(url,keywords,relevant,location,item,post_time,email,phone,
				web,city,category,date)
			values($t0,$t1,$relevant,$t2,'$item','$pdt',$pemail,
				$phone, $web, $c1,'$jobs',now())}
		);
	}

	$mech->back();
}

goto LOOP if ($page_url);

$dbh->disconnect();

$end_time = time;
$craig->write_log( "Total [$todate] days' data (end at: $end_date): [ " . ( $end_time - $start_time ) . " ] seconds used.\n" );
$craig->write_log( "[$jobs],[$city],[$item]: There are total [ $num ] records was processed succesfully!\n");
$craig->write_log("----------------------------------------------\n");
$craig->close_log();

exit 8;

sub usage {
	print <<HELP;
Uage:
      $0
     or:
      $0 -c city -i category
     or:
      $0 -t 3
     or:
      $0 -k keyword -e email
     or:
      $0 -h  [-v]
Description:
  -t from what date to download? default it's from 2 days before.
  -c city, which city to scrape?
  -i category/item, which category/item to scrape?
  -h this help
  -v version

Examples:
     (1) $0     # use default
     (2) $0 -d  # use default 
     (3) $0 -c vancouver -i services       # scrape vancouver's gigs
     (4) $0 -c calgory -i 'services'
     (5) $0 -h  # get help
     (6) $0 -v  # get version

HELP
	exit 3;
}

