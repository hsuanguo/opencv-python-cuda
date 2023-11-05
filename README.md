# opencv-python-cuda

Dockerised scripts based on project [opencv-python](https://github.com/opencv/opencv-python)  to build opencv python wheels with CUDA support.

## Prerequisites

- NVDIA Driver installed, and please make sure the CUDA version shown in `nvidia-smi` >= the cuda version(default=11.7) you would like to build for the wheel.

- Install [docker-ce](https://docs.docker.com/engine/install/) with instructions provided. complete post-installation steps to ensure that the docker can be run without sudo.

- Install [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html), please do follow the official guide.

- Download [CuDNN](https://developer.nvidia.com/rdp/cudnn-archive) and [Video Codec SDK](https://developer.nvidia.com/nvidia-video-codec-sdk/download), I have been using CuDNN 8.6 and Video Codec SDK 12.1.14, but other versions should work as well. After downloading, put them under `<repository_root>/downloads`.


## Build docker image

```bash
./scripts/build_docker.sh
```

By default, cuda 11.7 is used, you can change it by providing the url of the cuda version that you would like to use:

```bash
./scripts/build_docker.sh x86_64 opencv-manylinux-cu11x [cuda_toolkit_url]
```

Please refer to `./scripts/build_docker.sh` fro more details.

## Build the wheel

To build wheel:

```bash
./scripts/build_wheel.sh
```

This script will build the wheel using the docker image built in the previous step, please refer to the script to change opencv version, wheel name, etc.

Once done, you can find the built wheel under `./build/opencv-python/wheelhouse`.

Note: To reduce wheel size, CUDA and CuDNN libraries are not packed into the wheel, please make sure you have installed them to **use** the wheel.
