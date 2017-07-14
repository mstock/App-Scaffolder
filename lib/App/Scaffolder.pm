package App::Scaffolder;

# ABSTRACT: Application for scaffolding using templates

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
templates is usually constructed using L<File::HomeDir|File::HomeDir> and
L<File::ShareDir|File::ShareDir>, so one may override existing templates or add
new templates by putting them in the directory returned by

	File::HomeDir->my_dist_data('App-Scaffolder-MyDist')

and appending the command name as subdirectory to it. So on Linux and the
distribution C<App-Scaffolder-Mydist>, which provides the command C<mycommand>,
this path would look something like the following:

	$HOME/.local/share/Perl/dist/App-Scaffolder-MyDist/mycommand

In addition to this, the L<App::Scaffolder::Command|App::Scaffolder::Command>
base class also uses the C<SCAFFOLDER_TEMPLATE_PATH> environment variable to add
additional directories to the search path. Thus setting

	export SCAFFOLDER_TEMPLATE_PATH=~/scaffolder_templates

and putting a directory called C<mycommand> below C<~/scaffolder_templates> which
contains templates would also make them available to C<scaffolder mycommand>. This
could be useful to share templates with other users if the templates are stored
in a location that is accessible to the other users, too.

The L<App::Scaffolder::Command|App::Scaffolder::Command> command base class also
provides two parameters related to the template search path:

=over

=item --list

Show the search path and list the templates found there.

=item --create-template-dir

Create the template directory in the C<my_dist_data> directory returned by
L<File::HomeDir|File::HomeDir> and print the search path.

=back

=head1 INSTALLATION

L<App::Scaffolder|App::Scaffolder> can be installed like any other Perl
distribution. However, some people might prefer an approach which uses as
many packages from the operating system distribution they use as possible, and
which does not touch anything in directories managed by the package manager. The
following section describes an approach to achieve this that can be used on
Debian.

=head2 DEBIAN

=over

=item *

Install runtime and test dependencies:

	apt-get install libapp-cmd-perl libfile-homedir-perl libfile-sharedir-perl \
		libmro-compat-perl libpath-class-perl libtemplate-perl libdirectory-scratch-perl \
		libtest-class-perl libtest-exception-perl libtest-file-perl libtest-file-sharedir-perl

=item *

Install L<local::lib|local::lib> and L<cpanm|cpanm>:

	apt-get install liblocal-lib-perl cpanminus

=item *

Setup L<local::lib|local::lib> in your shell by adding

	eval "$(perl -Mlocal::lib)"

to your C<~/.bash_profile> or C<~/.bashrc> file and restarting your shell.

=item *

Install L<App::Scaffolder|App::Scaffolder>:

	cpanm App::Scaffolder

=back

The C<scaffolder> command should be in your C<$PATH> now and if you run it, it
will show a short help and the available commands (which are provided by other
distributions below the C<App::Scaffolder> namespace, so by default, the list
will be empty).

=cut

1;

