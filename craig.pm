package craig;

# $Id$
# craig inherit ../lib/common.pm

use lib qw(../lib);
use craig_config;
use common;
@ISA = qw(common);
use strict;
our ( $dbh, $sth );

sub new {
	my ( $type, $dbh_handle ) = @_;
	my $self = {};
	$self->{dbh} = $dbh_handle;
	$self->{app} = 'craig';
	bless $self, $type;
}
# <blockquote><p><a href=/web>Continue to web / info design job postings</a></p>
sub parse_cgi_page {
	my ( $self, $html ) = @_;
	while (
		$html =~ m {
		<blockquote>
		(?:.*?)
		<p>
		<a(?:.*?)href=(.*?)>
		(?:.*?)
		</a>
		(?:.*?)
		</blockquote>
	}sgix
	  )
	{
		my $url = $1;
		$url =~ s/"//g if $url=~m/"/;
		return $url;
	}
	return '';
}

# return 'today' and Only today's data in a page.
sub parse_today {
	my ( $self, $html ) = @_;
	my ( $m, $n ) = ( undef, undef );
	while (
		$html =~ m{
		<h4>
		(.*?)
		</h4>
		(.*?)
		(?=<h4>|</body>|<p\salign="center">)
	}sgix
	  )
	{
		if ( !defined $m ) {
			$m = $1;
			$n = $2;
			next;
		}
		else {
			if ( $m ne $1 ) {
				last;
			}
		}
	}
	return [ $m, $n ];
}

# (?:<h4>$t1\s$t2\s$t3</h4>|<p\s+align="center"|</body>)
# http://auburn.craigslist.org/search/crg?query=+
sub parse_date {
	my ( $self, $date, $html ) = @_;
	my ( $t1, $t2, $t3 ) = $date =~ m/(\w+)\s(\w+)\s(\w+)/g;
	$html =~ m{
		(?=<h4\sclass="ban">)
		(.*?)
		(?:<h4>$t1\s$t2\s$t3</h4>|<div\sid="footer"|</body>)
	}sgix;
	return $1;
}
sub parse_gigs_html {
	my ( $self, $html ) = @_;
	$html =~ m{
		<div>
		sort\sby
		(.*?)
		<div>
		sort\sby
	}sgix;
	return $1;
}
sub parse_main {
	my ( $self, $html ) = @_;
	my $aoh = [];

	while (
		$html =~ m {
		<p>
		<a\s+href="(.*?)"> 	# keywords url.
		(.*?)				# keywords.
		</a>
		(.*?)				# location.
		<small\sclass="gc">
		<a\s+href="(.*?)">	# item url.
		(.*?)				# item
		</a>
		(?:.*?)
		</small>
	}sgix
	  )
	{
		my ( $t1, $t2, $t3, $t4, $t5 ) = ( $1, $2, $3, $4, $5 );
		$t2 = $self->trim($t2);
		$t2 =~ s/\s+-//g if ( $t2 =~ m/\s+-/ );
		$t3 =~ s/\<.*?\>//g;
		$t3 =~ s/-//;
		$t3 = $self->trim($t3);
		$t3 =~ s/^\(//      if ( $t3 =~ m/\(/ );
		$t3 =~ s/\)$//      if ( $t3 =~ m/\)/ );
		$t5 =~ s/&nbsp;/ /g if ( $t5 =~ m/&nbsp;/ );
		$t5 =~ s/&amp;/ /g  if ( $t5 =~ m/&amp;/ );
		push( @{$aoh}, [ $t1, $t2, $t3, $t4, $t5 ] );
	}
	return $aoh;
}

sub parse_item_main {
	my ( $self, $html ) = @_;
	my $aoh = [];
	return [] unless $html;
	while (
		$html =~ m {
		<p>
		(?:.*?)				# for gigs: <p>Jun 9 - <a href="...">
		<a\s+href="(.*?)"> 	# keywords url.
		(.*?)				# keywords.
		</a>
		(.*?)
		</p>
	}sgix
	  )
	{
		my ( $url, $keywords, $location ) = ( $1, $2, $3 );
		$keywords = $self->trim($2);
		$location =~ s/\<.*?\>//g;
		$location =~ s/-//;
		$location = $self->trim($location);
		$location =~ s/^\(// if ( $location =~ m/\(/ );
		$location =~ s/\)$// if ( $location =~ m/\)/ );
		push( @{$aoh}, [ $url, $keywords, $location ] );
	}
	return $aoh;
}

sub parse_next_page {
	my ( $self, $html ) = @_;
	return '' unless $html;
	while (
		$html =~ m {
		<p\salign="center">
		<font\ssize="4">
		<a\shref="(.*?)">
		(?:.*?)
		</a>
		</font>
	}sgix
	  )
	{
		return $1;
	}
	return '';
}

