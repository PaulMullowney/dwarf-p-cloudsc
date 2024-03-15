#!/bin/bash -l
#
for i in "$@"; do
    case "$1" in
        -r=*|--ranks=*)
            ranks="${i#*=}"
            shift # past argument=value
            ;;
        -rocm=*|--rocm=*)
            rocm="${i#*=}"
            shift # past argument=value
            ;;
        -cce=*|--cce=*)
            cce="${i#*=}"
            shift # past argument=value
            ;;
        -arch=*|--arch=*)
            arch="${i#*=}"
            shift # past argument=value
            ;;
        -machine=*|--machine=*)
            machine="${i#*=}"
            shift # past argument=value
            ;;
        -build_dir=*|--build_dir=*)
            build_dir="${i#*=}"
            shift # past argument=value
            ;;
        -hip|--hip)
            enable_hip=YES
            shift # past argument=value
            ;;
        -use_ecbundle|--use_ecbundle)
            use_ecbundle=YES
            shift # past argument=value
            ;;
        --)
            shift
            break
            ;;
    esac
done

module purge
module load PrgEnv-cray
export PATH=/home/users/pmullown/software/cmake-3.24.2/bin:$PATH
which cmake

if [[ $cce == "17.0.1" ]]
then
    module load cpe/24.03
    export ROCM_PATH=/opt/rocm-6.0.2/
    #module load rocm/${rocm}
elif [[ $cce == "17.0.0" ]]
then
    module load cpe/23.12
    module load rocm/${rocm}
elif [[ $cce == "16.0.1" ]]
then
    module load cpe/23.09
	 module load rocm/${rocm}
elif [[ $cce == "16.0.0" ]]
then
    module load cpe/23.05
    module load rocm/${rocm}
else
    export MODULEPATH=/opt/cray/pe/lmod/modulefiles/mpi/crayclang/14.0/ofi/1.0/cray-mpich/8.0:/opt/cray/pe/lmod/modulefiles/comnet/crayclang/14.0/ofi/1.0:/opt/cray/pe/lmod/modulefiles/compiler/crayclang/14.0:/opt/cray/pe/lmod/modulefiles/mix_compilers:/opt/cray/pe/lmod/modulefiles/perftools/23.05.0:/opt/cray/pe/lmod/modulefiles/net/ofi/1.0:/opt/cray/pe/lmod/modulefiles/cpu/x86-rome/1.0:/opt/cray/pe/modulefiles/Linux:/opt/cray/pe/modulefiles/Core:/opt/cray/pe/lmod/lmod/modulefiles/Core:/opt/cray/pe/lmod/modulefiles/core:/opt/cray/pe/lmod/modulefiles/craype-targets/default:/opt/cray/modulefiles:/opt/cray/pe/lmod/modulefiles/comnet/crayclang/10.0/ofi/1.0/cray-mpich
    module load cpe/23.03
    module load amd/5.4.3
    module load cce/15.0.1
    export ROCM_PATH=/opt/rocm-5.4.3/
    export GCC_X86_64=/opt/cray/pe/gcc/12.2.0/snos
fi
module load craype-accel-amd-${arch}
module list

export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}

