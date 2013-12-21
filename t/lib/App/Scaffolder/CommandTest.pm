package App::Scaffolder::CommandTest;
use parent qw(Test::Class);

use strict;
use warnings;

use Carp;
use Test::More;
use Test::Exception;

use Path::Class::Dir;
use Test::File::ShareDir '-share' => {
	'-dist' => { 'App-Scaffolder' => Path::Class::Dir->new(qw(t testdata)) }
};
use File::ShareDir;

use App::Scaffolder::Command;

my $share_dir = Path::Class::Dir->new(File::ShareDir::dist_dir('App-Scaffolder'));

sub test_new : Test(1) {
	my ($self) = @_;

	new_ok('App::Scaffolder::Command::dummy' => [{}]);
}

sub get_template_dirs_test : Test(1) {
	my ($self) = @_;

	my $dummy = App::Scaffolder::Command::dummy->new({});
	is_deeply(
		[ $dummy->get_template_dirs() ],
		[ $share_dir->subdir('dummy') ],
		'template dirs found'
	);
}

sub get_templates_test : Test(3) {
	my ($self) = @_;

	my $dummy = App::Scaffolder::Command::dummy->new({});
	my $template = $dummy->get_templates();
	isnt($template->{template}, undef, 'template found');
	is($template->{template}->get_name(), 'template', 'name ok');
	is_deeply(
		$template->{template}->get_path(),
		[$share_dir->subdir('dummy', 'template')],
		'path ok'
	);
}


sub get_template_test : Test(1) {
	my ($self) = @_;

	my $dummy = App::Scaffolder::Command::dummy->new({});
	my $template = $dummy->get_template('template');
	is($template->get_name(), 'template', 'name ok');
}


package App::Scaffolder::Command::dummy;
use parent qw(App::Scaffolder::Command);

use strict;
use warnings;

sub get_dist_name {
	return 'App-Scaffolder';
}

1;
