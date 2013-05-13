use Test::More tests => 5;
use lib 't/testlib';    # Load fake 'Growl::Any'

use Carp::Growl;

is_deeply(
    $Growl::Any::SUB_NEW_ARGS,
    +{ appname => 'Carp::Growl', events => [qw/warn die/] },
    'correct args for Growl::Any->new'
);
my %notify_title = (
    warn  => [ 'warn', "WARNING" ],
    die   => [ 'die',  'FATAL' ],
    carp  => [ 'warn', "WARNING" ],
    croak => [ 'die',  'FATAL' ],
);
for my $func ( keys %notify_title ) {
    my $warn_message = 'do ' . $func . '()';
    my $warn_message_complete
        = $warn_message . ' at '
        . __FILE__
        . ' line '
        . ( __LINE__ + 1 ) . '.';
    eval { &{$func}($warn_message) };
    is_deeply( $Growl::Any::SUB_NOTIFY_ARGS,
        [ @{ $notify_title{$func} }, $warn_message_complete, undef ],
        $warn_message, );
    @$Growl::Any::SUB_NOTIFY_ARGS = ();    #reset
}
