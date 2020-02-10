#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use Data::Dumper;

my %FILES;

if( $ARGV[0] eq "-h" or $ARGV[0] eq "h" or $ARGV[0] eq "--help" or $ARGV[0] eq "-help" or $ARGV[0] eq "help" )
{
	print "
usage: boardionDemo_generateFile.pl [-h|--help] OUTPUT_DIR STAT_DIR TIME_WAIT NB_LINES FILE1 FILE2 ...

description: Simulate the creation of sequencing_summary.txt by copying block of lines (<NB_LINES> lines) from real sequencing_summary (input files) to files with the same name in output directory. Between the copy of each block it wait <TIME_WAIT> secondes. This program loop infinitely: if a file is entirely read, it remove the corresponding line in runInfo.txt (in <STAT_DIR>), reset the output file and restart from the top of the input file.\n";
	exit(1);
}

my $OUTPUT_DIR    = shift @ARGV;
my $STAT_DIR      = shift @ARGV;
my $TIME_INTERVAL = shift @ARGV;
my $N_LINES       = shift @ARGV;

my $runInfoFile = $STAT_DIR."/run_infostat.txt";
my $lock_file   = $STAT_DIR."/boardion_preprocess.inprocess"; 

if( not defined $OUTPUT_DIR )
{
	die "Need a output directory as first argument.";
}

if( not defined $STAT_DIR )
{
	die "Need a stat directory as second argument.";
}

if( not defined $TIME_INTERVAL )
{
	die "Nedd time to wait as third argument.";
}

if( not defined $N_LINES )
{
	die "Need number of lines to read as fourth argument.";
}

if( @ARGV < 1 )
{
	die "Need a least 1 input files as second argument.";
}

# Open input and output file
foreach my $file_in ( @ARGV )
{
	my $run_id;
	my $handle_in;

	open( $handle_in, $file_in ) or die "Can't open $file_in: $!";
	scalar(<$handle_in>);
	if( <$handle_in> =~ /(PAD\d+_\w{8})/ )
	{
		$run_id = $1;
	}
	close( $handle_in );

	my $file_out = $OUTPUT_DIR."/".basename( $file_in );

	open( $handle_in, $file_in ) or die "Can't open $file_in: $!";

	$FILES{ $run_id } = {};
	$FILES{ $run_id }{ IN } = $file_in;
	$FILES{ $run_id }{ HANDLE_IN } = $handle_in;
	$FILES{ $run_id }{ OUT } = $file_out;

	# remove output file as it is open in append mode in the main loop
	if( -e $file_out )
	{	
		unlink $file_out;
	}
}

# repeat the file generation infinitely
# print N lines of each files and then wait $TIME_INTERVAL seconds
while( 1 )
{
	# create lock file
	while ( -e $lock_file )
	{
		sleep $TIME_INTERVAL;
	}

	open(TMP, ">", $lock_file);
	close( TMP );

	# loop on each input file then wait
	foreach my $run ( keys  %FILES )
	{
		my $IN  = $FILES{ $run }{ HANDLE_IN };
		my $OUT;
		open( $OUT, ">>", $FILES{ $run }{ OUT });

		# if input file was completely read in the last iteration, close it and open it again
		if( eof $IN )
		{
			close( $IN );
			close( $OUT );

			delete_run_in_runInfo( $run, $runInfoFile );

			open( $IN, $FILES{ $run }{ IN } ) or die "Can't open ".$FILES{ $run }{ IN }.": $!";
			$FILES{ $run }{ HANDLES_IN } = $IN;

			open($OUT, ">", $FILES{ $run }{ OUT });
		}

		# print N lines of input file to output file
		for( 1..$N_LINES )
		{
			print $OUT scalar <$IN>;
		}
	}
	unlink $lock_file;
	sleep $TIME_INTERVAL;
}

sub delete_run_in_runInfo
{
	my ($run, $runInfo) = @_;

	if( -e $runInfo )
	{
		open( IN, $runInfo ) or die "can't open $runInfo: $!";
		open( OUT, ">", $runInfo.".tmp") or die "can't open ${runInfo}.tmp: $!";

		while(<IN>)
		{
			if(/^(\w+)\s+/)
			{
				if( $1 eq $run )
				{
					next;
				}
			}
			print OUT $_;
		}
		close(IN);
		close(OUT);
		rename $runInfo.".tmp", $runInfo;
	}
}


