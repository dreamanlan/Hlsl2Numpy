using Hlsl2Numpy.Analysis;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

namespace Hlsl2Numpy
{
    internal partial class ProgramTransform
    {
        private static int GenUniqueNumber()
        {
            return ++s_UniqueNumber;
        }
        private static KeyValuePair<string, string> ParseTypeDef(Dsl.FunctionData typeDefFunc, out bool isConst)
        {
            var typeInfo = typeDefFunc.GetParam(0);
            var typeInfoVal = typeInfo as Dsl.ValueData;
            var typeInfoFunc = typeInfo as Dsl.FunctionData;
            var typeInfoStm = typeInfo as Dsl.StatementData;
            var typeNameInfo = typeDefFunc.GetParam(1);
            var typeNameFunc = typeNameInfo as Dsl.FunctionData;
            string newType = typeNameInfo.GetId();

            isConst = false;
            string oriType = string.Empty;
            if (null != typeInfoVal) {
                oriType = typeInfoVal.GetId();
            }
            else if (null != typeInfoFunc) {
                var pf = typeInfoFunc;
                if (null != pf && pf.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_ANGLE_BRACKET_COLON) {
                    oriType = BuildTypeWithTypeArgs(pf);
                }
            }
            else if (null != typeInfoStm) {
                foreach (var p in typeInfoStm.Functions) {
                    var pv = p as Dsl.ValueData;
                    if (null != pv) {
                        string key = pv.GetId();
                        if (key == "const")
                            isConst = true;
                        else
                            oriType = key;
                    }
                    else {
                        var pf = p as Dsl.FunctionData;
                        if (null != pf && pf.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_ANGLE_BRACKET_COLON) {
                            oriType = BuildTypeWithTypeArgs(pf);
                        }
                    }
                }
            }
            if (null != typeNameFunc) {
                List<string> arrTags = new List<string>();
                BuildTypeWithArrTags(typeNameFunc, arrTags);
                if (arrTags.Count > 0) {
                    var sb = NewStringBuilder();
                    sb.Append(oriType);
                    for (int ix = arrTags.Count - 1; ix >= 0; --ix) {
                        sb.Append(arrTags[ix]);
                    }
                    oriType = sb.ToString();
                    RecycleStringBuilder(sb);
                }
            }
            return new KeyValuePair<string, string>(newType, oriType);
        }
        private static bool AddTypeDef(string newType, string oriType)
        {
            bool isGlobal = false;
            var funcInfo = CurFuncInfo();
            if (null != funcInfo) {
                var infos = funcInfo.LocalTypeDefs;
                infos[newType] = oriType;
            }
            else {
                var infos = s_GlobalTypeDefs;
                infos[newType] = oriType;
                isGlobal = true;
            }
            return isGlobal;
        }
        private static VarInfo ParseVarInfo(Dsl.FunctionData varFunc, Dsl.StatementData? varStm)
        {
            var varInfo = new VarInfo();
            string funcId = varFunc.GetId();
            if (funcId == "var" || funcId == "field" || funcId == "func") {
                var specFunc = varFunc.GetParam(0) as Dsl.FunctionData;
                Debug.Assert(null != specFunc);
                var typeInfo = varFunc.GetParam(1);
                var typeInfoVal = typeInfo as Dsl.ValueData;
                var typeInfoFunc = typeInfo as Dsl.FunctionData;
                var typeInfoStm = typeInfo as Dsl.StatementData;
                var nameInfo = varFunc.GetParam(2);
                var nameInfoFunc = nameInfo as Dsl.FunctionData;
                string varName = varFunc.GetParamId(2);
                string arrTag = string.Empty;
                if (null != nameInfoFunc) {
                    arrTag = BuildTypeWithTypeArgs(nameInfoFunc).Substring(varName.Length);
                }

                varInfo.Name = varName;
                if (null != typeInfoVal) {
                    varInfo.IsConst = false;
                    varInfo.Type = typeInfoVal.GetId() + arrTag;
                }
                else if (null != typeInfoFunc) {
                    var pf = typeInfoFunc;
                    if (null != pf && pf.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_ANGLE_BRACKET_COLON) {
                        varInfo.Type = BuildTypeWithTypeArgs(pf) + arrTag;
                    }
                }
                else if (null != typeInfoStm) {
                    foreach (var p in typeInfoStm.Functions) {
                        var pv = p as Dsl.ValueData;
                        if (null != pv) {
                            string key = pv.GetId();
                            if (key == "const")
                                varInfo.IsConst = true;
                            else
                                varInfo.Type = key + arrTag;
                        }
                        else {
                            var pf = p as Dsl.FunctionData;
                            if (null != pf && pf.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_ANGLE_BRACKET_COLON) {
                                varInfo.Type = BuildTypeWithTypeArgs(pf) + arrTag;
                            }
                        }
                    }
                }
                foreach (var p in specFunc.Params) {
                    var key = p.GetId();
                    varInfo.Modifiers.Add(key);

                    if (key == "inout")
                        varInfo.IsInOut = true;
                    else if (key == "out")
                        varInfo.IsOut = true;
                }
                if (null != varStm) {
                    for (int funcIx = 1; funcIx < varStm.GetFunctionNum(); ++funcIx) {
                        var func = varStm.GetFunction(funcIx);
                        string id = func.GetId();
                        if (id == "semantic") {
                            var adlFunc = func.AsFunction;
                            Debug.Assert(null != adlFunc);
                            if (adlFunc.IsHighOrder)
                                varInfo.Semantic = adlFunc.LowerOrderFunction.GetParamId(0);
                            else
                                varInfo.Semantic = adlFunc.GetParamId(0);
                        }
                        else if (id == "register") {
                            var adlFunc = func.AsFunction;
                            Debug.Assert(null != adlFunc);
                            varInfo.Register = adlFunc.GetParamId(0);
                        }
                    }
                }
                if (s_GlobalTypeDefs.TryGetValue(varInfo.Type, out var otype)) {
                    varInfo.Type = otype;
                }
                varInfo.OriType = varInfo.Type;
            }
            return varInfo;
        }
        private static FuncInfo? CurFuncInfo()
        {
            FuncInfo? curFuncInfo = null;
            if (s_LexicalScopeStack.Count > 0) {
                var curBlockInfo = s_LexicalScopeStack.Peek();
                curFuncInfo = curBlockInfo.OwnerFunc;
            }
            return curFuncInfo;
        }
        private static bool CurFuncBlockInfoConstructed()
        {
            bool ret = false;
            var funcInfo = CurFuncInfo();
            if (null != funcInfo) {
                ret = funcInfo.BlockInfoConstructed;
            }
            return ret;
        }
        private static bool CurFuncCodeGenerateEnabled()
        {
            bool ret = true;
            var funcInfo = CurFuncInfo();
            if (null != funcInfo) {
                ret = funcInfo.CodeGenerateEnabled;
            }
            return ret;
        }
        private static void ClearParamInfo(FuncInfo? funcInfo)
        {
            if (null == funcInfo)
                funcInfo = CurFuncInfo();
            if (null != funcInfo) {
                funcInfo.Params.Clear();
                funcInfo.HasInOutOrOutParams = false;
                funcInfo.InOutOrOutParams.Clear();
            }
        }
        private static void AddParamInfo(VarInfo varInfo, FuncInfo? funcInfo)
        {
            if (null == funcInfo)
                funcInfo = CurFuncInfo();
            if (null != funcInfo) {
                funcInfo.Params.Add(varInfo);
                if (varInfo.IsInOut || varInfo.IsOut) {
                    funcInfo.HasInOutOrOutParams = true;
                    funcInfo.InOutOrOutParams.Add(varInfo);
                }

                var curBlockInfo = funcInfo.ToplevelBlock;
                Debug.Assert(null != curBlockInfo);
                varInfo.OwnerBlock = curBlockInfo;
                varInfo.OwnerBasicBlockIndex = curBlockInfo.CurBasicBlockIndex;
                varInfo.OwnerStatementIndex = curBlockInfo.CurBasicBlock().CurStatementIndex;
            }
        }
        private static bool AddVar(VarInfo varInfo)
        {
            bool isGlobal = false;
            var funcInfo = CurFuncInfo();
            if (null != funcInfo) {
                if (funcInfo.LocalTypeDefs.TryGetValue(varInfo.Type, out var otype)) {
                    varInfo.Type = otype;
                    varInfo.OriType = otype;
                }
                bool isNew = false;
                if (funcInfo.UniqueLocalVarInfos.TryGetValue(varInfo.Name, out var vi)) {
                    vi.CopyParseInfoFrom(varInfo, out var ty);
                    if (varInfo.Type != ty)
                        varInfo.Type = ty;
                }
                else {
                    isNew = true;
                    funcInfo.UniqueLocalVarInfos.Add(varInfo.Name, varInfo);
                }
                if (!funcInfo.VarRenamed) {
                    var infos = funcInfo.LocalVarInfos;
                    if (!infos.TryGetValue(varInfo.OriName, out var varInfos)) {
                        varInfos = new Dictionary<int, VarInfo>();
                        infos.Add(varInfo.OriName, varInfos);
                    }
                    int curBlockId = CurBlockId();
                    if (!varInfos.TryGetValue(curBlockId, out var vinfo)) {
                        isNew = true;
                        varInfos.Add(curBlockId, varInfo);
                    }
                    else {
                        varInfos[curBlockId] = varInfo;
                    }
                }

                var curBlockInfo = CurBlockInfo();
                Debug.Assert(null != curBlockInfo);
                varInfo.OwnerBlock = curBlockInfo;
                varInfo.OwnerBasicBlockIndex = curBlockInfo.CurBasicBlockIndex;
                varInfo.OwnerStatementIndex = curBlockInfo.CurBasicBlock().CurStatementIndex;

                if (isNew) {
                    if (curBlockInfo.CurBasicBlockStatementDeclVars.TryGetValue(varInfo.Name, out var dvInfo)) {
                        dvInfo.Type = varInfo.Type;
                    }
                    else {
                        curBlockInfo.CurBasicBlockStatementDeclVars.Add(varInfo.Name, new DeclVarInfo { Name = varInfo.Name, Type = varInfo.Type });
                    }
                    if (!curBlockInfo.CurBasicBlockStatementUsingVars.TryGetValue(varInfo.Name, out var usingVarInfo)) {
                        usingVarInfo = new UsingVarInfo();
                        curBlockInfo.CurBasicBlockStatementUsingVars.Add(varInfo.Name, usingVarInfo);
                    }
                    if (!CurFuncBlockInfoConstructed()) {
                        var bvInfoNew = new BlockVarInfo { Name = varInfo.Name, Type = varInfo.Type, Usage = VarUsage.Decl, OwnerBlock = varInfo.OwnerBlock, OwnerBasicBlockIndex = varInfo.OwnerBasicBlockIndex, OwnerStatementIndex = varInfo.OwnerStatementIndex };
                        usingVarInfo.Vars.Add(bvInfoNew);
                    }
                    ++usingVarInfo.UsingCount;
                }
            }
            else {
                if (s_GlobalVarInfos.TryGetValue(varInfo.Name, out var vinfo)) {
                    vinfo.CopyParseInfoFrom(varInfo, out var ty);
                    if (varInfo.Type != ty)
                        varInfo.Type = ty;
                }
                else {
                    s_GlobalVarInfos.Add(varInfo.Name, varInfo);
                }
                isGlobal = true;
            }
            return isGlobal;
        }
        private static BlockInfo? GetOrNewBlockInfo(Dsl.ISyntaxComponent syntax, int ix)
        {
            BlockInfo? blockInfo = null;
            if (CurFuncBlockInfoConstructed()) {
                if (s_LexicalScopeStack.Count > 0) {
                    var curBlockInfo = s_LexicalScopeStack.Peek();
                    blockInfo = curBlockInfo.FindChild(syntax, ix);
                }
            }
            else {
                blockInfo = new BlockInfo();
                blockInfo.Syntax = syntax;
                blockInfo.FuncSyntaxIndex = ix;
            }
            var curFunc = CurFuncInfo();
            if (null != curFunc && null != blockInfo) {
                blockInfo.Attribute = curFunc.LastAttribute;
            }
            return blockInfo;
        }
        private static int CurBlockId()
        {
            if (s_LexicalScopeStack.Count > 0) {
                var curBlockInfo = s_LexicalScopeStack.Peek();
                return curBlockInfo.BlockId;
            }
            return 0;
        }
        private static BlockInfo? CurBlockInfo()
        {
            BlockInfo? ret = null;
            if (s_LexicalScopeStack.Count > 0) {
                ret = s_LexicalScopeStack.Peek();
            }
            return ret;
        }
        private static void PushBlock(BlockInfo blockInfo)
        {
            blockInfo.ResetCurBasicBlock(0);
            if (!CurFuncBlockInfoConstructed()) {
                ++s_LastBlockId;
                blockInfo.BlockId = s_LastBlockId;
                if (s_LexicalScopeStack.Count > 0) {
                    var parent = s_LexicalScopeStack.Peek();
                    blockInfo.Parent = parent;
                    blockInfo.OwnerFunc = parent.OwnerFunc;
                    parent.AddChild(blockInfo);
                }
                else {
                    blockInfo.Parent = null;
                }
            }
            s_LexicalScopeStack.Push(blockInfo);
        }
        private static void PopBlock()
        {
            PopBlock(false);
        }
        private static void PopBlock(bool keepBasicBlock)
        {
            var blockInfo = s_LexicalScopeStack.Pop();
            if (s_LexicalScopeStack.Count > 0) {
                var parent = s_LexicalScopeStack.Peek();
                if (CurFuncBlockInfoConstructed() && !keepBasicBlock) {
                    int ix = parent.FindChildIndex(blockInfo, out var six);
                    if (ix >= 0) {
                        if (six >= 0) {
                            var firstBlock = parent.ChildBlocks[ix];
                            if (six == firstBlock.SubsequentBlocks.Count - 1) {
                                parent.ResetCurBasicBlock(ix + 1);
                            }
                        }
                        else if (blockInfo.SubsequentBlocks.Count == 0) {
                            parent.ResetCurBasicBlock(ix + 1);
                        }
                    }
                }
                else if (!keepBasicBlock) {
                    parent.ResetCurBasicBlock(parent.BasicBlocks.Count - 1);
                }
            }
        }

