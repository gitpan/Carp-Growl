use Test::More tests => 9;
use lib 't/testlib';    # Load fake 'Growl::Any'

use Carp::Growl;
my $CAPTURED_WARN;
local $SIG{__WARN__} = local $SIG{__DIE__} = sub { $CAPTURED_WARN = shift; };

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
    my $warn_message          = 'LF-ended ' . $func . '()';
    my $warn_message_complete = $warn_message;
    $warn_message_complete
        .= $/ . ' at ' . __FILE__ . ' line ' . ( __LINE__ + 3 ) . '.'
        if ( $func eq 'carp' || $func eq 'croak' );
#    $warn_message_complete .= $/;
    eval { &{$func}( $warn_message . $/ ) };
    is_deeply(
        $Growl::Any::SUB_NOTIFY_ARGS,
        [ @{ $notify_title{$func} }, $warn_message_complete, undef ],
        $warn_message . ' of GROWL',
    );
    $warn_message_complete
        .= $/ . "\t"
        . 'eval {...} called at '
        . __FILE__
        . ' line '
        . ( __LINE__ - 11 )
        if ( $func eq 'carp' || $func eq 'croak' );
    $warn_message_complete .= $/;
    is( $CAPTURED_WARN, $warn_message_complete,
        $warn_message . ' of ' . $func );
#    my $got      = [ split '', $CAPTURED_WARN ];
#    my $expected = [ split '', $warn_message_complete ];
#    is_deeply( $got, $expected, $warn_message . ' of ' . $func );
    @$Growl::Any::SUB_NOTIFY_ARGS = ();       #reset
    $CAPTURED_WARN                = undef;    #reset
}
