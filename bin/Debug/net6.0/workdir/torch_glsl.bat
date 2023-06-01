rem working directory

set workdir=%~dp0
cd %workdir%
cd ..

Hlsl2Numpy -shadertoy -gl -torch -gendsl -vectorizebranch -vectorization %workdir%test.glsl

cd %workdir%

