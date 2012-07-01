package bp_config;

require Exporter;
@ISA = qw( Exporter );
@EXPORT = qw(USER PASS HOST DSN DSN_new LOG CHTML URL1 URL2 URL3 CATEGORY CITY COUNTRY_STATE ITEM TOPIC DEFAULT_CITY DEFAULT_CATEGORY
VERSION INTERVAL_DATE);

use constant USER => 'backpage';
use constant PASS => 'william';
use constant HOST => 'localhost';
use constant DSN => 'DBI:mysql:backpage';
use constant LOG => q{../logs/};
use constant CHTML => q{./html/};
use constant URL1 => q{http://www.backpage.com/};
use constant URL2 => q{http://vancouver.backpage.com/};
use constant URL3 => q{http://vancouver.backpage.com/employment/};
use constant DEFAULT_CITY => 'vancouver';
use constant DEFAULT_CATEGORY => 'employment';
use constant VERSION => '1.0';
use constant INTERVAL_DATE => '2';

use constant CITY => q{backpage_city};
use constant CATEGORY => q{backpage_category};
use constant ITEM => q{backpage_item};
use constant TOPIC => q{backpage_topic};

1;

