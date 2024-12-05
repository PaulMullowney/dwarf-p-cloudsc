# (C) Copyright 1988- ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

####################################################################
# COMPILER
####################################################################

set( ECBUILD_FIND_MPI OFF )
set( ENABLE_USE_STMT_FUNC ON CACHE STRING "" )

####################################################################
# OpenMP FLAGS
####################################################################

set( OpenMP_Fortran_FLAGS   "${OpenMP_Fortran_FLAGS} -O3 -ffast-math -mtune=native -fopenmp --offload-arch=gfx942 --save-temps" CACHE STRING "" )
set(ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -O3 -ffast-math -mtune=native -fopenmp --offload-arch=gfx942 --save-temps")

if(NOT DEFINED CMAKE_HIP_ARCHITECTURES)
  set(CMAKE_HIP_ARCHITECTURES gfx942)
endif()

set( HAVE_OMP_TARGET_LOOP_CONSTRUCT_BIND_PARALLEL OFF CACHE BOOL "" )
set( HAVE_OMP_TARGET_LOOP_CONSTRUCT_BIND_THREAD OFF CACHE BOOL "" )
