#!/usr/local/bin/perl

=head1 NAME

Tie::FileHandle::Split - Filehandle tie that captures, splits and stores output into files in a given path.

=head1 DESCRIPTION

This module, when tied to a filehandle, will capture and store all that
is output to that handle. You should then select a path to store files and a
size to split files.

=head1 SYNOPSIS

# $path should exist or the current process have
# $size should be > 0
tie *HANDLE, 'Tie::FileHandle::Split', $path, $size;

(tied *HANDLE)->print( ' ' x 1024 );

# write all outstanding output from buffers to files
(tied *HANDLE)->write_buffers;

# get generated filenames to the moment
(tied *HANDLE)->get_filenames();

=head1 TODO

=over 4

=item * write_buffers should sync to disk to ensure data has been written.

=back

=head1 BUGS

No known bugs. Please report.

=cut

package Tie::FileHandle::Split;

use vars qw(@ISA $VERSION);
use base qw(Tie::FileHandle::Base);
$VERSION = 0.9;

use File::Temp;

# TIEHANDLE
# Usage: tie *HANDLE, 'Tie::FileHandle::Split'
sub TIEHANDLE {
	my ( $class, $path, $size ) = @_;

	my $self = {
		class => $class,
		path => $path,
		split_size => $size,
		buffer => '',
		buffer_size => 0,
		filenames => (),
	};

	bless $self, $class;
}

# Print to the selected handle
sub PRINT {
	my ( $self, $data ) = @_;
	$self->{buffer} .= $data;
	$self->{buffer_size} += length( $data );

	$self->_write_files( $self->{split_size} );
}

sub _write_files{
	my ( $self, $min_size ) = @_;

	while ( $self->{buffer_size} >= $min_size ) {
		my ($fh, $filename) = File::Temp::tempfile( DIR => $self->{path} );

		$fh->print( substr $self->{buffer},0,$min_size );
		$self->{buffer_size} -= $min_size;
		$fh->close;

		push @{$self->{filenames}}, $filename;
	}
}

# Write outstanding data to files
sub write_buffers {
	# Must implement
	my ( $self ) = @_;

	# this should not happen...
	$self->_write_files( $self->{split_size} );
	if ( $self->{buffer_size} > 0 ) {
		$self->_write_files( $self->{buffer_size} );
	}
}

# Returns filenames generated up to the moment the method is called
sub get_filenames {
	my ( $self ) = @_;

	return @{$self->{filenames}};
}

1;

=head1 AUTHORS AND COPYRIGHT

Written by Gonzalo Barco based on Tie::FileHandle::Buffer written by Robby Walker ( robwalker@cpan.org )

You may redistribute/modify/etc. this module under the same terms as Perl itself.

