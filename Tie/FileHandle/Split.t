use strict;
use Test::More tests=>10;
use lib '../..';

my @tie_file_handle_split_exported = qw( TIEHANDLE PRINT PRINTF WRITE GETC READ READLINE EOF );

BEGIN {
	use_ok('FileHandle');
	use_ok('File::Temp');
	use_ok('Tie::FileHandle::Split');
}

can_ok( 'FileHandle', qw ( new ) );
can_ok( 'Tie::FileHandle::Split', @tie_file_handle_split_exported );

my $fh = FileHandle->new();
my $dir = tempdir( CLEANUP => 1 );
my $split_size = 512;

tie $fh, 'Tie::FileHandle::Split', $dir, $split_size;

$fh->print( ' ' x ( $split_size - 1 ) );
is( scalar $fh->get_filenames(), 0, 'No files generated when output less than split_size.' );

$fh->print( ' ' x 1 );
is( scalar $fh->get_filenames(), 1, 'First file generated at split_size.' );

$fh->print( ' ' x 1 );
is( scalar $fh->get_filenames(), 1, 'No extra file 1B after split_size.' );

$fh->print( ' ' x ( $split_size - 2 ) );
is( scalar $fh->get_filenames(), 1, 'No extra file at second split_size - 1 split_size.' );

$fh->print( ' ' x 1 );
is( scalar $fh->get_filenames(), 2, 'Second file generated at split_size * 2.' );

$fh->write_buffers();
is( scalar $fh->get_filenames(), 2, 'No extra file generated when write_buffers is called on a file limit.' );

$fh->print( ' ' x ( $split_size - 1 ) );
is( scalar $fh->get_filenames(), 2, 'No extra file generated after write_buffers at split_size - 1.' );

$fh->print( ' ' x 1 );
is( scalar $fh->get_filenames(), 3, 'Third file generated after split_size * 3 after a call to write_buffers.' );

$fh->print( ' ' x 1 );
$fh->write_buffers();
is( scalar $fh->get_filenames(), 4, 'Fourth file generated after split_size * 3 + 1 calling write_buffers.' );

my @files = $fh->get_filenames();
is( -s $files[scalar @files - 1], 1, 'File generated from write_buffers on partial buffers are of correct size.' );
