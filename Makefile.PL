use inc::Module::Install;
name 'Acme-CheckCharactorsOutsideRange';
all_from 'lib/Acme/CheckCharactorsOutsideRange.pm';

requires 'Filter::Util::Call';
requires 'PPI';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t t/*/*/*/*/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