# <a href="http://www.hostelcareers.ca/job-search/hi-banff-alpine-centre/activities-coordinator/263" rel="nofollow">
# www.hostelcareers.ca<a rel="nofollow">
sub parse_detail {
	my ( $self, $html ) = @_;
	my @ary = ();

	while (
		$html =~ m{
		Date:
		(.*?)		# Date
		<br
		(?:.*?)
		Reply\s+to:
		(.*?)		# Email
		<div\sid="userbody">
		(.*?)		# Content
		</div>
	}sgix
	  )
	{
		my ( $date, $email, $t3 ) = ( $1, $2, $3 );
		$date =~ s/^\s+// if ( $date =~ m/^\s/ );
		$date =~ s/\s+$// if ( $date =~ m/\s$/ );
		$date =~ s/,\s+/ /;
		$date =~ s/ \w+$//;
		$email = $self->get_email($email);
		my $web      = $self->get_web($t3);
		my $phone    = $self->get_phone($t3);
		my $shtml    = $self->strip_craig_userbody($t3);
		my $email1 = $self->get_email_1($shtml);
		my $relevant = $self->get_relevant($shtml);
		push( @ary, $date, $email, $phone, $web, $relevant, $email1 );
	}
	return @ary;
}

# How to get SUPER::get_email of common.pm ?
sub get_email_1
{
    my ($self, $html) = @_;
    return '' unless $html;
    my ($email) = $html =~ m{\b([\w\.\-]+@[\w\.\-]+)\b}s;
    return $email;
}

sub get_email {
	my ( $self, $str ) = @_;
	return '' unless $str;
	if ( $str =~ m/\@/ ) {
		$str =~ s/\<a.*?>//s;
		$str =~ s/<\/a>.*$//s;    # </a>
		$str = $self->trim($str);
	}
	elsif ( $str =~ m/see below/i ) {
		$str = '';
	}
	else {
		$str = '';
	}
	return $str;
}

# Deprecated from Jun 07,2010.
sub parse_detail_1 {
	my ( $self, $html ) = @_;
	my @ary = ();

	while (
		$html =~ m{
		Date:
		(.*?)		# Date
		<br
		(?:.*?)
		Reply\s+to:
		(?:.*?)
		<a\s(?:.*?)>
		(.*?)		# email
		</a>
		(?:.*?)
		<div\sid="userbody">
		(.*?)		# content
		</div>
	}sgix
	  )
	{
		my ( $date, $email, $t3 ) = ( $1, $2, $3 );
		$date =~ s/^\s+// if ( $date =~ m/^\s/ );
		$date =~ s/\s+$// if ( $date =~ m/\s$/ );
		$date =~ s/,\s+/ /;
		$date =~ s/ \w+$//;
		my $web      = $self->get_web($t3);
		my $phone    = $self->get_phone($t3);
		my $shtml    = $self->strip_craig_userbody($t3);
		my $relevant = $self->get_relevant($shtml);
		push( @ary, $date, $email, $phone, $web, $relevant );
	}
	return @ary;
}
sub parse_detail_resumes {
	my ( $self, $html ) = @_;
	my @ary = ();
	while (
		$html =~ m{
		Date:
		(.*?)		# Date
		<br
		(?:.*?)
		<div\sid="userbody">
		(.*?)		# content
		</div>
	}sgix
	  )
	{
		my ( $date, $t3 ) = ( $1, $2);
		$date =~ s/^\s+// if ( $date =~ m/^\s/ );
		$date =~ s/\s+$// if ( $date =~ m/\s$/ );
		$date =~ s/,\s+/ /;
		$date =~ s/ \w+$//;
		my $web      = $self->get_web($t3);
		my $phone    = $self->get_phone($t3);
		my $shtml    = $self->strip_craig_userbody($t3);
		my $relevant = $self->get_relevant($shtml);
		my $email    = $self->get_email_1($relevant);
		push( @ary, $date, $email, $phone, $web, $relevant );
	}
	return @ary;
}

sub select_ca_cities {
	my $self = shift;
	my $aref = [];
	$sth =
	  $self->{dbh}
	  ->prepare( q{select cname from } . CITY . qq{ where area2='canada'} );
	$sth->execute();
	$aref = $sth->fetchall_arrayref();
	$sth->finish();

	# print Dumper($aref);
	return $aref;
}

sub select_city {
	my ( $self, $city ) = @_;
	my @row = ();
	my $c1  = $self->{dbh}->quote($city);
	$sth =
	  $self->{dbh}->prepare( q{ select curl from } 
		  . CITY
		  . qq{ where cname=$c1 and area2='canada' } );
	$sth->execute();
	@row = $sth->fetchrow_array();
	$sth->finish();
	return $row[0];
}

sub select_us_cities {
	my $self = shift;
	my $aref = [];
	$sth =
	  $self->{dbh}->prepare(
		q{select cname from } . CITY . qq{ where area2='united states'} );
	$sth->execute();
	$aref = $sth->fetchall_arrayref();
	$sth->finish();

	# print Dumper($aref);
	return $aref;
}

