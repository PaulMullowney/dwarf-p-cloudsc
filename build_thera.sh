#!/bin/bash -l
#
afar=
enable_hip=
enable_cuda=
nvhpc=
staging=
serialbox=OFF
sp=OFF
for i in "$@"; do
    echo $i
    case "$1" in
        -hip|--hip)
            enable_hip=YES
            shift # past argument=value
            ;;
        -cuda|--cuda)
            enable_cuda=YES
            shift # past argument=value
            ;;
	-staging|--staging)
   	    staging=YES
	    shift # past argument=value
	    ;;
	-single-precision|--single-precision)
   	    sp=YES
	    shift # past argument=value
	    ;;
	-serialbox|--serialbox)
   	    serialbox=YES
	    shift # past argument=value
	    ;;
        -r=*|--ranks=*)
            ranks="${i#*=}"
            shift # past argument=value
            ;;
        -cce=*|--cce=*)
            cce="${i#*=}"
            shift # past argument=value
            ;;
        -rocm=*|--rocm=*)
            rocm="${i#*=}"
            shift # past argument=value
            ;;
        -nvhpc=*|--nvhpc=*)
            nvhpc="${i#*=}"
            shift # past argument=value
            ;;
	-afar=*|--afar=*)
            afar="${i#*=}"
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
        --)
            shift
            break
            ;;
    esac
done

export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}

if [[ $nvhpc ]];
then
    if [[ $enable_cuda ]];
    then
	bdir=${build_dir}_cuda_${nvhpc}
	./cloudsc-bundle build --clean --build-dir=${bdir} --arch=arch/${machine}/nvhpc/${nvhpc}  -j=${ranks} --cmake="CMAKE_CUDA_ARCHITECTURES=80" --with-serialbox=${serialbox} --with-cuda --without-openmp --with-acc=OFF --with-openmp=OFF --with-single-precision=${sp}
    else
	bdir=${build_dir}_${nvhpc}
	./cloudsc-bundle build --clean --build-dir=${bdir} --arch=arch/${machine}/nvhpc/${nvhpc} -j=${ranks} --with-serialbox=${serialbox} --with-acc=ON --with-openmp=OFF --with-single-precision=${sp}
    fi
else
    if [[ $enable_hip ]];
    then
	echo "Build HIP"
	bdir=${build_dir}_hip_${rocm}
	./cloudsc-bundle build -v --clean --build-dir=${bdir} --arch=arch/${machine}/hip_${rocm} -j=${ranks} --cmake="CMAKE_HIP_ARCHITECTURES=gfx942 CMAKE_EXE_LINKER_FLAGS_INIT=\"-L/share/modules/gcc/11.3.0/lib64 -lgfortran\"" --with-serialbox=${serialbox} --with-hip --with-acc=OFF --with-openmp=OFF --with-single-precision=${sp}
    else
	if [[ $staging ]];
	then	
	    echo "Build Staging"
	    bdir=${build_dir}_amd_staging
	    ./cloudsc-bundle build --clean --build-dir=${bdir} --build-type=RELEASE --arch=arch/${machine}/amd_staging -j=${ranks} --cmake="CMAKE_EXE_LINKER_FLAGS_INIT='-lflang_rt.hostdevice -fopenmp --offload-arch=${arch}'" --with-serialbox=${serialbox} --with-hip=OFF --with-acc=OFF --with-openmp=ON --with-single-precision=${sp} --with-hdf5=ON --with-prototype1=OFF
	else
	    echo "Build AFAR"
	    bdir=${build_dir}_afar_${afar}
	    ./cloudsc-bundle build --clean --build-dir=${bdir} --build-type=RELEASE --arch=arch/${machine}/afar_${afar} -j=${ranks} --cmake="CMAKE_EXE_LINKER_FLAGS_INIT='-lflang_rt.hostdevice -fopenmp --offload-arch=${arch} --save-temps'" --with-serialbox=${serialbox} --with-hip=OFF --with-acc=OFF --with-openmp=ON --with-single-precision=${sp} --with-hdf5=ON --with-prototype1=OFF
	fi
    fi
fi