        private static ComputeGraph CurComputeGraph()
        {
            var curFunc = CurFuncInfo();
            if (null != curFunc)
                return curFunc.FuncComputeGraph;
            else
                return s_GlobalComputeGraph;
        }
        private static void AddComputeGraphRootNode(ComputeGraphNode gn)
        {
            var cg = CurComputeGraph();
            cg.RootNodes.Add(gn);
        }
        private static void AddComputeGraphVarNode(ComputeGraphVarNode cgvn)
        {
            var cg = CurComputeGraph();
            if (cg.VarNodes.TryGetValue(cgvn.VarName, out var node)) {
                node.Type = cgvn.Type;
                node.IsOut = cgvn.IsOut;
                node.IsInOut = cgvn.IsInOut;
            }
            else {
                cg.VarNodes.Add(cgvn.VarName, cgvn);
            }
        }
        private static ComputeGraphVarNode? FindComputeGraphVarNode(string name)
        {
            ComputeGraphVarNode? ret = null;
            var cg = CurComputeGraph();
            if (cg.VarNodes.TryGetValue(name, out var node)) {
                ret = node;
            }
            else if (s_GlobalComputeGraph != cg) {
                if (s_GlobalComputeGraph.VarNodes.TryGetValue(name, out var gnode))
                    ret = gnode;
            }
            return ret;
        }

