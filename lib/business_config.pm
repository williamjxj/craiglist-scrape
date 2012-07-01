package business_config;

require Exporter;
@ISA = qw( Exporter );
@EXPORT = qw(USER PASS HOST DSN LOGDIR VERSION BIZ CONTACTS EMAILS UKCONTACTS UKEMAILS);

use constant USER => 'biz_us';
use constant PASS => 'william';
use constant HOST => 'localhost';
use constant DSN => 'DBI:mysql:business_db';
use constant LOGDIR => q{./logs/};
use constant VERSION => '2.0';

use constant CONTACTS => q{biz_us_contacts};
use constant EMAILS => q{biz_us_contacts_email};

use constant UKCONTACTS => q{biz_uk_contacts};
use constant UKEMAILS => q{biz_uk_contacts_email};

=comment
# Deprecated.
use constant BIZ => q{biz_us};
use constant CONTACT => q{biz_us_contact};
use constant EMAIL => q{biz_us_contact_email};
=cut

1;

