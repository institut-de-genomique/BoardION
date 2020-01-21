#include "reads_length_map_stat.hpp"

void ReadsLengthMap::add(const ReadsLengthMap& reads_length_map)
{
	for(auto iter : reads_length_map.data)
	{
        this->data[iter.first] += iter.second;
	}
}

void ReadsLengthMap::add(const uint_fast32_t& length)
{
    this->data[length]++;
}

void ReadsLengthMap::add(const uint_fast32_t& length, const uint_fast32_t& count)
{
    this->data[length]+=count;
}

void ReadsLengthMap::subtract(const ReadsLengthMap& reads_length_map)
{
	for(auto iter : reads_length_map.data)
	{
        this->data[iter.first] -= iter.second;
	}
}

uint_fast32_t ReadsLengthMap::compute_n50(const uint_fast64_t& nb_bases)
{
	if(nb_bases == 0)
	{
		return(0);
	}
	
	long int length = 0;
	long int sum_length = 0;
	const float middle = float(nb_bases)/2;
	
	while(sum_length<middle)
	{
		++length;
        
		if(this->data.count(length) > 0)
		{
			sum_length+=this->data[length]*length;
		}
	}
	return(length);
}

float ReadsLengthMap::median_by_hash(const uint_fast32_t& nb_reads)
{
	if(nb_reads == 0)
	{
		return(0);
	}
	
	long int length = 0;
	int count = 0;
	float middle = float(nb_reads)/2;
	
	while(count<middle)
	{
		++length;
		if(this->data.count(length) > 0)
		{
			count+=this->data[length];
		}
	}
	
	if(nb_reads%2 == 0) // The median is the mean of the 2 middle items
	{
		if(count==middle) // if false the 2 middle items are equal, if true, search the next item in the hash and compute the mean
		{
			long int next_item_in_hash = length+1;
			while(this->data.count(next_item_in_hash) == 0)
			{
				++next_item_in_hash;
			}
			return(static_cast<float>(length + next_item_in_hash)/2);
		}
	}
    return(static_cast<float>(length));
}

void ReadsLengthMap::write(const fs::path& output_path)
{
	std::ofstream file(output_path);
	file << "LENGTH COUNT\n";
	
	if(this->data.empty())
	{
		return;
	}
	
	for(auto &it : this->data)
	{
		file << it.first << ' ' << it.second << '\n';
	}
	file.close();
}

void ReadsLengthMap::read(const std::filesystem::path& input_path)
{
	std::ifstream input(input_path);
	unsigned long int length = 0, count = 0;
	std::string header;
	std::getline(input,header);

	while(input >> length >> count)
	{
		this->add(length, count);
	}
}

void ReadsLengthMap::clear()
{
    this->data.clear();
}

uint_fast32_t ReadsLengthMap::at(const uint_fast32_t& l)
{
	return(this->data.at(l));
}

std::unordered_map<uint_fast32_t,uint_fast32_t> ReadsLengthMap::getMap()
{
	return(this->data);
}

std::ostream& operator<<(std::ostream& os, const ReadsLengthMap& rlm)
{
	for(auto &it : rlm.data)
	{
		os << it.first << ' ' << it.second << '\n';
	}
	return(os);
}