if [[ $enable_hip ]];
then
    if [[ $use_ecbundle ]];
    then
	./cloudsc-bundle build --clean --cmake="GPU_TARGETS=${arch} OpenMP_C_LIB_NAMES=craymp OpenMP_CXX_LIB_NAMES=craymp OpenMP_Fortran_LIB_NAMES=craymp OpenMP_craymp_LIBRARY=/opt/cray/pe/cce/${cce}/cce/x86_64/lib/libcraymp.so OpenMP_C_FLAGS=-fopenmp OpenMP_CXX_FLAGS=-fopenmp OpenMP_Fortran_FLAGS='-homp -hlist=aimd' BUILD_serialbox=ON ENABLE_SERIALBOX=ON ENABLE_HDF5=OFF ENABLE_CLOUDSC_HIP=ON" --arch arch/${machine}/cray-gpu/${cce} --build-dir=${build_dir}_${cce} --with-gpu -j=${ranks}
    else
	# HIP build requires one to turn off HDF5 and build SerialBox (this requires boost)
	mkdir ${build_dir}_${cce}
	cd ${build_dir}_${cce}
	ln -s ../arch/${machine}/cray-gpu/${cce}/env.sh env.sh
	ln -s ../arch/${machine}/cray-gpu/${cce}/toolchain.cmake toolchain.cmake
	source env.sh
	export CC=cc CXX=CC FC=ftn
	cmake ../source -DCMAKE_C_COMPILER=cc -DCMAKE_CXX_COMPILER=CC -DCMAKE_Fortran_COMPILER=ftn -DCMAKE_BUILD_TYPE=BIT -DCMAKE_INSTALL_PREFIX=../install -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake -DENABLE_CLOUDSC_GPU_OMP_SCC_HOIST=ON -DENABLE_CLOUDSC_GPU_OMP_SCC_HOIST_DR_LOOP=ON -DGPU_TARGETS=${arch} -DOpenMP_C_LIB_NAMES=craymp -DOpenMP_CXX_LIB_NAMES=craymp -DOpenMP_Fortran_LIB_NAMES=craymp -DOpenMP_craymp_LIBRARY=/opt/cray/pe/cce/${cce}/cce/x86_64/lib/libcraymp.so -DOpenMP_C_FLAGS=-fopenmp -DOpenMP_CXX_FLAGS=-fopenmp '-DOpenMP_Fortran_FLAGS=-homp -hlist=aimd' -DBUILD_serialbox=ON -DENABLE_SERIALBOX=ON -DENABLE_HDF5=OFF -DENABLE_CLOUDSC_HIP=ON
	make VERBOSE=1 -j${ranks}
	cd ..
	#-DCMAKE_HIP_ARCHITECTURES=${arch} 
    fi
else
    
    if [[ $use_ecbundle ]];
    then
	./cloudsc-bundle build --clean --cmake="OpenMP_C_LIB_NAMES=craymp OpenMP_CXX_LIB_NAMES=craymp OpenMP_Fortran_LIB_NAMES=craymp OpenMP_craymp_LIBRARY=/opt/cray/pe/cce/${cce}/cce/x86_64/lib/libcraymp.so OpenMP_C_FLAGS=-fopenmp OpenMP_CXX_FLAGS=-fopenmp OpenMP_Fortran_FLAGS='-homp -hlist=aimd'" --arch arch/${machine}/cray-gpu/${cce} --build-dir=${build_dir}_${cce} -j=${ranks}
	
    else
	mkdir ${build_dir}_${cce}
	cd ${build_dir}_${cce}
	ln -s ../arch/${machine}/cray-gpu/${cce}/env.sh env.sh
	ln -s ../arch/${machine}/cray-gpu/${cce}/toolchain.cmake toolchain.cmake
	source env.sh
	export CC=cc CXX=CC FC=ftn
	cmake ../source -DCMAKE_C_COMPILER=cc -DCMAKE_CXX_COMPILER=CC -DCMAKE_Fortran_COMPILER=ftn -DCMAKE_BUILD_TYPE=BIT -DCMAKE_INSTALL_PREFIX=../install -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake -DENABLE_CLOUDSC_GPU_OMP_SCC_HOIST=ON -DENABLE_CLOUDSC_GPU_OMP_SCC_HOIST_DR_LOOP=ON -DOpenMP_C_LIB_NAMES=craymp -DOpenMP_CXX_LIB_NAMES=craymp -DOpenMP_Fortran_LIB_NAMES=craymp -DOpenMP_craymp_LIBRARY=/opt/cray/pe/cce/${cce}/cce/x86_64/lib/libcraymp.so -DOpenMP_C_FLAGS=-fopenmp -DOpenMP_CXX_FLAGS=-fopenmp '-DOpenMP_Fortran_FLAGS=-homp -hlist=aimd' -DENABLE_CLOUDSC_HIP=OFF
	make -j${ranks}
	cd ..
    fi
fi
