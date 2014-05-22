#
# This file is part of MooseX-TraitFor-Meta-Class-BetterAnonClassNames
#
# This software is Copyright (c) 2014 by Chris Weyl.
#
# This is free software, licensed under:
#
#   The GNU Lesser General Public License, Version 2.1, February 1999
#
package MooseX::TraitFor::Meta::Class::BetterAnonClassNames;
BEGIN {
  $MooseX::TraitFor::Meta::Class::BetterAnonClassNames::AUTHORITY = 'cpan:RSRCHBOY';
}
# git description: 7888bc7
$MooseX::TraitFor::Meta::Class::BetterAnonClassNames::VERSION = '0.002001';

# ABSTRACT: Metaclass trait to *attempt* to demystify generated anonymous class names

use Moose::Role;
use namespace::autoclean;
use autobox::Core;

has is_anon => (is => 'ro', isa => 'Bool', default => 0);

has anon_package_prefix => (
    is       => 'ro',
    isa      => 'Str',
    builder  => '_build_anon_package_prefix',
);

sub _build_anon_package_prefix { Moose::Meta::Class->_anon_package_prefix }

sub _anon_package_middle { '::__ANON__::SERIAL::' }

# XXX around?
sub _anon_package_prefix {
    my $thing = shift @_;

    my $prefix = blessed $thing
        ? $thing->anon_package_prefix
        : Moose::Meta::Class->_anon_package_prefix
        ;

    my @caller = caller 1;
    ### @caller
    ### $prefix
    return $prefix;
}

around create => sub {
    my ($orig, $self) = (shift, shift);
    my @args = @_;

    unshift @args, 'package'
        if @args % 2;
    my %opts = @args;

    return $self->$orig(%opts)
        unless $opts{is_anon} && $opts{anon_package_prefix};

    ### old anon package name: $opts{package}
    my $serial = $opts{package}->split(qr/::/)->[-1]; #at(-1); #tail(1);
    $opts{package} = $opts{anon_package_prefix} . $serial;

    ### new anon package name: $opts{package}
    ### %opts
    return $self->$orig(%opts);
};

around create_anon_class => sub {
    my ($orig, $class) = (shift, shift);
    my %opts = @_;

    # we're going to need some additional logic here to make sure that our
    # prefixes make sense; e.g. if we're an anon descendent of an anon class,
    # we should just use our parent's prefix.

    $opts{is_anon} = 1;

    my $superclasses = $opts{superclasses} || [];

    # don't bother doing anything else if we don't have anything to add
    return $class->$orig(%opts)
        if exists $opts{anon_package_prefix};
    return $class->$orig(%opts)
        unless @$superclasses && @$superclasses == 1;

    # XXX ::class_of?
    my $sc = $superclasses->[0]->meta;

    #my $prefix
    $opts{anon_package_prefix}
        = $sc->is_anon
        ? $sc->_anon_package_prefix
        : $superclasses->[0] . $class->_anon_package_middle
        ;

    # basically:  if we have no superclasses, live with the default prefix; if
    # we have a superclass and it's anon, use it's anon prefix; if we have a
    # superclass and it's not anon, make a new prefix out of it
    #
    # cases where we have 2+ superclasses aren't handled right now; we use the
    # Moose::Meta::Class::_anon_package_prefix() for those
    #
    # if we're passed in 'anon_package_prefix', then just use that.

    return $class->$orig(%opts);
};

!!42;

__END__

=pod

=encoding UTF-8

=for :stopwords Chris Weyl

=for :stopwords Wishlist flattr flattr'ed gittip gittip'ed

=head1 NAME

MooseX::TraitFor::Meta::Class::BetterAnonClassNames - Metaclass trait to *attempt* to demystify generated anonymous class names

=head1 VERSION

This document describes version 0.002001 of MooseX::TraitFor::Meta::Class::BetterAnonClassNames - released May 22, 2014 as part of MooseX-TraitFor-Meta-Class-BetterAnonClassNames.

=head1 SUMMARY

You really want to be looking at L<MooseX::Util/with_traits>.

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<MooseX::Util>

=back

=head1 SOURCE

The development version is on github at L<http://https://github.com/RsrchBoy/moosex-traitfor-class-betteranonclassnames>
and may be cloned from L<git://https://github.com/RsrchBoy/moosex-traitfor-class-betteranonclassnames.git>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/RsrchBoy/moosex-traitfor-class-betteranonclassnames/issu
es

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Chris Weyl <cweyl@alumni.drew.edu>

=head2 I'm a material boy in a material world

=begin html

<a href="https://www.gittip.com/RsrchBoy/"><img src="https://raw.githubusercontent.com/gittip/www.gittip.com/master/www/assets/%25version/logo.png" /></a>
<a href="http://bit.ly/rsrchboys-wishlist"><img src="http://wps.io/wp-content/uploads/2014/05/amazon_wishlist.resized.png" /></a>
<a href="https://flattr.com/submit/auto?user_id=RsrchBoy&url=https%3A%2F%2Fgithub.com%2FRsrchBoy%2Fmoosex-traitfor-class-betteranonclassnames&title=RsrchBoy's%20CPAN%20MooseX-TraitFor-Meta-Class-BetterAnonClassNames&tags=%22RsrchBoy's%20MooseX-TraitFor-Meta-Class-BetterAnonClassNames%20in%20the%20CPAN%22"><img src="http://api.flattr.com/button/flattr-badge-large.png" /></a>

=end html

Please note B<I do not expect to be gittip'ed or flattr'ed for this work>,
rather B<it is simply a very pleasant surprise>. I largely create and release
works like this because I need them or I find it enjoyable; however, don't let
that stop you if you feel like it ;)

L<Flattr this|https://flattr.com/submit/auto?user_id=RsrchBoy&url=https%3A%2F%2Fgithub.com%2FRsrchBoy%2Fmoosex-traitfor-class-betteranonclassnames&title=RsrchBoy's%20CPAN%20MooseX-TraitFor-Meta-Class-BetterAnonClassNames&tags=%22RsrchBoy's%20MooseX-TraitFor-Meta-Class-BetterAnonClassNames%20in%20the%20CPAN%22>,
L<gittip me|https://www.gittip.com/RsrchBoy/>, or indulge my
L<Amazon Wishlist|http://bit.ly/rsrchboys-wishlist>...  If you so desire.

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Chris Weyl.

This is free software, licensed under:

  The GNU Lesser General Public License, Version 2.1, February 1999

=cut
