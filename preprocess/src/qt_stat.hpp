#ifndef QT_STAT_H 
#define QT_STAT_H
#pragma once

#include <filesystem>
#include <iostream>
#include <fstream>
#include <iomanip>

#include <doctest/doctest.h>

#include "read.hpp"
#include "myUtil.hpp"

/*
 * Store statistics for a bin
 */
class Bin
{
public:
	uint_fast32_t count; // number of read in the bin
	uint_fast64_t read_length;
	float start_time;
	float duration;
	float template_duration;
	float speed;
	
	Bin();
	void add(const uint_fast32_t& read_length, const float& start_time, const float& duration, const float& template_duration, const float& speed);
	void add(Read r);
	void add(const uint_fast32_t& count, const uint_fast32_t& read_length, const float& start_time, const float& duration, const float& template_duration, const float& speed);
	friend std::ostream& operator<<(std::ostream& os, const Bin& b);
};

/*
 * Compute statistic on reads group by quality and sequencing start time
 */
class QTStat
{
public:
	QTStat();
	void add(const float& quality, const float& time, const uint_fast32_t& read_length, const float& start_time, const float& duration, const float& template_duration, const float& speed);
	void add(Read r);
	void add(const float& quality_idx, const float& time_idx, const uint_fast32_t& count, const uint_fast32_t& reads_length, const float& start_time, const float& duration, const float& template_duration, const float& speed);
	void bin(const float& quality, const float& time, unsigned int& quality_idx, unsigned int& time_idx);
	void resizeStat1stDim(const uint_fast16_t& max_quality_idx);
	void resizeStat2ndDim(const uint_fast16_t& quality_idx, const uint_fast16_t& max_time_idx);
	void write(const std::filesystem::path& output_path); // write this->stat
	void read(const std::filesystem::path& input_path);
	Bin& at(const uint_fast16_t& quality_idx, const uint_fast16_t& time_idx);
	std::size_t size1stDim();
	std::size_t size2stDim(const uint_fast16_t& quality_idx);
	
private:
	std::vector<std::vector<Bin>> data; // matrix of Bin
};

TEST_CASE("Bin")
{
	Bin b;

	SUBCASE("Constructor")
	{
		CHECK( b.count              == 0 );
		CHECK( b.read_length        == 0 );
		CHECK( b.start_time         == 0 );
		CHECK( b.duration           == 0 );
		CHECK( b.template_duration  == 0 );
		CHECK( b.speed              == 0 );
	}

	SUBCASE("Add read 1 at time")
	{
		b.add( 1000, 200.59, 2.36, 2.36, 301.54);
		b.add( 1000, 200.59, 2.36, 2.36, 301.54);

		CHECK( b.count                              == 2 );
		CHECK( b.read_length                        == 2000 );
		CHECK( doctest::Approx(b.start_time)        == 401.18);
		CHECK( doctest::Approx(b.duration)          == 4.72 );
		CHECK( doctest::Approx(b.template_duration) == 4.72 );
		CHECK( doctest::Approx(b.speed)             == 603.08 );
	}

	SUBCASE("Add 2 reads at time")
	{
		b.add( 2, 1000, 200.59, 2.36, 2.36, 301.54);

		CHECK( b.count                              == 2 );
		CHECK( b.read_length                        == 2000 );
		CHECK( doctest::Approx(b.start_time)        == 401.18);
		CHECK( doctest::Approx(b.duration)          == 4.72 );
		CHECK( doctest::Approx(b.template_duration) == 4.72 );
		CHECK( doctest::Approx(b.speed)             == 603.08 );
	}

	SUBCASE("Operator<<")
	{
		b.add( 1000, 200.591, 2.361, 2.365, 301.548);

		std::stringstream ss;
		ss << b;

		CHECK(ss.str() == "1 200.591 2.361 2.365 1000 301.548");
	}
}

