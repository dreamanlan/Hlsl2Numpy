rem working directory

set workdir=%~dp0
cd %workdir%
cd ..

Hlsl2Numpy -gendsl -gl -torch %workdir%hlsl_test.hlsl

cd %workdir%

