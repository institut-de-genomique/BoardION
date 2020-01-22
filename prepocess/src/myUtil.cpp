#include "myUtil.hpp"

std::vector<std::string> splitString (const std::string &s, const char delim) {

	std::vector<std::string> result;
	std::stringstream ss (s);
	std::string item;

	while (ss.good()) {
		std::getline (ss, item, delim);
		result.emplace_back (item);
	}

	return result;
}

std::string joinString(std::vector<std::string> v, const char * delim)
{
	std::ostringstream joined;
	std::copy(v.begin(), v.end(), std::ostream_iterator<std::string>(joined, delim));
	std::string s = joined.str();

	if(delim[0] != '\0') {
		s.pop_back();
	}
	return(s);
}
