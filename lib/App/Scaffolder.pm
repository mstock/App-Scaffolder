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

=cut

1;

