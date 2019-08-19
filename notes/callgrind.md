# Callgrind

How to profile using Valgrind in ROS

## roslaunch

    <!-- Valgrind Arguments -->
    <arg name="valgrind" default="false" />
    <arg unless="$(arg valgrind)" name="launch_prefix2" value="" />
    <arg     if="$(arg valgrind)" name="launch_prefix2" value="valgrind --tool=callgrind --collect-atstart=no" />

In your <node>

    launch-prefix="$(arg launch_prefix) $(arg launch_prefix2)"

## C++

```
// Profiling
#include <valgrind/callgrind.h>


CALLGRIND_TOGGLE_COLLECT;
functionToProfile();
CALLGRIND_TOGGLE_COLLECT;
CALLGRIND_DUMP_STATS;
```

## Post-processing

```
cd ~/.ros
ll callgrind*
c++filt < callgrind.out.12003.1 > callgrind.out.12003.1.demangled
kcachegrind callgrind.out.12003.1.demangled
```
