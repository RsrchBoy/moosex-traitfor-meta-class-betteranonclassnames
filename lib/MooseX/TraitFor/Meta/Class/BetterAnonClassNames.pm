package MooseX::TraitFor::Meta::Class::BetterAnonClassNames;

# ABSTRACT: Metaclass trait to *attempt* to demystify generated anonymous class names

use Moose::Role;
use namespace::autoclean;
use autobox::Core;

has is_anon => (is => 'ro', isa => 'Bool', default => 0);

has anon_package_prefix => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
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

=head1 SUMMARY

You really want to be looking at L<MooseX::Util/with_traits>.

=head1 SEE ALSO

L<MooseX::Util>

=cut