        internal static bool TryRenameVar(VarInfo varInfo)
        {
            bool ret = false;
            var funcInfo = CurFuncInfo();
            if (null != funcInfo && !funcInfo.VarRenamed) {
                var infos = funcInfo.LocalVarInfos;
                if (infos.TryGetValue(varInfo.Name, out var varInfos) && varInfos.Count > 0) {
                    int curBlockId = CurBlockId();
                    if (!varInfos.TryGetValue(curBlockId, out var vinfo)) {
                        varInfo.OriName = varInfo.Name;
                        varInfo.Name = varInfo.Name + "_" + CurBlockId();
                        ret = true;
                    }
                }
                else {
                    varInfo.OriName = varInfo.Name;
                }
            }
            else {
                varInfo.OriName = varInfo.Name;
            }
            return ret;
        }
        internal static VarInfo? GetVarInfo(string name, VarUsage usage)
        {
            VarInfo? varInfo = null;
            bool hasLocalVar = false;
            var funcInfo = CurFuncInfo();
            if (null != funcInfo) {
                if (!funcInfo.VarRenamed && funcInfo.LocalVarInfos.TryGetValue(name, out var varInfos)) {
                    hasLocalVar = true;
                    foreach (var blockInfo in s_LexicalScopeStack) {
                        int blockId = blockInfo.BlockId;
                        if (varInfos.TryGetValue(blockId, out varInfo))
                            break;
                    }
                }
                else if (funcInfo.UniqueLocalVarInfos.TryGetValue(name, out var vinfo)) {
                    varInfo = vinfo;
                }
                if (null == varInfo) {
                    foreach (var p in funcInfo.Params) {
                        if (p.Name == name) {
                            varInfo = p;
                            if (hasLocalVar) {
                                Console.WriteLine("[error]: the param '{0}' of function '{1}' conflicts with local variable. please rename it !", name, funcInfo.Name);
                            }
                            break;
                        }
                    }
                }
            }
            if (null == varInfo) {
                if (s_GlobalVarInfos.TryGetValue(name, out var vinfo)) {
                    varInfo = vinfo;
                    if (hasLocalVar) {
                        Debug.Assert(null != funcInfo);
                        Console.WriteLine("[error]: the local variable '{0}' of function '{1}' conflicts with global variable. please rename it !", name, funcInfo.Name);
                    }
                }
                if (!s_IsVectorizing && null != varInfo && (usage == VarUsage.Read || usage == VarUsage.Write || usage == VarUsage.ObjSet)) {
                    if (null != funcInfo) {
                        if (!funcInfo.UsingGlobals.Contains(name))
                            funcInfo.UsingGlobals.Add(name);
                    }
                    else {
                        AddInitGlobal(name);
                    }
                }
            }
            if (!s_IsVectorizing && null != varInfo) {
                var curBlockInfo = CurBlockInfo();
                Debug.Assert(null == curBlockInfo && null == funcInfo || null != curBlockInfo);
                if (null != curBlockInfo) {
                    if (usage == VarUsage.ObjSet) {
                        if (null != funcInfo) {
                            foreach (var p in funcInfo.Params) {
                                if (p.Name == name) {
                                    var mps = funcInfo.ModifiedParams;
                                    if (!mps.Contains(name))
                                        mps.Add(name);
                                    break;
                                }
                            }
                        }
                    }
                    switch (usage) {
                        case VarUsage.Decl:
                        case VarUsage.Read:
                        case VarUsage.Write:
                        case VarUsage.ObjSet:
                            if (!curBlockInfo.CurBasicBlockStatementUsingVars.TryGetValue(varInfo.Name, out var usingVarInfo)) {
                                usingVarInfo = new UsingVarInfo();
                                curBlockInfo.CurBasicBlockStatementUsingVars.Add(varInfo.Name, usingVarInfo);
                            }
                            if (!CurFuncBlockInfoConstructed()) {
                                var bvInfoNew = new BlockVarInfo { Name = varInfo.Name, Type = varInfo.Type, Usage = usage, OwnerBlock = varInfo.OwnerBlock, OwnerBasicBlockIndex = varInfo.OwnerBasicBlockIndex, OwnerStatementIndex = varInfo.OwnerStatementIndex };
                                usingVarInfo.Vars.Add(bvInfoNew);
                            }
                            ++usingVarInfo.UsingCount;
                            break;
                    }
                }
            }
            return varInfo;
        }
        internal static void AddGlobalDecl(VarInfo varInfo)
        {
            s_DeclGlobals.Add(varInfo);
        }
        internal static void AddInitGlobal(string name)
        {
            if (!s_InitGlobals.Contains(name))
                s_InitGlobals.Add(name);
        }
        internal static void RemoveInitGlobal(string name)
        {
            s_InitGlobals.Remove(name);
        }
        internal static StringBuilder NewStringBuilder()
        {
            return s_StringBuilderPool.Alloc();
        }
        internal static void RecycleStringBuilder(StringBuilder sb)
        {
            s_StringBuilderPool.Recycle(sb);
        }

