# Catkin

Using ROS Catkin Workspaces

## VCSTool

This is a handy tool for managing multiple git repos at once:

### See which repos have uncommitted changes

    vcs status

### See what branch each repo is on

    vcs branch

### Pull all changes from origin

    vcs pull

### Delete all local branches that are not on remote (is this true?)

    vcs custom --args remote prune origin

## Catkin ---------------------------------------------------

### Build catkin with roslint

Copy CMakeLists.txt example in ``rviz_visual_tools``, then:

    catkin bot --make-args roslint

### Build catkin with tests

Run test for just 1 package

    catkin run_tests --no-deps --this -iv

Run test for all packages

    catkin run_tests -iv

Run test for 1 package, old catkin_make version

    catkin_make run_tests_control_toolbox
    #catkin_make run_tests_packageName_gtest_testTarget
    catkin_test_results

## Optional compile Flags for CATKIN

Before the build section (include_directories section) add:

    set(ROS_COMPILE_FLAGS "-W -Wall -Wno-unused-parameter -fno-strict-aliasing")

Or during build time

    catkin build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Catkin Tools - Build A Workspace With Different Debug/Release Levels

    catkin profile add debug
	catkin profile set debug
	catkin config -b build_debug
	catkin config -d devel_debug
	catkin build -DCMAKE_BUILD_TYPE=Debug
	# OR
	catkin build -DCMAKE_BUILD_TYPE=Release

# Catkin Tools - build a specific workspace

    catkin build --profile default

# Catkin Verbose

    VERBOSE=1 catkin bot -v -p 1
