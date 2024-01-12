rem working directory

set workdir=%~dp0
cd %workdir%

BatchCommand.exe gen_hlsl_lib_numpy_swizzle.dsl > %workdir%../bin/Debug/shaderlib/hlsl_lib_numpy_swizzle.py
BatchCommand.exe gen_hlsl_lib_torch_swizzle.dsl > %workdir%../bin/Debug/shaderlib/hlsl_lib_torch_swizzle.py

