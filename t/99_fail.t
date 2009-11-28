use strict;
use warnings;
use utf8;
use Test::More;

BEGIN {
	SKIP: {
		skip 'characters outside the range of CP932', 1;
		use_ok 'Acme::CheckCharactorsOutsideRange';
	}
}

my $unicode = qq( \x{2600} );

done_testing;
