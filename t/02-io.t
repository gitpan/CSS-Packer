#!perl -T

# =========================================================================== #
#
# All these tests are stolen from CSS::Minifier
#
# =========================================================================== #

use Test::More;

my $not = 10;

SKIP: {
	eval( 'use CSS::Packer' );

	skip( 'CSS::Packer not installed!', $not ) if ( $@ );

	plan tests => $not;

	minTest( 's1', { compress => 'pretty' } );
	minTest( 's2', { compress => 'pretty' } );
	minTest( 's3', { compress => 'minify' } );
	minTest( 's4', { compress => 'minify' } );
	minTest( 's5', { compress => 'minify' } );
	minTest( 's6', { compress => 'minify' } );
	minTest( 's7', { compress => 'minify', no_compress_comment => 1 } );

	my $packer = CSS::Packer->init();

	my $var = "foo {\na : b;\n}";
	$packer->minify( \$var, { 'compress' => 'minify' } );
	is( $var, 'foo{a:b;}', 'string literal input and ouput (minify)' );
	$var = "foo {\na : b;\n}";
	$packer->minify( \$var, { 'compress' => 'pretty' } );
	is( $var, "foo{\na:b;\n}\n", 'string literal input and ouput (pretty)' );
	$var = "foo {\nborder:0;\nmargin:1;\npadding:0\n}";
	$packer->minify( \$var, { 'compress' => 'minify' } );
	is( $var, "foo{border:0;margin:1;padding:0;}", 'string literal input and ouput (minify)' );
}

sub filesMatch {
	my $file1 = shift;
	my $file2 = shift;
	my $a;
	my $b;

	while (1) {
		$a = getc($file1);
		$b = getc($file2);

		if (!defined($a) && !defined($b)) { # both files end at same place
			return 1;
		}
		elsif (
			!defined($b) || # file2 ends first
			!defined($a) || # file1 ends first
			$a ne $b
		) {     # a and b not the same
			return 0;
		}
	}
}

sub minTest {
	my $filename    = shift;
	my $opts        = shift || {};

	open(INFILE, 't/stylesheets/' . $filename . '.css') or die("couldn't open file");
	open(GOTFILE, '>t/stylesheets/' . $filename . '-got.css') or die("couldn't open file");

	my $css = join( '', <INFILE> );

	my $packer = CSS::Packer->init();

	$packer->minify( \$css, $opts );

	print GOTFILE $css;
	close(INFILE);
	close(GOTFILE);

	open(EXPECTEDFILE, 't/stylesheets/' . $filename . '-expected.css') or die("couldn't open file");
	open(GOTFILE, 't/stylesheets/' . $filename . '-got.css') or die("couldn't open file");
	ok(filesMatch(GOTFILE, EXPECTEDFILE));
	close(EXPECTEDFILE);
	close(GOTFILE);
}