        private static Dictionary<string, StructInfo> s_StructInfos = new Dictionary<string, StructInfo>();
        private static Dictionary<string, CBufferInfo> s_CBufferInfos = new Dictionary<string, CBufferInfo>();
        private static Dictionary<string, string> s_GlobalTypeDefs = new Dictionary<string, string>();
        private static Dictionary<string, VarInfo> s_GlobalVarInfos = new Dictionary<string, VarInfo>();
        private static Stack<BlockInfo> s_LexicalScopeStack = new Stack<BlockInfo>();
        private static int s_LastBlockId = 0;
        private static int s_UniqueNumber = 0;

        internal static List<VarInfo> s_DeclGlobals = new List<VarInfo>();
        internal static List<string> s_InitGlobals = new List<string>();
        internal static ComputeGraph s_GlobalComputeGraph = new ComputeGraph();
        internal static Dictionary<string, FuncInfo> s_FuncInfos = new Dictionary<string, FuncInfo>();
        internal static HashSet<string> s_VectorizableFuncs = new HashSet<string>();

        internal static string s_MainEntryFuncSignature = string.Empty;
        internal static SortedDictionary<string, Dsl.StatementData> s_EntryFuncs = new SortedDictionary<string, Dsl.StatementData>();
        internal static Dictionary<string, HashSet<string>> s_FuncCallFuncs = new Dictionary<string, HashSet<string>>();
        internal static List<string> s_AllFuncSigs = new List<string>();
        internal static Dictionary<string, Dsl.StatementData> s_AllFuncDsls = new Dictionary<string, Dsl.StatementData>();
        internal static Dictionary<string, StringBuilder> s_AllFuncCodes = new Dictionary<string, StringBuilder>();

