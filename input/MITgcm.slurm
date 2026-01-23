#!/bin/bash
#SBATCH -J MITgcm
#SBATCH -p xahcnormal
#SBATCH -N 10
#SBATCH --ntasks-per-node=32 # 每节点起多少进程，需要和dcu数量保持一致
#SBATCH --cpus-per-task=1 # 每进程使用多少核

source /work/home/zhanghua1504/MITgcm_c65y/env.sh
export PATH=/work/home/zhanghua1504/MITgcm_c65y/verification/circulation/run:$PATH

mpirun -np 315 mitgcmuv
