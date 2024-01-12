rem working directory

set workdir=%~dp0
cd %workdir%
cd ..

Hlsl2Numpy -gendsl %workdir%hlsl_test.hlsl

cd %workdir%

