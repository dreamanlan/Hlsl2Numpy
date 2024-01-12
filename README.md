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

[风暴](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t0.gif "test0")

2. 噪声FBM图

[噪声FBM图](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t1.gif "test1")

3. 立方体里的雾

[立方体里的雾](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t2.gif "test2")

4. SDF圆盘

[SDF圆盘](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t3.gif "test3")

5. 雾中的小球

[雾中的小球](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t4.gif "test4")

6. 荒漠风暴

[荒漠风暴](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t5.gif "test5")

7. 小小的石头

[小小的石头](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t6.gif "test6")

8. 旋转的球

[旋转的球](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t7.gif "test7")

9. 化学立方体

[化学立方体](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t8.gif "test8")

10. 云和山和海洋

[云和山和海洋](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t9.gif "test9")

11. 高云之上

[高云之上](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t10.gif "test10")

12. 绿地、树、水

[绿地、树、水](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t11.gif "test11")

13. switch

[switch](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t12.gif "test12")

14. 计数器版本一
15. 计数器版本二

[计数器](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t13&14.gif "test13&test14")

16. 云中高塔

[云中高塔](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t15.gif "test15")

17. 色块

[色块](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t16.gif "test16")

18. 小小寰球

[小小寰球](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t17.gif "test17")

19. 沙漠

[沙漠](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t18.gif "test18")

20. 水晶

[水晶](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t19.gif "test19")

21. SDF几何体

[SDF几何体](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t20.gif "test20")

22. 简单体积云

[简单体积云](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t21.gif "test21")

23. 穿过云层

[穿过云层](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t22.gif "test22")

24. 哈利波特字幕

[哈利波特字幕](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t23.gif "test23")

25. 穿过浓雾

[穿过浓雾](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t24.gif "test24")

26. 秋月山谷

[秋月山谷](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t25.gif "test25")

27. 蘑菇云

[蘑菇云](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t26.gif "test26")

28. 跑步的人

[跑步的人](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t27.gif "test27")

29. 找头的机器人

[找头的机器人](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t28.gif "test28")

30. 跑步的机器人（骨骼动画）

[跑步的机器人](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t29.gif "test29")

31. 平衡木上的火柴人

[平衡木上的火柴人](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t30.gif "test30")

32. 变形人

[变形人](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t31.gif "test31")

33. 桃花朵朵开

[桃花朵朵开](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t32.gif "test32")

34. 海浪

[海浪](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t33.gif "test33")

35. 黑色烟雾

[黑色烟雾](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t34.gif "test34")

36. 熔岩

[熔岩](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t35.gif "test35")

37. 万有引力

[万有引力](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t36.gif "test36")

38. 水底礁石

[水底礁石](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t37.gif "test37")

39. 飞翔的鸟

[飞翔的鸟](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t38.gif "test38")

40. 花瓣与藤

[花瓣与藤](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t39.gif "test39")

41. 流体

[流体](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t40.gif "test40")

42. 棋盘与红酒

[棋盘与红酒](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t41.gif "test41")

43. 机关小球

[机关小球](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t42.gif "test42")

44. 陨石坠落

[陨石坠落](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t43.gif "test43")

45. 分形

[分形](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t44.gif "test44")

46. 孤独的机器人

[孤独的机器人](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t45.gif "test45")

47. 贴地飞行

[贴地飞行](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t46.gif "test46")

48. 湖光山色

[湖光山色](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t47.gif "test47")

49. 眼睛与石化

[眼睛与石化](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t48.gif "test48")

50. 三色烟雾

[三色烟雾](https://github.com/dreamanlan/docs/tree/main/hlsl2numpy_images/t49.gif "test49")
