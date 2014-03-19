use strict;
use Test::More tests=>15;
use lib '../..';

my @tie_file_handle_split_exported = qw( TIEHANDLE PRINT PRINTF WRITE GETC READ READLINE EOF );

BEGIN {
	use_ok('FileHandle');
	use_ok('File::Temp');
	use_ok('Tie::FileHandle::Split');
}

can_ok( 'FileHandle', qw ( new ) );
can_ok( 'Tie::FileHandle::Split', @tie_file_handle_split_exported );

my $dir = File::Temp::tempdir( CLEANUP => 1 );
my $split_size = 512;

tie *TEST, 'Tie::FileHandle::Split', $dir, $split_size;

TEST->print( ' ' x ( $split_size - 1 ) );
is( scalar (tied *TEST)->get_filenames(), undef, 'No files generated when output less than split_size.' );

TEST->print( ' ' x 1 );
my @files = (tied *TEST)->get_filenames();
is( scalar @files, 1, 'First file generated at split_size.' );

TEST->print( ' ' x 1 );
@files = (tied *TEST)->get_filenames();
is( scalar @files, 1, 'No extra file 1B after split_size.' );

TEST->print( ' ' x ( $split_size - 2 ) );
@files = (tied *TEST)->get_filenames();
is( scalar @files, 1, 'No extra file at second split_size - 1 split_size.' );

TEST->print( ' ' x 1 );
@files = (tied *TEST)->get_filenames();
is( scalar @files, 2, 'Second file generated at split_size * 2.' );

(tied *TEST)->write_buffers();
@files = (tied *TEST)->get_filenames();
is( scalar @files, 2, 'No extra file generated when write_buffers is called on a file limit.' );

TEST->print( ' ' x ( $split_size - 1 ) );
@files = (tied *TEST)->get_filenames();
is( scalar @files, 2, 'No extra file generated after write_buffers at split_size - 1.' );

TEST->print( ' ' x 1 );
@files = (tied *TEST)->get_filenames();
is( scalar @files, 3, 'Third file generated after split_size * 3 after a call to write_buffers.' );

TEST->print( ' ' x 1 );
(tied *TEST)->write_buffers();
@files = (tied *TEST)->get_filenames();
is( scalar @files, 4, 'Fourth file generated after split_size * 3 + 1 calling write_buffers.' );

@files = (tied *TEST)->get_filenames();
is( -s $files[scalar @files - 1], 1, 'File generated from write_buffers on partial buffers are of correct size.' );
