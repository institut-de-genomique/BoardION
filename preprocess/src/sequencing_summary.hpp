#ifndef SEQUENCING_SUMMARY_H
#define SEQUENCING_SUMMARY_H
#pragma once

#include <filesystem>
#include <fstream>
#include <string>
#include <iostream>
#include <regex>

#include "read.hpp"
#include "myUtil.hpp"

#include <doctest/doctest.h>
namespace fs = std::filesystem;

class SequencingSummary
{
public:
	fs::path filePath;
	std::ifstream ifs;

	// positions of the columns in the file
	unsigned int channelIdx;
	unsigned int startTimeIdx;
	unsigned int durationIdx;
	unsigned int templateStartIdx;
	unsigned int templateDurationIdx;
	unsigned int readLengthIdx;
	unsigned int meanQScoreIdx;

	SequencingSummary(fs::path &filePath);	
	void setColumnIndex();
	bool readLine(Read &r, unsigned int &line_length);

	static bool getShortRunId (fs::path filePath, std::string &id);
	static bool isSequencingSummary (fs::path &file);
};


TEST_CASE("SequencingSummary")
{
	fs::path p ("./test_sequencing.summary.txt");
	std::ofstream out = std::ofstream( p );

	out << "filename_fastq	filename_fast5	read_id	run_id	channel	mux	start_time	duration	num_events	passes_filtering	template_start	num_events_template	template_duration	sequence_length_template	mean_qscore_template	strand_score_template	median_template	mad_template	pore_type	experiment_id	sample_id	end_reason" << std::endl <<
		"PAE09299_pass_9bef8aa8_0.fastq	PAE09299_pass_9bef8aa8_0.fast5	9f14ec38-2b4a-4a4c-a8cc-0e4b510f8a23	9bef8aa815e45db878f9d76ad7f15a2799fa370b	809	1	6.159500	0.715250	1430	TRUE	6.338500	1072	0.536250	249	8.121380	0.000000	98.324249	9.503459	not_set	prom242	PAE09299	signal_negative" << std::endl << 
		"PAE09299_pass_9bef8aa8_0.fastq	PAE09299_pass_9bef8aa8_0.fast5	fb8d8995-83c1-4d27-862a-284f8819dbcf	9bef8aa815e45db878f9d76ad7f15a2799fa370b	2291	1	6.152000	1.145750	2291	TRUE	6.256000	2083	1.041750	441	9.531655	0.000000	107.827705	8.041389	not_set	prom242	PAE09299	signal_positive" << std::endl <<
		"PAE09299_fail_9bef8aa8_0.fastq	PAE09299_fail_9bef8aa8_0.fast5	3b9e2195-7e84-42b0-bc4f-a642f8b5d3fd	9bef8aa815e45db878f9d76ad7f15a2799fa370b	1733	1	6.124000	0.776750	1553	FALSE	6.311500	1178	0.589250	275	6.381978	0.000000	77.124222	8.041389	not_set	prom242	PAE09299	signal_negative" << std::endl <<
		"PAE09299_fail_9bef8aa8_0.fastq	PAE09299_fail_9bef8aa8_0.fast5	fe4fd154-3d41-4a82-9dc0-bf7e88ad03e6	9bef8aa815e45db878f9d76ad7f15a2799fa370b	415	1	6.946750	0.594750	1189	FALSE	7.178750	725	0.362750	172	4.101632	0.000000	138.531189	8.406906	not_set	prom242	PAE09299	signal_positive" << std::endl;

	SequencingSummary s = SequencingSummary(p);

	SUBCASE("Constructor")
	{
		CHECK( s.channelIdx          == 4 );
		CHECK( s.startTimeIdx        == 6 );
		CHECK( s.durationIdx         == 7 );
		CHECK( s.templateStartIdx    == 10 );
		CHECK( s.templateDurationIdx == 12 );
		CHECK( s.readLengthIdx       == 13 );
		CHECK( s.meanQScoreIdx       == 14 );
	}

	SUBCASE("readLine")
	{
		Read r1;
		unsigned int line_length1;
		bool b1;

		Read r2;
		unsigned int line_length2;
		bool b2;

		b1 = s.readLine( r1, line_length1 );
		b2 = s.readLine( r2, line_length2 );


		CHECK( r1.channel           == 809 );
		CHECK( r1.start_time        == doctest::Approx( 6.159500 ));
		CHECK( r1.duration          == doctest::Approx( 0.715250 ));
		CHECK( r1.template_start    == doctest::Approx( 6.338500 ));
		CHECK( r1.template_duration == doctest::Approx( 0.536250 ));
		CHECK( r1.length            == 249 );
		CHECK( r1.mean_q_score      == doctest::Approx( 8.121380 ));
		CHECK( r1.speed             == doctest::Approx( 249 / 0.715250 ));
		CHECK( line_length1         == 278 );
		CHECK( b1                   == true );

		CHECK( r2.channel           == 2291 );
		CHECK( r2.start_time        == doctest::Approx( 6.152000 ));
		CHECK( r2.duration          == doctest::Approx( 1.145750 ));
		CHECK( r2.template_start    == doctest::Approx( 6.256000 ));
		CHECK( r2.template_duration == doctest::Approx( 1.041750 ));
		CHECK( r2.length            == 441 );
		CHECK( r2.mean_q_score      == doctest::Approx( 9.531655 ));
		CHECK( r2.speed             == doctest::Approx( 441 / 1.145750 ));
		CHECK( line_length2         == 280 );
		CHECK( b2                   == true );

		b1 = s.readLine( r1, line_length1 );
		b1 = s.readLine( r1, line_length1 );
		b1 = s.readLine( r1, line_length1 );

		CHECK(b1 == false);
	}
}

#endif
