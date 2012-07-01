package google_config;

require Exporter;
@ISA = qw( Exporter );
@EXPORT = qw(USER PASS HOST DSN LOGDIR VERSION CONTACTS URL URL1 KEYWORD KEYWORD_FILE OFILE EMAILS);

use constant URL => q{http://www.google.com};
use constant URL1 => q{http://www.google.ca};
use constant USER => 'biz_google';
use constant PASS => 'william';
use constant HOST => 'localhost';
use constant DSN => 'DBI:mysql:business_db';
use constant LOGDIR => q{./logs/};
use constant VERSION => '1.0';
use constant CONTACTS => q{biz_google};
use constant KEYWORD => q{ martial arts studio };
use constant KEYWORD_FILE => q{./keywords.txt};
use constant OFILE => q{/public_html/ofile.html};
use constant EMAILS => q{biz_google_email};
1;

