rem working directory

set workdir=%~dp0
cd %workdir%
cd ..

Hlsl2Numpy -gendsl %workdir%test.glsl

cd %workdir%

