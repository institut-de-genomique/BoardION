#ifndef RUN_INFO_STAT_H 
#define RUN_INFO_STAT_H
#pragma once

#include <filesystem>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <unordered_map>

#include <doctest/doctest.h>

#include "myUtil.hpp"

namespace fs = std::filesystem;

/*
 * Global informations and statistics of a run
 */
class RunInfoStat
{
public:
	std::string flowcell;
	std::string start_time;
	std::string ended;
	uint_fast16_t duration;
	uint_fast32_t nb_reads;
	uint_fast32_t n50;
	uint_fast64_t yield;
	float speed;
	float quality;
	float average_length;
	float median;

	// Positions during the previous execution
	std::streampos lastReadPosition; // Position in the input file (in octet) of the last read
	std::streampos lastStepStartPosition; // Position in the input file of the start of the last step

	RunInfoStat();
	bool isFinish(const fs::path& file_path);
	friend std::ostream& operator<<(std::ostream& os, const RunInfoStat& run);
};

/*
 * Represent several runs
 */
class RunsInfoStat
{
public:
	std::unordered_map<std::string, RunInfoStat> runs;

	void parseFile(const fs::path& run_info_file_path);
	void createFile(const fs::path& run_info_path);
	void writeAllBut1(const fs::path& file, const std::string& no_write);
};

TEST_CASE("RunsInfoStat")
{
	std::filesystem::path p("test_rfs.txt");
	RunsInfoStat rfs;

	RunInfoStat run1;
	run1.flowcell = "PAD0001";
	run1.start_time = "01/01/01";
	run1.ended = "NO";
	run1.duration = 259200;
	run1.yield = 1000000000;
	run1.nb_reads = 1000000;
	run1.speed = 302.5697;
	run1.quality = 8.9565;
	run1.n50 = 100000;
	run1.average_length = 15000;
	run1.median = 10000;
	run1.lastReadPosition = 2000000000;
	run1.lastStepStartPosition = 1950000000;

	RunInfoStat run2;
	run2.flowcell = "PAD0002";
	run2.start_time = "01/01/01";
	run2.ended = "YES";
	run2.duration = 259200;
	run2.yield = 1000000000;
	run2.nb_reads = 1000000;
	run2.speed = 302.5697;
	run2.quality = 8.9565;
	run2.n50 = 100000;
	run2.average_length = 15000;
	run2.median = 10000;
	run2.lastReadPosition = 2000000000;
	run2.lastStepStartPosition = 1950000000;

	rfs.runs[run1.flowcell] = run1;
	rfs.runs[run2.flowcell] = run2;

	SUBCASE("createFile parseFile")
	{
		rfs.createFile(p); // only PAD0002 is write

		RunsInfoStat rfs2;
		rfs2.parseFile(p);

		std::stringstream ss1,ss2;
		ss1 << run2;

		for(auto &it : rfs2.runs)
		{
			ss2 << it.second;
		}

		CHECK(rfs2.runs.size() == 1);
		CHECK(rfs2.runs.count("PAD0002") != 0);
		CHECK(ss1.str() == ss2.str());
	}

	SUBCASE("writeAllBut1")
	{
		rfs.createFile(p); // only PAD0002 is write
		rfs.writeAllBut1( p, "PAD0002"); // write PAD0001

		RunsInfoStat rfs2;
		rfs2.parseFile(p);

		std::stringstream ss1,ss2;
		ss1 << rfs.runs["PAD0001"];
		ss1 << rfs.runs["PAD0002"];

		ss2 << rfs2.runs["PAD0001"];
		ss2 << rfs2.runs["PAD0002"];

		CHECK( ss1.str() == ss2.str() );
		CHECK( rfs.runs.size() == rfs2.runs.size() );
	}
}
#endif
