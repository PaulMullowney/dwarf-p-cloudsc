# (C) Copyright 1988- ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

# Source me to get the correct configure/build/run environment

# NB: This does currently not support the Serialbox-based build modes
#     because the available Boost module does not include the boost_filesystem library

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

# Load modules
module load cmake/3.24.2
module load python/3.10.14
module load boost
module list

hpctk_ver=24.9
hpcdr_ver=12.6

NVHPC_CUDA_HOME=/opt/nvidia/hpc_sdk
TARGET=Linux_x86_64
VERSION=${hpctk_ver}
DRIVER_VER=${hpcdr_ver}
OMP_VER=openmpi4

CUDA_DIR=${NVHPC_CUDA_HOME}/${TARGET}/${VERSION}/cuda
nvcompdir=${NVHPC_CUDA_HOME}/${TARGET}/${VERSION}/compilers
nvmathdir=${NVHPC_CUDA_HOME}/${TARGET}/${VERSION}/math_libs
nvcommdir=${NVHPC_CUDA_HOME}/${TARGET}/${VERSION}/comm_libs/${DRIVER_VER}
nvompidir=${nvcommdir}/${OMP_VER}

export NVHPC=${NVHPC_CUDA_HOME}
export NVHPC_CMAKE=${NVHPC_CUDA_HOME}/${TARGET}/${VERSION}/cmake

export OPAL_PREFIX=${nvcommdir}/hpcx/latest/ompi
# export OPAL_PREFIX=$nvcommdir/openmpi4/openmpi-4.0.5
export PATH=${nvcompdir}/bin:${PATH}
export PATH=${CUDA_DIR}/bin:${PATH}
export PATH=${OPAL_PREFIX}/bin:${PATH}

export LD_LIBRARY_PATH=${nvcompdir}/lib/:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${CUDA_DIR}/lib64/:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${nvmathdir}/lib64/:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${OPAL_PREFIX}/lib/:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${nvcommdir}/nccl/lib/:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${nvcommdir}/nvshmem/lib:${LD_LIBRARY_PATH}

export LIBRARY_PATH=${nvcompdir}/lib/:${LIBRARY_PATH}
export LIBRARY_PATH=${CUDA_DIR}/lib64/:${LIBRARY_PATH}
export LIBRARY_PATH=${nvmathdir}/lib64/:${LIBRARY_PATH}
export LIBRARY_PATH=${OPAL_PREFIX}/lib/:${LIBRARY_PATH}
export LIBRARY_PATH=${nvcommdir}/nccl/lib/:${LIBRARY_PATH}
export LIBRARY_PATH=${nvcommdir}/nvshmem/lib:${LIBRARY_PATH}

# export NVHPC_CUDA_HOME=${CUDA_DIR}
export FFTW3_ROOT=${HOME}/workspace/FFT/FFTW3_INS
export C_INCLUDE_PATH=${CUDA_DIR}/include:${C_INCLUDE_PATH}
export C_INCLUDE_PATH=${nvmathdir}/include:${C_INCLUDE_PATH}

export CPLUS_INCLUDE_PATH=${CUDA_DIR}/include:${CPLUS_INCLUDE_PATH}
export CPLUS_INCLUDE_PATH=${nvmathdir}/include:${CPLUS_INCLUDE_PATH}

export CPATH=${CUDA_DIR}/include:${CPATH}
export CPATH=${nvmathdir}/include:${CPATH}

export INCLUDE=${CUDA_DIR}/include:${INCLUDE}
export INCLUDE=${nvmathdir}/include:${INCLUDE}


export CC=${nvcompdir}/bin/nvc
export CXX=${nvcompdir}/bin/nvc++
export FC=${nvcompdir}/bin/nvfortran
export F90=${nvcompdir}/bin/nvfortran
export F77=${nvcompdir}/bin/nvfortran

which $FC
$FC --version


# Increase stack size to maximum
ulimit -S -s unlimited

set -x

# Restore tracing to stored setting
{ if [[ -n "$tracing_" ]]; then set -x; else set +x; fi } 2>/dev/null

# Variable no longer required, make sure it is not set
unset ECBUILD_TOOLCHAIN
