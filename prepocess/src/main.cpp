#include <string>
#include <filesystem>
#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <unordered_map>
#include <iterator>
#include <thread> // for sleep_for
#include <iomanip>
#include <ctime>
#include <regex>

#include <tclap/CmdLine.h>

#include "qt_stat.hpp"
#include "runInfoStat.hpp"
#include "channel_stat.hpp"
#include "reads_length_map_stat.hpp"
#include "time_step_stat.hpp"

namespace fs = std::filesystem;

/*
TODO:
	mettre les header des fichiers de sortie en attributs des classes
	qtstat: faire que le bin du temps depend du temps d'un step
*/

fs::path getProgramTag(fs::path out_directory, fs::path program_base_name)
{
	fs::path path = out_directory / program_base_name;
	path += ".inprocess";
	return(path);
}

void createProgramTag(fs::path program_tag_path)
{
	if(fs::exists(program_tag_path))
	{
		std::cerr << "ERROR: File tag found " << program_tag_path << ": older execution of the program in process or not correctly ended" << std::endl;
		exit(1);
	}
	std::ofstream file(program_tag_path);
}

fs::path getRunTagFile(fs::path input_directory, std::string flowcell)
{
	fs::path path = input_directory / fs::path(flowcell);
	path += ".inprocess";
	return(path);
}

bool createRunTag(fs::path run_tag_path)
{
	using namespace std::chrono_literals; // for sleep_for

	int count = 0;
	const int max_count = 5;
	while(count<max_count && fs::exists(run_tag_path))
	{
		std::this_thread::sleep_for(1s);
		++count;
	}

	if(fs::exists(run_tag_path))
	{
		std::cerr << "WARNING: tag " << run_tag_path << " found for more than " << max_count*10/60 << " min" << std::endl;;
		return(0);
	} else
	{
		std::ofstream file(run_tag_path);
		return(1);
	}
}

fs::path getRunInfoPath(fs::path out_directory)
{
	fs::path path = out_directory / fs::path("run_infostat.txt");
	return(path);
}

fs::path getRunInfoTmpPath(fs::path run_info_path)
{
	run_info_path += ".tmp";
	return(run_info_path);
}

bool isSequencingSummary ( fs::path &file )
{
	std::string name = file.filename().string();
	if( file.extension().compare(".txt") == 0 )
	{
		if( name.find("sequencing_summary") != std::string::npos )
		{
			return(true);
		}
	}
	return(false);
}

bool getRunIdFromFileName ( fs::path &file, std::regex &r, std::string &id )
{
	std::string name = file.filename().string();
	std::smatch m;

	if( std::regex_search( name, m, r) )
	{
		if( m.size() == 2 )
		{
			id = m.str(1);
			return(true);
		}
		else
		{
			std::cerr << "regex match more than once on the file " << name << std::endl;
			return(false);
		}
	}
	else
	{
		std::cerr << "regex doesn't match on file " << name << std::endl;
		return(false);
	}
}

bool getRunIdFromSequencingSummary ( fs::path &file, std::string &id )
{
	std::string line, fastq_name, fast5_name, read_id, run_id;
	std::stringstream s;
	std::regex r(R"((PA\w\d{5,})_)");
	std::smatch m;

	std::ifstream f (file);
	
	std::getline(f, line);
	std::getline(f, line);

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
		std::cerr << "regex to get flowcell id doesn't match on first field of second line in file " << file << std::endl;
		return(false);
	}
}

void parseLine(std::string &line, std::ifstream &sequencing_summary,unsigned int &channel, float &start_time, float &duration, float &template_start, float &template_duration, unsigned long int &read_length, float &mean_q_score, float &read_speed)
{
//	std::cout << line << std::endl;
	std::vector<std::string> line_field = splitString(line, '\t');

	channel           = std::stoi(line_field[4]);
	start_time        = std::stof(line_field[6]);
	duration          = std::stof(line_field[7]);
	template_start    = std::stof(line_field[10]);
	template_duration = std::stof(line_field[12]);
	read_length       = std::stoul(line_field[13]);
	mean_q_score      = std::stof(line_field[14]);
	read_speed        = read_length / duration;
}

float stepStartTime(int const step_duration, int const step_number)
{
	return(step_duration * step_number / 60);
}

void completStepReadLength(std::ifstream &sequencing_summary, ReadsLengthMap &step_reads_length, const std::streampos  last_read_position)
{
	std::string line;
	unsigned long int read_length = 0;

	while(sequencing_summary.tellg() < last_read_position && getline(sequencing_summary, line))
	{
		std::vector<std::string> line_field = splitString(line, '\t');
		read_length = std::stoul(line_field[13]);
		step_reads_length.add(read_length);
	}
}

