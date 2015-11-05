use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

sub notify {
    my $msg = shift;
    system('notify-send', $msg);
}

sub print_text_notify {
    my $event = shift;

    if ($event->{level} & MSGLEVEL_HILIGHT) {
        notify('You were highlighted.');
    }
}

sub message_private_notify {
    notify('You were private messaged.')
}

Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add('message private', 'message_private_notify');
