use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

sub notify {
    my $msg = shift;
    system('notify-send', $msg);
}

sub print_text_notify {
    my ($event, $text, $nick_and_msg) = @_;

    if ($event->{level} & MSGLEVEL_HILIGHT) {
        my $sender = $nick_and_msg;
        $sender =~ s/^\<([^\>]+)\>.+/\1/;
        notify("You were highlighted by $sender in " . ${event}->{target} . ".");
    }
}

sub message_private_notify {
    my ($server, $msg, $nick, $address) = @_;
    notify("You were private messaged by $nick.")
}

Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add('message private', 'message_private_notify');
