#!/bin/bash -l
#
afar=
enable_hip=
for i in "$@"; do
    echo $i
    case "$1" in
        -hip|--hip)
            enable_hip=YES
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


if [[ $afar ]];
then
    bdir=${build_dir}_afar_${afar}
    ./cloudsc-bundle build --clean --build-dir=${bdir} --arch=arch/${machine}/amd-gpu/afar_${afar} -j=${ranks} --cmake="ENABLE_CLOUDSC_GPU_SCC=OFF ENABLE_CLOUDSC_GPU_OMP_SCC=OFF ENABLE_CLOUDSC_GPU_SCC_STACK=OFF ENABLE_CLOUDSC_GPU_OMP_SCC_STACK=OFF ENABLE_CLOUDSC_GPU_SCC_HOIST=OFF ENABLE_CLOUDSC_GPU_OMP_SCC_HOIST=ON ENABLE_CLOUDSC_GPU_SCC_K_CACHING=OFF ENABLE_CLOUDSC_GPU_OMP_SCC_K_CACHING=ON CMAKE_EXE_LINKER_FLAGS_INIT=-lFortranRuntimeHostDevice" --with-gpu --with-serialbox
else
    if [[ $enable_hip ]];
    then
	./cloudsc-bundle build --clean --cmake=" ENABLE_CLOUDSC_GPU_SCC=OFF ENABLE_CLOUDSC_GPU_OMP_SCC=OFF ENABLE_CLOUDSC_GPU_SCC_STACK=OFF ENABLE_CLOUDSC_GPU_OMP_SCC_STACK=OFF ENABLE_CLOUDSC_GPU_SCC_HOIST=OFF ENABLE_CLOUDSC_GPU_OMP_SCC_HOIST=OFF ENABLE_CLOUDSC_GPU_SCC_K_CACHING=OFF ENABLE_CLOUDSC_GPU_OMP_SCC_K_CACHING=OFF" --with-hip --with-serialbox --arch arch/${machine}/cray-gpu/${cce} --build-dir=${bdir} --with-gpu -j=${ranks}
    else
	bdir=${build_dir}_cce_${cce}
	./cloudsc-bundle build --clean --build-dir=${bdir} --arch=arch/${machine}/cray-gpu/${cce} -j=${ranks} --cmake="ENABLE_CLOUDSC_GPU_SCC=OFF ENABLE_CLOUDSC_GPU_OMP_SCC=OFF ENABLE_CLOUDSC_GPU_SCC_STACK=OFF ENABLE_CLOUDSC_GPU_OMP_SCC_STACK=OFF ENABLE_CLOUDSC_GPU_SCC_HOIST=OFF ENABLE_CLOUDSC_GPU_OMP_SCC_HOIST=ON ENABLE_CLOUDSC_GPU_SCC_K_CACHING=OFF ENABLE_CLOUDSC_GPU_OMP_SCC_K_CACHING=ON" --with-serialbox --with-gpu
    fi
fi