sub select_items {
	my ( $self, $category ) = @_;
	my $aref = [];
	if ($category eq 'resumes') {
		$aref->[0][0] = 'resumes';
		return $aref;
	}
	my $c2  = $self->{dbh}->quote($category);
	$sth =
	  $self->{dbh}->prepare( q{select iname from } 
		  . ITEM
		  . qq{ where category=$c2 and selected='Y' order by iname} );
	$sth->execute();
	$aref = $sth->fetchall_arrayref();
	$sth->finish();
	return $aref;
}

sub select_us_city {
	my ( $self, $city ) = @_;
	my @row = ();
	my $c1  = $self->{dbh}->quote($city);
	$sth =
	  $self->{dbh}->prepare( q{ select curl from } 
		  . CITY
		  . qq{ where cname=$c1 and area2='united states' } );
	$sth->execute();
	@row = $sth->fetchrow_array();
	$sth->finish();
	return $row[0];
}

sub select_category {
	my ( $self, $item, $category ) = @_;
	my @row = ();
	$sth =
	  $self->{dbh}
	  ->prepare( q{ select curl from } . CATEGORY . qq{ where cname='$item' } );
	$sth->execute();
	@row = $sth->fetchrow_array();
	$sth->finish();
	if ( $row[0] ) {
		return $row[0];
	}
	else {
		$sth =
		  $self->{dbh}->prepare(
			qq{ select iurl from } . ITEM . qq{ where iname='$item' and category = '$category' and selected='Y' } );
		$sth->execute();
		@row = $sth->fetchrow_array();
		$sth->finish();
		return $row[0];
	}
}

sub select_keywords_email {
	my ( $self, $k, $e ) = @_;
	my $sql =
	    "select * from " 
	  . TOPIC
	  . " where keywords like '%"
	  . $k
	  . "%' and email like '%"
	  . $e . "%'";
	$self->show_results($sql);
}

sub select_keywords {
	my ( $self, $k ) = @_;
	my $sql = "select * from " . TOPIC . " where keywords like '%" . $k . "%'";
	$self->show_results($sql);
}

sub select_email {
	my ( $self, $e ) = @_;
	my $sql = "select * from " . TOPIC . " where email like '%" . $e . "%'";
	$self->show_results($sql);
}

sub get_relevant {
	my ( $self, $html ) = @_;

	return unless $html;
	$html =~ s/<!-- START CLTAGS -->.*$//si;
	$html =~ s/(<br>|<br\s*\/>)/\n/g;
	$html =~ s/<div.*?>//g;
	$html =~ s/<p>/\n/g;
	$html =~ s/<ul.*?>/\n/g;
	$html =~ s/<\/div>//g;
	$html =~ s/<\/p>//g;
	$html =~ s/<\/ul>//g;
	$html =~ s/<li>//g;
	$html =~ s/<\/li>/;/g;

	# $html =~ s/<(?!br).*$//is;
	# $html =~ s/<.*$//is;

	$html =~ s/<img.*?>//sg            if ( $html =~ m/<img/ );
	$html =~ s/\<font.*?\<\/font\>//sg if ( $html =~ m/<font/ );
	$html =~ s/\<a\s.*?\<\/a\>//sg     if ( $html =~ m/<a\s/ );
	$html =~ s/<br>//sg                if ( $html =~ m/<br>/ );
	$html =~ s/<b>//sg                 if ( $html =~ m/<b>/ );
	$html =~ s/^\W+//mg;
	$html =~ s/\n/ /g;
	$html =~ s/&bull;/ /g;
	$html =~ s/&sdot;/ /g;
	$html =~ s/\s{2,}/ /g;
	return $html;

=comment
	my $ret = $html;
	if (length($html) > 253) {
		$ret = substr($html, 0, 252) . '...';
	}
	return $ret;
=cut

}

sub strip_craig_userbody {
	my ( $self, $html ) = @_;
	$html =~ s/<!-- CLTAG GeographicArea=NW -->.*$//si
	  if ( $html =~ m/CLTAG GeographicArea/i );
	return $html;
}

# Thu 25 Mar
sub get_end_date {
	my ( $self, $todate ) = @_;
	my $sth =
	  $self->{dbh}->prepare( qq{ select date_format(date_sub(now(), interval } 
		  . $todate
		  . qq{ day), '%a %d %b' ) } );
	$sth->execute();
	my @row = $sth->fetchrow_array();
	$sth->finish();
	return $row[0];
}
# US uses: Thu Jun 03; while Canada uses: Mon 07 Jun
sub get_us_end_date {
	my ( $self, $todate ) = @_;
	my $sth =
	  $self->{dbh}->prepare( qq{ select date_format(date_sub(now(), interval } 
		  . $todate
		  . qq{ day), '%a %b %d' ) } );
	$sth->execute();
	my @row = $sth->fetchrow_array();
	$sth->finish();
	return $row[0];
}

1;
