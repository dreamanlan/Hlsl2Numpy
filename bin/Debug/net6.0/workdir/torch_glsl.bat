rem working directory

set workdir=%~dp0
cd %workdir%
cd ..

Hlsl2Numpy -gl -torch -gen-dsl %workdir%test.glsl

cd %workdir%

