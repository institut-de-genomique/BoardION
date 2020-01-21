#ifndef CHANNEL_STAT_H 
#define CHANNEL_STAT_H
#pragma once

#include <filesystem>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>

#include <doctest/doctest.h>

/*
 * Metric on reads sequenced by  a channel
 *
 * nb_reads: number of reads sequenced
 * start_time: reads start time sum
 * duration: reads duration sum
 * template_start: reads template start sum
 * template_duration: reads template duration sum
 * reads_length: reads length sum
 * mean_q_score: reads mean quality score sum
 */
class Channel
{
public:
	uint_fast32_t nb_reads;
	uint_fast64_t reads_length;
	float start_time;
	float duration;
	float template_start;
	float template_duration;
	float mean_q_score;
	float speed;
	
	Channel();
	friend std::ostream& operator<<(std::ostream& os, const Channel& c);
};

/*
 * Store reads statistics per channel
 * Max of 3000 channels (as in the PromethION)
 */
class ChannelsStat
{
public:
	ChannelsStat();
	void add(const uint_fast16_t& channel, const float& start_time, const float& duration, const float& template_start, const float& template_duration, const uint_fast32_t& reads_length, const float& mean_q_score, const float& speed);
	void add(const uint_fast16_t& channel, const uint_fast32_t& nb_reads, const float& start_time, const float& duration, const float& template_start, const float& template_duration, const uint_fast32_t& reads_length, const float& mean_q_score, const float& speed);
	void write(const std::filesystem::path& output_path);
	void read(const std::filesystem::path& input_path);
	Channel& at(const uint_fast16_t& idx);

private:
	std::array<Channel,3000> data;
};


TEST_CASE("Channel")
{
	Channel c = Channel();

	SUBCASE("Constructor")
	{
		CHECK(0 == c.nb_reads);
		CHECK(0 == c.start_time);
		CHECK(0 == c.duration);
		CHECK(0 == c.template_start);
		CHECK(0 == c.template_duration);
		CHECK(0 == c.reads_length);
		CHECK(0 == c.mean_q_score);
		CHECK(0 == c.speed);
	}

	SUBCASE("Operator<<")
	{
		c.nb_reads = 10;
		c.duration = 10.5;
		c.reads_length = 888;
		c.mean_q_score = 999.95;
		c.speed = 14;

		std::stringstream ss;
		ss << c;
		CHECK(ss.str() == "10 0 1.05 0 0 88.8 99.995 1.4");
	}
}

TEST_CASE("ChannelsStat")
{
	ChannelsStat cs;
	REQUIRE(0 == cs.at(2000).nb_reads);

	SUBCASE("Add one read")
	{
		cs.add(2000,100.52, 2.96, 100.52, 2.95, 142321, 7.58, 301.2);

		CHECK( 1                       == cs.at(2000).nb_reads );
		CHECK( doctest::Approx(100.52) == cs.at(2000).start_time );
		CHECK( doctest::Approx(2.96)   == cs.at(2000).duration );
		CHECK( doctest::Approx(100.52) == cs.at(2000).template_start );
		CHECK( doctest::Approx(2.95)   == cs.at(2000).template_duration );
		CHECK( doctest::Approx(142321) == cs.at(2000).reads_length );
		CHECK( doctest::Approx(7.58)   == cs.at(2000).mean_q_score );
		CHECK( doctest::Approx(301.2)  == cs.at(2000).speed );
	}

	SUBCASE("Add multiple reads")
	{
		cs.add(2000, 10, 100.52, 2.96, 100.52, 2.95, 142321, 7.58, 301.2);

		CHECK( 10                       == cs.at(2000).nb_reads );
		CHECK( doctest::Approx(1005.2)  == cs.at(2000).start_time );
		CHECK( doctest::Approx(29.6)    == cs.at(2000).duration );
		CHECK( doctest::Approx(1005.2)  == cs.at(2000).template_start );
		CHECK( doctest::Approx(29.5)    == cs.at(2000).template_duration );
		CHECK( doctest::Approx(1423210) == cs.at(2000).reads_length );
		CHECK( doctest::Approx(75.8)    == cs.at(2000).mean_q_score );
		CHECK( doctest::Approx(3012)    == cs.at(2000).speed );
	}

	SUBCASE("Read write")
	{
		cs.add(2000, 1.15, 1.15, 1.15, 1.15, 100, 1.15, 1.15);
		cs.add(2000, 1.15, 1.15, 1.15, 1.15, 100, 1.15, 1.15);
		cs.add(2999, 1.15, 1.15, 1.15, 1.15, 10000, 1.15, 1.15);
		cs.add(2999, 1.15, 1.15, 1.15, 1.15, 10000, 1.15, 1.15);
		cs.add(2999, 1.15, 1.15, 1.15, 1.15, 10000, 1.15, 1.15);

		cs.write(std::filesystem::path("test_channel.txt"));

		ChannelsStat cs2;
		cs2.read(std::filesystem::path("test_channel.txt"));

		CHECK( 2                     == cs2.at(2000).nb_reads );
		CHECK( doctest::Approx(2.30) == cs2.at(2000).start_time );
		CHECK( doctest::Approx(2.30) == cs2.at(2000).duration );
		CHECK( doctest::Approx(2.30) == cs2.at(2000).template_start );
		CHECK( doctest::Approx(2.30) == cs2.at(2000).template_duration );
		CHECK( doctest::Approx(200)  == cs2.at(2000).reads_length );
		CHECK( doctest::Approx(2.30) == cs2.at(2000).mean_q_score );
		CHECK( doctest::Approx(2.30) == cs2.at(2000).speed );

		CHECK( 3                       == cs2.at(2999).nb_reads );
		CHECK( doctest::Approx(3.45)   == cs2.at(2999).start_time );
		CHECK( doctest::Approx(3.45)   == cs2.at(2999).duration );
		CHECK( doctest::Approx(3.45)   == cs2.at(2999).template_start );
		CHECK( doctest::Approx(3.45)   == cs2.at(2999).template_duration );
		CHECK( doctest::Approx(30000)  == cs2.at(2999).reads_length );
		CHECK( doctest::Approx(3.45)   == cs2.at(2999).mean_q_score );
		CHECK( doctest::Approx(3.45)   == cs2.at(2999).speed );

		std::stringstream ss1,ss2;
		ss1 << cs.at(2000);
		ss2 << cs2.at(2000);
		CHECK(ss1.str() == ss2.str());
	}
}
#endif
