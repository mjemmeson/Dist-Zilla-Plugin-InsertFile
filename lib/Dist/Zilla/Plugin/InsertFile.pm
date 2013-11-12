use strict;
use warnings;
package Dist::Zilla::Plugin::InsertFile;

use v5.10;
use Moose;

# ABSTRACT: Insert contents of file(s) into POD

# VERSION

=head1 SYNOPSIS

In your dist.ini:

    [InsertFile]
    
    [InsertFile / FOO]
    file: foo.pod
    
    [InsertFile / BAR]
    file: /path/to/bar.pod

In a file:

    # FOO
    
    # BAR
    
    # INSERTFILE: /path/to/baz

=head1 DESCRIPTION

=cut

with 'Dist::Zilla::Role::FileMunger';
with 'Dist::Zilla::Role::FileFinderUser' => {
  default_finders => [ qw( :InstallModules :ExecFiles ) ],
};

has file   => ( is => 'ro', isa => 'Maybe[Str]', default => undef );

sub munge_files {
    my ($self) = @_;
    $self->munge_file($_) for @{ $self->found_files };
}

sub munge_file {
    my ( $self, $file ) = @_;

    my $content = $file->content;

    if ( $content
        =~ s{^#\s*INSERT_FILE:\s*(.+)\s*$}{$self->_slurp_file($1)."\n"}meg )
    {
        $self->log( [ 'inserting file %s into %s', $1, $file->name ] );
    }

    if ( my $to_insert = $self->file ) {

        my $name = $self->plugin_name;

        if ( $content
            =~ s{^#\s*$name\s*$}{$self->_slurp_file($to_insert)."\n"}meg )
        {
            $self->log(
                [ 'inserting file %s into %s', $to_insert, $file->name ] );
        }
    }

    $file->content($content)
        if $content ne $file->content;
}

sub _slurp_file {
    my ( $self, $filename ) = @_;

    my $file = $self->zilla->root->file($filename);

    $self->log_fatal("no such example file $filename") unless -r $file;

    return join "\n", split /\r?\n/, $file->slurp;
}

__PACKAGE__->meta->make_immutable;

1;