bool stringHasEnding (std::string const &fullString, std::string const &ending)
{
    if (fullString.length() >= ending.length()) {
        return (0 == fullString.compare (fullString.length() - ending.length(), ending.length(), ending));
    } else {
        return false;
    }
}

const std::string getRunStart(float timeSinceStart)
{
	auto time_epoch = std::time(nullptr); // time since epoch
	time_epoch = time_epoch - timeSinceStart; // time since epoch at the start of the run

    auto gmT = std::gmtime(&time_epoch);
    auto oss = std::ostringstream();

    oss << 1900 + gmT->tm_year << '-' << std::setfill('0') << std::setw(2) << gmT->tm_mon + 1 << '-' << std::setfill('0') << std::setw(2) << gmT->tm_mday << 'T' << std::setfill('0') << std::setw(2) << gmT->tm_hour << ':' << std::setfill('0') << std::setw(2) << gmT->tm_min << ':' << std::setfill('0') << std::setw(2) << gmT->tm_sec << "+00:00";
    return oss.str();
}

int main(int argc, char** argv)
{
	fs::path program_base_name = fs::path(argv[0]).stem();

	fs::path input_directory = "", output_directory = "";
	std::string user_runId = "";
	unsigned int step_duration = 600;
	std::regex regex_user_runId;
	bool getIdFromFileName = false;
	bool user_give_runId = false;

 	try
	{
		auto desc =
		"This program generates statistics files from sequencing_summary.txt files.\n"
		"It creates and uses the file run_infostat.txt that contains one line per run processed. This file contains global statistics on each run and also marks completed run that no longer need to be processed.\n"
		"For each sequencing_summary file it produces 5 files prefixed with the flowcell name:\n"
		"\t- _channel_stat.txt:   statistics per channel\n"
		"\t- _A_currentstat.txt:  bins read by --step-duration minutes and makes statistics independently on each bin (bin 20 independent from bin 10)\n"
		"\t- _A_globalstat.txt:   bins read by --step-duration minutes and makes cumulative statistics on each bin (bin 20 contain bin 10)\n"
		"\t- _A_quality_stat.txt: statistics binned by quality and time\n"
		"\t- _A_readsLength.txt:  count of reads per length\n";

		TCLAP::CmdLine cmd(desc, ' ', "0.1");

		TCLAP::ValueArg<std::string> argInputDir ("i", "in", "Directory containing sequencing_summary.txt files to process", true, "", "DIRECTORY");
		TCLAP::ValueArg<std::string> argOutputDir("o", "out", "Path to the output directory", true, "", "DIRECTORY");
		TCLAP::ValueArg<std::string> argRunId("r", "runId", "Run id to monitor. If not present, monitor all runs", false, "", "RUN ID");
		TCLAP::ValueArg<int> argDuration("d", "step-duration", "Duration between stats points in seconds", false, 600, "DURATION");
		TCLAP::ValueArg<std::string> argRegex("R", "regex", "Regular expression to get uniq run id from sequencing summary file name. If not present, run id is the concatenation of the flowcell id and the first 8 characters of the run_id field of the sequencing summary", false, "", "REGEX");

		cmd.add( argInputDir );
		cmd.add( argOutputDir );
		cmd.add( argRunId );
		cmd.add( argDuration );
		cmd.add( argRegex );

		cmd.parse( argc, argv );

		input_directory = fs::path(argInputDir.getValue());
		output_directory = fs::path(argOutputDir.getValue());
		user_runId = argRunId.getValue();
		step_duration = argDuration.getValue();
		
		if( !argRunId.getValue().empty() )
		{
			user_runId = argRunId.getValue();
			user_give_runId = true;
		}
		
		if( !argRegex.getValue().empty() )
		{
			regex_user_runId.assign(argRegex.getValue());
			getIdFromFileName = true;
		}

	} catch (TCLAP::ArgException &e) {// catch any exceptions
		std::cerr << "error: " << e.error() << " for arg " << e.argId() << std::endl;
	}

	// empty file that show the program is running
	const auto program_tag_path = getProgramTag(output_directory,program_base_name);
	createProgramTag(program_tag_path);

	// file containing one line per run
	const auto run_info_path = getRunInfoPath(output_directory);
	RunsInfoStat runs_info = RunsInfoStat();
	runs_info.parseFile(run_info_path);

	// temporary run info file that will replace the old one at the end of the program
	const auto run_info_tmp_path = getRunInfoTmpPath(run_info_path);
	runs_info.createFile(run_info_tmp_path);

	std::vector<fs::path> summary_files;

	// TODO
	// If the user define a flowcell, then only process the corresponding sequencing_summary file
	if( user_give_runId )
	{

		bool file_found = false;
		for(auto& it: fs::directory_iterator(input_directory))
		{
			fs::path file_path = it.path();
			if( file_path.filename().string().find(user_runId) != std::string::npos )
			{
				if( file_found )
				{
		                        std::cerr << "ERROR at least two files name contain the run id " << user_runId << " in the input directory(" << input_directory << ")" << std::endl;
					exit(1);
				}
				summary_files.emplace_back( file_path );
				runs_info.writeAllBut1( run_info_tmp_path, user_runId );
			}
		}
		if( !file_found )
		{
			std::cerr << "ERROR run id " << user_runId << " can't be found in " << input_directory << std::endl;
			exit(1);
		}
	}
	// else find all sequencing_summary in the input directory
	else
	{
		for(auto& it: fs::directory_iterator(input_directory))
		{
			fs::path file_path = it.path();
			if( isSequencingSummary(file_path) )
			{
				summary_files.emplace_back(file_path);
			}
		}
	}

	for(auto &input_file : summary_files)
	{ 
		std::string processed_runId;

		if( user_give_runId )
		{
			processed_runId = user_runId;
		}
		else
		{
			bool res = false;
			if( getIdFromFileName )
			{
				res = getRunIdFromFileName( input_file, regex_user_runId, processed_runId );
			}
			else
			{
				res = getRunIdFromSequencingSummary( input_file, processed_runId );
			}

			if( !res )
			{
				continue;
			}
		}

		// initialize the run object
		if(runs_info.runs.count(processed_runId) == 0)
		{
			runs_info.runs[processed_runId].flowcell = processed_runId;
			runs_info.runs[processed_runId].start_time = "NA";
			runs_info.runs[processed_runId].ended = "NO";
		}

		auto run = runs_info.runs[processed_runId];

		// empty file that show which flowcell is currently processed
		const auto run_tag_path = getRunTagFile(input_directory,processed_runId);

		if ( run.ended.compare("NO") == 0 )
		{
			if ( createRunTag(run_tag_path) )
			{
				// Files path
				const fs::path prefix_path = output_directory / processed_runId;


				// name of final summary is the same as the sequencing summary but 'sequencing' is 'final'
				std::string sequencing_summary_name = input_file.filename().string();
				auto pos = sequencing_summary_name.find("sequencing_summary");
				auto finale_summary_path = input_directory;
				finale_summary_path += '/';
				finale_summary_path += sequencing_summary_name.replace(pos, std::string("sequencing").length(), "final");

				auto global_stat_path = prefix_path;
				global_stat_path += "_globalstat.txt";

				auto current_stat_path = prefix_path;
				current_stat_path += "_currentstat.txt";

				auto reads_length_path = prefix_path;
				reads_length_path += "_readsLength.txt";

				auto channel_stat_path = prefix_path;
				channel_stat_path += "_channel_stat.txt";

				auto qt_stat_path = prefix_path;
				qt_stat_path += "_quality_stat.txt";

				run.isFinish(finale_summary_path);

				// cumulative statistics on all step
				TimeStepStat cumulative_step_stat;
				ReadsLengthMap reads_length;
				ChannelsStat channels_stat;

				// statistics separated by step (a step = <argDuration> secondes)
				TimeStepStat current_step_stat;
				ReadsLengthMap step_reads_length;
				QTStat qt_stat;

				unsigned int step_number = 1;
				float max_time = 0;

				// TimeStepStat output files
				std::ofstream global_stat;
				std::ofstream current_stat;

				// open input file
				std::ifstream sequencing_summary(input_file);

				// if part of the input is already processed during a previous execution, load the result of the previous execution
				if( run.lastReadPosition > 0 )
				{
					unsigned int previous_duration = cumulative_step_stat.read(global_stat_path);
					step_number = previous_duration * 60 / step_duration;

					current_step_stat.read(current_stat_path);
					reads_length.read(reads_length_path);
					channels_stat.read(channel_stat_path);
					qt_stat.read(qt_stat_path);

					global_stat = std::ofstream(global_stat_path, std::ofstream::app);
					current_stat = std::ofstream(current_stat_path, std::ofstream::app);

					// need to read the whole last step for step_n50 and step_median
					if( run.lastStepStartPosition == 0 )
					{
						// read header line
						std::string header;
						std::getline(sequencing_summary, header);
					}
					else
					{
						sequencing_summary.seekg(run.lastStepStartPosition);
					}

					completStepReadLength(sequencing_summary, step_reads_length, run.lastReadPosition);

					cumulative_step_stat.subtract(current_step_stat); // when a step end current_step_stat is added to cumulative_step_stat, but part of current_step_stat was already added in the precedent execution.
					reads_length.subtract(step_reads_length);
				}
				else
				{
					global_stat = std::ofstream(global_stat_path);
					current_stat = std::ofstream(current_stat_path);

					// Files headers
					global_stat << "FLOWCELL DURATION(mn) YIELD(b) #READS SPEED(b/mn) QUALITY AVG(b) N50 MED(b)\n";
					current_stat << "FLOWCELL DURATION(mn) YIELD(b) #READS SPEED(b/mn) QUALITY AVG(b) N50 MED(b)\n";

					// read header line
					std::string header;
					std::getline(sequencing_summary, header);
				}

				//
				std::streampos stepStartPosition = run.lastStepStartPosition;

				// value searched in the input file
				unsigned int channel;
				unsigned long int read_length;
				float start_time, mean_q_score, duration, template_start, template_duration, read_speed;

				if(sequencing_summary.tellg() != -1)
				{
					std::string line;
					while(std::getline(sequencing_summary, line))
					{
						parseLine(line, sequencing_summary, channel, start_time, duration, template_start, template_duration, read_length, mean_q_score, read_speed);

						max_time = std::max(max_time, start_time+duration);
						if (max_time > step_duration * step_number)
						{
							cumulative_step_stat.add(current_step_stat);
							reads_length.add(step_reads_length);

							int n50 = reads_length.compute_n50(cumulative_step_stat.nb_bases);
							int step_n50 = step_reads_length.compute_n50(current_step_stat.nb_bases);
							float median = reads_length.median_by_hash(cumulative_step_stat.nb_reads);
							float step_median = step_reads_length.median_by_hash(current_step_stat.nb_reads);

							while(max_time > step_duration * step_number) // if true the last line read is in a new step
							{
								global_stat  << processed_runId << ' ' <<
										std::fixed << std::setprecision(0) << stepStartTime(step_duration, step_number) << ' ' <<
										cumulative_step_stat << ' ' <<
										n50 << ' ' <<
										std::fixed << std::setprecision(0) << median << '\n';

								current_stat << processed_runId << ' ' <<
										std::fixed << std::setprecision(0) << stepStartTime(step_duration, step_number) << ' ' <<
										current_step_stat << ' ' <<
										step_n50 << ' ' <<
										std::fixed << std::setprecision(0) << step_median << '\n';

								++step_number;
								current_step_stat.clear();
								step_n50 = 0;
								step_median = 0;
							}
							current_step_stat.clear();
							step_reads_length.clear();

							stepStartPosition = sequencing_summary.tellg() - std::streamoff(line.length()) - std::streamoff(1); // get the start of the new step, (actual position minus the length of the last line read, -1 for the '\n' )
						}

						channels_stat.add(channel, start_time, duration, template_start, template_duration, read_length, mean_q_score, read_speed);
						qt_stat.add(mean_q_score, template_start, read_length, start_time, duration, template_duration, read_speed);
						current_step_stat.add(read_length, read_speed, mean_q_score);
						step_reads_length.add(read_length);
					}
				}

				// set start time the run based on the current date and duration of the run (only if the run isn't finished)
				if ( run.ended.compare("NO") == 0 )
				{
					run.start_time = getRunStart(start_time + duration);
				}

				cumulative_step_stat.add(current_step_stat);
				reads_length.add(step_reads_length);

				int n50 = reads_length.compute_n50(cumulative_step_stat.nb_bases);
				int step_n50 = step_reads_length.compute_n50(current_step_stat.nb_bases);
				float median = reads_length.median_by_hash(cumulative_step_stat.nb_reads);
				float step_median = step_reads_length.median_by_hash(current_step_stat.nb_reads);


				global_stat << processed_runId << ' ' <<
						std::fixed << std::setprecision(0) << stepStartTime(step_duration, step_number) << ' ' <<
						cumulative_step_stat << ' ' <<
						n50 << ' ' <<
						std::fixed << std::setprecision(0) << median << '\n';

				current_stat << processed_runId << ' ' <<
						std::fixed << std::setprecision(0) << stepStartTime(step_duration, step_number) << ' ' <<
						current_step_stat << ' ' <<
						step_n50 << ' ' <<
						std::setprecision(0) << step_median << '\n';

				reads_length.write(reads_length_path);
				channels_stat.write(channel_stat_path);
				qt_stat.write(qt_stat_path);

				run.duration       = stepStartTime(step_duration, step_number);
				run.yield          = cumulative_step_stat.nb_bases;
				run.nb_reads       = cumulative_step_stat.nb_reads;
				run.speed          = cumulative_step_stat.speed/cumulative_step_stat.nb_reads;
				run.quality        = cumulative_step_stat.quality/cumulative_step_stat.nb_reads;
				run.average_length = cumulative_step_stat.nb_bases/cumulative_step_stat.nb_reads;
				run.n50            = n50;
				run.median         = median;

				run.lastReadPosition = fs::file_size(input_file);
				run.lastStepStartPosition = stepStartPosition;

				std::ofstream out( run_info_tmp_path, std::ofstream::app);
				out << run;
				out.close();

				fs::remove(run_tag_path);
			}
		}
	}
	fs::rename(run_info_tmp_path,run_info_path);
	fs::remove(program_tag_path);
}

