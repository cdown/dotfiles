use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

sub notify {
    my ($title, $msg) = @_;
    system('notify-send', $title, $msg);
    system('pushbullet-push', $title, $msg);
}

sub print_text_notify {
    my ($event, $text, $nick_and_msg) = @_;

    if ($event->{level} & MSGLEVEL_HILIGHT) {
        my $nick = $nick_and_msg;
        my $msg = $nick_and_msg;
        $nick =~ s/^\<([^\>]+)\>.+/\1/;
        $msg =~ s/^.*?\> (.*)$/\1/;
        notify("HLed by $nick in " . ${event}->{target}, $msg);
    }
}

sub message_private_notify {
    my ($server, $msg, $nick, $address) = @_;
    notify("PMed by $nick", $msg)
}

Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add('message private', 'message_private_notify');
