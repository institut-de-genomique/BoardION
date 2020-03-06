#include "qt_stat.hpp"

Bin::Bin()
{
	this->count = 0;
	this->read_length = 0;
	this->start_time = 0;
	this->duration = 0;
	this->template_duration = 0;
	this->speed = 0;
}

void Bin::add(const uint_fast32_t& read_length, const float& start_time, const float& duration, const float& template_duration, const float& speed)
{
	this->count++;
	this->read_length += read_length;
	this->start_time += start_time;
	this->duration += duration;
	this->template_duration += template_duration;
	this->speed += speed;
}

void Bin::add(const uint_fast32_t& count, const uint_fast32_t& read_length, const float& start_time, const float& duration, const float& template_duration, const float& speed)
{
	this->count += count;
	this->read_length += read_length * count;
	this->start_time += start_time * count;
	this->duration += duration * count;
	this->template_duration += template_duration * count;
	this->speed += speed * count;
}

std::ostream& operator<<(std::ostream& os, const Bin& b)
{
	os << b.count << ' ' <<
		b.start_time / b.count << ' ' <<
		b.duration  / b.count << ' ' <<
		b.template_duration / b.count << ' ' <<
		b.read_length / b.count << ' ' <<
		b.speed / b.count;
	return(os);
}

QTStat::QTStat()
{
	this->data.resize(200); // initialise matrix second dimension (can contain quality up to 20 with bin of 0.1)
	for (auto &itI : this->data)
	{
		itI.resize(450); // initialise matrix first dimension (can contain 4500 min with bin of 10 min)
		for (auto& itJ : itI)
		{
			itJ = Bin();
		}
	}
}

void QTStat::resizeStat1stDim(const uint_fast16_t& max_quality_idx)
{
	int old_quality_idx = this->data.size();
	this->data.resize(max_quality_idx);
	for(uint_fast16_t i=old_quality_idx; i<max_quality_idx; ++i)
	{
		for( auto &it : this->data[i])
		{
			it = Bin();
		}
	}
}

void QTStat::resizeStat2ndDim(const uint_fast16_t& quality_idx, const uint_fast16_t& max_time_idx)
{
	int old_time_idx = this->data.size();
	this->data[quality_idx].resize(max_time_idx);
	for(uint_fast16_t j=old_time_idx; j<max_time_idx; j++)
	{
		this->data[quality_idx][j] = Bin();
	}
}

void QTStat::add(const float& quality, const float& time, const uint_fast32_t& read_length, const float& start_time, const float& duration, const float& template_duration, const float& speed)
{
	unsigned int quality_idx = binValue(quality,10.0); // bin quality every 0.1
	unsigned int time_idx = binValue(time/60.0,0.1); // convert starttime from seconde to minute and bin it every 10 min
	
	if(quality_idx>this->data.size())
	{
		this->resizeStat1stDim(quality_idx+1);
	}
	
	if(time_idx>this->data[quality_idx].size())
	{
		this->resizeStat2ndDim(quality_idx,time_idx+1);
	}
	
	this->data[quality_idx][time_idx].add(read_length,start_time,duration,template_duration, speed);
}

void QTStat::add(const float& quality, const float& time, const uint_fast32_t& count, const uint_fast32_t& reads_length, const float& start_time, const float& duration, const float& template_duration, const float& speed)
{
	unsigned int quality_idx = binValue(quality, 10.0); // bin quality every 0.1
	unsigned int time_idx = binValue(time, 0.1); // bin time every 10 min

	if(quality_idx>this->data.size())
	{
		this->resizeStat1stDim(quality_idx+1);
	}

	if(time_idx+1>this->data[quality_idx].size())
	{
		this->resizeStat2ndDim(quality_idx,time_idx+1);
	}

	this->data[quality_idx][time_idx].add(count, reads_length,start_time,duration,template_duration, speed);
}

void QTStat::write(const std::filesystem::path& output_path)
{
	std::ofstream file(output_path);
	file << "Quality TemplateStart #Reads StartTime Duration TemplateDuration Length Speed\n";
	
	int quality_idx = 0;
	for (auto &iTI : this->data)
	{
		float quality = float(quality_idx)/10;
		int time_idx = 0;
		for (auto& iTJ : iTI)
		{
			if(iTJ.count>0)
			{
				int time = time_idx*10;
				file << quality << ' ' << time << ' ' << iTJ << '\n';
			}
			++time_idx;
		}
		++quality_idx;
	}
}

void QTStat::read(const std::filesystem::path& input_path)
{
	std::ifstream input(input_path);
	std::string header;
	std::getline(input,header);

	float quality, start_time, duration, template_duration, speed;
	unsigned long int nb_reads, reads_length;
	unsigned int template_start;

	while(input >> quality >> template_start >> nb_reads >> start_time >> duration >> template_duration >> reads_length >> speed)
	{
		this->add(quality, template_start, nb_reads, reads_length, start_time, duration, template_duration, speed);
	}
	input.close();
}

Bin& QTStat::at(const uint_fast16_t& quality_idx, const uint_fast16_t& time_idx)
{
	return(this->data[quality_idx][time_idx]);
}

std::size_t QTStat::size1stDim()
{
	return(this->data.size());
}

std::size_t QTStat::size2stDim(const uint_fast16_t& quality_idx)
{
	return(this->data.at(quality_idx).size());
}
