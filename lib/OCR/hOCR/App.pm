package OCR::hOCR::App;
use strict;
use parent 'OCR::App';

our $VERSION = '0.01';

sub _default_command_base { 'OCR::App::Command' }

sub prepare_command {
    my $self = shift;

    my($cmd, $opt, @args) = $self->SUPER::prepare_command(@_);

    if ($cmd->isa("OCR::App::Command::convert")) {
        $opt->{install_command} ||= 'cpanm .';
    } elsif ($cmd->isa("OCR::App::Command::check")) {
        $ENV{DZIL_CONFIRMRELEASE_DEFAULT} = 1
          unless defined $ENV{DZIL_CONFIRMRELEASE_DEFAULT};
    } elsif ($cmd->isa("OCR::App::Command::new")) {
        $opt->{provider} = 'hOCR';
    }

    return $cmd, $opt, @args;
}

1;
