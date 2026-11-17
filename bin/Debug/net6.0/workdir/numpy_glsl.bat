rem working directory

set workdir=%~dp0
cd %workdir%
cd ..

Hlsl2Numpy -gen-dsl %workdir%test.glsl

cd %workdir%

