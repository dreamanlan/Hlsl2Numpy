#!/bin/bash

cur_dir=$(pwd)
script_dir=$(cd $(dirname $0); pwd)
echo "cur dir:" $cur_dir "script dir:" $script_dir

cd $script_dir
cd ..

./Hlsl2NumpyMac -gendsl -ngl -notorch -vectorizebranch -vectorization workdir/hlsl_test.hlsl

cd $cur_dir

