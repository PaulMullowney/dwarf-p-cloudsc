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

module_load() {
  echo "+ module load $1"
  module load $1
}
module_unload() {
  echo "+ module unload $1"
  module unload $1
}

# Unload to be certain
#module reset

# Load modules
module load PrgEnv-cray
#module load cpe/23.03
module load rocm/5.4.3
module load cce/15.0.1
export ROCM_PATH=/opt/rocm-5.4.3/
export GCC_X86_64=/opt/cray/pe/gcc/12.2.0/snos
module load craype-accel-amd-gfx90a
module load cray-hdf5/1.12.2.7
module load boost/1.83.0
module list

set -x

export CC=cc CXX=CC FC=ftn

# Restore tracing to stored setting
{ if [[ -n "$tracing_" ]]; then set -x; else set +x; fi } 2>/dev/null

export ECBUILD_TOOLCHAIN="./toolchain.cmake"
