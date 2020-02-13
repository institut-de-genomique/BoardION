cmake_minimum_required( VERSION 2.8 )

project( promethion_reporting )

# set gcc and g++ compiler
set( CMAKE_C_COMPILER gcc )
set( CMAKE_CXX_COMPILER g++ )

# specify the C++ standard
set( CMAKE_CXX_STANDARD 17 )
set( CMAKE_CXX_STANDARD_REQUIRED True )

# add compile options
set( CMAKE_CXX_FLAGS "-O3 -std=c++17 -Wall -static-libgcc -static-libstdc++" ) # static compilation

INCLUDE_DIRECTORIES( "${PROJECT_BINARY_DIR}" )
INCLUDE_DIRECTORIES( ./include )
INCLUDE_DIRECTORIES( ./src )

set( SRCS
     src/channel_stat.cpp
     src/myUtil.cpp
     src/qt_stat.cpp
     src/reads_length_map_stat.cpp
     src/runInfoStat.cpp
     src/time_step_stat.cpp
   )

set( HEADERS
     src/channel_stat.hpp
     src/myUtil.hpp
     src/qt_stat.hpp
     src/reads_length_map_stat.hpp
     src/runInfoStat.hpp
     src/time_step_stat.hpp
   )

set( TCLAP
     include/tclap/ArgException.h
     include/tclap/Arg.h
     include/tclap/ArgTraits.h
     include/tclap/CmdLine.h
     include/tclap/CmdLineInterface.h
     include/tclap/CmdLineOutput.h
     include/tclap/Constraint.h
     include/tclap/DocBookOutput.h
     include/tclap/HelpVisitor.h
     include/tclap/IgnoreRestVisitor.h
     include/tclap/MultiArg.h
     include/tclap/MultiSwitchArg.h
     include/tclap/OptionalUnlabeledTracker.h
     include/tclap/sstream.h
     include/tclap/StandardTraits.h
     include/tclap/StdOutput.h
     include/tclap/SwitchArg.h
     include/tclap/UnlabeledMultiArg.h
     include/tclap/UnlabeledValueArg.h
     include/tclap/ValueArg.h
     include/tclap/ValuesConstraint.h
     include/tclap/VersionVisitor.h
     include/tclap/Visitor.h
     include/tclap/XorHandler.h
     include/tclap/ZshCompletionOutput.h
   )

set( DOCTEST
     include/doctest/doctest.h
   )

# Executable for test
#enable_testing()
#add_executable( boardion_preprocess_test ${DOCTEST} ${SRCS} ${HEADERS} test/test.cpp )
#target_link_libraries( boardion_preprocess_test stdc++fs ${BOARDION_PREPROCESS_LIB} )
#add_test( NAME testBoardionPreprocess COMMAND boardion_preprocess_test )

# Executable
add_executable( boardion_preprocess ${TCLAP} ${DOCTEST} ${SRCS} ${HEADERS} src/main.cpp )
target_link_libraries( boardion_preprocess stdc++fs ${BOARDION_PREPROCESS_LIB} )
set_target_properties( boardion_preprocess PROPERTIES COMPILE_FLAGS "-DDOCTEST_CONFIG_DISABLE" )

INSTALL( TARGETS boardion_preprocess DESTINATION .)
