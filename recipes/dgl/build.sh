#!/bin/bash
set -euxo pipefail

rm -rf build || true


CUDA_CMAKE_OPTIONS="-DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc -DCMAKE_CUDA_HOST_COMPILER=${CXX}"

# remove -std=c++17 from CXXFLAGS for compatibility with nvcc
export CXXFLAGS="$(echo $CXXFLAGS | sed -e 's/ -std=[^ ]*//')"

CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DPython_EXECUTABLE=${PYTHON}"

echo $CONDA_PREFIX

mkdir build
cd build
# cmake -E environment
export DLPACK=$BUILD_PREFIX
export DMLC=$BUILD_PREFIX
export NANOFLANN=$BUILD_PREFIX
export PHMAP=$BUILD_PREFIX

cmake -DUSE_CUDA=ON -DUSE_CONDA_INCLUDES=ON -DUSE_EXTERNAL_THRUST=OFF -DUSE_EXTERNAL_DLPACK=ON  -DUSE_EXTERNAL_DMLC=ON -DUSE_EXTERNAL_METIS=OFF -DUSE_EXTERNAL_PHMAP=ON -DUSE_EXTERNAL_XBYAK=ON -DUSE_EXTERNAL_NANOFLANN=ON  -DUSE_LIBXSMM=OFF -DUSE_OPENMP=ON -DCUDA_ARCH_NAME=All ${CMAKE_FLAGS} ${CUDA_CMAKE_OPTIONS} ${SRC_DIR}
make -j$CPU_COUNT
cd ../python
${PYTHON} setup.py install --single-version-externally-managed --record=record.txt

# Fix some overlinking warnings/errors
ln -s $SP_DIR/dgl/libdgl.so $PREFIX/lib