        internal static HashSet<string> s_AllUsingFuncOrApis = new HashSet<string>();
        internal static Dictionary<string, StringBuilder> s_AutoGenCodes = new Dictionary<string, StringBuilder>();

        internal static HashSet<string> s_ScalarUsingFuncOrApis = new HashSet<string>();
        internal static Dictionary<string, StringBuilder> s_ScalarAutoGenCodes = new Dictionary<string, StringBuilder>();

        internal static HashSet<string> s_GlobalCalledScalarFuncs = new HashSet<string>();
        internal static HashSet<string> s_GlobalUsingFuncOrApis = new HashSet<string>();
        internal static Dictionary<string, StringBuilder> s_GlobalAutoGenCodes = new Dictionary<string, StringBuilder>();

        internal static Dictionary<string, HashSet<string>> s_FuncOverloads = new Dictionary<string, HashSet<string>>();

        internal static StringBuilderPool s_StringBuilderPool = new StringBuilderPool();
        internal static bool s_IsDebugMode = false;
        internal static bool s_UseHlsl2018 = true;

        internal static bool s_VarRenamed = false;
        internal static bool s_IsVectorizing = false;
        internal static bool s_IsVectorized = false;

        internal static bool s_IsTorch = false;
        internal static bool s_AutoUnrollLoops = false;
        internal static bool s_EnableVectorization = true;
        internal static bool s_EnableConstPropagation = true;
        internal static bool s_PrintVectorizedVars = false;

        internal static Dsl.ValueData s_ConstDslValueOne = new Dsl.ValueData("1", Dsl.ValueData.NUM_TOKEN);
        internal static string s_FloatFormat = "###########################0.00#####";
        internal static string s_DoubleFormat = "###########################0.000000#########";

