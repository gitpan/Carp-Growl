package Carp::Growl;

use warnings;
use strict;
use Carp ();

use version; our $VERSION = qv('0.0.3');

use Growl::Any;
my $g = Growl::Any->new( appname => __PACKAGE__, events => [qw/warn die/] );

my $global   = {};
my $local    = {};
my $imported = 0;

my $AVAILABLE_IMPORT_ARGS = [qw/global/];

my $check_args = sub {
    my %bads;
    for my $good (@$AVAILABLE_IMPORT_ARGS) {
        $bads{$_}++ for grep { $_ ne $good } @_;
    }
    keys %bads;
};

my $CARP_FUNCS = +{
    warn  => \&Carp::carp,
    die   => \&Carp::croak,
    carp  => \&Carp::carp,
    croak => \&Carp::croak,
};

my $BUILD_FUNC_ARGS = +{
    warn  => { event => 'warn', title => 'WARNING', },
    die   => { event => 'die',  title => 'FATAL', },
    carp  => { event => 'warn', title => 'WARNING', },
    croak => { event => 'die',  title => 'FATAL', },
};

sub _build_func {
    my $func = shift;
    return sub {
        my ( $pkg, $file, $line, ) = ( caller() )[ 0 .. 2 ];
        my $msg = join( $",
            @_, 'at', $pkg eq 'main' ? $file : $pkg,
            'line', $line, )
            . '.';
        $g->notify(
            $BUILD_FUNC_ARGS->{$func}->{event},    # event
            $BUILD_FUNC_ARGS->{$func}->{title},    # title
            $msg,                                  # message
            undef,                                 # icon
            )
            if defined $^S;
        no strict 'refs';
        &{ $CARP_FUNCS->{$func} }(@_);
    };
}

##~~~~~  IMPORT  ~~~~~##

sub import {
    my $self = shift;
    my @args = @_;
    if (@args) {
        my @bads = $check_args->(@args);
        CORE::die 'Illegal args: "'
            . join( '", "', @bads )
            . '" for import()'
            if @bads;
        return if $imported >= 2;
        $imported = 2;
        goto &_global_import;
    }
    else {
        return if $imported;
        $imported = 1;
        goto &_local_import;
    }
}

sub _local_import {
    my $args = @_ ? \@_ : [ keys %$BUILD_FUNC_ARGS ];
    my ($pkg) = caller();
    no strict 'refs';
    for my $func ( keys %$BUILD_FUNC_ARGS ) {
        $local->{$pkg}->{$func} = delete ${ $pkg . '::' }{$func}
            if defined &{ $pkg . '::' . $func };
    }
    for my $func (@$args) {
        no warnings 'redefine';
        *{ $pkg . '::' . $func } = _build_func($func);
    }
}

sub _global_import {
    no strict 'refs';
    for my $func (qw/warn die/) {
        $global->{$func} = \&{ 'CORE::GLOBAL::' . $func }
            if defined &{ 'CORE::GLOBAL::' . $func };
    }

    no warnings 'redefine';
    for my $func (qw/warn die/) {
        *{ 'CORE::GLOBAL::' . $func } = _build_func($func);
    }
    @_ = qw/carp croak/;
    goto &_local_import;
}

##~~~~~  UNIMPORT  ~~~~~##

sub unimport {
    my $self = shift;
    my @args = @_;
    CORE::die 'Illegal args: "' . join( '", "', @args ) . '" for unimport()'
        if @args;
    $imported = 0;
    goto &_global_unimport;
}

sub _local_unimport {
    my $args = @_ ? \@_ : [ keys %$BUILD_FUNC_ARGS ];
    my ($pkg) = caller();
    no strict 'refs';
    no warnings 'redefine';
    for my $func (@$args) {
        if ( $local->{$pkg}->{$func} ) {
            *{ $pkg . '::' . $func } = \&{ $local->{$pkg}->{$func} };
        }
        else {
            delete ${ $pkg . '::' }{$func};
        }
    }
}

sub _global_unimport {
    no strict 'refs';
    no warnings 'redefine';
    for my $func (qw/warn die/) {
        if ( $global->{$func} ) {
            *{ 'CORE::GLOBAL::' . $func } = \&{ $global->{$func} };
        }
        else {
            delete ${'CORE::GLOBAL::'}{$func};
        }
    }
#    @_ = qw/carp croak/;
    goto &_local_unimport;
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

Carp::Growl - Send warnings to Growl


=head1 VERSION

This document describes Carp::Growl version 0.0.1


=head1 SYNOPSIS

    use Carp::Growl;

    warn "Here we are!!"; # display message on Growl notify

=head1 DESCRIPTION

Carp::Growl is a Perl module that can send warning-messages to Growl,
and also outputs usual(to tty etc...)

Basicaly, only type this at the head of your script.

    use Carp::Growl;

This works only in your 'package-scope'.
If you want to work it globally, use with arg 'global',

    use Carp::Growl 'global';

Of cource, it is only 'warn' and 'die' that influence globally,
(can your hear about global-scoped carp and croak?)
but 'carp' and 'croak' are also installed in 'package-scope'.

However, you can disable this module,

    no Carp::Growl;

so, every warnings works as usual.


=head1 DIAGNOSTICS

=over

=item C<< Illegal args: "%s"[, "%s"...] for (un)import >>

%s is not correct keyword for import|unimport.

only 'global' is available keyword for import(),
and unimport takes no keywords.

=back


=head1 CONFIGURATION AND ENVIRONMENT

Carp::Growl requires notify system which Growl::Any supports is required for this module..

Carp::Growl requires no environment variables.


=head1 DEPENDENCIES

Growl::Any


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS


No bugs have been reported.

Please report any bugs or feature requests to
C<bug-carp-growl@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

kpee  C<< <kpee.cpanx@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, kpee C<< <kpee.cpanx@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
