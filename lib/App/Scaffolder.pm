package App::Scaffolder;

# ABSTRACT: Application for scaffoldind using templates

use App::Cmd::Setup -app;

=head1 SYNOPSIS

	use App::Scaffolder;
	App::Scaffolder->run();

=head1 DESCRIPTION

App::Scaffolder is the entry point for the application. It uses
L<App::Cmd|App::Cmd> to provide the actual commands. See
L<App::Scaffolder::Command|App::Scaffolder::Command> for a command base class.

=head1 COMMANDS

C<App-Scaffolder> itself provides only a small framework for actual commands. In
order to provide a new command, the following is necessary:

=over

=item *

A command below the C<App::Scaffolder::Command> namespace that extends
L<App::Scaffolder::Command|App::Scaffolder::Command>, for example something like
C<App::Scaffolder::Command::mycommand>.

=item *

Templates that are installed for L<File::ShareDir|File::ShareDir>, in the
directory that belongs to the distribution. Inside this directory, the following
structure is required:

	<Command name>
	`-- <Template name>
		`-- <Template files>

=back

=head1 TEMPLATES

The templates (which are actually directory trees containing files and
L<Template|Template> templates) are handled by
L<App::Scaffolder::Template|App::Scaffolder::Template>. The search path for the
templates is constructed using L<File::HomeDir|File::HomeDir> and
L<File::ShareDir|File::ShareDir>, so one may override existing templates or add
new templates by putting them in the directory returned by

	File::HomeDir->my_dist_data('App-Scaffolder-MyDist')

and appending the command name as subdirectory to it. So on Linux and the
distribution C<App-Scaffolder-Mydist>, which provides the command C<mycommand>,
this path would look something like the following:

	$HOME/.local/share/Perl/dist/App-Scaffolder-MyDist/mycommand

The L<App::Scaffolder::Command|App::Scaffolder::Command> command base class also
provides two parameters related to this:

=over

=item --list

Show the search path and list the templates found there.

=item --create-template-dir

Create the template directory in the C<my_dist_data> directory returned by
L<File::HomeDir|File::HomeDir> and print the search path.

=back

=cut

1;