        internal static List<string> s_TorchImports = new List<string> {
            "hlsl_lib_torch.py",
            "hlsl_lib_torch_swizzle.py",
        };
        internal static List<string> s_NumpyImports = new List<string> {
            "hlsl_lib_numpy.py",
            "hlsl_lib_numpy_swizzle.py",
        };
        internal static List<string> s_TorchImportsFor2021 = new List<string> {
            "hlsl_lib_torch.py",
            "hlsl_lib_torch_swizzle.py",
        };
        internal static List<string> s_NumpyImportsFor2021 = new List<string> {
            "hlsl_lib_numpy.py",
            "hlsl_lib_numpy_swizzle.py",
        };
        internal static string s_TorchInc = "hlsl_inc_torch.py";
        internal static string s_NumpyInc = "hlsl_inc_numpy.py";
        internal static string s_TorchIncFor2021 = "hlsl_inc_torch.py";
        internal static string s_NumpyIncFor2021 = "hlsl_inc_numpy.py";

        private static Dictionary<string, string> s_HlslType2TorchTypes = new Dictionary<string, string> {
            { "half", "torch.float16" },
            { "float", "torch.float32" },
            { "double", "torch.float64" },
            { "bool", "torch.bool" },
            { "int", "torch.int32" },
            { "uint", "torch.int32" },
            { "dword", "torch.int32" },
        };
        internal static Dictionary<string, string> s_HlslType2NumpyTypes = new Dictionary<string, string> {
            { "half", "np.float16" },
            { "float", "np.float32" },
            { "double", "np.float64" },
            { "bool", "np.bool" },
            { "int", "np.int32" },
            { "uint", "np.uint32" },
            { "dword", "np.uint32" },
        };

        internal const string c_TupleTypePrefix = "tuple_";
        internal const string c_VectorialTupleTypeTag = "_t_";
        internal const string c_VectorialTypePrefix = "t_";
        internal const string c_VectorialNameSuffix = "_arr";

        internal static Dictionary<string, string> s_OperatorNames = new Dictionary<string, string> {
            { "+", "h_add" },
            { "-", "h_sub" },
            { "*", "h_mul" },
            { "/", "h_div" },
            { "%", "h_mod" },
            { "&", "h_bitand" },
            { "|", "h_bitor" },
            { "^", "h_bitxor" },
            { "~", "h_bitnot" },
            { "<<", "h_lshift" },
            { ">>", "h_rshift" },
            { "&&", "h_and" },
            { "||", "h_or" },
            { "!", "h_not" },
            { "==", "h_equal" },
            { "!=", "h_not_equal" },
            { "<", "h_less_than" },
            { ">", "h_greater_than" },
            { "<=", "h_less_equal_than" },
            { ">=", "h_greater_equal_than" },
        };

        internal static HashSet<string> s_KeepBaseTypeFuncs = new HashSet<string> {
            "h_inc",
            "h_dec",
            "h_add",
            "h_sub",
            "h_mul",
            "h_div",
            "h_mod",
            "h_bitand",
            "h_bitor",
            "h_bitxor",
            "h_bitnot",
            "h_lshift",
            "h_rshift",
        };
        internal static HashSet<string> s_KeepFullTypeFuncs = new HashSet<string> {
            "h_matmul",
        };

