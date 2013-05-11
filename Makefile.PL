use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Carp::Growl',
    AUTHOR              => 'kpee <kpee.cpanx@gmail.com>',
    VERSION_FROM        => 'lib/Carp/Growl.pm',
    ABSTRACT_FROM       => 'lib/Carp/Growl.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Carp-Growl-*' },
);
