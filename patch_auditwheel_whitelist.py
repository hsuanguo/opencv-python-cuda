from os.path import join, dirname, abspath
import json
import argparse
import os

from auditwheel import policy

def add_whitelisted_libs(cuda_version, cudnn_version):
    policies = None

    basic_cuda_libs = ['libcuda.so.1', 'libnvcuvid.so.1', 'libnvidia-encode.so.1']

    npp_libs = [
        f'libnppc.so.{cuda_version}',
        f'libnppial.so.{cuda_version}',
        f'libnppicc.so.{cuda_version}',
        f'libnppidei.so.{cuda_version}',
        f'libnppif.so.{cuda_version}',
        f'libnppig.so.{cuda_version}',
        f'libnppim.so.{cuda_version}',
        f'libnppist.so.{cuda_version}',
        f'libnppitc.so.{cuda_version}'
    ]

    cublas_libs = [f'libcublas.so.{cuda_version}', f'libcublasLt.so.{cuda_version}']

    cufft_version = cuda_version - 1

    other_libs = [f'libcudnn.so.{cudnn_version}', f'libcufft.so.{cufft_version}', f'libcufftw.so.{cufft_version}']

    all_cuda_libs = basic_cuda_libs + npp_libs + cublas_libs + other_libs

    with open(join(dirname(abspath(policy.__file__)), "manylinux-policy.json")) as f:
        policies = json.load(f)

    for p in policies:
        p["lib_whitelist"].append("libxcb.so.1")
        p["lib_whitelist"].extend(all_cuda_libs)

    with open(join(dirname(abspath(policy.__file__)), "manylinux-policy.json"), "w") as f:
        f.write(json.dumps(policies))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Add libraries to manylinux whitelist')

    parser.add_argument('--cuda_version', type=int, default=11, help='Major CUDA version to use.')
    parser.add_argument('--cudnn_version', type=int, default=8, help='Major CUDNN version to use.')

    args = parser.parse_args()

    major_cudnn_version = os.environ.get('CUDNN_MAJOR_VERSION', args.cudnn_version)
    major_cuda_version = os.environ.get('CUDA_MAJOR_VERSION', args.cuda_version)

    major_cudnn_version = int(major_cudnn_version)
    major_cuda_version = int(major_cuda_version)

    add_whitelisted_libs(major_cuda_version, major_cudnn_version)
