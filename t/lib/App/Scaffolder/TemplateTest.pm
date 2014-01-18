package App::Scaffolder::TemplateTest;
use parent qw(Test::Class);

use strict;
use warnings;

use Carp;
use Test::More;
use Test::Exception;
use Path::Class::Dir;
use Path::Class::File;
use Directory::Scratch;

use App::Scaffolder::Template;

my $dir0 = Path::Class::Dir->new(qw(t testdata test_template))->absolute();
my $dir1 = Path::Class::Dir->new(qw(t testdata test_template2))->absolute();

sub new_test : Test(1) {
	my ($self) = @_;

	new_ok('App::Scaffolder::Template' => [{
		name => 'test_template',
		path => [Path::Class::Dir->new(qw(t testdata test_template))]
	}]);
}

sub path_test : Test(2) {
	my ($self) = @_;

	my $template = App::Scaffolder::Template->new({
		name => 'test_template',
		path => [$dir0],
	});
	is_deeply($template->get_path(), [$dir0], 'path set');

	$template->add_path_entry($dir1);
	is_deeply($template->get_path(), [$dir0, $dir1], 'path extended');
}

sub get_template_files_test : Test(2) {
	my ($self) = @_;

	my $template = App::Scaffolder::Template->new({
		name => 'test_template',
		path => [$dir0],
	});

	my $files = $template->get_template_files();
	is_deeply($files, {
		'foo.txt' => {
			source     => $dir0->file('foo.txt'),
			rel_target => Path::Class::File->new('foo.txt'),
		},
		'bar.txt' => {
			source     => $dir0->file('bar.txt.tt'),
			rel_target => Path::Class::File->new('bar.txt'),
		},
	}, 'files found');

	$template = App::Scaffolder::Template->new({
		name => 'test_template',
		path => [$dir1, $dir0],
	});
	$files = $template->get_template_files();
	is_deeply($files, {
		'foo.txt' => {
			source     => $dir0->file('foo.txt'),
			rel_target => Path::Class::File->new('foo.txt'),
		},
		'bar.txt' => {
			source     => $dir1->file('bar.txt'),
			rel_target => Path::Class::File->new('bar.txt'),
		},
		'foobar.txt' => {
			source     => $dir1->file('foobar.txt'),
			rel_target => Path::Class::File->new('foobar.txt'),
		},
	}, 'files found');
}

sub process_test : Test(4) {
	my ($self) = @_;

	my $template = App::Scaffolder::Template->new({
		name => 'test_template',
		path => [$dir0],
	});

	my $scratch = Directory::Scratch->new();
	my @files = $template->process({
		target    => $scratch->base(),
		variables => {
			variable_value => 'a variable value',
		}
	});
	is(scalar @files, 2, 'two files created');
	is_deeply([
		sort @files
	], [
		$scratch->base()->file('bar.txt'), $scratch->base()->file('foo.txt')
	], 'files created');
	is(
		$scratch->base()->file('bar.txt')->slurp(),
		"Some test text with a variable value.\n",
		'content of bar.txt ok'
	);
	is(
		$scratch->base()->file('foo.txt')->slurp(),
		"Some static test text.\n",
		'content of bar.txt ok'
	);
}

1;
