use Test::More tests => 2;

BEGIN {
    use_ok('Carp::Growl');
}

diag("Testing Carp::Growl $Carp::Growl::VERSION");
can_ok( 'Carp::Growl', qw[import unimport] );
