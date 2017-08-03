use strict;
use POSIX;
use Irssi;
use vars qw($VERSION %IRSSI);

sub crappy_escape_html {
    # notify-send doesn't take real HTML, so this isn't really escape_html
    # since some of those things we don't want to escape.
    my ($text) = @_;
    $text =~ s/&/&amp;/g;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;
    return $text;
}

sub notify {
    my ($title, $msg) = @_;

    my $pid = fork();

    if (!defined($pid)) {
        Irssi::print("Couldn't fork in notify.pl");
        return;
    }

    if ($pid == 0) {
        system('notify-send', $title, crappy_escape_html($msg));
        system('if-locked', 'pushover-push', $title, $msg, "1");
        POSIX::_exit(1);
    } else {
        Irssi::pidwait_add($pid);
    }
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
