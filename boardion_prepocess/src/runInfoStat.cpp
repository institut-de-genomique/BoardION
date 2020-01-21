#include "runInfoStat.hpp"

RunInfoStat::RunInfoStat()
{
	this->flowcell       = "";
	this->start_time     = "";
	this->ended          = "NO";
	this->duration       = 0;
	this->yield          = 0;
	this->nb_reads       = 0;
	this->speed          = 0;
	this->quality        = 0;
	this->n50            = 0;
	this->average_length = 0;
	this->median         = 0;

	this->lastReadPosition = 0;
	this->lastStepStartPosition = 0;
}

bool RunInfoStat::isFinish(const fs::path& file_path)
{
	if(fs::exists(file_path))
	{
		std::ifstream file(file_path);
		if (!file.is_open())
		{
			std::cout << "failed to open " << file_path << '\n';
		}
		
		this->start_time = "NA";

		std::string line;
		while(std::getline(file,line))
		{
			if(line.compare("")!=0)
			{
				std::vector<std::string> line_field = splitString(line,'=');
				if(line_field[0].compare("started")==0)
				{
					if(line_field[1].compare("") != 0)
					{
						this->start_time = line_field[1];
					}
				}
			}
		}
		this->ended = "YES";
		return(1);
	} else {
		return(0);
	}
}

std::ostream& operator<<(std::ostream& os, const RunInfoStat& run)
{
	os << run.flowcell << ' ' <<
		run.start_time << ' ' <<
		run.ended << ' ' <<
		run.duration << ' ' <<
		run.yield << ' ' <<
		run.nb_reads << ' ' <<
		run.speed << ' ' <<
		run.quality << ' ' <<
		run.average_length << ' ' <<
		run.n50 << ' ' <<
		run.median << ' ' <<
		run.lastReadPosition << ' ' <<
		run.lastStepStartPosition << "\n";
	return(os);
}

void RunsInfoStat::parseFile(const fs::path& run_info_file_path)
{
	if(fs::exists(run_info_file_path))
	{
		std::ifstream file(run_info_file_path);
		if (!file.is_open())
		{
			std::cout << "failed to open " << run_info_file_path << '\n';
		}
		
		std::string header, flowcell;
		std::getline(file,header);

		intmax_t lastReadPosition,lastStepStartPosition;

		while (file >> flowcell)
		{
			auto run = RunInfoStat();
			run.flowcell = flowcell;

			file >> run.start_time >> run.ended >> run.duration >> run.yield >> run.nb_reads >> run.speed >> run.quality >> run.average_length >> run.n50 >> run.median >> lastReadPosition >> lastStepStartPosition;

			run.lastReadPosition = std::streampos(lastReadPosition);
			run.lastStepStartPosition = std::streampos(lastStepStartPosition);

			this->runs[flowcell] = run;
		}
		file.close();
	}
}

void RunsInfoStat::createFile(const fs::path& run_info_path)
{
	std::ofstream file(run_info_path);
	file << "FLOWCELL STARTTIME ENDED DURATION(mn) YIELD(b) #READS SPEED(b/mn) QUALITY AVG(b) N50(b) MED(b) LASTREADPOSITION LASTSTEPSTARTPOSITION\n"; // file header
	
	// write run marked as complete as they will not be processed
	for( auto& n : this->runs )
	{
		if(n.second.ended.compare("YES") == 0)
		{
			file << n.second;
		}
	}
	file.close();
}

void RunsInfoStat::writeAllBut1(const fs::path& file, const std::string& no_write)
{
	std::ofstream out(file,std::ofstream::app);
	for(auto &it : this->runs)
	{
		if(it.second.flowcell.compare(no_write) != 0)
		{
			out << it.second;
		}
	}
	out.close();
}
