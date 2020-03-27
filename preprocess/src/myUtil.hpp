#ifndef MY_UTIL_H
#define MY_UTIL_H
#pragma once

#include <cmath>
#include <string>
#include <sstream>
#include <vector>
#include <iterator>

#include <doctest/doctest.h>

std::vector<std::string> splitString (const std::string &s, const char delim);
std::string joinString(std::vector<std::string> v, const char * delim);
inline int binValue(float value, float factor)
{
	return(int(round(value*factor)));
}

TEST_CASE("Split string")
{
	std::string s = "Hello world!";

	SUBCASE("Split by 'z'")
	{
		auto v = splitString(s,'z');
		CHECK(v.size() == 1);
		CHECK(v[0] == s);
	}

	SUBCASE("Split by ' '")
	{
		auto v = splitString(s,' ');
		CHECK(v.size() == 2);
		CHECK(v[0] == "Hello");
		CHECK(v[1] == "world!");
	}

	SUBCASE("Split by 'o'")
	{
		auto v = splitString(s,'o');
		CHECK(v.size() == 3);
		CHECK(v[0] == "Hell");
		CHECK(v[1] == " w");
		CHECK(v[2] == "rld!");
	}

	SUBCASE("Split by 'l'")
	{
		auto v = splitString(s,'l');
		CHECK(v.size() == 4);
		CHECK(v[0] == "He");
		CHECK(v[1] == "");
		CHECK(v[2] == "o wor");
		CHECK(v[3] == "d!");
	}
}

TEST_CASE("Join string")
{
	std::vector<std::string> v{ "Hello", "world", "!"};

	SUBCASE("Join on ''")
	{
		auto s = joinString(v,"");
		CHECK(s == "Helloworld!");
	}
	SUBCASE("Join on ' '")
	{
		auto s = joinString(v," ");
		CHECK(s == "Hello world !");
	}
	SUBCASE("Join on ' foo '")
	{
		auto s = joinString(v," foo ");
		CHECK(s != "Hello foo world foo !");
	}
}

TEST_CASE("binValue")
{
	CHECK( binValue(5.4354, 100) == 544 );
	CHECK( binValue(1.2648, 100) == 126 );
	CHECK( binValue(12345, 0.01) == 123 );
	CHECK( binValue(100,0.01)    == 1 );
	CHECK( binValue(101,0.01)    == 1 );
	CHECK( binValue(39,0.02)     == 1 );
	CHECK( binValue(121,0.02)    == 2 );
	CHECK( binValue(61,0.02)     == 1 );
}

#endif
