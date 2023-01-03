########################################
# Header ###############################
########################################

use strict;
use Encode();
use Irssi;
use vars qw($VERSION %IRSSI);
$VERSION = 'r4';
%IRSSI = (
    'name'        => 'colored_nicks',
    'authors'     => 'Trilkk',
    'contact'     => 'trilkk ät iki.fi',
    'url'         => 'https://github.com/trilkk/irssi-colored-nicks',
    'license'     => 'BSD',
    'description' => 'Exposes colored nickname variables for themes',
);

# List of protocols to act on.
my @action_protos = qw(irc silc xmpp);
# Global expando variable.
my $expando_cnnick = '';
# Global expando variable.
my $expando_cnpadl = '';
# Global expando variable.
my $expando_cnpads = '';
# Global expando variable.
my $expando_cnuser = '';

########################################
# Functions ############################
########################################

# Creates a terminal color command code string.
# Use cubes.pl to check string input.
# Similar function in nickcolor_expando.pl by Nei was used as basis.
# See: https://github.com/irssi/scripts.irssi.org/blob/master/scripts/nickcolor_expando.pl
# \param 0 Irssi color code.
# \return Color command code.
sub create_color_command_code
{
    my $input_code = $_[0];
    $input_code =~ /%(.*)/;
    my $code = $1;

    # First, try simple 16-color terminal codes.
    my %color_map_16c =
    (
        'k' => '0',
        'b' => '1',
        'g' => '2',
        'c' => '3',
        'r' => '4',
        'm' => '5',
        'y' => '6',
        'w' => '7',
        'K' => '8',
        'B' => '9',
        'G' => ':',
        'C' => ';',
        'R' => '<',
        'M' => '=',
        'Y' => '>',
        'W' => '?',
    );
    if(exists $color_map_16c{$code})
    {
        return "\cD" . $color_map_16c{$code} . '/';
    }

    # Try 256-color terminal codes.
    my @ext_colour_off =
    (
        '.', '-', ',', '+', "'", '&',
    );
    if($code =~ /^(x)(?:0([[:xdigit:]])|([1-6])(?:([0-9])|([a-z]))|7([a-x]))$/i)
    {
        my $bg = $1 eq 'x';
        my $col = defined $2 ? hex $2
        : defined $6 ? 232 + (ord lc $6) - (ord 'a')
        : 16 + 36 * ($3 - 1) + (defined $4 ? $4 : 10 + (ord lc $5) - (ord 'a'));
        if ($col < 0x10)
        {
            my $chr = chr $col + ord '0';
            return "\cD" . ($bg ? "/$chr" : "$chr/")
        }
        else
        {
            return "\cD" . $ext_colour_off[($col - 0x10) / 0x50 + $bg * 3] . chr (($col - 0x10) % 0x50 - 1 + ord '0')
        }
    }

    # Default fallback is just gray.
    return "\cD" . '7/';
}

# Create an irssi nickname string for a nick with maximum amount of characters.
# \param 0 Nick.
# \param 1 Attribution.
# \param 2 Number of characters nick can use at maximum.
# \return Truncated, colored nickname string.
sub create_irssi_nick
{
    my $nick = $_[0];
    my $attr = $_[1];
    my $truncation = $_[2];

    my $len = nick_length($nick);
    if($attr)
    {
        $len += nick_length($attr);
    }

    # Hash the color before modifying nick.
    my $color = simple_hash_color($nick);
    my $format = create_color_command_code($color);

    # Decrease until within parameters.
    if($truncation > 0)
    {
        while($len > $truncation)
        {
            if(length($attr) > 1)
            {
                chop($attr);
            }
            else
            {
                chop($nick);
            }
            --$len;
        }
    }

    if($attr)
    {
        return $format . $nick . create_color_command_code('%K') . $attr;
    }
    return $format . $nick;
}

# Create a buffer of spaces to pad a nick to n characters.
# \param 0 Nick.
# \param 1 Attribution.
# \param 2 Number of characters nick can use at maximum.
# \return Whitespace padding buffer.
sub create_padding
{
    my $nick = $_[0];
    my $attr = $_[1];
    my $truncation = $_[2];

    my $len = nick_length($nick);
    if($attr)
    {
        $len += nick_length($attr);
    }

    my $ret = '';
    if($truncation > 0)
    {
        while($len < $truncation)
        {
            ++$len;
            $ret .= ' ';
        }
    }
    return $ret;
}

