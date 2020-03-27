#ifndef READ_H
#define READ_H
#pragma once

#include <doctest/doctest.h>

class Read
{
public:
	unsigned int channel;
	float start_time;
	float duration;
	float template_start;
	float template_duration;
	unsigned long int length;
	float mean_q_score;
	float speed;

	void set(unsigned int channel, float start_time, float duration, float template_start, float template_duration, unsigned long int length, float mean_q_score);

};
#endif
