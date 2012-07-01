package craig_config;
# $Id$
# http://vancouver.craigslist.ca/

require Exporter;
@ISA = qw( Exporter );
@EXPORT = qw(USER PASS HOST DSN LOGDIR CHTML URL1 URL2 URL3 URL4 URL5 URL6 CATEGORY CITY COUNTRY_STATE ITEM US_ITEM TOPIC DEFAULT_CITY DEFAULT_CATEGORY
VERSION INTERVAL_DATE CUT_LENGTH USJOBS USSERVICES USGIGS USRESUMES);

use constant USER => 'craig';
use constant PASS => 'william';
use constant HOST => 'localhost';
use constant DSN => 'DBI:mysql:craig';
use constant LOGDIR => q{./logs/};
use constant CHTML => q{./html/};
use constant URL1 => q{http://www.craigslist.org/about/sites};
use constant URL2 => q{http://vancouver.en.craigslist.ca/};
use constant URL3 => q{http://vancouver.en.craigslist.ca/jjj/};
use constant URL4 => q{http://vancouver.en.craigslist.ca/cgi-bin/jobs.cgi?&category=jjj/};
use constant URL5 => 'http://calgary.en.craigslist.ca/cgi-bin/jobs.cgi?&category=jjj/';
use constant URL6 => 'http://calgary.en.craigslist.ca/';
use constant DEFAULT_CITY => 'vancouver';
use constant DEFAULT_CATEGORY => 'jobs';
use constant VERSION => '2.0';
use constant INTERVAL_DATE => '2';
use constant CUT_LENGTH => '198';

use constant CATEGORY => q{craigslist_category};
use constant CITY => q{craigslist_city};
use constant COUNTRY_STATE => q{craigslist_country_state};
use constant ITEM => q{craigslist_item};
use constant US_ITEM => q{craigslist_us_item};
use constant TOPIC => q{craigslist_topic};
use constant USJOBS => q{craigslist_usjobs};
use constant USSERVICES => q{craigslist_usservices};
use constant USGIGS => q{craigslist_usgigs};
use constant USRESUMES => q{craigslist_usresumes};

1;

