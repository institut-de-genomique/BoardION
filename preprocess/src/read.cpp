#include "read.hpp"

void Read::set(unsigned int channel, float start_time, float duration, float template_start, float template_duration, unsigned long int length, float mean_q_score)
{
	this->channel = channel;
	this->start_time = start_time;
	this->duration = duration;
	this->template_start = template_start;
	this->template_duration = template_duration;
	this->length = length;
	this->mean_q_score = mean_q_score;
	this->speed = length / duration;
}
