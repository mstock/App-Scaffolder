package App::Scaffolder::Command;

# ABSTRACT: Base class for App::Scaffolder commands

use strict;
use warnings;

use Carp;

use App::Cmd::Setup -command;
use File::HomeDir;
use File::ShareDir;
use Path::Class::Dir;
use MRO::Compat;

use App::Scaffolder::Template;

=head1 SYNOPSIS

	use parent qw(App::Scaffolder::Command);

=head1 DESCRIPTION

App::Scaffolder::Command is a base class for L<App::Scaffolder|App::Scaffolder>
commands.

=cut

sub opt_spec {
	my ($class, $app) = @_;
	return (
		[ 'list|l'       => 'List the search path and the available templates' ],
		[ 'template|t=s' => 'Name of the template that should be used' ],
		[ 'target=s'     => 'Target directory where output should go - '
			. 'defaults to current directory, but commands may override this' ],
		$class->get_options($app),
	)
}

sub validate_args {
	my ($self, $opt, $args) = @_;

	$self->next::method($opt, $args);
	unless ($opt->list() || $opt->template()) {
		$self->usage_error("Parameter 'template' required");
	}
}


=head2 get_options

Getter for the options. Should be implemented by subclasses.

=head3 Result

A list with additional options for the command.

=cut

sub get_options {
	my ($class, $app) = @_;
	return ();
}


=head2 get_template_dirs

Getter for the directories where templates are searched. Uses
L<File::HomeDir|File::HomeDir> and L<File::ShareDir|File::ShareDir> using the
distribution name and appends the command name to the directory.

=head3 Result

A list with the directories.

=cut

sub get_template_dirs {
	my ($self) = @_;

	my @dirs;
	my $command_name = $self->command_names();
	if (my $my_dist_data = File::HomeDir->my_dist_data($self->get_dist_name())) {
		my $my_command_dir = Path::Class::Dir->new($my_dist_data)->subdir($command_name);
		if (-d $my_command_dir) {
			push @dirs, $my_command_dir;
		}
	}
	my $command_dir = Path::Class::Dir->new(
		File::ShareDir::dist_dir($self->get_dist_name())
	)->subdir($command_name);
	if (-d $command_dir) {
		push @dirs, $command_dir;
	}

	return @dirs;
}


=head2 get_templates

Reads the template directories and creates a
L<App::Scaffolder::Template|App::Scaffolder::Template> object for each template
that is found.

=head3 Result

A hash reference with the found templates.

=cut

sub get_templates {
	my ($self) = @_;

	my $template = {};
	for my $dir ($self->get_template_dirs()) {
		for my $template_dir (grep { $_->is_dir() } $dir->children()) {
			my $name = $template_dir->dir_list(-1, 1);
			if (exists $template->{$name}) {
				$template->{$name}->add_path_entry($template_dir);
			}
			else {
				$template->{$name} = App::Scaffolder::Template->new({
					name => $name,
					path => [ $template_dir ],
				});
			}
		}
	}
	return $template;
}


=head2 get_template

Get the template with a given name.

=head3 Parameters

This method expects positional parameters.

=over

=item name

Name of the template.

=back

=head3 Result

The L<App::Scaffolder::Template|App::Scaffolder::Template> with the given name.

=cut

sub get_template {
	my ($self, $name) = @_;
	my $template = $self->get_templates();
	unless (exists $template->{$name}) {
		croak("No template called '$name' found");
	}
	return $template->{$name}
}


=head2 get_target

Extract the target directory from the options.

=head3 Parameters

This method expects positional parameters.

=over

=item opt

Options as passed to C<execute>.

=back

=head3 Result

A L<Path::Class::Dir|Path::Class::Dir> object with the target directory.

=cut

sub get_target {
	my ($self, $opt) = @_;
	return Path::Class::Dir->new($opt->target() || '.');
}


=head2 get_variables

Get variables that should be passed to templates. Should be overridden by
subclasses.

=head3 Result

A hash reference with template variables.

=cut

sub get_variables {
	my ($self, $opt) = @_;
	return {};
}


=head2 get_dist_name

Getter for the distribution name. Must be implemented by subclasses.

=head3 Result

The name of the distribution the command belongs to.

=cut

sub get_dist_name {
	confess("get_dist_name must be implemented by scaffolder commands");
}


=head2 execute

Execute the command.

=head3 Result

Nothing on success, an exception otherwise.

=cut

sub execute {
	my ($self, $opt, $args) = @_;

	if ($opt->list()) {
		print "Template search path for ".$self->command_names().":\n ";
		print join "\n ", $self->get_template_dirs();
		print "\nAvailable templates for ".$self->command_names().":\n ";
		print join "\n ", sort keys %{$self->get_templates()};
		print "\n";
		return;
	}

	$self->get_template($opt->template())->process({
		target    => $self->get_target($opt),
		variables => $self->get_variables($opt),
	});

	return;
}

1;

