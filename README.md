# Hlsl2Numpy
 translate shadertoy shader to python

## 命令行
	Usage:Hlsl2Numpy [-out outfile] [-args arg_dsl_file] [-notshadertoy] [-gl] [-profiling] [-torch] [-autodiff] [-gendsl] [-rewritedsl] [-printblocks] [-printfinalblocks] [-printgraph] [-printfinalgraph] [-printvecvars] [-unroll] [-novecterization] [-noconst] [-multiple] [-maxloop max_loop] [-debug] [-src ] hlsl_file
	 [-out outfile] output file path and name
	 [-args arg_dsl_file] config file path and name, default is [hlsl_file_name]_args.dsl
	 [-notshadertoy] not shadertoy mode [-shadertoy] shadertoy mode (default)
	 [-gl] render with opengl [-ngl] render with matplotlib (default)
	 [-profiling] profiling mode [-notprofiling] normal mode (default)
	 [-torch] use pytorch lib [-notorch] dont use pytorch lib (default)
	 [-autodiff] autodiff mode, only valid with torch mode [-noautodiff] normal mode (default)
	 [-gendsl] generate prune dsl and final dsl [-notgendsl] dont generate prune dsl and final dsl (default)
	 [-rewritedsl] rewrite [hlsl_file_name].dsl to [hlsl_file_name].txt [-notrewritedsl] dont rewrite dsl (default)
	 [-printblocks] output dataflow structure built in scalar phase [-notprintblocks] dont output (default)
	 [-printfinalblocks] output dataflow structure built in vectorizing phase [-notprintfinalblocks] dont output (default)
	 [-printgraph] output compute graph built in scalar phase [-notprintgraph] dont output (default)
	 [-printfinalgraph] output compute graph built in vectorizing phase [-notprintfinalgraph] dont output (default)
	 [-printvecvars] output vectorized var by compute graph [-notprintvecvars] dont output (default)
	 [-unroll] unroll loop [-notunroll] dont unroll loop (default)
	 [-novecterization] dont do vectorization [-vecterization] do vectorization (default)
	 [-noconst] dont do const propagation [-const] do const propagation (default)
	 [-multiple] output standalone python lib files [-single] output one python file including lib contents (default)
	 [-maxloop max_loop] max loop count while unroll loops, -1 default, means dont unroll an uncounted loops
	 [-debug] debug mode
	 [-src ] hlsl_file source hlsl/glsl file, -src can be omitted when file is the last argument
	
## 常见问题

1. 翻译时提示全局变量向量化
	- 需要将全局变量修改为mainImage函数局部变量与其它使用变量的函数的inout参数
	- 修改相关函数调用加上对应全局变量的局部变量或参数变量
2. 打开循环展开开关翻译时提示某个循环无法展开
	- 可以添加 -maxloop 64这样的命令行参数指定循环的最大次数
	- 可以修改循环为for(int i=0;i<64;++i)这样有明确次数的循环，原来的循环条件则变成一个if语句
	- 可以不理会，hlsl2numpy会按不展开的循环翻译运行
3. 运行时提示有h_开头的函数未定义
	- 对numpy需要修改bin/Debug/shaderlib/hlsl_lib_numpy.py与bin/Debug/shaderlib/hlsl_lib_torch.py这2个库函数文件
	- 分别添加基于numpy与torch的api实现
	- 重新生成python代码
4. 其它错误提示
	- 可能是实现bug

## 一些技术细节

[Hlsl2Numpy实现笔记](https://zhuanlan.zhihu.com/p/634485306/edit "Hlsl2Numpy实现笔记")