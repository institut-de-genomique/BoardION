#ifndef TIME_STEP_STAT_H
#define TIME_STEP_STAT_H
#pragma once

#include <filesystem>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>

#include <doctest/doctest.h>

#include "myUtil.hpp"

class TimeStepStat
{
public:
	uint_fast64_t nb_bases;
	uint_fast32_t nb_reads;
	float speed;
	float quality;

	TimeStepStat();
	void add(const uint_fast64_t& nb_bases, const float& speed, const float& quality);
	void add(const TimeStepStat& time_step_stat);
	void subtract(const TimeStepStat& time_step_stat);
	void clear();
	uint_fast16_t read(const std::filesystem::path& input_path);
	friend std::ostream& operator<<(std::ostream& os, const TimeStepStat& tss);
};

TEST_CASE("TimeStepStat")
{
	TimeStepStat tss;

	SUBCASE("add read 1 by 1")
	{
		tss.add( 1203, 302.2163, 7.5469 );
		tss.add( 20, 3.5, 0.2 );

		CHECK( tss.nb_reads == 2 );
		CHECK( tss.nb_bases == 1223 );
		CHECK( doctest::Approx(tss.speed)   == 305.7163 );
		CHECK( doctest::Approx(tss.quality) == 7.7469 );
	}

	SUBCASE("add a TimeStepStat object")
	{
		tss.add( 1000, 300, 7 );

		TimeStepStat tss2;
		tss2.add( 1203, 302.2163, 7.5469 );
		tss2.add( 20, 3.5, 0.2 );

		tss.add(tss2);

		CHECK( tss.nb_reads == 3 );
		CHECK( tss.nb_bases == 2223 );
		CHECK( doctest::Approx(tss.speed)   == 605.7163 );
		CHECK( doctest::Approx(tss.quality) == 14.7469 );
	}

	SUBCASE("subtract a TimeStepStat object")
	{
		tss.add( 1000, 300, 7 );
		tss.add( 1203, 302.2163, 7.5469 );
		tss.add( 20, 3.5, 0.2 );

		TimeStepStat tss2;
		tss2.add( 1203, 302.2163, 7.5469 );
		tss2.add( 20, 3.5, 0.2 );

		tss.subtract(tss2);

		CHECK( tss.nb_reads == 1 );
		CHECK( tss.nb_bases == 1000 );
		CHECK( doctest::Approx(tss.speed)   == 300.0 );
		CHECK( doctest::Approx(tss.quality) == 7.0 );
	}

	SUBCASE("clear")
	{
		tss.add( 1000, 300, 7 );
		tss.add( 1203, 302.2163, 7.5469 );
		tss.add( 20, 3.5, 0.2 );

		tss.clear();

		CHECK( tss.nb_reads == 0 );
		CHECK( tss.nb_bases == 0 );
		CHECK( doctest::Approx(tss.speed)   == 0.0 );
		CHECK( doctest::Approx(tss.quality) == 0.0 );
	}

	SUBCASE("Read write") // todo test if output file is complet after the read (the read delete last line)
	{
		tss.add( 1000, 300, 7 );
		tss.add( 1203, 302.2163, 7.5469 );
		tss.add( 20, 3.5, 0.2 );

		std::filesystem::path p ("test_tss.txt");
		std::ofstream os(p);
		os << "RunID Duration(mn) Yield(b) #Reads Speed(b/mn) Quality Average(b) N50 Median(b)\n";
		os << "RunID 60 " << tss << " 50 50"; // n50 and median
		os.close();

		TimeStepStat tss2;
		int duration = tss2.read(p);

		std::stringstream ss1,ss2;
		ss1 << tss;
		ss2 << tss2;

		CHECK( ss1.str() == ss2.str() );
		CHECK( duration == 60 );
	}
}
#endif
