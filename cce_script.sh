#! /bin/bash
wgsize=64
opt=O1
wavesmin=1
wavesmax=1
filepath=build/cloudsc-dwarf/src/cloudsc_gpu/dwarf-cloudsc-gpu-omp-scc-hoist
for i in "$@"; do
    case "$1" in
        -wgsize=*|--wgsize=*)
            wgsize="${i#*=}"
            shift # past argument=value
            ;;
        -wmin=*|--wavesmin=*)
            wavesmin="${i#*=}"
            shift # past argument=value
            ;;
        -wmax=*|--wavesmax=*)
            wavesmax="${i#*=}"
            shift # past argument=value
            ;;
        -opt=*|--opt=*)
            opt="${i#*=}"
            shift # past argument=value
            ;;
	-fp=*|--filepath=*)
            filepath="${i#*=}"
            shift # past argument=value
            ;;
        --)
            shift
            break
            ;;
    esac
done

CCE_LLVM_PATH=${CRAY_CCE_CLANGSHARE}/../

## Turning bitcode into human-readable IR
echo "Disassembling"
${CCE_LLVM_PATH}/bin/llvm-dis ${filepath}-cce-openmp-pre-llc.bc

## Find/replace the workgroup size to what it _should be_ in the (human readable) IR #
#echo "Globally setting amdgpu-flat-work-group-size size to 1,$wgsize"
#sed "s/\"amdgpu-flat-work-group-size\"\=\"1,64\"/\"amdgpu-flat-work-group-size\"\=\"1,${wgsize}\" \"amdgpu-waves-per-eu\"\=\"${wavesmin},${wavesmax}\"  \"amdgpu-lds-size\"\=\"1,64000\"/g" ${filepath}-cce-openmp-pre-llc.ll > ${filepath}-cce-openmp-pre-llc.ll
#sed "s/\"amdgpu-flat-work-group-size\"\=\"1,64\"/\"amdgpu-flat-work-group-size\"\=\"1,${wgsize}\" \"amdgpu-waves-per-eu\"\=\"${wavesmin},${wavesmax}\" \"amdgpu-num-vgpr\"=\"64\" \"amdgpu-num-sgpr\"=\"64\" \"amdgpu-no-workitem-id-y\" \"amdgpu-no-workitem-id-z\" \"amdgpu-no-workgroup-id-y\" \"amdgpu-no-workgroup-id-z\"/g" ${filepath}-cce-openmp-pre-llc.ll > ${filepath}-cce-openmp-pre-llc.ll.new
#sed "s/\"amdgpu-flat-work-group-size\"\=\"1,64\"/\"amdgpu-flat-work-group-size\"\=\"1,${wgsize}\"/g" ${filepath}-cce-openmp-pre-llc.ll > ${filepath}-cce-openmp-pre-llc.ll

## This is building to an AMD GPU code object, using internal copy/pasted Cray Fortran   flags.
## The flags may need to be adjusted for future compiler versions
echo "Invoking LLC to compile" #  -amdgpu-dpp-combine -amdgpu-use-aa-in-codegen -amdgpu-vgpr-index-mode
# -mtriple=amdgcn-amd-amdhsa
${CCE_LLVM_PATH}/bin/llc -O3 -mtriple=amdgcn-amd-amdhsa -mcpu=gfx90a -amdgpu-dump-hsa-metadata ${filepath}-cce-openmp-pre-llc.ll -filetype=obj -o ${filepath}-cce-openmp-pre-llc.amdgpu

## Wrapping AMD GPU code object in an object that CCE OpenACC runtime understands
echo "Linking to a CCE Offload module"
${CCE_LLVM_PATH}/bin/lld  -flavor gnu --no-undefined -shared -o ${filepath}.lld.exe ${filepath}-cce-openmp-pre-llc.amdgpu

## Backend/hidden env var that tells the runtime where to find the offload object
echo ""
echo "export CRAY_ACC_MODULE=${PWD}/${filepath}.lld.exe"
echo "to use the new GPU offload code."
echo "To use the original build"
echo "unset CRAY_ACC_MODULE"

# # This goes inside an sbatch script for multi-node submissions (> 1000 nodes important)
# # Requet an nvme via
# #SBATCH -C nvme
# # Put this in the sbatch script before execution via srun
# sbcast -pf ${PWD}/build/simulation/simulation.lld.exe /mnt/bb/$USER/simulation.lld.exe
# export CRAY_ACC_MODULE=/mnt/bb/$USER/simulation.lld.exe"
