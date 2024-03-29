package xtar::xtar;

use Moose;

use constant true  => 1;
use constant false => 0;
use Carp;
use Clone 'clone';
use Cwd 'getcwd';
use Data::Dumper;
use File::Copy 'mv';
use File::Copy::Recursive 'dircopy';
use File::Path 'make_path';
use File::Spec::Functions qw{rel2abs splitpath catfile};
use File::Temp qw{tempdir cleanup};
use File::Which;
use Scalar::Util 'looks_like_number';
use String::ShellQuote;

$Carp::Verbose = 1;

use xtar::File;
use xtar::OutPath;
use xtar::Colors;
use xtar::Utils;

use 5.32.0; use warnings; use strict;
use feature 'signatures';
no warnings 'experimental::signatures';
use utf8;
# use open qw(:std :utf8);
no feature 'indirect';

#########################################################################################

sub init_outpath       :prototype($);
sub init_archive       :prototype($$;$);
sub extract            :prototype($);
sub _get_tempdir       :prototype($);
sub try_extractions    :prototype($);
sub _do_try_extraction :prototype($$$$);
sub _extraction_failed :prototype($$$);
sub do_extraction      :prototype($$$$$);
sub extract_tar        :prototype($$$);
sub extract_else       :prototype($$$);
sub substitute_cmd     :prototype($$$$);
sub safe_make_path     :prototype($);
sub force_extract      :prototype($$);

#########################################################################################

has 'CWD'         => (is => 'ro', isa => 'Str');
has 'NumArchives' => (is => 'ro', isa => 'Int');
has 'Options'     => (is => 'rw', isa => 'HashRef');
has 'counter'     => (is => 'rw', isa => 'Int');
has 'tmpdir'      => (is => 'rw', isa => 'Str');
has 'out'         => (is => 'rw', isa => 'Object');
has 'file'        => (is => 'rw', isa => 'Object');

my $cmd_color = 'Bcyan';
our $DEBUG    = false;

#########################################################################################

around BUILDARGS => sub
{
    my $orig  = shift;
    my $class = shift;
    my $ret   = $class->$orig(@_);
    $DEBUG    = $ret->{Options}->{Debug};

    $ret->{out} = xtar::OutPath->new(
        CWD         => $ret->{CWD},
        Options     => $ret->{Options},
        NumArchives => $ret->{NumArchives},
    );

    return $ret;
};

sub init_archive :prototype($$;$) ($self, $filename, $second_try = false)
{
    if ($second_try) {
        $self->Options->{force} = false;
        esayC('RED', 'This is the second go.') if $DEBUG;
    }

    $self->file(xtar::File->new($filename, $self->Options, $second_try));
    if (not $self->file->analysis()) {
        return 0;
    }
    $self->out->init($self->file);
    return 1;
}

#########################################################################################

