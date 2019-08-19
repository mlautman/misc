# Boost Notes

## Casting a Shared Ptr

    my_shared_ptr = boost::dynamic_pointer_cast<ompl::tools::Bolt>(experience_setup_);

## Get the system boost version

    cat /usr/include/boost/version.hpp | grep BOOST_LIB_VERSION