# Extracts attribution information from the message.
# \param 0 Nick.
# \return Tuple of (nickname part, attribution part).
sub extract_attribution
{
    my $nick = $_[0];
    Encode::_utf8_on($nick);

    # Split nickname from boundary of allowed IRC nickname characters.
    # Non-breakable space and zero-width space are valid characters.
    $nick =~ /^([\w\s\|\^_`\-\{\}\[\]\\\x{00A0}\x{200B}\x{202F}]+)(.*)$/;
    return ($1, $2);
}

# Calculates djb2 hash over an array.
# \param 0 Input array.
# \return calculated hash.
sub hash_djb2
{
    my @array = @_;
    my $ret = 5381;
    foreach my $cc (@array)
    {
        my $oo = ord($cc);
        if(!is_zero_width($oo))
        {
            $ret = (($ret * 33) + $oo) & 0xFFFFFFFF;
        }
    }
    return $ret;
}

# Calculates sdbm hash over an array.
# \param 0 Input array.
# \return calculated hash.
sub hash_sdbm
{
    my @array = @_;
    my $ret = 0;
    foreach my $cc (@array)
    {
        my $oo = ord($cc);
        if(!is_zero_width($oo))
        {
            $ret = (($ret * 65599) + $oo) & 0xFFFFFFFF;
        }
    }
    return $ret;
}

# Gets the color array.
# \return Color array.
sub get_color_array()
{
    my $ret = Irssi::settings_get_str('colored_nicks_colors');
    $ret =~ s/^\s+//;
    $ret =~ s/\s+$//;
    return split /\s/, $ret;
}

# Tells if a character has zero width.
# \param 0 Character.
# \return True if character has zero widh, false otherwise.
sub is_zero_width
{
    my $cc = $_[0];
    my @zero_width_chars =
    (
        0x200B,
    );
    foreach my $zz (@zero_width_chars)
    {
        if(($cc == $zz) || (ord($cc) == $zz))
        {
            return 1;
        }
    }
    return 0;
}

# Calculate real length of a nickname.
# Non-breakable space is not included.
# \param 0 Nick, must be in unicode.
# \return Nick length in terminal characters.
sub nick_length
{
    my $nick = $_[0];
    my $ret = 0;
    foreach my $cc (split //,$nick)
    {
        if(!is_zero_width($cc))
        {
            ++$ret;
        }
    }
    return $ret;
};

# Simple hash based on nick.
# \param 0 String to hash.
# \return Hash value.
sub simple_hash
{
    # Remove characters that should not be taken into account for.
    my $input_string = $_[0];
    $input_string =~ s/^[\s_\-^]*//;
    $input_string =~ s/[\s_\-^]*$//;
    my @array = split(//, $input_string);
    # Check for djb2 hash.
    my $hash_function = Irssi::settings_get_str('colored_nicks_hash_function');
    if($hash_function =~ /^djb2$/i)
    {
        return hash_djb2(@array);
    }
    # Fallback to sdbm hash.
    return hash_sdbm(@array);
}

# Simple hash, but pick color based on nick.
# \param 0 String to hash.
# \return Color change string.
sub simple_hash_color
{
    my $input_string = $_[0];
    my @colors = get_color_array();
    return $colors[simple_hash($input_string) % @colors];
}

########################################
# Commands #############################
########################################

# Test command to list all colors in use.
sub cmd_cn_list
{
    my $window = Irssi::active_win;
    my $mode = MSGLEVEL_NEVER | MSGLEVEL_CLIENTCRAP;
    my @colors = get_color_array();
    for(my $ii = 0; ($ii < @colors); ++$ii)
    {
        my $color = @colors[$ii];
        my $code = create_color_command_code($color);
        # Insert non-breakable space as second character so irssi doesn't use the color code.
        $color = substr($color, 0, 1) . "\x{200B}" . substr($color, 1);
        $window->print($code . 'colored_nicks_' . $ii . '_' . $color, $mode);
    }
}

# Test command for given input.
# \param 0 Test nickname.
sub cmd_cn_test
{
    my @nicks = split /\s/, $_[0];
    my $window = Irssi::active_win;
    my $mode = MSGLEVEL_NEVER | MSGLEVEL_CLIENTCRAP;
    my $truncation_long = Irssi::settings_get_int('colored_nicks_truncation_long');
    # Iterate over the input.
    my $ret = '';
    foreach my $nick (@nicks)
    {
        if($ret)
        {
            $ret .= ' ';
        }
        $ret .= create_irssi_nick($nick, '', $truncation_long);
    }
    # Only print if there was legit input.
    if($ret)
    {
        $window->print($ret, $mode);
    }
}

########################################
# Signal hooks #########################
########################################

# Signal function for private messages to the user.
# \param 0 Server struct.
# \param 1 ???
# \param 2 Input nickname.
# \param 3 ???
# \param 4 ???
sub signal_cn_private
{
    my ($server, $param1, $input_nick, $param3, $param4) = @_;
    my ($nick, $attr) = extract_attribution($input_nick);
    my $truncation_long = Irssi::settings_get_int('colored_nicks_truncation_long');
    $expando_cnnick = create_irssi_nick($nick, $attr, $truncation_long);
    $expando_cnpadl = create_padding($nick, $attr, $truncation_long);
    $expando_cnpads = '';
    $expando_cnuser = '';
}

# Signal function for public messages by others.
# \param 0 Server struct.
# \param 1 ???
# \param 2 Input nickname.
# \param 3 ???
# \param 4 ???
sub signal_cn_public
{
    my ($server, $param1, $input_nick, $param3, $param4) = @_;
    my ($nick, $attr) = extract_attribution($input_nick);
    my $truncation_long = Irssi::settings_get_int('colored_nicks_truncation_long');
    my $truncation_short = Irssi::settings_get_int('colored_nicks_truncation_short');
    $expando_cnnick = create_irssi_nick($nick, $attr, $truncation_long);
    $expando_cnpadl = create_padding($nick, $attr, $truncation_long);
    $expando_cnpads = create_padding($nick, $attr, $truncation_short);
    $expando_cnuser = '';
}

# Signal function for public messages from the user.
# \param 0 Server struct.
# \param 1 ???
# \param 2 ???
sub signal_cn_own_public
{
    my ($server, $param1, $param2) = @_;
    my $truncation_long = Irssi::settings_get_int('colored_nicks_truncation_long');
    $expando_cnnick = '';
    $expando_cnpadl = create_padding($server->{nick}, '', $truncation_long);
    $expando_cnpads = '';
    $expando_cnuser = create_irssi_nick($server->{nick}, '', $truncation_long);
}

# Signal function for private messages from the user.
# \param 0 Server struct.
# \param 1 ???
# \param 2 Input nick
# \param 3 ???
# \param 4 ???
sub signal_cn_own_private
{
    my ($server, $param1, $input_nick, $param3) = @_;
    my ($nick, $attr) = extract_attribution($input_nick);
    my $truncation_long = Irssi::settings_get_int('colored_nicks_truncation_long');
    $expando_cnnick = create_irssi_nick($nick, $attr, $truncation_long);
    $expando_cnpadl = create_padding($nick, $attr, $truncation_long);
    $expando_cnpads = create_padding($server->{nick}, '', $truncation_long);
    $expando_cnuser = create_irssi_nick($server->{nick}, '', $truncation_long);
}

########################################
# Irssi:: ##############################
########################################

Irssi::settings_add_str('misc', 'colored_nicks_colors',
    '%c %X3N' . # cyans
    ' ' .
    '%X59 %X4B %X4A %m' . # magentas/purples
    ' ' .
    '%w %X7P %X7Q %X7R' . # whites
    ' ' .
    '%g %X1J %X2I %X2J %X3I' . # greens
    ' ' .
    '%X46 %X4C %X5I' . # browns
    ' ' .
    '%X2N %X2M %X1N %B' . # blues
    ' ' .
    '%X5C %X56 %y' . # oranges/yellows
    ' ' .
    '%X58 %X57' . # pinks/reds
    '');
Irssi::settings_add_str('misc', 'colored_nicks_hash_function', 'djb2');
Irssi::settings_add_int('misc', 'colored_nicks_truncation_long', 12);
Irssi::settings_add_int('misc', 'colored_nicks_truncation_short', 11);

Irssi::expando_create('cnnick', sub { $expando_cnnick }, {
        'message public' => 'none',
        'message own_public' => 'none',
        (map { ("message $_ action" => 'none',
                "message $_ own_action" => 'none')
            } @action_protos),
    });

Irssi::expando_create('cnpadl', sub { $expando_cnpadl }, {
        'message public' => 'none',
        'message own_public' => 'none',
        (map { ("message $_ action" => 'none',
                "message $_ own_action" => 'none')
            } @action_protos),
    });

Irssi::expando_create('cnpads', sub { $expando_cnpads }, {
        'message public' => 'none',
        'message own_public' => 'none',
        (map { ("message $_ action" => 'none',
                "message $_ own_action" => 'none')
            } @action_protos),
    });

Irssi::expando_create('cnuser', sub { $expando_cnuser }, {
        'message public' => 'none',
        'message own_public' => 'none',
        (map { ("message $_ action" => 'none',
                "message $_ own_action" => 'none')
            } @action_protos),
    });

Irssi::signal_add({
        'message private' => 'signal_cn_private',
        'message public' => 'signal_cn_public',
        'message own_public' => 'signal_cn_own_public',
        'message own_private' => 'signal_cn_own_private',
});

Irssi::command_bind('colored_nicks_list', 'cmd_cn_list');
Irssi::command_bind('colored_nicks_test', 'cmd_cn_test');