        internal static Dictionary<string, string> s_BuiltInFuncs = new Dictionary<string, string> {
            { "float", "@@" },
            { "float2", "@@" },
            { "float3", "@@" },
            { "float4", "@@" },
            { "double", "@@" },
            { "double2", "@@" },
            { "double3", "@@" },
            { "double4", "@@" },
            { "uint", "@@" },
            { "uint2", "@@" },
            { "uint3", "@@" },
            { "uint4", "@@" },
            { "dword", "@@" },
            { "dword2", "@@" },
            { "dword3", "@@" },
            { "dword4", "@@" },
            { "int", "@@" },
            { "int2", "@@" },
            { "int3", "@@" },
            { "int4", "@@" },
            { "bool", "@@" },
            { "bool2", "@@" },
            { "bool3", "@@" },
            { "bool4", "@@" },
            { "half", "@@" },
            { "half2", "@@" },
            { "half3", "@@" },
            { "half4", "@@" },
            { "float2x2", "@@" },
            { "float3x3", "@@" },
            { "float4x4", "@@" },
            { "double2x2", "@@" },
            { "double3x3", "@@" },
            { "double4x4", "@@" },
            { "uint2x2", "@@" },
            { "uint3x3", "@@" },
            { "uint4x4", "@@" },
            { "dword2x2", "@@" },
            { "dword3x3", "@@" },
            { "dword4x4", "@@" },
            { "int2x2", "@@" },
            { "int3x3", "@@" },
            { "int4x4", "@@" },
            { "bool2x2", "@@" },
            { "bool3x3", "@@" },
            { "bool4x4", "@@" },
            { "half2x2", "@@" },
            { "half3x3", "@@" },
            { "half4x4", "@@" },
            { "abort", "void" },
            { "abs", "@0" },
            { "acos", "@0" },
            { "all", "bool" },
            { "AllMemoryBarrier", "void" },
            { "AllMemoryBarrierWithGroupSync", "void" },
            { "any", "bool" },
            { "asdouble", "double$0" },
            { "asfloat", "float$0" },
            { "asin", "@0" },
            { "asint", "int$0" },
            { "asuint", "uint$0" },
            { "atan", "@0" },
            { "atan2", "@0" },
            { "ceil", "@0" },
            { "CheckAccessFullyMapped", "bool" },
            { "clamp", "@m" },
            { "clip", "void" },
            { "cos", "@0" },
            { "cosh", "@0" },
            { "countbits", "uint" },
            { "cross", "float3" },
            { "D3DCOLORtoUBYTE4", "int4" },
            { "ddx", "@0" },
            { "ddx_coarse", "float" },
            { "ddx_fine", "float" },
            { "ddy", "@0" },
            { "ddy_coarse", "float" },
            { "ddy_fine", "float" },
            { "degrees", "@0" },
            { "determinant", "float" },
            { "DeviceMemoryBarrier", "void" },
            { "DeviceMemoryBarrierWithGroupSync", "void" },
            { "distance", "float" },
            { "dot", "@0-$0" },
            { "dst", "@0" },
            { "errorf", "void" },
            { "EvaluateAttributeCentroid", "@0" },
            { "EvaluateAttributeAtSample", "@0" },
            { "EvaluateAttributeSnapped", "@0" },
            { "exp", "@0" },
            { "exp2", "@0" },
            { "f16tof32", "float" },
            { "f32tof16", "uint" },
            { "faceforward", "@0" },
            { "firstbithigh", "int"},
            { "firstbitlow", "int"},
            { "floor", "@0" },
            { "fma", "@0" },
            { "fmod", "@0" },
            { "frac", "@0" },
            { "frexp", "@0" },
            { "fwidth", "@0" },
            { "GetRenderTargetSampleCount", "uint" },
            { "GetRenderTargetSamplePosition", "float2" },
            { "GroupMemoryBarrier", "void" },
            { "GroupMemoryBarrierWithGroupSync", "void" },
            { "InterlockedAdd", "void" },
            { "InterlockedAnd", "void" },
            { "InterlockedCompareExchange", "void" },
            { "InterlockedCompareStore", "void" },
            { "InterlockedExchange", "void" },
            { "InterlockedMax", "void" },
            { "InterlockedMin", "void" },
            { "InterlockedOr", "void" },
            { "InterlockedXor", "void" },
            { "isfinite", "bool$0" },
            { "isinf", "bool$0" },
            { "isnan", "bool$0" },
            { "ldexp", "@0" },
            { "length", "float" },
            { "lerp", "@0" },
            { "lit", "float4" },
            { "log", "@0" },
            { "log10", "@0" },
            { "log2", "@0" },
            { "mad", "@0" },
            { "max", "@0" },
            { "min", "@0" },
            { "modf", "@0" },
            { "msad4", "uint4" },
            { "normalize", "@0" },
            { "pow", "@0" },
            { "printf", "void" },
            { "Process2DQuadTessFactorsAvg", "void" },
            { "Process2DQuadTessFactorsMax", "void" },
            { "Process2DQuadTessFactorsMin", "void" },
            { "ProcessIsolineTessFactors", "void" },
            { "ProcessQuadTessFactorsAvg", "void" },
            { "ProcessQuadTessFactorsMax", "void" },
            { "ProcessQuadTessFactorsMin", "void" },
            { "ProcessTriTessFactorsAvg", "void" },
            { "ProcessTriTessFactorsMax", "void" },
            { "ProcessTriTessFactorsMin", "void" },
            { "radians", "@0" },
            { "rcp", "@0" },
            { "reflect", "@0" },
            { "refract", "@0" },
            { "reversebits", "uint" },
            { "round", "@0" },
            { "rsqrt", "@0" },
            { "saturate", "@0" },
            { "sign", "int$0" },
            { "sin", "@0" },
            { "sincos", "@0" },
            { "sinh", "@0" },
            { "smoothstep", "@m" },
            { "sqrt", "@0" },
            { "step", "@m" },
            { "tan", "@0" },
            { "tanh", "@0" },
            { "tex1D", "float4" },
            { "tex1Dbias", "float4" },
            { "tex1Dgrad", "float4" },
            { "tex1Dlod", "float4" },
            { "tex1Dproj", "float4" },
            { "tex2D", "float4" },
            { "tex2Dbias", "float4" },
            { "tex2Dgrad", "float4" },
            { "tex2Dlod", "float4" },
            { "tex2Dproj", "float4" },
            { "tex3D", "float4" },
            { "tex3Dbias", "float4" },
            { "tex3Dgrad", "float4" },
            { "tex3Dlod", "float4" },
            { "tex3Dproj", "float4" },
            { "texCUBE", "float4" },
            { "texCUBEbias", "float4" },
            { "texCUBEgrad", "float4" },
            { "texCUBElod", "float4" },
            { "texCUBEproj", "float4" },
            { "transpose", "@0" },
            { "trunc", "@0" },
        };
        internal static Dictionary<string, Dictionary<string, string>> s_BuiltInMemFuncs = new Dictionary<string, Dictionary<string, string>> {
            { "Texture2D", new Dictionary<string, string> {
                    { "Load", "@0-$04" },
                    { "Sample", "@1-$14" },
                    { "SampleBias", "@1-$14" },
                    { "SampleLevel", "@1-$14" },
                    { "SampleGrad", "@1-$14" },
                    { "Gather", "@1-$14" },
                }},
            { "Texture2D__float4_T", new Dictionary<string, string> {
                    { "Load", "@0-$04" },
                    { "Sample", "@1-$14" },
                    { "SampleBias", "@1-$14" },
                    { "SampleLevel", "@1-$14" },
                    { "SampleGrad", "@1-$14" },
                    { "Gather", "@1-$14" },
                }},
            { "Texture2DArray", new Dictionary<string, string> {
                    { "Load", "@0-$04" },
                    { "Sample", "@1-$14" },
                    { "SampleBias", "@1-$14" },
                    { "SampleLevel", "@1-$14" },
                    { "SampleGrad", "@1-$14" },
                    { "Gather", "@1-$14" },
                }},
            { "Texture3D", new Dictionary<string, string> {
                    { "Load", "@0-$04" },
                    { "Sample", "@1-$14" },
                    { "SampleBias", "@1-$14" },
                    { "SampleLevel", "@1-$14" },
                    { "SampleGrad", "@1-$14" },
                    { "Gather", "@1-$14" },
                }},
            { "Texture3D__float4_T", new Dictionary<string, string> {
                    { "Load", "@0-$04" },
                    { "Sample", "@1-$14" },
                    { "SampleBias", "@1-$14" },
                    { "SampleLevel", "@1-$14" },
                    { "SampleGrad", "@1-$14" },
                    { "Gather", "@1-$14" },
                }},
            { "TextureCube", new Dictionary<string, string> {
                    { "Load", "@0-$04" },
                    { "Sample", "@1-$14" },
                    { "SampleBias", "@1-$14" },
                    { "SampleLevel", "@1-$14" },
                    { "SampleGrad", "@1-$14" },
                    { "Gather", "@1-$14" },
                }},
            { "TextureCube__float4_T", new Dictionary<string, string> {
                    { "Load", "@0-$04" },
                    { "Sample", "@1-$14" },
                    { "SampleBias", "@1-$14" },
                    { "SampleLevel", "@1-$14" },
                    { "SampleGrad", "@1-$14" },
                    { "Gather", "@1-$14" },
                }},
            { "TextureCubeArray", new Dictionary<string, string> {
                    { "Load", "@0-$04" },
                    { "Sample", "@1-$14" },
                    { "SampleBias", "@1-$14" },
                    { "SampleLevel", "@1-$14" },
                    { "SampleGrad", "@1-$14" },
                    { "Gather", "@1-$14" },
                }},
            { "ByteAddressBuffer", new Dictionary<string, string> {
                    { "Load", "@0-$0" },
                    { "Load2", "@0-$02" },
                    { "Load3", "@0-$03" },
                    { "Load4", "@0-$04" },
                }},
            { "RWByteAddressBuffer", new Dictionary<string, string> {
                    { "Load", "@0-$0" },
                    { "Load2", "@0-$02" },
                    { "Load3", "@0-$03" },
                    { "Load4", "@0-$04" },
                    { "Store", "void" },
                    { "Store2", "void" },
                    { "Store3", "void" },
                    { "Store4", "void" },
                }},
        };
        internal static Dictionary<string, Dictionary<string, string>> s_BuiltInMembers = new Dictionary<string, Dictionary<string, string>> {
        };

        internal static Dictionary<string, string> s_BaseTypeAbbrs = new Dictionary<string, string> {
            { "bool", "b" },
            { "int", "i" },
            { "uint", "u" },
            { "dword", "u" },
            { "half", "h" },
            { "float", "f" },
            { "double", "d" },
            { "min16float", "s16f" },
            { "min10float", "s10f" },
            { "min16int", "s16i" },
            { "min12int", "s12i" },
            { "min16uint", "s16u" },
            { "texture", "tx" },
            { "Texture1D", "t1d" },
            { "Texture1DArray", "t1da" },
            { "Texture2D", "t2d" },
            { "Texture2DArray", "t2da" },
            { "Texture3D", "t3d" },
            { "TextureCube", "tc" },
            { "sampler", "sx" },
            { "sampler1D", "s1d" },
            { "sampler2D", "s2d" },
            { "sampler3D", "s3d" },
            { "samplerCUBE", "sc" },
            { "sampler_state", "ss" },
            { "SamplerState", "ss" },
        };
    }
}
