package DUMMY;
use lib 'testlib';    # Load fake 'Growl::Any'

use Carp::Growl;

package main;
use Test::More tests => 8;

my @funcs = qw/warn die carp croak/;

diag "call Carp::Growl'ed DUMMY::<funcs> from main";
for my $func (@funcs) {
    my $warn_message = 'do ' . $func . '() in DUMMY';
    my $warn_message_complete
        = $warn_message . ' at '
        . __FILE__
        . ' line '
        . ( __LINE__ + 1 ) . '.';
    eval { &{ 'DUMMY::' . $func }($warn_message) };
    is( $Growl::Any::SUB_NOTIFY_ARGS->[2], $warn_message_complete );
    @$Growl::Any::SUB_NOTIFY_ARGS = ();    #reset
}
diag "call <funcs> normally from main";
for my $func (@funcs) {
    my $warn_message = 'do ' . $func . '() in main';
    eval { &{$func}($warn_message) };
    is_deeply( $Growl::Any::SUB_NOTIFY_ARGS, [] );
    @$Growl::Any::SUB_NOTIFY_ARGS = ();    #reset
}
