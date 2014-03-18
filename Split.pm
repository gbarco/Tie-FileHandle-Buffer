#!/usr/local/bin/perl

=head1 NAME

Tie::FileHandle::Split - filehandle tie that captures, splits and stores output
into files in a given path.

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

=item * finish should sync to disk to ensure data has been written to disk

test.pl

=back

=head1 BUGS

No known bugs. Please report.

=cut

package Tie::FileHandle::Split;

use vars qw(@ISA $VERSION);
use base qw(Tie::FileHandle::Base);
$VERSION = 0.11;

# TIEHANDLE
# Usage: tie *HANDLE, 'Tie::FileHandle::Split'
sub TIEHANDLE {
	my $self = '';
	bless \$self, $_[0];;
}

# Print to the selected handle
sub PRINT {
	${$_[0]} .= $_[1];
}

# Retrieve the contents
sub get_contents {
	${$_[0]};
}

# Discard the contents
sub clear {
	${$_[0]} = '';
}

1;

=head1 AUTHORS AND COPYRIGHT

Written by Gonzalo Barco based on Tie::FileHandle::Buffer written by Robby Walker ( robwalker@cpan.org ) for Point Writer ( http://www.pointwriter.com/ ).

You may redistribute/modify/etc. this module under the same terms as Perl itself.