TEST_CASE("QTStat")
{
	QTStat qt;

	SUBCASE("resize 1st dim")
	{
		int size = qt.size1stDim();
		qt.resizeStat1stDim(220);

		CHECK(qt.size1stDim() != size );
		CHECK(qt.size1stDim() == 220 );
	}

	SUBCASE("resize 1st dim")
	{
		int size = qt.size2stDim(1);
		qt.resizeStat2ndDim( 1, 500 );

		CHECK(qt.size2stDim(1) != size );
		CHECK(qt.size2stDim(1) == 500 );
	}

	SUBCASE("add read 1 by 1")
	{
		qt.add(7.168042, 1206.977500, 222, 6.732000, 0.837500, 0.592000, 265.075);
		qt.add(7.172516, 1206.706000, 409, 6.706000, 1.540500, 1.540500, 265.498);
		qt.add(7.732130, 607.108250, 388, 7.108250, 1.354750, 1.354750, 286.4  );
		qt.add(7.775364, 607.071000, 395, 6.902500, 1.333500, 1.165000, 296.213);

		CHECK( qt.at(72,2).count       == 2);
		CHECK( qt.at(72,2).read_length == 631);
		CHECK( doctest::Approx( qt.at(72,2).start_time )        == 13.438);
		CHECK( doctest::Approx( qt.at(72,2).duration )          == 2.378);
		CHECK( doctest::Approx( qt.at(72,2).template_duration ) == 2.1325);
		CHECK( doctest::Approx( qt.at(72,2).speed )             == 530.573);

		CHECK( qt.at(77,1).count       == 1);
		CHECK( qt.at(77,1).read_length == 388);
		CHECK( doctest::Approx( qt.at(77,1).start_time )        == 7.108250);
		CHECK( doctest::Approx( qt.at(77,1).duration )          == 1.354750);
		CHECK( doctest::Approx( qt.at(77,1).template_duration ) == 1.354750);
		CHECK( doctest::Approx( qt.at(77,1).speed )             == 286.4);

		CHECK( qt.at(78,1).count       == 1);
		CHECK( qt.at(78,1).read_length == 395);
		CHECK( doctest::Approx( qt.at(78,1).start_time )        == 6.902500);
		CHECK( doctest::Approx( qt.at(78,1).duration )          == 1.333500);
		CHECK( doctest::Approx( qt.at(78,1).template_duration ) == 1.165000);
		CHECK( doctest::Approx( qt.at(78,1).speed )             == 296.213);

	}

	SUBCASE("add read by group")
	{
		qt.add(7.2135, 20.054, 100, 222, 6.732000, 0.837500, 0.592000, 265.075);

		CHECK( qt.at(72,2).count       == 100);
		CHECK( qt.at(72,2).read_length == 22200);
		CHECK( doctest::Approx( qt.at(72,2).start_time )        == 673.2000);
		CHECK( doctest::Approx( qt.at(72,2).duration )          == 083.7500);
		CHECK( doctest::Approx( qt.at(72,2).template_duration ) == 059.2000);
		CHECK( doctest::Approx( qt.at(72,2).speed )             == 26507.5);
	}

	SUBCASE("Read write")
	{
		qt.add(7.168042, 1206.977500, 222, 6.732000, 0.837500, 0.592000, 265.075);
		qt.add(7.172516, 1206.706000, 409, 6.706000, 1.540500, 1.540500, 265.498);
		qt.add(7.732130, 607.108250, 388, 7.108250, 1.354750, 1.354750, 286.4  );
		qt.add(7.775364, 607.071000, 395, 6.902500, 1.333500, 1.165000, 296.213);
		qt.write(std::filesystem::path("test_qt.txt"));

		QTStat qt2;
		qt2.read(std::filesystem::path("test_qt.txt"));

		std::stringstream ss1,ss2;
		for(std::size_t i=0; i<qt.size1stDim(); i++)
		{
			for(std::size_t j=0; j<qt.size2stDim(i); j++)
			{
				if(qt.at(i,j).count>0)
				{
					ss1 << i << ' ' << j << ' ' << qt.at(i,j) << "\n";
				}
			}
		}

		for(std::size_t i=0; i<qt2.size1stDim(); i++)
		{
			for(std::size_t j=0; j<qt2.size2stDim(i); j++)
			{
				if(qt2.at(i,j).count>0)
				{
					ss2 << i << ' ' << j << ' ' << 	qt2.at(i,j) << "\n";
				}
			}
		}

		CHECK(ss1.str() == ss2.str());
	}
}
#endif
