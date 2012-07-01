package db;
# $Id$

use Data::Dumper;
use strict;

sub new
{
    my ($type, $user, $pass, $dsn) = @_;
    my $self = {};
	$self->{dbh} = DBI->connect($dsn, $user, $pass, { RaiseError=>1 });
	bless $self, $type;
}

# trace back to 2 days, '15-Mar-10'
sub get_routine_date
{
	my ($self,$todate) = @_;

	my $sth = $self->{dbh}->prepare(qq{ select date_format(date_sub(now(), interval }. $todate.  qq{ day), '%d-%b-%y') });
	$sth->execute();
	my @row = $sth->fetchrow_array();
	$sth->finish();
	return $row[0];
}

sub show_results
{
	my ($self, $sql) = @_;
	my $count = 0;  # number of entries printed so far
	my $total = 0;
	my @label = (); # column label array
	my $label_width = 0;

	my $sth = $self->{dbh}->prepare ($sql);
	$sth->execute ();

	# get column names to use for labels and
	# determine max column name width for formatting
	@label = @{$sth->{NAME}};
	foreach my $label (@label) {
		$label_width = length ($label) if $label_width < length ($label);
	}

	print "Total columns for each record: [" . $sth->{NUM_OF_FIELDS} . "]\n\n";

	while (my @ary = $sth->fetchrow_array ()) {
		++ $total;
		# print newline before 2nd and subsequent entries
		print "\n" if ++$count > 1;
		foreach (my $i = 0; $i < $sth->{NUM_OF_FIELDS}; $i++)
		{
			printf "%-*s", $label_width+1, $label[$i] . ":";
			print " ", $ary[$i] if defined ($ary[$i]);
			print "\n";
		}
	}
	$sth->finish ();
}

1;
