# (C) Copyright 1988- ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

# Source me to get the correct configure/build/run environment

# Store tracing and disable (module is *way* too verbose)
{ tracing_=${-//[^x]/}; set +x; } 2>/dev/null

module load amd-staging
module load cmake/3.27.4

export HDF5_DIR=/PATH/TO/HDF5_BUILT_WITH_AMD_STAGING/
if [[ ! -d $HDF5_DIR ]]; then
    echo "You must set the HDF5 directory to one built with amd-staging"
    echo "You must also set the paths to the amd-staging compiler correctly"
    exit
fi

export HDF5_ROOT=$HDF5_DIR
export LD_LIBRARY_PATH=${HDF5_DIR}/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=${HDF5_DIR}/lib:$LIBRARY_PATH
export C_INCLUDE_PATH=${HDF5_DIR}/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=${HDF5_DIR}/include:$CPLUS_INCLUDE_PATH
export CPATH=${HDF5_DIR}/include:$CPATH
export INCLUDE=${HDF5_DIR}/include:$INCLUDE
export PATH=${HDF5_DIR}/bin:$PATH


# Specify compilers
export CC=amdclang CXX=amdclang++ FC=amdflang

module list

set -x

# Restore tracing to stored setting
{ if [[ -n "$tracing_" ]]; then set -x; else set +x; fi } 2>/dev/null

export ECBUILD_TOOLCHAIN="./toolchain.cmake"
