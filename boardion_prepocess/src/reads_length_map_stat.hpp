#ifndef READS_LENGTH_MAP_STAT_H 
#define READS_LENGTH_MAP_STAT_H
#pragma once

#include <filesystem>
#include <iostream>
#include <fstream>
#include <unordered_map>

#include <doctest/doctest.h>

namespace fs = std::filesystem;

/*
 * Store reads length
 */
class ReadsLengthMap
{
private:
	std::unordered_map<uint_fast32_t,uint_fast32_t> data;

public:
    void add(const ReadsLengthMap& reads_length_map);
    void add(const uint_fast32_t& length);
    void add(const uint_fast32_t& length, const uint_fast32_t& count);
    void subtract(const ReadsLengthMap& reads_length_map);
    uint_fast32_t compute_n50(const uint_fast64_t& nb_bases);
    float median_by_hash(const uint_fast32_t& nb_reads);
    void write(const fs::path& output_path);
    void read(const fs::path& input_path);
    void clear();
    uint_fast32_t at(const uint_fast32_t& l);
    std::unordered_map<uint_fast32_t,uint_fast32_t> getMap();

    friend std::ostream& operator<<(std::ostream& os, const ReadsLengthMap& rlm);
};

TEST_CASE("ReadsLengthMap")
{
	ReadsLengthMap rlm;

	SUBCASE("add length 1 by 1")
	{
		rlm.add(100);
		rlm.add(25300);
		rlm.add(132543);
		rlm.add(100);

		CHECK( rlm.at(100) == 2 );
		CHECK( rlm.at(25300) == 1 );
		CHECK( rlm.at(132543) == 1 );
	}

	SUBCASE("add length by group")
	{
		rlm.add(100,1000);
		rlm.add(10000,1);
		rlm.add(100000,10000);

		CHECK( rlm.at(100) == 1000 );
		CHECK( rlm.at(10000) == 1 );
		CHECK( rlm.at(100000) == 10000 );
	}

	SUBCASE("add a readLengthMap")
	{
		ReadsLengthMap rlm2;
		rlm2.add(100);
		rlm2.add(123456,1000);
		rlm2.add(10949,5);

		rlm.add(100,5);
		rlm.add(9999);
		rlm.add(10949);

		rlm.add(rlm2);

		CHECK( rlm.at(100) == 6 );
		CHECK( rlm.at(9999) == 1 );
		CHECK( rlm.at(10949) == 6 );
		CHECK( rlm.at(123456) == 1000 );
	}

	SUBCASE("subtract a readLengthMap")
	{
		rlm.add(100,5);
		rlm.add(9999);
		rlm.add(10949);

		ReadsLengthMap rlm2;
		rlm2.add(100,4);
		rlm2.add(9999);
		rlm2.add(10949);

		rlm.subtract(rlm2);
		CHECK( rlm.at(100) == 1 );
		CHECK( rlm.at(9999) == 0 );
		CHECK( rlm.at(10949) == 0 );
	}

	SUBCASE("compute_n50")
	{
		CHECK( doctest::Approx( rlm.compute_n50(0) ) == 0);

		rlm.add(10,5);
		rlm.add(100,5);
		rlm.add(1000);

		CHECK( doctest::Approx( rlm.compute_n50(1550) ) == 1000);

		rlm.add(1010);
		CHECK( doctest::Approx( rlm.compute_n50(2560) ) == 1000);
	}

	SUBCASE("median_by_hash")
	{
		CHECK( doctest::Approx( rlm.median_by_hash(0) ) == 0);

		rlm.add(10,5);
		rlm.add(100,5);
		rlm.add(1000);

		CHECK( doctest::Approx( rlm.median_by_hash(11) ) == 100);

		rlm.add(1010,9);
		CHECK( doctest::Approx( rlm.median_by_hash(20) ) == 550);
	}

	SUBCASE("Read write")
	{
		rlm.add(10,5);
		rlm.add(100,5);
		rlm.add(1000);
		rlm.add(1010,9);
		rlm.add(1000000);

		std::filesystem::path p("test_rlm.txt");
		rlm.write(p);

		ReadsLengthMap rlm2;
		rlm2.read(p);

		CHECK( rlm.getMap() == rlm2.getMap() );
	}
}

#endif
