#!/bin/bash

set -e

REPO_DIR=.
PROJECT_SPEC=opencv-python
MB_PYTHON_VERSION=3.7
TRAVIS_PYTHON_VERSION=3.7
MB_ML_VER=2014
TRAVIS_BUILD_DIR=/home/ci
CONFIG_PATH=travis_config.sh
DOCKER_IMAGE=opencv-manylinux-cu11x
USE_CCACHE=0
UNICODE_WIDTH=32
PLAT=x86_64
SDIST=0
ENABLE_HEADLESS=0
ENABLE_CONTRIB=1
WHEEL_CU_VERSION=cu11x

script_dir=$(
  cd "$(dirname "$0")"
  pwd
)

repository_dir="${script_dir}/.."

build_dir="${repository_dir}/build"

# remove build dir if exists
if [ -d "$build_dir" ]; then
  rm -rf $build_dir
fi

cd "${repository_dir}"

# create build dir
mkdir "${build_dir}"

cd "${build_dir}"

# clone opencv-python repo
git clone https://github.com/jasonjiang8866/opencv-python-cuda.git opencv-python
cd opencv-python
git checkout 4.x.cudafix

# insert the following after  "-DPYTHON3_LIMITED_API=ON", in setup.py
sed -i 's/-DPYTHON3_LIMITED_API=ON/-DPYTHON3_LIMITED_API=ON", "-DCUDA_FAST_MATH=ON", "-DWITH_CUBLAS=ON", "-DWITH_CUFFT=ON", "-DWITH_NVCUVID=ON", "-DWITH_NVCUVENC=ON", "-DWITH_CUDA=ON", "-DWITH_CUDNN=ON/g' setup.py

# Check out and prepare the source
# Multibuild doesn't have releases, so --depth would break eventually (see
# https://superuser.com/questions/1240216/server-does-not-allow-request-for-unadvertised)
git submodule update --init multibuild
source multibuild/common_utils.sh

# change retry docker pull $docker_image to #retry docker pull $docker_image(comment out) in file multibuild/travis_linux_steps.sh
sed -i 's/retry docker pull $docker_image/#retry docker pull $docker_image/g' multibuild/travis_linux_steps.sh

# change docker run --rm to docker run --rm --privileged --gpus all  in file multibuild/travis_linux_steps.sh
sed -i 's/docker run --rm/docker run --rm --privileged --gpus all/g' multibuild/travis_linux_steps.sh

# replace patch_auditwheel_whitelist.py(force)
cp -f ${repository_dir}/patch_auditwheel_whitelist.py ./patch_auditwheel_whitelist.py

# update wheel name in setup.py
sed -i "s/skbuild.setup(/package_name='opencv-${WHEEL_CU_VERSION}-python'\n    skbuild.setup(/g" setup.py

# https://github.com/matthew-brett/multibuild/issues/116
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then export ARCH_FLAGS=" "; fi
source multibuild/travis_steps.sh
# This sets -x
# source travis_multibuild_customize.sh
echo $ENABLE_CONTRIB > contrib.enabled
echo $ENABLE_HEADLESS > headless.enabled
echo $ENABLE_ROLLING > rolling.enabled
set -x
build_wheel $REPO_DIR $PLAT
