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

## 测试用例列表
0. 风暴
![风暴](doc_images/t0.gif "test0")
2. 噪声FBM图
![噪声FBM图](doc_images/t1.gif "test0")
4. 立方体里的雾
5. SDF圆盘
6. 体积雾中的三个小球
7. 荒漠风暴
8. 石头近观
9. 旋转的纹理球
10. 化学立方体
11. 云和山和海洋
12. 高云之上
13. 绿地、树、水
14. switch
15. 计数器版本一
16. 计数器版本二
17. 云中高塔
18. 色块、结构与数组测试
19. 小小寰球
20. 沙漠
21. 水晶
22. SDF几何体
23. 简单体积云
24. 穿过云层
25. 哈利波特字幕
26. 穿过浓雾（室内）
27. 秋月山谷
28. 蘑菇云
29. 跑步的人
30. 寻找头的机器人
31. 跑步的机器人（骨骼动画）
32. 平衡木上的火柴人
33. 变形人
34. 桃花朵朵开
35. 海浪
36. 黑色烟雾
37. 熔岩
38. 万有引力
39. 水底礁石
40. 飞翔的鸟
41. 花瓣与藤
42. 流体
43. 棋盘与红酒
44. 机关小球
45. 陨石坠落
46. 分形
47. 孤独的机器人
48. 贴地飞行
49. 湖光山色
50. 眼睛与石化
51. 三色烟雾
