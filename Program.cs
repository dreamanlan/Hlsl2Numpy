using Hlsl2Numpy.Analysis;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.CompilerServices;
using System.Security.AccessControl;
using System.Text;
using System.Xml.Linq;
using static Hlsl2Numpy.Program;

namespace Hlsl2Numpy
{
    internal partial class Program
    {
        static void Main(string[] args)
        {
            if (args.Length == 0) {
                PrintHelp();
                return;
            }
            else {
                bool isGlsl = true;
                bool fromShaderToy = true;
                bool isCompute = false;
                bool isDsl = false;
                bool opengl = false;
                bool profiling = false;
                bool autodiff = false;
                bool genDsl = false;
                bool rewriteDsl = false;
                bool printBlocks = false;
                bool printFinalBlocks = false;
                bool printGraph = false;
                bool printFinalGraph = false;
                bool multiple = false;
                string srcFilePath = string.Empty;
                string outFilePath = string.Empty;
                string argFilePath = string.Empty;
                int maxLoop = -1;
                for (int i = 0; i < args.Length; ++i) {
                    if (0 == string.Compare(args[i], "-out", true)) {
                        if (i < args.Length - 1) {
                            string arg = args[i + 1];
                            if (!arg.StartsWith("-")) {
                                outFilePath = arg;
                                ++i;
                            }
                        }
                    }
                    else if (0 == string.Compare(args[i], "-src", true)) {
                        if (i < args.Length - 1) {
                            string arg = args[i + 1];
                            if (!arg.StartsWith("-")) {
                                srcFilePath = arg;
                                if (!File.Exists(srcFilePath)) {
                                    Console.WriteLine("file path not found ! {0}", srcFilePath);
                                }
                                ++i;
                            }
                        }
                    }
                    else if (0 == string.Compare(args[i], "-args", true)) {
                        if (i < args.Length - 1) {
                            string arg = args[i + 1];
                            if (!arg.StartsWith("-")) {
                                argFilePath = arg;
                                if (!File.Exists(argFilePath)) {
                                    Console.WriteLine("file path not found ! {0}", argFilePath);
                                }
                                ++i;
                            }
                        }
                    }
                    else if (0 == string.Compare(args[i], "-shadertoy", true)) {
                        isGlsl = true;
                        fromShaderToy = true;
                    }
                    else if (0 == string.Compare(args[i], "-notshadertoy", true)) {
                        isGlsl = false;
                        fromShaderToy = false;
                    }
                    else if (0 == string.Compare(args[i], "-gl", true)) {
                        opengl = true;
                    }
                    else if (0 == string.Compare(args[i], "-ngl", true)) {
                        opengl = false;
                    }
                    else if (0 == string.Compare(args[i], "-profiling", true)) {
                        profiling = true;
                    }
                    else if (0 == string.Compare(args[i], "-notprofiling", true)) {
                        profiling = false;
                    }
                    else if (0 == string.Compare(args[i], "-torch", true)) {
                        ProgramTransform.s_IsTorch = true;
                    }
                    else if (0 == string.Compare(args[i], "-notorch", true)) {
                        ProgramTransform.s_IsTorch = false;
                    }
                    else if (0 == string.Compare(args[i], "-autodiff", true)) {
                        autodiff = true;
                    }
                    else if (0 == string.Compare(args[i], "-noautodiff", true)) {
                        autodiff = false;
                    }
                    else if (0 == string.Compare(args[i], "-gendsl", true)) {
                        genDsl = true;
                    }
                    else if (0 == string.Compare(args[i], "-notgendsl", true)) {
                        genDsl = false;
                    }
                    else if (0 == string.Compare(args[i], "-rewritedsl", true)) {
                        rewriteDsl = true;
                    }
                    else if (0 == string.Compare(args[i], "-notrewritedsl", true)) {
                        rewriteDsl = false;
                    }
                    else if (0 == string.Compare(args[i], "-printblocks", true)) {
                        printBlocks = true;
                    }
                    else if (0 == string.Compare(args[i], "-notprintblocks", true)) {
                        printBlocks = false;
                    }
                    else if (0 == string.Compare(args[i], "-printfinalblocks", true)) {
                        printFinalBlocks = true;
                    }
                    else if (0 == string.Compare(args[i], "-notprintfinalblocks", true)) {
                        printFinalBlocks = false;
                    }
                    else if (0 == string.Compare(args[i], "-printgraph", true)) {
                        printGraph = true;
                    }
                    else if (0 == string.Compare(args[i], "-notprintgraph", true)) {
                        printGraph = false;
                    }
                    else if (0 == string.Compare(args[i], "-printfinalgraph", true)) {
                        printFinalGraph = true;
                    }
                    else if (0 == string.Compare(args[i], "-notprintfinalgraph", true)) {
                        printFinalGraph = false;
                    }
                    else if (0 == string.Compare(args[i], "-printvecvars", true)) {
                        ProgramTransform.s_PrintVectorizedVars = true;
                    }
                    else if (0 == string.Compare(args[i], "-notprintvecvars", true)) {
                        ProgramTransform.s_PrintVectorizedVars = false;
                    }
                    else if (0 == string.Compare(args[i], "-unroll", true)) {
                        ProgramTransform.s_AutoUnrollLoops = true;
                    }
                    else if (0 == string.Compare(args[i], "-notunroll", true)) {
                        ProgramTransform.s_AutoUnrollLoops = false;
                    }
                    else if (0 == string.Compare(args[i], "-vectorization", true)) {
                        ProgramTransform.s_EnableVectorization = true;
                    }
                    else if (0 == string.Compare(args[i], "-novectorization", true)) {
                        ProgramTransform.s_EnableVectorization = false;
                    }
                    else if (0 == string.Compare(args[i], "-const", true)) {
                        ProgramTransform.s_EnableConstPropagation = true;
                    }
                    else if (0 == string.Compare(args[i], "-noconst", true)) {
                        ProgramTransform.s_EnableConstPropagation = false;
                    }
                    else if (0 == string.Compare(args[i], "-single", true)) {
                        multiple = false;
                    }
                    else if (0 == string.Compare(args[i], "-multiple", true)) {
                        multiple = true;
                    }
                    else if (0 == string.Compare(args[i], "-maxloop", true)) {
                        if (i < args.Length - 1) {
                            string key = args[i].Substring(1);
                            string arg = args[i + 1];
                            if (!arg.StartsWith("-")) {
                                int.TryParse(arg, out maxLoop);
                                ++i;
                            }
                        }
                    }
                    else if (0 == string.Compare(args[i], "-hlsl2018", true)) {
                        ProgramTransform.s_UseHlsl2018 = true;
                    }
                    else if (0 == string.Compare(args[i], "-hlsl2021", true)) {
                        ProgramTransform.s_UseHlsl2018 = false;
                    }
                    else if (0 == string.Compare(args[i], "-debug", true)) {
                        ProgramTransform.s_IsDebugMode = true;
                        ProgramTransform.s_StringBuilderPool.IsDebugMode = true;
                    }
                    else if (0 == string.Compare(args[i], "-h", true)) {
                        PrintHelp();
                    }
                    else if (args[i][0] == '-') {
                        Console.WriteLine("unknown command option ! {0}", args[i]);
                    }
                    else {
                        srcFilePath = args[i];
                        if (!File.Exists(srcFilePath)) {
                            Console.WriteLine("file path not found ! {0}", srcFilePath);
                        }
                        break;
                    }
                }

                string oldCurDir = Environment.CurrentDirectory;
                string exeFullName = System.Reflection.Assembly.GetExecutingAssembly().Location;
                string? exeDir = Path.GetDirectoryName(exeFullName);
                Debug.Assert(null != exeDir);
                Environment.CurrentDirectory = exeDir;
                Console.WriteLine("curdir {0} change to exedir {1}", oldCurDir, exeDir);
                try {
                    string? workDir = Path.GetDirectoryName(srcFilePath);
                    Debug.Assert(null != workDir);
                    string tmpDir = Path.Combine(workDir, "tmp");
                    if (!Directory.Exists(tmpDir)) {
                        Directory.CreateDirectory(tmpDir);
                    }
                    string srcFileName = Path.GetFileName(srcFilePath);
                    string srcFileNameWithoutExt = Path.GetFileNameWithoutExtension(srcFileName);
                    string hlslFilePath = srcFilePath;
                    string srcExt = Path.GetExtension(srcFilePath);
                    bool isHlsl = true;
                    if (srcExt == ".compute") {
                        isCompute = true;
                    }
                    if (srcExt == ".dsl") {
                        isDsl = true;
                    }
                    else if (srcExt != ".hlsl") {
                        hlslFilePath = Path.Combine(tmpDir, Path.ChangeExtension(srcFileName, "hlsl"));
                        isHlsl = false;
                        if (srcExt == ".glsl") {
                            isGlsl = true;
                            ProgramTransform.s_UseHlsl2018 = true;
                        }
                    }

                    string dxcHlslVerOption = string.Empty;
                    if (ProgramTransform.s_UseHlsl2018)
                        dxcHlslVerOption = "-HV 2018 ";

                    string dslFilePath = Path.Combine(tmpDir, Path.ChangeExtension(srcFileName, "dsl"));
                    string dsl2FilePath = Path.Combine(tmpDir, srcFileNameWithoutExt + "_pruned.dsl");
                    string dsl3FilePath = Path.Combine(tmpDir, srcFileNameWithoutExt + "_finally.dsl");
                    string rewriteFilePath = Path.Combine(tmpDir, Path.ChangeExtension(srcFileName, "txt"));
                    string pyFilePath = outFilePath;
                    if (string.IsNullOrEmpty(pyFilePath)) {
                        pyFilePath = Path.Combine(tmpDir, Path.ChangeExtension(srcFileName, "py"));
                    }
                    string? pyDir = Path.GetDirectoryName(pyFilePath);
                    Debug.Assert(null != pyDir);

                    string mainEntryFunc = string.Empty;
                    var additionalEntryFuncs = new HashSet<string>();
                    if (string.IsNullOrEmpty(argFilePath)) {
                        argFilePath = Path.Combine(workDir, srcFileNameWithoutExt + "_args.dsl");
                    }
                    if (File.Exists(argFilePath)) {
                        LoadShaderArgs(argFilePath, tmpDir);
                        if (!string.IsNullOrEmpty(s_MainShaderInfo.Entry)) {
                            mainEntryFunc = s_MainShaderInfo.Entry;
                        }
                        foreach (var bufInfo in s_ShaderBufferInfos) {
                            additionalEntryFuncs.Add(bufInfo.Entry);
                        }
                    }

                    if (string.IsNullOrEmpty(mainEntryFunc)) {
                        if (fromShaderToy) {
                            mainEntryFunc = "mainImage";
                        }
                        else if (isGlsl) {
                            mainEntryFunc = GlslFragInfo.s_GlslFragEntry;
                        }
                        else if (isCompute) {
                            mainEntryFunc = "main";
                        }
                        else {
                            mainEntryFunc = "frag";
                        }
                    }

                    //0、preprocess src file
                    string libDir = Path.Combine(pyDir, "shaderlib");
                    if (!Directory.Exists(libDir)) {
                        Directory.CreateDirectory(libDir);
                    }
                    var libFiles = Directory.GetFiles("../shaderlib");
                    foreach (var libFile in libFiles) {
                        string libExt = Path.GetExtension(libFile);
                        string libFileName = Path.GetFileName(libFile);
                        string targetFile = Path.Combine(libDir, libFileName);
                        if (multiple && libExt == ".py") {
                            if (libFileName.StartsWith("hlsl_lib_numpy_")) {
                                var impLines = new List<string>();
                                impLines.Add("import numpy as np");
                                impLines.Add("from numba import njit");
                                var libLines = File.ReadAllLines(libFile);
                                impLines.AddRange(libLines);
                                File.WriteAllLines(targetFile, impLines);
                            }
                            else if (libFileName.StartsWith("hlsl_lib_torch_")) {
                                var impLines = new List<string>();
                                impLines.Add("import numpy as np");
                                impLines.Add("import torch");
                                impLines.Add("import pyjion #conflict with matplotlib");
                                impLines.Add("pyjion.enable()");
                                var libLines = File.ReadAllLines(libFile);
                                impLines.AddRange(libLines);
                                File.WriteAllLines(targetFile, impLines);
                            }
                            else {
                                File.Copy(libFile, targetFile, true);
                            }
                        }
                        else {
                            File.Copy(libFile, targetFile, true);
                        }
                    }
                    string dslTxt = string.Empty;
                    if (isDsl) {
                        dslTxt = File.ReadAllText(dslFilePath);
                    }
                    else {
                        if (isGlsl) {
                            var glslSrc = new StringBuilder();
                            if (fromShaderToy) {
                                //The preprocessing of glsllang requires strict matching of macro parameters. Many shaders on shadertoy are not very standardized. Here we use dxc to do preprocessing first.
                                //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                //call dxc.exe -P -Fi input.i input.glsl
                                //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                string iFilePath = Path.Combine(tmpDir, Path.ChangeExtension(srcFileName, "i"));
                                {
                                    var coption = new ProcessStartOption();
                                    int cr = -1;
                                    if (OperatingSystem.IsWindows())
                                        cr = ProcessHelper.RunProcess("dxc.exe", "-P -Fi \"" + iFilePath + "\" \"" + srcFilePath + "\"", coption, null, null, null, null, null, false, true, Encoding.UTF8);
                                    else
                                        cr = ProcessHelper.RunProcess("dxc", "-P -Fi \"" + iFilePath + "\" \"" + srcFilePath + "\"", coption, null, null, null, null, null, false, true, Encoding.UTF8);
                                    if (cr != 0) {
                                        Console.WriteLine("run dxc failed, exit code:{0}", cr);
                                    }
                                }
                                glslSrc.AppendLine("#version 450");
                                glslSrc.AppendLine("precision mediump float;");
                                glslSrc.AppendLine("layout (location = TEXCOORD0) in vec2 {0};", GlslFragInfo.s_GlslFragInVar);
                                glslSrc.AppendLine("layout (location = SV_Target0) out vec4 {0};", GlslFragInfo.s_GlslFragOutVar);
                                glslSrc.AppendLine(string.Empty);
                                // Do not assign initial values to the variables built into shadertoy,
                                // otherwise glslcc will assign values to these variables in the main
                                // function when converting to hlsl.
                                //This is inconsistent with the behavior of shadertoy. We assign values
                                //every frame in the python lib.
                                glslSrc.AppendLine("vec3 iResolution;");
                                glslSrc.AppendLine("float iTime;");
                                glslSrc.AppendLine("float iTimeDelta;");
                                glslSrc.AppendLine("float iFrameRate;");
                                glslSrc.AppendLine("int iFrame;");
                                glslSrc.AppendLine("float iChannelTime[4];");
                                glslSrc.AppendLine("vec3 iChannelResolution[4];");
                                glslSrc.AppendLine("vec4 iMouse;");
                                glslSrc.AppendLine("vec4 iDate;");
                                glslSrc.AppendLine("float iSampleRate;");
                                foreach (var pair in s_MainShaderInfo.TexTypes) {
                                    glslSrc.AppendLine(string.Format("layout (binding = 0) uniform {0} {1};", pair.Value, pair.Key));
                                }
                                foreach (var bufInfo in s_ShaderBufferInfos) {
                                    foreach (var pair in bufInfo.TexTypes) {
                                        glslSrc.AppendLine(string.Format("layout (binding = 0) uniform {0} {1}_{2};", pair.Value, bufInfo.BufferId, pair.Key));
                                    }
                                }
                                glslSrc.AppendLine();
                                glslSrc.Append(File.ReadAllText(iFilePath));
                                glslSrc.AppendLine();
                                glslSrc.AppendLine("void main()");
                                glslSrc.AppendLine("{");
                                foreach (var fn in additionalEntryFuncs) {
                                    glslSrc.AppendLine("\t{0}({1}, {2});", fn, GlslFragInfo.s_GlslFragOutVar, GlslFragInfo.s_GlslFragInVar);
                                }
                                glslSrc.AppendLine("\t{0}({1}, {2});", mainEntryFunc, GlslFragInfo.s_GlslFragOutVar, GlslFragInfo.s_GlslFragInVar);
                                glslSrc.AppendLine("}");
                            }
                            else {
                                glslSrc.Append(File.ReadAllText(srcFilePath));
                                glslSrc.AppendLine();
                            }
                            string newGlslPath = Path.Combine(tmpDir, srcFileName);
                            File.WriteAllText(newGlslPath, glslSrc.ToString());

                            //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                            //call glslcc.exe --frag=input.glsl --output=input.hlsl
                            //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                            //glslcc.exe compiled from https://github.com/dreamanlan/glslcc/tree/modify_for_hlsl2numpy, a modified glslcc fork
                            //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                            {
                                var coption = new ProcessStartOption();
                                int cr = -1;
                                if (OperatingSystem.IsWindows())
                                    cr = ProcessHelper.RunProcess("glslcc.exe", "--frag=\"" + newGlslPath + "\" --output=\"" + hlslFilePath + "\" --lang=hlsl", coption, null, null, null, null, null, false, true, Encoding.UTF8);
                                else
                                    cr = ProcessHelper.RunProcess("glslcc", "--frag=\"" + newGlslPath + "\" --output=\"" + hlslFilePath + "\" --lang=hlsl", coption, null, null, null, null, null, false, true, Encoding.UTF8);
                                if (cr != 0) {
                                    Console.WriteLine("run glslcc failed, exit code:{0}", cr);
                                }
                                string glslccOutFile = Path.Combine(tmpDir, srcFileNameWithoutExt + "_fs.hlsl");
                                File.Move(glslccOutFile, hlslFilePath, true);
                            }
                        }
                        else if (!isHlsl) {
                            File.WriteAllText(hlslFilePath, File.ReadAllText(srcFilePath));
                        }
                        //call dxr.exe convert hlsl to dsl
                        //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                        //dxr.exe compiled from https://github.com/dreamanlan/DirectXShaderCompiler/tree/Dxc2Dsl, a modified DXC fork
                        //dsl.dll compiled from https://github.com/dreamanlan/MetaDSL (master branch), a common meta-DSL language for data and logic (JSON, in contrast, is primarily used for data)
                        //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                        var option = new ProcessStartOption();
                        var output = new StringBuilder();
                        int r = -1;
                        if (OperatingSystem.IsWindows())
                            r = ProcessHelper.RunProcess("dxr.exe", dxcHlslVerOption + "\"" + hlslFilePath + "\"", option, null, null, null, output, null, false, true, Encoding.UTF8);
                        else
                            r = ProcessHelper.RunProcess("dxr", dxcHlslVerOption + "\"" + hlslFilePath + "\"", option, null, null, null, output, null, false, true, Encoding.UTF8);
                        if (r != 0) {
                            Console.WriteLine("run dxr failed, exit code:{0}", r);
                        }

                        dslTxt = output.ToString();
                        File.WriteAllText(dslFilePath, dslTxt);
                    }

                    //dsl transform to python
                    var dslFile = new Dsl.DslFile();
                    if (dslFile.LoadFromString(dslTxt, msg => { Console.WriteLine(msg); })) {
                        if (rewriteDsl)
                            dslFile.Save(rewriteFilePath);

                        var sb = new StringBuilder();
                        if (multiple) {
                            sb.AppendLine("import sys");
                            sb.AppendLine("import os");
                            sb.AppendLine("import inspect");
                            sb.AppendLine("hlslLibPath = os.path.realpath(os.path.join(os.path.dirname(inspect.getfile(inspect.currentframe())), './shaderlib'))");
                            sb.AppendLine("if hlslLibPath not in sys.path:");
                            sb.AppendLine("\tsys.path.append(hlslLibPath)");
                            sb.AppendLine("#print(sys.path)");
                        }
                        var imports = ProgramTransform.s_IsTorch ? ProgramTransform.s_TorchImports : ProgramTransform.s_NumpyImports;
                        var include = ProgramTransform.s_IsTorch ? ProgramTransform.s_TorchInc : ProgramTransform.s_NumpyInc;
                        if (!ProgramTransform.s_UseHlsl2018) {
                            imports = ProgramTransform.s_IsTorch ? ProgramTransform.s_TorchImportsFor2021 : ProgramTransform.s_NumpyImportsFor2021;
                            include = ProgramTransform.s_IsTorch ? ProgramTransform.s_TorchIncFor2021 : ProgramTransform.s_NumpyIncFor2021;
                        }
                        foreach (var importFile in imports) {
                            if (multiple) {
                                string ifn = Path.GetFileNameWithoutExtension(importFile);
                                sb.Append("from " + ifn + " import *");
                                sb.AppendLine();
                            }
                            else {
                                string txt = File.ReadAllText(Path.Combine(libDir, importFile));
                                sb.AppendLine(txt);
                            }
                        }
                        sb.AppendLine();
                        string incTxt = File.ReadAllText(Path.Combine(libDir, include));
                        sb.AppendLine(incTxt);

                        var globalSb = new StringBuilder();
                        var initSb = new StringBuilder();
                        //first pass
                        foreach (var info in dslFile.DslInfos) {
                            string id = info.GetId();
                            if (id == "struct") {
                                ProgramTransform.ParseStruct(info);
                            }
                            else if (id == "cbuffer") {
                                ProgramTransform.ParseCBuffer(info);
                            }
                            else if (id == "typedef") {
                                ProgramTransform.ParseTypeDef(info);
                            }
                        }
                        //second pass
                        foreach (var info in dslFile.DslInfos) {
                            string id = info.GetId();
                            if (id == "var") {
                                var vinfo = ProgramTransform.ParseVarDecl(info);
                                if (null != vinfo) {
                                    ProgramTransform.AddGlobalDecl(vinfo);
                                }
                            }
                            else if (id == "=") {
                                var tempSb = ProgramTransform.NewStringBuilder();
                                var tempSi = new SemanticInfo(false);
                                ProgramTransform.TransformAssignmentStatement(id, info, tempSb, 0, ref tempSi);
                                var vinfo = ProgramTransform.GetVarInfo(tempSi.NameOrConst, VarUsage.Find);
                                if (null != vinfo) {
                                    if (vinfo.IsConst || fromShaderToy && s_ShaderToyParamNames.Contains(vinfo.Name)) {
                                        ProgramTransform.RemoveInitGlobal(vinfo.Name);
                                        globalSb.Append(tempSb);
                                    }
                                    else {
                                        ProgramTransform.AddGlobalDecl(vinfo);
                                        initSb.Append("\t");
                                        initSb.Append(tempSb);
                                    }
                                }
                                ProgramTransform.RecycleStringBuilder(tempSb);
                            }
                            else if (id == "func") {
                                ProgramTransform.ParseAndPruneFuncDef(info, mainEntryFunc, additionalEntryFuncs);
                            }
                        }

                        const int c_max_globals_per_line_for_init = 10;

                        foreach (var varInfo in ProgramTransform.s_DeclGlobals) {
                            string name = varInfo.Name;
                            if (name == "inCoord" || name == "outColor") {
                                ProgramTransform.GenDeclVar(globalSb, 0, varInfo, true, Dsl.AbstractSyntaxComponent.NullSyntax);
                            }
                            else {
                                ProgramTransform.GenDeclVar(globalSb, 0, varInfo, false, Dsl.AbstractSyntaxComponent.NullSyntax);
                            }
                        }
                        globalSb.AppendLine();
                        if (ProgramTransform.s_InitGlobals.Count > 0) {
                            globalSb.AppendLine("def init_globals():");
                            for (int ix = 0; ix < ProgramTransform.s_InitGlobals.Count; ++ix) {
                                if (ix % c_max_globals_per_line_for_init == 0) {
                                    if (ix > 0)
                                        globalSb.AppendLine();
                                    globalSb.Append("\tglobal ");
                                }
                                else if (ix > 0) {
                                    globalSb.Append(", ");
                                }
                                var name = ProgramTransform.s_InitGlobals[ix];
                                globalSb.Append(name);
                            }
                            globalSb.AppendLine();
                            globalSb.Append(initSb);
                        }

                        if (genDsl) {
                            dslFile.Save(dsl2FilePath);
                        }
                        ProgramTransform.CacheGlobalCallInfo();

                        //final pass
                        foreach (var info in dslFile.DslInfos) {
                            string id = info.GetId();
                            if (id == "func") {
                                ProgramTransform.TransformFunc(info);
                            }
                        }

                        if (printBlocks) {
                            Console.WriteLine("===[Blocks:]===");
                            foreach (var pair in ProgramTransform.s_FuncInfos) {
                                string sig = pair.Key;
                                var func = pair.Value;
                                Console.WriteLine("func:{0}", sig);
                                Console.WriteLine("{0}params:", Literal.GetSpaceString(1));
                                foreach (var p in func.Params) {
                                    Console.WriteLine("{0}name:{1} type:{2}", Literal.GetSpaceString(2), p.Name, p.Type);
                                }
                                Console.WriteLine("{0}return:{1}", Literal.GetSpaceString(1), func.RetInfo.Type);
                                func.ToplevelBlock.Print(1);
                            }
                        }

                        if (printGraph) {
                            Console.WriteLine("===[ComputeGraph]===");
                            Console.WriteLine("[global]");
                            ProgramTransform.s_GlobalComputeGraph.Print(null);
                            foreach (var pair in ProgramTransform.s_FuncInfos) {
                                string sig = pair.Key;
                                var func = pair.Value;
                                Console.WriteLine("[func:{0}]", sig);
                                func.FuncComputeGraph.Print(func);
                            }
                        }

                        ProgramTransform.GenerateScalarFuncCode();
                        ProgramTransform.TryUnrollLoops(maxLoop);

                        //3、vectorization
                        var transformSb = new StringBuilder();
                        if (ProgramTransform.s_EnableVectorization) {
                            ProgramTransform.s_IsVectorizing = true;
                            ProgramTransform.s_IsVectorized = true;
                            ProgramTransform.Vectorizing(transformSb);
                        }
                        else {
                            ProgramTransform.s_IsVectorized = false;
                            foreach (var sig in ProgramTransform.s_AllFuncSigs) {
                                if (ProgramTransform.s_AllFuncCodes.TryGetValue(sig, out var fsb)) {
                                    transformSb.Append(fsb);
                                    if (ProgramTransform.s_FuncInfos.TryGetValue(sig, out var fi)) {
                                        transformSb.AppendLine();
                                    }
                                }
                            }
                        }

                        if (genDsl) {
                            dslFile.Save(dsl3FilePath);
                        }

                        if (printFinalBlocks) {
                            Console.WriteLine("===[Final Blocks:]===");
                            foreach (var sig in ProgramTransform.s_VectorizableFuncs) {
                                if (ProgramTransform.s_FuncInfos.TryGetValue(sig, out var func)) {
                                    Console.WriteLine("func:{0}", sig);
                                    Console.WriteLine("{0}params:", Literal.GetSpaceString(1));
                                    foreach (var p in func.Params) {
                                        Console.WriteLine("{0}name:{1} type:{2}", Literal.GetSpaceString(2), p.Name, p.Type);
                                    }
                                    Console.WriteLine("{0}return:{1}", Literal.GetSpaceString(1), func.RetInfo.Type);
                                    func.ToplevelBlock.Print(1);
                                }
                            }
                        }

                        if (printFinalGraph) {
                            Console.WriteLine("===[Final ComputeGraph]===");
                            Console.WriteLine("[global]");
                            ProgramTransform.s_GlobalComputeGraph.Print(null);
                            foreach (var sig in ProgramTransform.s_VectorizableFuncs) {
                                if (ProgramTransform.s_FuncInfos.TryGetValue(sig, out var func)) {
                                    Console.WriteLine("[func:{0}]", sig);
                                    func.FuncComputeGraph.Print(func);
                                }
                            }
                        }

                        foreach (var pair in ProgramTransform.s_AutoGenCodes) {
                            sb.Append(pair.Value);
                        }
                        sb.Append(transformSb);
                        sb.AppendLine();
                        var resoFast = s_MainShaderInfo.ResolutionOnFullVec;
                        if (ProgramTransform.s_IsTorch)
                            resoFast = s_MainShaderInfo.ResolutionOnGpuFullVec;
                        var resoSlow = s_MainShaderInfo.Resolution;
                        var reso = ProgramTransform.s_IsVectorized ? resoFast : resoSlow;
                        sb.AppendLine("vec_broadcast_count = {0}", (int)(reso.x * reso.y));
                        sb.Append(globalSb);
                        sb.AppendLine();
                        if (ProgramTransform.s_AllFuncCodes.TryGetValue(GlslFragInfo.s_GlslFragEntry, out var glslEntry) && null != glslEntry) {
                            sb.AppendLine(glslEntry.ToString());
                        }
                        if (fromShaderToy) {
                            sb.AppendLine("def shader_main(fc, fcd):");
                            sb.Append("\tglobal ");
                            var initBuffers = new SortedSet<string>();
                            var usingChannels = new SortedSet<string>();
                            var definedBuffers = new SortedSet<string>();
                            string prestr = string.Empty;
                            foreach (var bufInfo in s_ShaderBufferInfos) {
                                var bufId = bufInfo.BufferId;
                                sb.Append("{0}{1}", prestr, bufId);
                                prestr = ", ";
                                foreach (var pair in bufInfo.TexTypes) {
                                    var texname = pair.Key;
                                    var textype = pair.Value;
                                    string channel = bufId + "_" + texname;
                                    if (bufInfo.TexBuffers.TryGetValue(texname, out var texbuf)) {
                                        if (s_ShaderToyBufferNames.Contains(texbuf)) {
                                            if (!definedBuffers.Contains(texbuf)) {
                                                if (!initBuffers.Contains(texbuf))
                                                    initBuffers.Add(texbuf);
                                            }
                                        }
                                        if (!usingChannels.Contains(channel))
                                            usingChannels.Add(channel);
                                    }
                                    else if (bufInfo.TexFiles.TryGetValue(texname, out var texfile)) {
                                        if (!usingChannels.Contains(channel))
                                            usingChannels.Add(channel);
                                        sb.Append("{0}g_{1}_{2}", prestr, bufId, texname);
                                        prestr = ", ";
                                    }
                                }
                                if (!definedBuffers.Contains(bufId))
                                    definedBuffers.Add(bufId);
                            }
                            foreach (var pair in s_MainShaderInfo.TexTypes) {
                                var texname = pair.Key;
                                var textype = pair.Value;
                                string channel = texname;
                                if (s_MainShaderInfo.TexBuffers.TryGetValue(texname, out var texbuf)) {
                                    if (!usingChannels.Contains(channel))
                                        usingChannels.Add(channel);
                                }
                                else if (s_MainShaderInfo.TexFiles.TryGetValue(texname, out var texfile)) {
                                    if (!usingChannels.Contains(channel))
                                        usingChannels.Add(channel);
                                    sb.Append("{0}g_main_{1}", prestr, texname);
                                    prestr = ", ";
                                }
                            }
                            foreach (var channel in usingChannels) {
                                sb.Append("{0}{1}", prestr, channel);
                                prestr = ", ";
                            }
                            sb.Append(prestr);
                            sb.Append("iChannelTime");
                            sb.AppendLine();
                            if (ProgramTransform.s_InitGlobals.Count > 0) {
                                sb.AppendLine("\tinit_globals()");
                            }
                            else {
                                sb.AppendLine("\t{0}()", GlslFragInfo.s_GlslFragEntry);
                            }
                            sb.AppendLine("\tiChannelTime[0] = iTime");
                            sb.AppendLine("\tiChannelTime[1] = iTime");
                            sb.AppendLine("\tiChannelTime[2] = iTime");
                            sb.AppendLine("\tiChannelTime[3] = iTime");
                            sb.AppendLine();
                            foreach (var bufInfo in s_ShaderBufferInfos) {
                                var entry = bufInfo.Entry;
                                var bufId = bufInfo.BufferId;
                                if (ProgramTransform.s_FuncOverloads.TryGetValue(entry, out var overloads)) {
                                    foreach (var pair in bufInfo.TexTypes) {
                                        var texname = pair.Key;
                                        var textype = pair.Value;
                                        if (bufInfo.TexBuffers.TryGetValue(texname, out var texbuf)) {
                                            sb.AppendLine("\t{0}_{1} = {2}", bufId, texname, texbuf);
                                        }
                                        else if (bufInfo.TexFiles.TryGetValue(texname, out var texfile)) {
                                            sb.AppendLine("\t{0}_{1} = g_{0}_{2}", bufId, texname, texname);
                                        }
                                        int chanIx = s_ShaderToyChannels.IndexOf(texname);
                                        if (chanIx >= 0) {
                                            sb.AppendLine("\tset_channel_resolution({0}, {1}_{2})", chanIx, bufId, texname);
                                        }
                                    }
                                    foreach (var argInfo in bufInfo.ArgInfos) {
                                        sb.AppendLine("\t{0}_{1} = {2}", bufId, argInfo.ArgName, argInfo.ArgValue);
                                    }
                                    foreach (var sig in overloads) {
                                        var vsig = sig + ProgramTransform.c_VectorialNameSuffix;
                                        sb.AppendLine("\t{0} = buffer_to_tex({1}{2}(fc, fcd))", bufInfo.BufferId, sig, ProgramTransform.c_VectorialNameSuffix);
                                        break;
                                    }
                                }
                            }
                            foreach (var pair in s_MainShaderInfo.TexTypes) {
                                var texname = pair.Key;
                                var textype = pair.Value;
                                if (s_MainShaderInfo.TexBuffers.TryGetValue(texname, out var texbuf)) {
                                    sb.AppendLine("\t{0} = {1}", texname, texbuf);
                                }
                                else {
                                    sb.AppendLine("\t{0} = g_main_{0}", texname);
                                }
                                int chanIx = s_ShaderToyChannels.IndexOf(texname);
                                if (chanIx >= 0) {
                                    sb.AppendLine("\tset_channel_resolution({0}, {1})", chanIx, texname);
                                }
                            }
                            foreach (var argInfo in s_MainShaderInfo.ArgInfos) {
                                sb.AppendLine("\t{0} = {1}", argInfo.ArgName, argInfo.ArgValue);
                            }
                            sb.AppendLine("\treturn {0}{1}(fc, fcd)", ProgramTransform.s_MainEntryFuncSignature, ProgramTransform.c_VectorialNameSuffix);
                            sb.AppendLine();
                            sb.Append("if __name__ == \"__main__\":");
                            sb.AppendLine();
                            if (opengl)
                                sb.AppendLine("\tg_show_with_opengl = True");
                            else
                                sb.AppendLine("\tg_show_with_opengl = False");
                            if (autodiff)
                                sb.AppendLine("\tg_is_autodiff = True");
                            else
                                sb.AppendLine("\tg_is_autodiff = False");
                            if (profiling)
                                sb.AppendLine("\tg_is_profiling = True");
                            else
                                sb.AppendLine("\tg_is_profiling = False");
                            if (ProgramTransform.s_IsVectorized)
                                sb.AppendLine("\tg_is_full_vectorized = True");
                            else
                                sb.AppendLine("\tg_is_full_vectorized = False");

                            sb.AppendLine("\tg_face_color = \"{0}\"", s_MainShaderInfo.FaceColor);
                            sb.AppendLine("\tg_win_zoom = {0}", s_MainShaderInfo.WinZoom > 0.01f ? s_MainShaderInfo.WinZoom.ToString() : "None");
                            sb.AppendLine("\tg_win_size = {0}", s_MainShaderInfo.WinSize > 0.01f ? s_MainShaderInfo.WinSize.ToString() : "None");

                            var initMouse = s_MainShaderInfo.InitMousePos;
                            sb.AppendLine("\tiResolution = {0}.asarray([{1}, {2}, {3}])", ProgramTransform.s_IsTorch ? "torch" : "np", reso.x, reso.y, reso.z);
                            sb.AppendLine();
                            sb.AppendLine("\tiMouse[0] = iResolution[0] * {0}", initMouse.x);
                            sb.AppendLine("\tiMouse[1] = iResolution[1] * {0}", initMouse.y);
                            sb.AppendLine("\tiMouse[2] = iResolution[0] * {0}", initMouse.z);
                            sb.AppendLine("\tiMouse[3] = iResolution[1] * {0}", initMouse.w);
                            sb.AppendLine();

                            foreach (var bufId in initBuffers) {
                                sb.AppendLine("\t{0} = init_buffer()", bufId);
                            }
                            foreach (var bufInfo in s_ShaderBufferInfos) {
                                var bufId = bufInfo.BufferId;
                                foreach (var pair in bufInfo.TexTypes) {
                                    var texname = pair.Key;
                                    var textype = pair.Value;
                                    if (bufInfo.TexBuffers.TryGetValue(texname, out var texbuf)) {
                                    }
                                    else if (bufInfo.TexFiles.TryGetValue(texname, out var texfile)) {
                                        if (textype == "sampler2D")
                                            sb.AppendLine("\tg_{0}_{1} = load_tex_2d(\"{2}\")", bufId, texname, texfile);
                                        else if (textype == "sampler3D")
                                            sb.AppendLine("\tg_{0}_{1} = load_tex_3d(\"{2}\")", bufId, texname, texfile);
                                        else
                                            sb.AppendLine("\tg_{0}_{1} = load_tex_cube(\"{2}\")", bufId, texname, texfile);
                                    }
                                }
                            }
                            foreach (var pair in s_MainShaderInfo.TexTypes) {
                                var texname = pair.Key;
                                var textype = pair.Value;
                                if (s_MainShaderInfo.TexBuffers.TryGetValue(texname, out var texbuf)) {
                                }
                                else if (s_MainShaderInfo.TexFiles.TryGetValue(texname, out var texfile)) {
                                    if (textype == "sampler2D")
                                        sb.AppendLine("\tg_main_{0} = load_tex_2d(\"{1}\")", texname, texfile);
                                    else if (textype == "sampler3D")
                                        sb.AppendLine("\tg_main_{0} = load_tex_3d(\"{1}\")", texname, texfile);
                                    else
                                        sb.AppendLine("\tg_main_{0} = load_tex_cube(\"{1}\")", texname, texfile);
                                }
                            }

                            sb.AppendLine("\tif g_is_autodiff and g_is_profiling:");
                            sb.AppendLine("\t\tprofile_entry(main_entry_autodiff)");
                            sb.AppendLine("\telif g_is_autodiff:");
                            sb.AppendLine("\t\tmain_entry_autodiff()");
                            sb.AppendLine("\telif g_is_profiling:");
                            sb.AppendLine("\t\tprofile_entry(main_entry)");
                            sb.AppendLine("\telse:");
                            sb.AppendLine("\t\tmain_entry()");
                            sb.AppendLine();
                        }
                        else {
                            string vecsig = ProgramTransform.s_MainEntryFuncSignature + ProgramTransform.c_VectorialNameSuffix;
                            if (isCompute) {
                                sb.AppendLine("def shader_main(fc, fcd):");
                                if (ProgramTransform.s_InitGlobals.Count > 0) {
                                    sb.AppendLine("\tinit_globals()");
                                }
                                else if (isGlsl) {
                                    sb.AppendLine("\t{0}()", GlslFragInfo.s_GlslFragEntry);
                                }
                                sb.AppendLine();
                                sb.AppendLine("\treturn compute_dispatch(fc, fcd, {0}{1})", ProgramTransform.s_MainEntryFuncSignature, ProgramTransform.c_VectorialNameSuffix);
                            }
                            else {
                                sb.AppendLine("def shader_main(fc, fcd):");
                                sb.AppendLine("\tglobal iChannelTime");
                                if (ProgramTransform.s_InitGlobals.Count > 0) {
                                    sb.AppendLine("\tinit_globals()");
                                }
                                else if (isGlsl) {
                                    sb.AppendLine("\t{0}()", GlslFragInfo.s_GlslFragEntry);
                                }
                                sb.AppendLine("\tiChannelTime[0] = iTime");
                                sb.AppendLine("\tiChannelTime[1] = iTime");
                                sb.AppendLine("\tiChannelTime[2] = iTime");
                                sb.AppendLine("\tiChannelTime[3] = iTime");
                                sb.AppendLine();
                                sb.AppendLine("\treturn shader_dispatch(fc, fcd, {0}{1})", ProgramTransform.s_MainEntryFuncSignature, ProgramTransform.c_VectorialNameSuffix);
                            }
                            sb.AppendLine();
                            sb.Append(globalSb);
                            sb.AppendLine();
                            sb.Append("if __name__ == \"__main__\":");
                            sb.AppendLine();
                            if (opengl)
                                sb.AppendLine("\tg_show_with_opengl = True");
                            else
                                sb.AppendLine("\tg_show_with_opengl = False");
                            if (autodiff)
                                sb.AppendLine("\tg_is_autodiff = True");
                            else
                                sb.AppendLine("\tg_is_autodiff = False");
                            if (profiling)
                                sb.AppendLine("\tg_is_profiling = True");
                            else
                                sb.AppendLine("\tg_is_profiling = False");
                            if (ProgramTransform.s_IsVectorized)
                                sb.AppendLine("\tg_is_full_vectorized = True");
                            else
                                sb.AppendLine("\tg_is_full_vectorized = False");

                            sb.AppendLine("\tg_face_color = \"{0}\"", s_MainShaderInfo.FaceColor);
                            sb.AppendLine("\tg_win_zoom = {0}", s_MainShaderInfo.WinZoom > 0.01f ? s_MainShaderInfo.WinZoom.ToString() : "None");
                            sb.AppendLine("\tg_win_size = {0}", s_MainShaderInfo.WinSize > 0.01f ? s_MainShaderInfo.WinSize.ToString() : "None");

                            var initMouse = s_MainShaderInfo.InitMousePos;
                            sb.AppendLine("\tiResolution = {0}.asarray([{1}, {2}, {3}])", ProgramTransform.s_IsTorch ? "torch" : "np", reso.x, reso.y, reso.z);
                            sb.AppendLine();
                            sb.AppendLine("\tiMouse[0] = iResolution[0] * {0}", initMouse.x);
                            sb.AppendLine("\tiMouse[1] = iResolution[1] * {0}", initMouse.y);
                            sb.AppendLine("\tiMouse[2] = iResolution[0] * {0}", initMouse.z);
                            sb.AppendLine("\tiMouse[3] = iResolution[1] * {0}", initMouse.w);
                            sb.AppendLine();

                            foreach (var argInfo in s_MainShaderInfo.ArgInfos) {
                                if (argInfo.ArgType == "tex2d") {
                                    sb.AppendLine("\t{0} = load_tex_2d(\"{1}\")", argInfo.ArgName, argInfo.ArgValue);
                                }
                                else if (argInfo.ArgType == "tex3d") {
                                    sb.AppendLine("\t{0} = load_tex_3d(\"{1}\")", argInfo.ArgName, argInfo.ArgValue);
                                }
                                else if (argInfo.ArgType == "texcube") {
                                    sb.AppendLine("\t{0} = load_tex_cube(\"{1}\")", argInfo.ArgName, argInfo.ArgValue);
                                }
                                else {
                                    sb.AppendLine("\t{0} = {1}", argInfo.ArgName, argInfo.ArgValue);
                                }
                            }

                            sb.AppendLine("\tif g_is_profiling:");
                            sb.AppendLine("\t\tprofile_entry(main_entry)");
                            sb.AppendLine("\telse:");
                            sb.AppendLine("\t\tmain_entry()");
                            sb.AppendLine();
                        }
                        File.WriteAllText(pyFilePath, sb.ToString());
                    }
                    Console.WriteLine("Transform done.");
                    Console.Out.Flush();
                }
                catch (Exception ex) {
                    Console.WriteLine("{0}", ex.Message);
                    Console.WriteLine("[Stack]:");
                    Console.WriteLine("{0}", ex.StackTrace);
                }
                finally {
                    Environment.CurrentDirectory = oldCurDir;
                }
            }
        }
        static void PrintHelp()
        {
            Console.WriteLine("Usage:Hlsl2Numpy [-out outfile] [-args arg_dsl_file] [-notshadertoy] [-gl] [-profiling] [-torch] [-autodiff] [-gendsl] [-rewritedsl] [-printblocks] [-printfinalblocks] [-printgraph] [-printfinalgraph] [-printvecvars] [-unroll] [-novecterization] [-noconst] [-multiple] [-maxloop max_loop] [-hlsl2018] [-hlsl2021] [-debug] [-src ] hlsl_file");
            Console.WriteLine(" [-out outfile] output file path and name");
            Console.WriteLine(" [-args arg_dsl_file] config file path and name, default is [hlsl_file_name]_args.dsl");
            Console.WriteLine(" [-notshadertoy] not shadertoy mode [-shadertoy] shadertoy mode (default)");
            Console.WriteLine(" [-gl] render with opengl [-ngl] render with matplotlib (default)");
            Console.WriteLine(" [-profiling] profiling mode [-notprofiling] normal mode (default)");
            Console.WriteLine(" [-torch] use pytorch lib [-notorch] dont use pytorch lib (default)");
            Console.WriteLine(" [-autodiff] autodiff mode, only valid with torch mode [-noautodiff] normal mode (default)");
            Console.WriteLine(" [-gendsl] generate prune dsl and final dsl [-notgendsl] dont generate prune dsl and final dsl (default)");
            Console.WriteLine(" [-rewritedsl] rewrite [hlsl_file_name].dsl to [hlsl_file_name].txt [-notrewritedsl] dont rewrite dsl (default)");
            Console.WriteLine(" [-printblocks] output dataflow structure built in scalar phase [-notprintblocks] dont output (default)");
            Console.WriteLine(" [-printfinalblocks] output dataflow structure built in vectorizing phase [-notprintfinalblocks] dont output (default)");
            Console.WriteLine(" [-printgraph] output compute graph built in scalar phase [-notprintgraph] dont output (default)");
            Console.WriteLine(" [-printfinalgraph] output compute graph built in vectorizing phase [-notprintfinalgraph] dont output (default)");
            Console.WriteLine(" [-printvecvars] output vectorized var by compute graph [-notprintvecvars] dont output (default)");
            Console.WriteLine(" [-unroll] unroll loop [-notunroll] dont unroll loop (default)");
            Console.WriteLine(" [-novecterization] dont do vectorization [-vecterization] do vectorization (default)");
            Console.WriteLine(" [-noconst] dont do const propagation [-const] do const propagation (default)");
            Console.WriteLine(" [-multiple] output standalone python lib files [-single] output one python file including lib contents (default)");
            Console.WriteLine(" [-maxloop max_loop] max loop count while unroll loops, -1 default, means dont unroll an uncounted loops");
            Console.WriteLine(" [-hlsl2018] use hlsl 2018, default");
            Console.WriteLine(" [-hlsl2021] use hlsl 2021 or later");
            Console.WriteLine(" [-debug] debug mode");
            Console.WriteLine(" [-src ] hlsl_file source hlsl/glsl file, -src can be omitted when file is the last argument");
        }
    }
}