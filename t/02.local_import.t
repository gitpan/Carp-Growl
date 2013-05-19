use Test::More tests => 2;

use lib 't/testlib';    # for loading DUMMY Growl::Any

{
    eval { require Carp::Growl } or BAIL_OUT("Can't load 'Carp::Growl'");

    subtest 'simple (un)import' => sub {
        Carp::Growl->import();
        ok( defined &{ __PACKAGE__ . '::warn' },  'import local warn()' );
        ok( defined &{ __PACKAGE__ . '::die' },   'import local die()' );
        ok( defined &{ __PACKAGE__ . '::carp' },  'import local carp()' );
        ok( defined &{ __PACKAGE__ . '::croak' }, 'import local croak()' );

        Carp::Growl->unimport();
        ok( !defined &{ __PACKAGE__ . '::warn' },  'unimport local warn()' );
        ok( !defined &{ __PACKAGE__ . '::die' },   'unimport local die()' );
        ok( !defined &{ __PACKAGE__ . '::carp' },  'unimport local carp()' );
        ok( !defined &{ __PACKAGE__ . '::croak' }, 'unimport local croak()' );
    };
    subtest '(un)import against defined func' => sub {
        sub pre_installed_sub {1}
        *{ __PACKAGE__ . '::warn' } = \&pre_installed_sub;
        Carp::Growl->import();
        ok( defined &{ __PACKAGE__ . '::warn' }, 'import local warn()' );
        isnt(
            \&{ __PACKAGE__ . '::warn' },
            \&::pre_installed_sub,
            'override local warn()'
        );

        Carp::Growl->unimport();
        is( \&{ __PACKAGE__ . '::warn' },
            \&pre_installed_sub, 'restore local warn()' );
    };
}
