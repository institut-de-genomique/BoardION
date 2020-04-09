#include "sequencing_summary.hpp"

SequencingSummary::SequencingSummary(fs::path &filePath)
{
	this->filePath = filePath;
	this->ifs = std::ifstream(filePath);
	this->setColumnIndex();
}

void SequencingSummary::setColumnIndex()
{
	std::string header;
	std::getline( this->ifs, header);
	std::vector<std::string> columnName = splitString( header, '\t');

	unsigned int i = 0;
	for(auto &it : columnName)
	{
		if( it.compare("channel") == 0 )
		{
			this->channelIdx = i;
		}
	       	else if ( it.compare("start_time") == 0)
		{
			this->startTimeIdx = i;
		}
		else if ( it.compare("duration") == 0)
		{
			this->durationIdx = i;
		}
		else if ( it.compare("template_start") == 0)
		{
			this->templateStartIdx = i;
		}
		else if ( it.compare("template_duration") == 0) 
		{
			this->templateDurationIdx = i;
		}
		else if ( it.compare("sequence_length_template") == 0)
		{
			this->readLengthIdx = i;
		}
		else if ( it.compare("mean_qscore_template") == 0)
		{
			this->meanQScoreIdx = i;
		}
	
		++i;
	}
}

bool SequencingSummary::readLine(Read &r, unsigned int &line_length)
{
	std::string line;
	if(std::getline( this->ifs, line))
	{
		line_length = line.length();
		std::vector<std::string> fields = splitString( line, '\t');
	
		r.set(
			std::stoi(fields[this->channelIdx]),
			std::stof(fields[this->startTimeIdx]),
			std::stof(fields[this->durationIdx]),
			std::stof(fields[this->templateStartIdx]),
			std::stof(fields[this->templateDurationIdx]),
			std::stoul(fields[this->readLengthIdx]),
			std::stof(fields[this->meanQScoreIdx])
		);;
		return(true);
	}
	return(false);
}

/*
Create a short run id from the second line of a sequencing_summary.txt file.
The id is {flowcell name}_{first 8 chars from run_id}
*/
bool SequencingSummary::getShortRunId ( fs::path filePath, std::string &id )
{
	std::string line, fastq_name, fast5_name, read_id, run_id;
	std::stringstream s;
	std::regex r( R"((\w{3}\d{5,})_)" );
	std::smatch m;

	std::ifstream f ( filePath );

	std::getline ( f, line ); // header
	std::getline ( f, line );

	s << line;
	s >> fastq_name >> fast5_name >> read_id >> run_id;

	if( std::regex_search( fastq_name, m, r) )
	{
		std::stringstream s2;
		s2 << m.str(1) << "_" << run_id.substr(0,8);
		id = s2.str();
		return(true);
	}
	else
	{
		std::cerr << "regex to get flowcell id doesn't match on first field of second line in file " << filePath << std::endl;
		return(false);
	}
}

bool SequencingSummary::isSequencingSummary ( fs::path &file )
{
	if( file.extension().compare(".txt") == 0 )
	{
		if( file.filename().string().find("sequencing_summary") != std::string::npos )
		{
			return(true);
		}
	}
	return(false);
}

