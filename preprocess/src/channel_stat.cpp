#include "channel_stat.hpp"

Channel::Channel()
{
	this->nb_reads = 0;
	this->start_time = 0;
	this->duration = 0;
	this->template_start = 0;
	this->template_duration = 0;
	this->reads_length = 0;
	this->mean_q_score = 0;
	this->speed = 0;
}

// no test for division by 0 (nb_reads == 0)
std::ostream& operator<<(std::ostream& os, const Channel& c)
{
	os << c.nb_reads << ' ' <<
			c.start_time / c.nb_reads << ' ' <<
			c.duration / c.nb_reads << ' ' <<
			c.template_start / c.nb_reads << ' ' <<
			c.template_duration / c.nb_reads << ' ' <<
			(float)c.reads_length / (float)c.nb_reads << ' ' <<
			c.mean_q_score / c.nb_reads << ' ' <<
			c.speed / c.nb_reads;
	return(os);
}

ChannelsStat::ChannelsStat()
{
	for(auto &it : this->data)
	{
		it = Channel();
	}
}

void ChannelsStat::add(const uint_fast16_t& channel, const float& start_time, const float& duration, const float& template_start, const float& template_duration, const uint_fast32_t& reads_length, const float& mean_q_score, const float& speed)
{
	this->data[channel].nb_reads++;
	this->data[channel].start_time += start_time;
	this->data[channel].duration += duration;
	this->data[channel].template_start += template_start;
	this->data[channel].template_duration += template_duration;
	this->data[channel].reads_length += reads_length;
	this->data[channel].mean_q_score += mean_q_score;
	this->data[channel].speed += speed;
}

void ChannelsStat::add(Read r)
{
	this->data[r.channel].nb_reads++;
	this->data[r.channel].start_time        += r.start_time;
	this->data[r.channel].duration          += r.duration;
	this->data[r.channel].template_start    += r.template_start;
	this->data[r.channel].template_duration += r.template_duration;
	this->data[r.channel].reads_length      += r.length;
	this->data[r.channel].mean_q_score      += r.mean_q_score;
	this->data[r.channel].speed             += r.speed;
}

void ChannelsStat::add(const uint_fast16_t& channel, const uint_fast32_t& nb_reads, const float& start_time, const float& duration, const float& template_start, const float& template_duration, const uint_fast32_t& reads_length, const float& mean_q_score, const float& speed)
{
	this->data[channel].nb_reads += nb_reads;
	this->data[channel].start_time += start_time * nb_reads;
	this->data[channel].duration += duration * nb_reads;
	this->data[channel].template_start += template_start * nb_reads;
	this->data[channel].template_duration += template_duration * nb_reads;
	this->data[channel].reads_length += reads_length * nb_reads;
	this->data[channel].mean_q_score += mean_q_score * nb_reads;
	this->data[channel].speed += speed * nb_reads;
}

void ChannelsStat::write(const std::filesystem::path& output_path)
{
	std::ofstream file(output_path);
	file << "Channel #Reads StartTime Duration TemplateStart TemplateDuration Length MeanQScore Speed\n";
	for(std::size_t channel=0; channel<this->data.size(); ++channel)
	{
		if(this->data[channel].nb_reads != 0)
		{
			file << channel << ' ' << this->data[channel] << "\n";
		}
	}
}

void ChannelsStat::read(const std::filesystem::path& input_path)
{
	std::ifstream input(input_path);
	std::string header;
	std::getline(input,header);

	unsigned int channel = 0;
	unsigned long int nb_reads = 0;
	double start_time = 0, duration = 0, template_start = 0, template_duration = 0, reads_length = 0, mean_q_score = 0;
	float speed = 0;

	while(input >> channel >> nb_reads >> start_time >> duration >> template_start >> template_duration >> reads_length >> mean_q_score >> speed)
	{
		this->add(channel, nb_reads, start_time, duration, template_start, template_duration, reads_length, mean_q_score, speed);
	}
	input.close();
}

Channel& ChannelsStat::at(const uint_fast16_t& idx)
{
	return(this->data.at(idx));
}
