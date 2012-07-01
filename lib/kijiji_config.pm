package kijiji_config;
# define kijiji canada and kijiji the states.

require Exporter;
@ISA = qw( Exporter );
@EXPORT = qw(USER PASS HOST DSN LOG CHTML URL1 URL2 URL3 URL4 CATEGORY CITY COUNTRY_STATE ITEM TOPIC DEFAULT_CITY DEFAULT_CATEGORY
VERSION INTERVAL_DATE URL5 CAJOBS CASERVICES USITEM USCATEGORY USJOBS USSERVICES US_DATEFORMAT CA_DATEFORMAT);

use constant USER => 'kijiji';
use constant PASS => 'william';
use constant HOST => 'localhost';
use constant DSN => 'DBI:mysql:kijiji';
use constant LOG => q{../logs/};
use constant CHTML => q{./html/};
use constant URL1 => q{http://vancouver.kijiji.ca/};
use constant URL2 => q{http://www.kijiji.ca/};
use constant URL3 => q{http://vancouver.kijiji.ca/f-services-W0QQCatIdZ72};
use constant URL4 => q{http://wyoming.ebayclassifieds.com/};
use constant URL5 => q{http://www.ebayclassifieds.com/?change=true};
use constant DEFAULT_CITY => 'vancouver';
use constant DEFAULT_CATEGORY => 'jobs';
use constant VERSION => '2.0';
use constant INTERVAL_DATE => '7';

use constant CITY => q{kijiji_city};
use constant COUNTRY_STATE => q{kijiji_country_state}; # not use.

use constant CATEGORY => q{kijiji_category};
use constant ITEM => q{kijiji_item};
use constant USCATEGORY => q{kijiji_us_category};
use constant USITEM => q{kijiji_us_item};

use constant TOPIC => q{kijiji_topic};

use constant CAJOBS => q{kijiji_ca_jobs};
use constant CASERVICES => q{kijiji_ca_services};

use constant USJOBS => q{kijiji_us_jobs};
use constant USSERVICES => q{kijiji_us_services};

# 25-Mar-10
use constant CA_DATEFORMAT => q{%d-%b-%y};

# 06/15/10
use constant US_DATEFORMAT => q{%c/%e/%y};
# Tuesday, June 15
# use constant US_DATEFORMAT => q{%W,%M %d};

1;
