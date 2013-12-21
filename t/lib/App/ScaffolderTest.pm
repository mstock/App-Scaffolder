package App::ScaffolderTest;
use parent qw(Test::Class);

use strict;
use warnings;

use Carp;
use Test::More;
use Test::Exception;
use App::Cmd::Tester;
use Test::File;
use Directory::Scratch;
use Path::Class::Dir;
use Test::File::ShareDir '-share' => {
	'-dist' => { 'App-Scaffolder' => Path::Class::Dir->new(qw(t testdata)) }
};
use App::Scaffolder;


sub app_test : Test(4) {
	my ($self) = @_;

	my $scratch = Directory::Scratch->new();
	my $result = test_app('App::Scaffolder' => [
		qw(dummy --template template --target), $scratch->base()
	]);
	is($result->stdout(), '', 'no output');
	is($result->error, undef, 'threw no exceptions');
	my $file = $scratch->base()->file('content.txt');
	file_exists_ok($file);
	is($file->slurp(), "Some file.\n", 'content ok');
}


package App::Scaffolder::Command::dummy;
use parent qw(App::Scaffolder::Command);

use strict;
use warnings;

sub get_dist_name {
	return 'App-Scaffolder';
}

1;
