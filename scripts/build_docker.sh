#!/bin/bash

# Usage: ./scripts/build_docker.sh [target] [docker_image_tag] [cuda_toolkit_url] [download_dir]

set -e
set -u
set -o pipefail

script_dir=$(
  cd "$(dirname "$0")"
  pwd
)

repository_dir="${script_dir}/.."

target="${1:-x86_64}"

docker_image_tag="${2:-opencv-manylinux-cu11x}"

cuda_toolkit_url="${3:-https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run}"

download_dir="${4:-./downloads}"

cd "${repository_dir}"

# find cudnn-linux-*-archive.tar.xz file in downloads dir, there should be only one
cudnn_archive="$(find "${download_dir}" -name 'cudnn-linux-*-archive.tar.xz')"

if [ -z "${cudnn_archive}" ]; then
  echo "cudnn archive not found in ${download_dir}"
  exit 1
fi

# get the file name
cudnn_archive_file="$(basename "${cudnn_archive}")"

# find Video_Codec_SDK*.zip file in downloads dir, there should be only one
video_codec_sdk_archive="$(find "${download_dir}" -name 'Video_Codec_SDK*.zip')"

if [ -z "${video_codec_sdk_archive}" ]; then
  echo "video codec sdk archive not found in ${download_dir}"
  exit 1
fi

# get the file name
video_codec_sdk_archive_file="$(basename "${video_codec_sdk_archive}")"


# get cuda run file name from url
cuda_toolkit_file="$(basename "${cuda_toolkit_url}")"

# get cuda version from cuda run file name, for example, 11.7.1_515.65.01 -> 11.7
cuda_version="$(echo "${cuda_toolkit_file}" | sed -n 's/cuda_\([0-9]\+\.[0-9]\+\)\.[0-9]\+_\([0-9]\+\.[0-9]\+\.[0-9]\+\)_linux.run/\1/p')"


docker_file="./docker/Dockerfile_${target}"

echo "cuda version: ${cuda_toolkit_url}"
echo "cuda toolkit url: ${cuda_toolkit_file}"
echo "cudnn archive file: ${cudnn_archive_file}"
echo "video codec sdk archive file: ${video_codec_sdk_archive_file}"
echo "docker file: ${docker_file}"


docker build -t "${docker_image_tag}" -f "${docker_file}" \
  --build-arg DOWNLOADED_PKG_DIR=${download_dir} \
  --build-arg CUDA_TOOLKIT_URL=${cuda_toolkit_url} \
  --build-arg CUDA_TOOLKIT_RUN_FILE=${cuda_toolkit_file} \
  --build-arg CUDA_VERSION=${cuda_version} \
  --build-arg CUDNN_TAR_FILE=${cudnn_archive_file} \
  --build-arg UID=$(id -u) \
  --build-arg VIDEO_CODEC_SDK_FILE=${video_codec_sdk_archive_file} \
  .
