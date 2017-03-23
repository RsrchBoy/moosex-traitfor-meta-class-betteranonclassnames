package MooseX::TraitFor::Meta::Class::BetterAnonClassNames;

# ABSTRACT: Metaclass trait to *attempt* to demystify generated anonymous class names

use Moose::Role;
use namespace::autoclean;
use autobox::Core;

use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    trait_aliases => [ __PACKAGE__ ],
);

=attr is_anon

Read-only, L<Boolean|Moose::Util::TypeConstraints/Default Type Constraints>,
default: false.

Provides an attribute in the place of L<Class::MOP::Package/is_anon>.

=cut

has is_anon => (is => 'ro', isa => 'Bool', default => 0);

=attr anon_package_prefix

Read-only, L<String|Moose::Util::TypeConstraints/Default Type Constraints>

=method _build_anon_package_prefix

Builder method for the L</anon_package_prefix> attribute.

=cut

has anon_package_prefix => (
    is       => 'ro',
    isa      => 'Str',
    builder  => '_build_anon_package_prefix',
);

sub _build_anon_package_prefix { Moose::Meta::Class->_anon_package_prefix }

=method _anon_package_middle

Defines what the "middle" of our anonymous package names is; provided for ease
of overriding and hardcoded to:

    ::__ANON__::SERIAL::

=cut

sub _anon_package_middle { '::__ANON__::SERIAL::' }

=method _anon_package_prefix

Returns the full prefix used to generate anonymous package names; if called
on an instance then returns a sensible prefix (generally class name)
stashed in L</anon_package_prefix>; otherwise returns the result of a call
to L<Moose::Meta::Class/_anon_package_prefix>.

=cut

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

=method create

Set the package name to a nicer anonymous class name if is_anon is passed
and true and anon_package_prefix is passed and a non-empty string.

=cut

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

=method create_anon_class

Create an anonymous class, as via L<Moose::Meta::Class/create_anon_class>,
but with a kinder, gentler package name -- if possible.

=cut

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

=head1 TRAIT ALIASES

=head2 BetterAnonClassNames

Resolves out to the full name of this trait.

=head1 SEE ALSO

L<MooseX::Util>

=cut
