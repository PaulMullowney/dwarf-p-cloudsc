#!/bin/bash -l
use_lockhart=
for i in "$@"; do
    case "$1" in
        -build1=*|--build1=*)
            build1="${i#*=}"
            shift # past argument=value
            ;;
        -name1=*|--name1=*)
            name1="${i#*=}"
            shift # past argument=value
            ;;
        -build2=*|--build2=*)
            build2="${i#*=}"
            shift # past argument=value
            ;;
        -name2=*|--name2=*)
            name2="${i#*=}"
            shift # past argument=value
            ;;
        -b=*|--block=*)
            block="${i#*=}"
            shift # past argument=value
            ;;
	-ul|--ul)
            use_lockhart=YES
	    shift # past argument=value
	    ;;	    
        --)
            shift
            break
            ;;
    esac
done

export INSTALL_DIR=/home/pmullown/software/rocprofiler-compute/
export PATH=$INSTALL_DIR/3.0.0/bin:$PATH
export PYTHONPATH=$INSTALL_DIR/python-libs
if [[ $use_lockhart == "YES" ]]; then
    module load cray-python/3.10.10
else
    module load python/3.10.14
fi
rocprof-compute analyze -p ${build1}/workloads/${name1}/MI200 -k 0 -p ${build2}/workloads/${name2}/MI200 -k 0  -b ${block}

