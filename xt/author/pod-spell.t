use strict;
use warnings;
use Test::More;

# generated by Dist::Zilla::Plugin::Test::PodSpelling 2.007004
use Test::Spelling 0.12;
use Pod::Wordlist;


add_stopwords(<DATA>);
all_pod_files_spelling_ok( qw( bin lib ) );
__DATA__
ABEND
AFAICT
BetterAnonClassNames
Chris
Class
Formattable
Gratipay
Meta
MooseX
RSRCHBOY
RSRCHBOY's
TraitFor
Weyl
codebase
coderef
cweyl
formattable
gpg
implementers
ini
lib
metaclass
metaclasses
parameterization
parameterized
subclasses