sub extract :prototype($) ($self)
{
    my $lonefile;
    my $orig_options = clone $self->Options;

    unless ($self->try_extractions()) {
        $self->Options($orig_options);
        err "Extraction failed, returning." if $DEBUG;
        return false;
    }

    while (($lonefile = $self->out->analyze_output($self->tmpdir))) {
        if (Basename($lonefile) eq $self->file->filename) {
            my $new = catfile($self->tmpdir, $self->file->bname);

            err ("Rename '$lonefile' -> '$new'") if $DEBUG;

            if (-d $new) {
                my $tdir = $new;
                $new .= '_';
                rename $lonefile, $new
                    or croak qq{Failed to rename file "$lonefile" -- $!};
                rmdir $tdir
                    or croak qq{Failed to remove directory "$tdir" -- $!};
                rename $new, $tdir
                    or croak qq{Failed to rename file "$new" -- $!};
                $lonefile = $tdir;
            }
            else {
                rename $lonefile, $new
                    or croak qq{Failed to rename file "$lonefile" -- $!};
                $lonefile = $new;
            }
        }

        #if ($self->init_archive($lonefile, true)) {
        #    esayC(
        #        'bRED',
        #        'The output contains only a single file.',
        #        "It could be a sub-archive. Attempting to extract."
        #    );
        #    unless ($self->try_extractions()) {
        #        $self->Options($orig_options);
        #            err "Extraction failed, returning." if $DEBUG;
        #        #return false;
        #    }
        #}
        if (not -d $lonefile) {
            last;
        }
    }

    $self->Options($orig_options);

    my $out_file = ($lonefile) ? $lonefile : $self->out->bottom;

    if (-d $out_file) {
        # What a mess of a command follows here.
        safe_make_path $self->out->top_dir;

        mv($out_file, $self->out->odir)
            or ($DEBUG && err ("Resorting to dircopy") or true)
                && dircopy($out_file, $self->out->odir)
            or croak("Dircopy failed. Aborting. - $!");
    }
    else {
        my $odir;

        if ($self->out->top_dir) {
            $odir = $self->out->top_dir;
            mkdir($odir)
                or croak qq{Can't create output directory "$odir":  $!\n}
                    unless (-d $odir);
        }
        else {
            $odir = $self->out->odir;
            croak "File exists somehow?!" if (-e $odir);
        }

        mv($out_file, $self->out->odir)
            or croak qq{Failed to move "$out_file" to "$odir":  $!\n};
    }

    my $CWD    = $self->CWD;
    my $odir   = $self->out->odir;
    my $reldir = $odir =~ s|${CWD}/(.*)|$1|r;
    my $otype  = (-d $odir) ? 'directory' : 'file';

    sayC('bGREEN', "Extracted to $otype $reldir") unless $self->Options->{quiet};
}

sub _get_tempdir :prototype($) ($self)
{
    my @odir_info = stat $self->out->top_exist;
    my $C         = 1;
    my $dir;

    if ($odir_info[0] == [ stat '/tmp' ]->[0]) {
        $dir = tempdir(CLEANUP => $C);
    }
    elsif (-w $self->out->top_exist) {
        $dir = tempdir(CLEANUP => $C, DIR => $self->out->top_exist);
    }
    elsif ($odir_info[0] == [ stat $self->CWD ]->[0] and -w $self->CWD) {
        $dir = tempdir(CLEANUP => $C, DIR => $self->CWD);
    }
    elsif ($odir_info[0] == [ $ENV{HOME} ]->[0]) {
        $dir = tempdir(CLEANUP => $C, DIR => $ENV{HOME});
    }
    else {    # If all else fails...
        $dir = tempdir(CLEANUP => $C);
    }

        err "Tmpdir is " . rel2abs($dir) if $DEBUG;
    return $dir;
}

#########################################################################################

sub try_extractions :prototype($) ($self)
{
    my $success = false;
    my $tmpdir;

    if (not $self->file->ID_Failure) {
        foreach my $try (('likely', 'mime', 'ext')) {
            last if $self->_do_try_extraction($try, \$success, \$tmpdir);
        }
    }
    unless ($success) { $self->_extraction_failed(\$success, \$tmpdir) }

    $self->tmpdir(rel2abs($tmpdir));
    chdir $self->CWD;
    return $success;
}

sub _do_try_extraction :prototype($$$$) ($self, $try, $success, $tmpdir)
{
    my $cmd    = eval qq{\$self->file->${try}_cmd};
    my $is_tar = eval qq{\$self->file->${try}_tar};

    if (not $cmd->{CMD}) { return 0 }
    esayC 'bYELLOW', "Using cmd " . $cmd->{CMD};

    $$tmpdir = $self->_get_tempdir;
    chdir $$tmpdir;

    $cmd->{tmpdir} = $$tmpdir;

    $$success = do_extraction($self->file->fullpath, $cmd, $is_tar, $$tmpdir, $self->Options);

    if ($$success) {
        if ($self->Options->{verbose}) {
            esayC 'GREEN', 'Operation appears successful.';
        }
        return 1;
    }
    elsif (not $self->Options->{quiet}) {
        esayC 'bRED', "Operation failed.\n";
    }

    chdir $self->CWD;
    return 0;
}

sub _extraction_failed :prototype($$$) ($self, $success, $tmpdir)
{
    if (not $self->file->ID_Failure and $self->file->notfirst) {
        esayC 'bRED', 'All identified programs have failed.';
    }
    if ($self->Options->{force}) {
        $$tmpdir = $self->_get_tempdir;
        chdir $$tmpdir;

        $$success = force_extract $self->file->fullpath, $self->Options->{TAR};
    }
}

#########################################################################################

sub do_extraction :prototype($$$$$) ($archive, $cmd, $is_tar, $tmpdir, $options)
{
    if ($cmd->{CMD} eq 'FAIL') {
        return false;
    }
    elsif ($is_tar and $cmd->{tflags} eq 'NOTAR') {
        return extract_else($cmd, $archive, $options);
    }
    else {
        if ($is_tar) {
            return extract_tar($cmd, $archive, $options);
        }
        else {
            return extract_else($cmd, $archive, $options);
        }
    }
}

sub extract_tar :prototype($$$) ($cmd, $file, $options)
{
    my $Q             = $options->{quiet};
    my $ret           = true;
    my $shortname     = Basename($file);
    my $command       = substitute_cmd($cmd, $cmd->{tflags}, $file, $options);
    my $short_command = substitute_cmd($cmd, $cmd->{tflags}, $shortname, $options);

    sayC($cmd_color, qq{$short_command | $options->{TAR} -xf -}) unless $Q || $DEBUG;
    sayC($cmd_color, qq{$command | $options->{TAR} -xf -}) if $DEBUG;

    my ($CmdPipe, $TarPipe);
    open $CmdPipe, '-|', qq{$command};
    open $TarPipe, '|-', qq{$options->{TAR} -xf -};

    # We just act like a filter between the commands.
    while (<$CmdPipe>) { print $TarPipe $_ }

    # If either command failed we won't be able to close its pipe.
    close $CmdPipe or $ret = false;
    close $TarPipe or $ret = false;

    return $ret;
}

sub extract_else :prototype($$$) ($cmd, $file, $options)
{
    my $Q             = $options->{quiet};
    my $shortname     = Basename($file);
    my $CWD           = getcwd();
    my $command       = substitute_cmd($cmd, $cmd->{eflags}, shell_quote($file), $options);
    my $short_command = substitute_cmd($cmd, $cmd->{eflags}, $shortname, $options);

    if ($cmd->{stdout}) {
        my $dst = shell_quote(catfile($CWD, $shortname));
        sayC($cmd_color, qq{$short_command > "$CWD/"}) unless $Q || $DEBUG;
        sayC($cmd_color, qq{$command > $dst}) if $DEBUG;
        system qq{$command > $dst};
    }
    else {
        sayC($cmd_color, qq{$short_command}) unless $Q || $DEBUG;
        sayC($cmd_color, qq{$command}) if $DEBUG;
        system qq{$command};
    }

    return $? == 0;
}

#########################################################################################

sub substitute_cmd :prototype($$$$) ($cmd, $flags, $file, $options)
{
    my $CMD = $cmd->{CMD};
    my $TAR = $options->{TAR};
    $CMD =~ s/TAR/$TAR/;


    if ($flags =~ / -- /) { $flags =~ s/ -- / $file / }
    else                  { $flags .= " $file" }

    my $ret = "$CMD $flags";
    if ($cmd->{needodir}) {
        $ret .= ' ' . $cmd->{tmpdir}
    }
    return $ret;
}

sub safe_make_path :prototype($) ($top_dir)
{
    my $dir = Dirname($top_dir);
    make_path($dir) unless (-e $dir);
}

#########################################################################################

sub force_extract :prototype($$) ($archive, $TAR)
{
    esayC 'bRED', "Attempting to force extract.\n";
    my $color = 'bYELLOW';

    for (my $index = 1;; ++$index) {
        if ($index == 1) {
            esayC $color, "Trying tar";
            system qq{$TAR -xf "$archive"};
            last if ($? == 0);
        }
        elsif ($index == 2 and which('patool')) {
            esayC $color, "\nTrying patool";
            system qq{patool extract "$archive"};
            last if ($? == 0);
        }
        elsif ($index == 3 and which('atool')) {
            esayC $color, "\nTrying atool";
            system qq{atool -x "$archive"};
            last if ($? == 0);
        }
        elsif ($index == 4 and which('7z')) {
            esayC $color, "\nTrying 7zip";
            system qq{7z x "$archive"};
            last if ($? == 0);
        }
        elsif ($index == 5 and which('zpaq')) {
            esayC $color, "\nTrying zpaq";
            system qq{zpaq x "$archive" -to tmp};
            last if ($? == 0);
        }
        elsif ($index == 6) {
            esayC 'bRED', "\n\nTotal failure. Giving up";
            return false;
        }
    }

    esayC 'bGREEN', 'Success!';
    return true;
}

#########################################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
