#include "time_step_stat.hpp"

TimeStepStat::TimeStepStat()
{
	this->nb_bases = 0;
	this->nb_reads = 0;
	this->speed = 0;
	this->quality = 0;
}

void TimeStepStat::add(const uint_fast64_t& nb_bases, const float& speed, const float& quality)
{
	this->nb_reads++;
	this->nb_bases += nb_bases;
	this->speed += speed;
	this->quality += quality;
}

void TimeStepStat::add(Read r)
{
	this->nb_reads++;
	this->nb_bases += r.length;
	this->speed += r.speed;
	this->quality += r.mean_q_score;
}

void TimeStepStat::add(const TimeStepStat& time_step_stat)
{
	this->nb_reads += time_step_stat.nb_reads;
	this->nb_bases += time_step_stat.nb_bases;
	this->speed += time_step_stat.speed;
	this->quality += time_step_stat.quality;
}

void TimeStepStat::subtract(const TimeStepStat& time_step_stat)
{
	this->nb_reads -= time_step_stat.nb_reads;
	this->nb_bases -= time_step_stat.nb_bases;
	this->speed -= time_step_stat.speed;
	this->quality -= time_step_stat.quality;
}

void TimeStepStat::clear()
{
	this->nb_bases = 0;
	this->nb_reads = 0;
	this->speed = 0;
	this->quality = 0;
}

uint_fast16_t TimeStepStat::read(const std::filesystem::path& input_path)
{
	std::ifstream input(input_path);
	std::string header, line;
	std::getline(input,header);

	std::vector<std::string> lines;

	while(std::getline(input,line))
	{
		lines.emplace_back(line);
	}
	input.close();

	auto field = splitString(lines.back(),' ');
	uint_fast16_t duration = std::stoul(field[1]);
	this->nb_bases = std::stoul(field[2]);
	this->nb_reads = std::stoul(field[3]);
	this->speed = std::stof(field[4]) * this->nb_reads;
	this->quality = std::stof(field[5]) * this->nb_reads;

	lines.pop_back();

	std::ofstream output (input_path);
	output << header << '\n';
	for(auto &it : lines)
	{
		output << it << '\n';
	}
	output.close();

	return(duration);
}

std::ostream& operator<<(std::ostream& os, const TimeStepStat& tss)
{
	if(tss.nb_reads == 0)
	{
		os << "0 0 0 0 0";
	}
	else
	{
//		std::cout << tss.speed << ' ' << tss.quality << ' ' << tss.nb_bases << ' ' << tss.nb_reads << '\n';
//      std::cout << tss.speed / tss.nb_reads << ' ' << tss.quality / tss.nb_reads << ' ' << tss.nb_bases << ' ' << tss.nb_reads << "\n\n";

		os << std::setprecision(6) << tss.nb_bases << ' ' <<
				tss.nb_reads << ' ' <<
				tss.speed / tss.nb_reads << ' ' <<
				tss.quality / tss.nb_reads << ' ' <<
				tss.nb_bases / tss.nb_reads;
	}
	return(os);
}
