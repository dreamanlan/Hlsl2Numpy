using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.CompilerServices;
using System.Security.AccessControl;
using System.Text;
using System.Xml.Linq;

namespace Hlsl2Numpy
{
    internal partial class ProgramTransform
    {
        internal static void CacheGlobalCallInfo()
        {
            foreach (var fn in s_AllUsingFuncOrApis) {
                s_GlobalUsingFuncOrApis.Add(fn);
            }
            foreach (var pair in s_AutoGenCodes) {
                s_GlobalAutoGenCodes.Add(pair.Key, pair.Value);
            }
        }
        internal static void SwapScalarCallInfo()
        {
            var apiNames = s_ScalarUsingFuncOrApis;
            s_ScalarUsingFuncOrApis = s_AllUsingFuncOrApis;
            s_AllUsingFuncOrApis = apiNames;

            var codes = s_ScalarAutoGenCodes;
            s_ScalarAutoGenCodes = s_AutoGenCodes;
            s_AutoGenCodes = codes;
        }
        internal static void MergeGlobalCallInfo()
        {
            foreach (var fn in s_GlobalCalledScalarFuncs) {
                if (s_FuncInfos.TryGetValue(fn, out var fi)) {
                    MarkCalledScalarFunc(fi);
                }
            }
            foreach (var fn in s_GlobalUsingFuncOrApis) {
                if (!s_AllUsingFuncOrApis.Contains(fn))
                    s_AllUsingFuncOrApis.Add(fn);
            }
            foreach (var pair in s_GlobalAutoGenCodes) {
                if (!s_AutoGenCodes.ContainsKey(pair.Key))
                    s_AutoGenCodes.Add(pair.Key, pair.Value);
            }
        }
        internal static void AddUsingFuncOrApi(string funcName)
        {
            if (!s_AllUsingFuncOrApis.Contains(funcName))
                s_AllUsingFuncOrApis.Add(funcName);
            var curFunc = CurFuncInfo();
            if (null != curFunc && !curFunc.UsingFuncOrApis.Contains(funcName)) {
                curFunc.UsingFuncOrApis.Add(funcName);
            }
        }
        internal static void AddFuncParamsToComputeGraph(FuncInfo funcInfo)
        {
            var graph = funcInfo.FuncComputeGraph;
            foreach (var p in funcInfo.Params) {
                var vgn = new ComputeGraphVarNode(funcInfo, p.Type, p.Name);
                vgn.IsInOut = p.IsInOut;
                vgn.IsOut = p.IsOut;
                vgn.IsParam = true;

                if (graph.VarNodes.TryGetValue(vgn.VarName, out var node)) {
                    node.Type = vgn.Type;
                    node.IsOut = vgn.IsOut;
                    node.IsInOut = vgn.IsInOut;
                }
                else {
                    graph.VarNodes.Add(vgn.VarName, vgn);
                }
            }
        }
        internal static void MarkCalledScalarFunc(FuncInfo funcInfo)
        {
            MarkCalledScalarFunc(funcInfo, false);
        }
        internal static void MarkCalledScalarFunc(FuncInfo funcInfo, bool isVecAdapter)
        {
            string sig = funcInfo.Signature;
            if (s_IsVectorizing) {
                if (!isVecAdapter)
                    funcInfo.ResetScalarFuncInfo();
                MarkCalledScalarFuncRecursively(sig);
            }
            else {
                var curFunc = CurFuncInfo();
                if (null != curFunc) {
                    string csig = curFunc.Signature;
                    if (!s_FuncCallFuncs.TryGetValue(csig, out var funcs)) {
                        funcs = new HashSet<string>();
                        s_FuncCallFuncs.Add(csig, funcs);
                    }
                    if (!funcs.Contains(sig)) {
                        funcs.Add(sig);
                    }
                }
                else if (!s_GlobalCalledScalarFuncs.Contains(sig)) {
                    s_GlobalCalledScalarFuncs.Add(sig);
                }
            }
        }
        internal static void MarkCalledScalarFuncRecursively(string funcSig)
        {
            if (s_FuncCallFuncs.TryGetValue(funcSig, out var funcs)) {
                foreach (var sig in funcs) {
                    MarkCalledScalarFuncRecursively(sig);
                }
            }
            if (!s_CalledScalarFuncs.Contains(funcSig))
                s_CalledScalarFuncs.Add(funcSig);
        }
        internal static bool IsSameType(string lhsType, string rhsType)
        {
            bool ret = true;
            if (lhsType != rhsType) {
                ret = false;
                string struName = GetTypeNoVecPrefix(lhsType, out var isVecBefore);
                if (IsTupleMatchStruct(struName, rhsType, out var fct, out var vct)) {
                    if (vct == 0) {
                        if (!isVecBefore)
                            ret = true;
                    }
                    else if (vct == fct) {
                        ret = true;
                    }
                }
            }
            return ret;
        }
        internal static bool IsTupleMatchStruct(string struName, string type, out int fieldCount, out int vecCt)
        {
            fieldCount = 0;
            vecCt = 0;
            bool ret = false;
            if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                fieldCount = struInfo.Fields.Count;
                int ix = 0;
                if (IsTupleMatchStruct(struInfo, type, ref ix, out var vecCt0)) {
                    vecCt = vecCt0;
                    ret = true;
                }
            }
            return ret;
        }
        internal static bool IsTupleMatchStruct(StructInfo struInfo, string type, ref int ix, out int vecCt)
        {
            vecCt = 0;
            bool ret = true;
            int nix0 = type.IndexOf(struInfo.Name, ix);
            if (nix0 == ix) {
                ix += struInfo.Name.Length;
            }
            else {
                string vty0 = GetTypeVec(struInfo.Name);
                nix0 = type.IndexOf(vty0, ix);
                if (nix0 == ix) {
                    ix += vty0.Length;
                    vecCt += struInfo.Fields.Count;
                }
                else {
                    ret = false;
                    string tag = c_TupleTypePrefix + struInfo.Fields.Count.ToString();
                    string struType = struInfo.Name;
                    string vecStruType = c_VectorialTypePrefix + struInfo.Name;
                    if (type.IndexOf(tag, ix) == ix) {
                        ix += tag.Length;
                        ret = true;
                        foreach (var fi in struInfo.Fields) {
                            string ty = fi.Type;
                            if (ix + 1 < type.Length && type[ix] == '_' && type[ix + 1] == '_') {
                                ix += 2;
                                if (s_StructInfos.TryGetValue(ty, out var cstruInfo)) {
                                    if (IsTupleMatchStruct(cstruInfo, type, ref ix, out var vct)) {
                                        if (cstruInfo.Fields.Count == vct)
                                            ++vecCt;
                                    }
                                    else {
                                        ret = false;
                                        break;
                                    }
                                }
                                else {
                                    int nix = type.IndexOf(ty, ix);
                                    if (nix == ix) {
                                        ix += ty.Length;
                                    }
                                    else {
                                        string vty = GetTypeVec(ty);
                                        nix = type.IndexOf(vty, ix);
                                        if (nix == ix) {
                                            ix += vty.Length;
                                            ++vecCt;
                                        }
                                        else {
                                            ret = false;
                                            break;
                                        }
                                    }
                                }
                            }
                            else {
                                ret = false;
                                break;
                            }
                        }
                    }
                    else if(type.IndexOf(struType, ix) == ix) {
                        ix += struType.Length;
                        ret = true;
                    }
                    else if (type.IndexOf(vecStruType, ix) == ix) {
                        ix += vecStruType.Length;
                        ret = true;
                    }
                }
            }
            return ret;
        }
        internal static string GetWhereResultType(string condExpType, string exp1Type, string exp2Type)
        {
            bool isVec = false;
            string opd1 = condExpType;
            string opd2 = exp1Type;
            string opd3 = exp2Type;
            string oriOpd2 = opd2;
            string oriOpd3 = opd3;
            if (s_IsVectorizing) {
                if (IsTypeVec(opd1)) {
                    isVec = true;
                }
                oriOpd2 = GetTypeNoVec(opd2, out var isTuple2, out var isStruct2, out var isVecBefore2);
                if (isVecBefore2) {
                    isVec = true;
                }
                oriOpd3 = GetTypeNoVec(opd3, out var isTuple3, out var isStruct3, out var isVecBefore3);
                if (isVecBefore3) {
                    isVec = true;
                }
            }
            Debug.Assert(oriOpd2 == oriOpd3);
            string resultType = GetMaxType(oriOpd2, oriOpd3);
            if (isVec)
                resultType = GetTypeVec(resultType);
            return resultType;
        }
        internal static string GetFuncResultType(string resultTypeTag, string funcOrObjType, IList<string> args, IList<string> oriArgs, bool isVec)
        {
            string ret;
            if (resultTypeTag == "@@")
                ret = funcOrObjType;
            else if (resultTypeTag == "@0-$0")
                ret = GetTypeRemoveSuffix(args[0]);
            else if (resultTypeTag == "@0")
                ret = args[0];
            else if (resultTypeTag == "@m") {
                ret = GetMaxType(oriArgs);
            }
            else if (!resultTypeTag.Contains('@') && !resultTypeTag.Contains('$'))
                ret = resultTypeTag;
            else {
                string rt = resultTypeTag.Replace("@@", funcOrObjType).Replace("@0-$0", GetTypeRemoveSuffix(args[0])).Replace("@0", args[0]).Replace("$0", GetTypeSuffix(args[0])).Replace("$R0", GetTypeSuffixReverse(args[0]));
                if (args.Count > 1) {
                    rt = rt.Replace("@1-$1", GetTypeRemoveSuffix(args[1])).Replace("@1", args[1]).Replace("$1", GetTypeSuffix(args[1])).Replace("$R1", GetTypeSuffixReverse(args[1]));
                }
                if (rt.Contains("m")) {
                    string mt;
                    mt = GetMaxType(oriArgs);
                    rt = rt.Replace("@m-$m", GetTypeRemoveSuffix(mt)).Replace("@m", mt).Replace("$m", GetTypeSuffix(mt)).Replace("$Rm", GetTypeSuffixReverse(mt));
                }
                ret = rt;
            }
            if (isVec)
                ret = GetTypeVec(ret);
            return ret;
        }
        internal static string GetMemberResultType(string resultTypeTag, string oriObjType, string memberOrType)
        {
            string ret;
            if (resultTypeTag == "@@")
                ret = oriObjType;
            else if (!resultTypeTag.Contains('@') && !resultTypeTag.Contains('$'))
                ret = resultTypeTag;
            else
                ret = resultTypeTag.Replace("@@", oriObjType).Replace("$0", memberOrType.Length.ToString());
            return ret;
        }
        internal static string GetMaxType(params string[] oriArgs)
        {
            IList<string> ats = oriArgs;
            return GetMaxType(ats);
        }
        internal static string GetMaxType(IList<string> oriArgs)
        {
            string ret = oriArgs[0];
            for (int i = 1; i < oriArgs.Count; ++i) {
                ret = ret.Length >= oriArgs[i].Length ? ret : oriArgs[i];
            }
            return ret;
        }
        internal static string GetMatmulType(string oriTypeA, string oriTypeB, bool isVec)
        {
            string ret;
            string bt1 = GetTypeRemoveSuffix(oriTypeA);
            string s1 = GetTypeSuffix(oriTypeA);
            string bt2 = GetTypeRemoveSuffix(oriTypeB);
            string s2 = GetTypeSuffix(oriTypeB);
            if (s1.Length == 0 && s2.Length == 0)
                ret = GetMaxType(oriTypeA, oriTypeB);
            else if (s1.Length == 0)
                ret = oriTypeB;
            else if (s2.Length == 0)
                ret = oriTypeA;
            else if (s1.Length == 1 && s2.Length == 1)
                ret = GetMaxType(oriTypeA, oriTypeB);
            else if (s1.Length == 1)
                ret = oriTypeA;
            else if (s2.Length == 1)
                ret = oriTypeB;
            else {
                string mt = GetMaxType(bt1, bt2);
                ret = mt + s1[0] + "x" + s2[2];
            }
            if (isVec)
                ret = GetTypeVec(ret);
            return ret;
        }
        internal static string GetFullTypeFuncSig(string funcName, IList<string> argTypes)
        {
            var sb = new StringBuilder();
            sb.Append(funcName);
            foreach (var t in argTypes) {
                sb.Append("_");
                sb.Append(GetTypeAbbr(t));
            }
            return sb.ToString();
        }
        internal static string GetBaseTypeCtorSig(string funcName, IList<string> argTypes)
        {
            bool hasVectorization = false;
            foreach (var argType in argTypes) {
                if (s_IsVectorizing && IsTypeVec(argType))
                    hasVectorization = true;
            }
            if (hasVectorization) {
                funcName = GetTypeVec(funcName);
            }
            var sb = new StringBuilder();
            sb.Append("h_");
            sb.Append(GetTypeAbbr(funcName));
            foreach (var argType in argTypes) {
                sb.Append(GetSuffixInfoFuncArgTag(argType));
            }
            return sb.ToString();
        }
        internal static string GetCastFuncSig(string argTypeDest, string argTypeSrc, out bool isBroadcast)
        {
            isBroadcast = false;
            if (s_IsVectorizing) {
                if (!IsTypeVec(argTypeSrc) && IsTypeVec(argTypeDest)) {
                    string argTypeDestNoVec = GetTypeNoVec(argTypeDest);
                    if (IsSameType(argTypeSrc, argTypeDestNoVec)) {
                        isBroadcast = true;
                    }
                }
                if (IsTypeVec(argTypeSrc)) {
                    argTypeDest = GetTypeVec(argTypeDest);
                }
            }
            var sb = new StringBuilder();
            if (isBroadcast) {
                sb.Append("h_broadcast_");
                sb.Append(GetTypeAbbr(argTypeSrc));
            }
            else {
                sb.Append("h_cast_");
                sb.Append(GetTypeAbbr(argTypeDest));
                sb.Append("_");
                sb.Append(GetTypeAbbr(argTypeSrc));
            }
            return sb.ToString();
        }
        internal static string GetFuncArgsTag(string funcName, params string[] argTypes)
        {
            IList<string> ats = argTypes;
            return GetFuncArgsTag(funcName, ats);
        }
        internal static string GetFuncArgsTag(string funcName, IList<string> argTypes)
        {
            var sb = new StringBuilder();
            if (s_KeepFullTypeFuncs.Contains(funcName)) {
                foreach (var t in argTypes) {
                    sb.Append("_");
                    sb.Append(GetTypeAbbr(t));
                }
            }
            else if (s_KeepBaseTypeFuncs.Contains(funcName)) {
                foreach (var t in argTypes) {
                    sb.Append(GetBaseTypeFuncArgTag(t));
                }
            }
            else {
                foreach (var t in argTypes) {
                    sb.Append(GetSimpleFuncArgTag(t));
                }
            }
            return sb.ToString();
        }

        internal static string GetSimpleFuncArgTag(string type)
        {
            string suffix = GetTypeSuffix(type, out var isTuple, out var isStruct, out var isArr, out var arrNums, out var typeWithoutArrTag);
            if (isTuple || isStruct)
                return "_" + GetSimpleArrayTypeAbbr(type);
            int dim = (suffix.Length == 3 ? 2 : (suffix.Length > 0 ? 1 : 0));
            string t = arrNums.Count > 0 ? "_" + new string('a', arrNums.Count) : "_";
            switch (dim) {
                case 0:
                    t += "n";
                    break;
                case 1:
                    t += "v";
                    break;
                case 2:
                default:
                    t += "m";
                    break;
            }
            string tag = (isArr ? "_t" : string.Empty) + t;
            return tag;
        }
        internal static string GetBaseTypeFuncArgTag(string type)
        {
            string suffix = GetTypeSuffix(type, out var isTuple, out var isStruct, out var isArr, out var arrNums, out var typeWithoutArrTag);
            if (isTuple || isStruct)
                return "_" + GetSimpleArrayTypeAbbr(type);
            string baseType = GetTypeNoVec(GetTypeRemoveSuffix(type));
            int dim = (suffix.Length == 3 ? 2 : (suffix.Length > 0 ? 1 : 0));
            string t = arrNums.Count > 0 ? "_" + new string('a', arrNums.Count) : "_";
            bool addUl = true;
            switch (dim) {
                case 0:
                    addUl = arrNums.Count > 0;
                    break;
                case 1:
                    t += "v";
                    break;
                case 2:
                default:
                    t += "m";
                    break;
            }
            string tag = (isArr ? "_t" : string.Empty) + t + GetBaseTypeAbbr(baseType, addUl);
            return tag;
        }
        internal static string GetSuffixInfoFuncArgTag(string type)
        {
            string suffix = GetTypeSuffix(type, out var isTuple, out var isStruct, out var isArr, out var arrNums, out var typeWithoutArrTag);
            if (isTuple || isStruct)
                return "_" + GetSimpleArrayTypeAbbr(type);
            string elemTag = "n";
            string struName = GetTypeNoVecPrefix(typeWithoutArrTag);
            if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                elemTag = GetTypeAbbr(struName);
            }
            string t = arrNums.Count > 0 ? "_" + new string('a', arrNums.Count) + elemTag : "_n";
            string tag = (isArr ? "_t" : string.Empty) + t + suffix;
            return tag;
        }
        internal static string GetSimpleArrayTypeAbbr(string type)
        {
            string typeWithoutArrTag = GetTypeRemoveArrTag(type, out var isTuple, out var isStruct, out var isVec, out var arrNums);
            string tag = GetTypeNoVecPrefix(GetTypeAbbr(typeWithoutArrTag, arrNums.Count > 0));
            string t = (arrNums.Count > 0 ? new string('a', arrNums.Count) : string.Empty) + tag;
            return (isVec ? GetTypeVec(t) : t);
        }
        internal static string GetTypeAbbr(string type)
        {
            return GetTypeAbbr(type, false);
        }
        internal static string GetTypeAbbr(string type, bool addUlOnComplex)
        {
            if (type.StartsWith(c_TupleTypePrefix)) {
                var sb = new StringBuilder();
                if (addUlOnComplex)
                    sb.Append("_");
                var strs = type.Split("__");
                string prestr = string.Empty;
                foreach (var str in strs) {
                    sb.Append(prestr);
                    if (str.StartsWith(c_TupleTypePrefix)) {
                        sb.Append("tp");
                        sb.Append(str.Substring(c_TupleTypePrefix.Length));
                    }
                    else {
                        sb.Append(GetTypeAbbr(str));
                    }
                    prestr = "_";
                }
                return sb.ToString();
            }
            string typeWithoutVec = GetTypeNoVec(type, out var isTuple, out var isStruct, out var isArr);
            string t;
            if (isStruct) {
                t = (addUlOnComplex ? "_" : string.Empty) + typeWithoutVec;
            }
            else {
                string baseType = GetTypeRemoveSuffix(typeWithoutVec);
                string suffixWithArr = typeWithoutVec.Substring(baseType.Length);
                t = GetBaseTypeAbbr(baseType, addUlOnComplex) + suffixWithArr;
            }
            return (isArr ? GetTypeVec(t) : t);
        }
        internal static string GetBaseTypeAbbr(string type, bool addUlOnComplex)
        {
            string ret;
            if (s_BaseTypeAbbrs.TryGetValue(type, out var r)) {
                ret = r;
            }
            else {
                ret = (addUlOnComplex ? "_" : string.Empty) + type;
            }
            return ret;
        }
        internal static bool IsBaseType(string type)
        {
            type = GetTypeNoVec(type);
            return type == "bool" || type == "int" || type == "uint" || type == "dword" ||
                        type == "float" || type == "double" || type == "half" ||
                        type == "min16float" || type == "min10float" || type == "min16int" ||
                        type == "min12int" || type == "min16uint";
        }
        internal static string GetTypeDims(string objType)
        {
            string ret = string.Empty;
            string oriObjType = GetTypeNoVec(objType);
            string suffix = GetTypeSuffix(oriObjType, out var isTuple, out var isStruct, out var isVec, out var arrNums, out var typeWithoutArrTag);
            if (isTuple || isStruct) {
                ret = "1";
            }
            else {
                if (string.IsNullOrEmpty(suffix))
                    ret = "1";
                else if (suffix.Length == 1)
                    ret = suffix;
                else
                    ret = suffix.Replace("x", ", ");
            }
            return ret;
        }
        internal static bool IsMemberAccess(Dsl.ISyntaxComponent func, out Dsl.FunctionData? funcData)
        {
            bool ret = false;
            funcData = func as Dsl.FunctionData;
            if (null != funcData && funcData.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_PERIOD) {
                ret = true;
            }
            return ret;
        }
        internal static bool IsElementAccess(Dsl.ISyntaxComponent func, out Dsl.FunctionData? funcData)
        {
            bool ret = false;
            funcData = func as Dsl.FunctionData;
            if (null != funcData && funcData.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_BRACKET) {
                ret = true;
            }
            return ret;
        }
        internal static bool IsArgsMatch(IList<string> args, FuncInfo funcInfo, out int score)
        {
            bool ret = false;
            score = 0;
            if (args.Count <= funcInfo.Params.Count) {
                ret = true;
                for (int ix = 0; ix < args.Count; ++ix) {
                    int argScore;
                    if (!IsTypeMatch(args[ix], funcInfo.Params[ix].Type, out argScore)) {
                        ret = false;
                        break;
                    }
                    score += argScore;
                }
                if (ret && args.Count < funcInfo.Params.Count) {
                    if (null == funcInfo.Params[args.Count].DefaultValueSyntax)
                        ret = false;
                }
            }
            return ret;
        }
        internal static bool IsTypeMatch(string argType, string paramType, out int score)
        {
            bool ret = false;
            score = 0;
            if (argType == paramType) {
                score = 2;
                ret = true;
            }
            else if ((argType == "bool" || argType == "int" || argType == "uint" || argType == "dword" || argType == "float" || argType == "double" || argType == "half")
                && (paramType == "bool" || paramType == "int" || paramType == "uint" || paramType == "dword" || paramType == "float" || paramType == "double" || paramType == "half")) {
                score = 1;
                ret = true;
            }
            else if ((argType == "bool2" || argType == "int2" || argType == "uint2" || argType == "dword2" || argType == "float2" || argType == "double2" || argType == "half2")
                && (paramType == "bool2" || paramType == "int2" || paramType == "uint2" || paramType == "dword2" || paramType == "float2" || paramType == "double2" || paramType == "half2")) {
                score = 1;
                ret = true;
            }
            else if ((argType == "bool3" || argType == "int3" || argType == "uint3" || argType == "dword3" || argType == "float3" || argType == "double3" || argType == "half3")
                && (paramType == "bool3" || paramType == "int3" || paramType == "uint3" || paramType == "dword3" || paramType == "float3" || paramType == "double3" || paramType == "half3")) {
                score = 1;
                ret = true;
            }
            else if ((argType == "bool4" || argType == "int4" || argType == "uint4" || argType == "dword4" || argType == "float4" || argType == "double4" || argType == "half4")
                && (paramType == "bool4" || paramType == "int4" || paramType == "uint4" || paramType == "dword4" || paramType == "float4" || paramType == "double4" || paramType == "half4")) {
                score = 1;
                ret = true;
            }
            else if ((argType == "bool2x2" || argType == "int2x2" || argType == "uint2x2" || argType == "dword2x2" || argType == "float2x2" || argType == "double2x2" || argType == "half2x2")
                && (paramType == "bool2x2" || paramType == "int2x2" || paramType == "uint2x2" || paramType == "dword2x2" || paramType == "float2x2" || paramType == "double2x2" || paramType == "half2x2")) {
                score = 1;
                ret = true;
            }
            else if ((argType == "bool3x3" || argType == "int3x3" || argType == "uint3x3" || argType == "dword3x3" || argType == "float3x3" || argType == "double3x3" || argType == "half3x3")
                && (paramType == "bool3x3" || paramType == "int3x3" || paramType == "uint3x3" || paramType == "dword3x3" || paramType == "float3x3" || paramType == "double3x3" || paramType == "half3x3")) {
                score = 1;
                ret = true;
            }
            else if ((argType == "bool4x4" || argType == "int4x4" || argType == "uint4x4" || argType == "dword4x4" || argType == "float4x4" || argType == "double4x4" || argType == "half4x4")
                && (paramType == "bool4x4" || paramType == "int4x4" || paramType == "uint4x4" || paramType == "dword4x4" || paramType == "float4x4" || paramType == "double4x4" || paramType == "half4x4")) {
                score = 1;
                ret = true;
            }
            else if (argType == "bool" || argType == "bool2" || argType == "bool3" || argType == "bool4") {
                ret = true;
            }
            else if (argType == "int" || argType == "int2" || argType == "int3" || argType == "int4") {
                ret = true;
            }
            else if (argType == "uint" || argType == "uint2" || argType == "uint3" || argType == "uint4") {
                ret = true;
            }
            else if (argType == "dword" || argType == "dword2" || argType == "dword3" || argType == "dword4") {
                ret = true;
            }
            else if (argType == "float" || argType == "float2" || argType == "float3" || argType == "float4") {
                ret = true;
            }
            else if (argType == "double" || argType == "double2" || argType == "double3" || argType == "double4") {
                ret = true;
            }
            else if (argType == "half" || argType == "half2" || argType == "half3" || argType == "half4") {
                ret = true;
            }
            return ret;
        }
        internal static string GetTypeNoVecPrefix(string type)
        {
            return GetTypeNoVecPrefix(type, out var isVecBefore);
        }
        internal static string GetTypeNoVecPrefix(string type, out bool isVecBefore)
        {
            isVecBefore = false;
            if (type.StartsWith(c_VectorialTypePrefix)) {
                type = type.Substring(c_VectorialTypePrefix.Length);
                isVecBefore = true;
            }
            return type;
        }
        internal static bool IsTypeVec(string type)
        {
            return IsTypeVec(type, out var isTuple, out var isStruct);
        }
        internal static bool IsTypeVec(string type, out bool isTuple, out bool isStruct)
        {
            isTuple = false;
            isStruct = false;
            bool ret = false;
            if (type.StartsWith(c_TupleTypePrefix)) {
                isTuple = true;
                if (type.Contains(c_VectorialTupleTypeTag)) {
                    ret = true;
                }
            }
            else {
                var struName = GetTypeNoVecPrefix(type, out ret);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    isStruct = true;
                }
            }
            return ret;
        }
        internal static string GetTypeVec(string type)
        {
            return GetTypeVec(type, out var isTuple, out var isStruct, out var isvec);
        }
        internal static string GetTypeVec(string type, out bool isTuple, out bool isStruct, out bool isVecBefore)
        {
            isTuple = false;
            isStruct = false;
            isVecBefore = false;
            if (type.StartsWith(c_TupleTypePrefix)) {
                isTuple = true;
                if (type.Contains(c_VectorialTupleTypeTag)) {
                    isVecBefore = true;
                }
            }
            else {
                var struName = GetTypeNoVecPrefix(type, out isVecBefore);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    isStruct = true;
                }
                if (!isVecBefore)
                    type = c_VectorialTypePrefix + struName;
            }
            return type;
        }
        internal static string GetTypeNoVec(string type)
        {
            return GetTypeNoVec(type, out var isTuple, out var isStruct, out var isvec);
        }
        internal static string GetTypeNoVec(string type, out bool isTuple, out bool isStruct, out bool isVecBefore)
        {
            isTuple = false;
            isStruct = false;
            isVecBefore = false;
            if (type.StartsWith(c_TupleTypePrefix)) {
                isTuple = true;
                if (type.Contains(c_VectorialTupleTypeTag)) {
                    isVecBefore = true;
                }
            }
            else {
                var struName = GetTypeNoVecPrefix(type, out isVecBefore);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    isStruct = true;
                }
                type = struName;
            }
            return type;
        }
        internal static string GetTypeRemoveSuffix(string type)
        {
            return GetTypeRemoveSuffix(type, out var suffix, out var isTuple, out var isStruct, out var isVec, out var arrNums, out var typeWithoutArrTag);
        }
        internal static string GetTypeRemoveSuffix(string type, out string suffix, out bool isTuple, out bool isStruct, out bool isVec, out IList<int> arrNums, out string typeWithoutArrTag)
        {
            typeWithoutArrTag = GetTypeRemoveArrTag(type, out isTuple, out isStruct, out isVec, out arrNums);
            if (isTuple || isStruct) {
                suffix = string.Empty;
                return typeWithoutArrTag;
            }
            if (typeWithoutArrTag.Length >= 3) {
                char last = typeWithoutArrTag[typeWithoutArrTag.Length - 1];
                if (last == '2' || last == '3' || last == '4') {
                    string last3 = typeWithoutArrTag.Substring(typeWithoutArrTag.Length - 3);
                    if (last3 == "2x2" || last3 == "3x3" || last3 == "4x4") {
                        suffix = last3;
                        return typeWithoutArrTag.Substring(0, typeWithoutArrTag.Length - 3);
                    }
                    else if (last3 == "2x3" || last3 == "3x2" || last3 == "3x4" || last3 == "4x3" || last3 == "2x4" || last3 == "4x2") {
                        suffix = last3;
                        return typeWithoutArrTag.Substring(0, typeWithoutArrTag.Length - 3);
                    }
                    else {
                        suffix = last.ToString();
                        return typeWithoutArrTag.Substring(0, typeWithoutArrTag.Length - 1);
                    }
                }
            }
            suffix = string.Empty;
            return typeWithoutArrTag;
        }
        internal static string GetTypeSuffix(string type)
        {
            return GetTypeSuffix(type, out var isTuple, out var isStruct, out var IsArr, out var arrNums, out var typeWithoutArrTag);
        }
        internal static string GetTypeSuffix(string type, out bool isTuple, out bool isStruct, out bool isVec, out IList<int> arrNums, out string typeWithoutArrTag)
        {
            typeWithoutArrTag = GetTypeRemoveArrTag(type, out isTuple, out isStruct, out isVec, out arrNums);
            if (isTuple || isStruct) {
                return string.Empty;
            }
            if (typeWithoutArrTag.Length >= 3) {
                char last = typeWithoutArrTag[typeWithoutArrTag.Length - 1];
                if (last == '2' || last == '3' || last == '4') {
                    string last3 = typeWithoutArrTag.Substring(typeWithoutArrTag.Length - 3);
                    if (last3 == "2x2" || last3 == "3x3" || last3 == "4x4") {
                        return last3;
                    }
                    else if (last3 == "2x3" || last3 == "3x2" || last3 == "3x4" || last3 == "4x3" || last3 == "2x4" || last3 == "4x2") {
                        return last3;
                    }
                    else {
                        return last.ToString();
                    }
                }
            }
            return string.Empty;
        }
        internal static string GetTypeSuffixReverse(string type)
        {
            return GetTypeSuffixReverse(type, out var isTuple, out var isStruct, out var IsArr, out var arrNums, out var typeWithoutArrTag);
        }
        internal static string GetTypeSuffixReverse(string type, out bool isTuple, out bool isStruct, out bool isVec, out IList<int> arrNums, out string typeWithoutArrTag)
        {
            typeWithoutArrTag = GetTypeRemoveArrTag(type, out isTuple, out isStruct, out isVec, out arrNums);
            if (isTuple || isStruct) {
                return string.Empty;
            }
            if (typeWithoutArrTag.Length >= 3) {
                char last = typeWithoutArrTag[typeWithoutArrTag.Length - 1];
                if (last == '2' || last == '3' || last == '4') {
                    string last3 = typeWithoutArrTag.Substring(typeWithoutArrTag.Length - 3);
                    if (last3 == "2x2" || last3 == "3x3" || last3 == "4x4") {
                        return last3;
                    }
                    else if (last3 == "2x3" || last3 == "3x2" || last3 == "3x4" || last3 == "4x3" || last3 == "2x4" || last3 == "4x2") {
                        return new string(new char[] { last3[2], last3[1], last3[0] });
                    }
                    else {
                        return last.ToString();
                    }
                }
            }
            return string.Empty;
        }
        internal static string GetTypeRemoveArrTag(string type, out bool isTuple, out bool isStruct, out bool isVec, out IList<int> arrNums)
        {
            var list = new List<int>();
            isVec = IsTypeVec(type, out isTuple, out isStruct);
            if (isTuple || isStruct) {
                arrNums = list;
                return type;
            }
            var r = GetTypeRemoveArrTagRecursively(type, list);
            arrNums = list;
            return r;
        }
        internal static string GetTypeRemoveArrTagRecursively(string type, List<int> arrNums)
        {
            int st = type.LastIndexOf("_x");
            if (st > 0) {
                string arrNumStr = type.Substring(st + 2);
                if (int.TryParse(arrNumStr, out int arrNum)) {
                    arrNums.Add(arrNum);
                    type = GetTypeRemoveArrTagRecursively(type.Substring(0, st), arrNums);
                }
            }
            return type;
        }
        internal static int GetMemberCount(string member)
        {
            int ct = 0;
            foreach (char c in member) {
                if (c == '_')
                    ++ct;
            }
            return ct;
        }
        internal static string GetNamespaceName(Dsl.FunctionData func)
        {
            if (func.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_PERIOD) {
                string m = func.GetParamId(0);
                if (func.IsHighOrder) {
                    return GetNamespaceName(func.LowerOrderFunction) + "." + m;
                }
                else {
                    return func.GetId() + "." + m;
                }
            }
            else {
                if (func.IsHighOrder) {
                    return GetNamespaceName(func.LowerOrderFunction);
                }
                else {
                    return func.GetId();
                }
            }
        }
        internal static void MarkLoop()
        {
            var funcInfo = CurFuncInfo();
            if (null != funcInfo) {
                funcInfo.HasLoop = true;
            }
        }
        internal static string SwizzleConvert(string m)
        {
            string v = m.Replace('r', 'x').Replace('g', 'y').Replace('b', 'z').Replace('a', 'w');
            v = v.Replace("_11", "_m00").Replace("_12", "_m01").Replace("_13", "_m02").Replace("_14", "_m03");
            v = v.Replace("_21", "_m10").Replace("_22", "_m11").Replace("_23", "_m12").Replace("_24", "_m13");
            v = v.Replace("_31", "_m20").Replace("_32", "_m21").Replace("_33", "_m22").Replace("_34", "_m23");
            v = v.Replace("_41", "_m30").Replace("_42", "_m31").Replace("_43", "_m32").Replace("_44", "_m33");
            return v;
        }

        internal static string BuildTypeWithTypeArgs(Dsl.FunctionData func)
        {
            var sb = new StringBuilder();
            if (func.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_BRACKET) {
                var arrTags = new List<string>();
                string baseType = BuildTypeWithArrTags(func, arrTags);
                sb.Append(baseType);
                for (int ix = arrTags.Count - 1; ix >= 0; --ix) {
                    sb.Append(arrTags[ix]);
                }
            }
            else {
                if (func.IsHighOrder) {
                    sb.Append(BuildTypeWithTypeArgs(func.LowerOrderFunction));
                }
                else {
                    sb.Append(func.GetId());
                }
                if (func.Params.Count > 0) {
                    sb.Append("__");
                }
                foreach (var p in func.Params) {
                    sb.Append(DslToNameString(p));
                    sb.Append("_T");
                }
            }
            return sb.ToString();
        }
        internal static string BuildTypeWithArrTags(Dsl.FunctionData func, List<string> arrTags)
        {
            string ret = string.Empty;
            if (func.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_BRACKET) {
                if (func.IsHighOrder) {
                    ret = BuildTypeWithArrTags(func.LowerOrderFunction, arrTags);
                }
                else {
                    ret = func.GetId();
                }
                string arrTag = "_x";
                if (func.GetParamNum() > 0) {
                    arrTag += func.GetParamId(0);
                }
                arrTags.Add(arrTag);
            }
            else {
                ret = BuildTypeWithTypeArgs(func);
            }
            return ret;
        }
        internal static string DslToNameString(Dsl.ISyntaxComponent syntax)
        {
            var valData = syntax as Dsl.ValueData;
            if (null != valData)
                return valData.GetId();
            else {
                var funcData = syntax as Dsl.FunctionData;
                if (null != funcData) {
                    var sb = new StringBuilder();
                    if (funcData.IsHighOrder) {
                        sb.Append(DslToNameString(funcData.LowerOrderFunction));
                    }
                    else {
                        sb.Append(funcData.GetId());
                    }
                    switch (funcData.GetParamClassUnmasked()) {
                        case (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_PERIOD:
                            sb.Append(".");
                            break;
                        case (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_BRACKET:
                            sb.Append("_x");
                            break;
                        default:
                            if (funcData.GetParamNum() > 0)
                                sb.Append("_");
                            break;
                    }
                    foreach (var p in funcData.Params) {
                        sb.Append(DslToNameString(p));
                    }
                    return sb.ToString();
                }
                else {
                    var stmData = syntax as Dsl.StatementData;
                    if (null != stmData) {
                        var sb = new StringBuilder();
                        for (int ix = 0; ix < stmData.GetFunctionNum(); ++ix) {
                            if (ix > 0)
                                sb.Append("__");
                            var func = stmData.GetFunction(ix);
                            sb.Append(DslToNameString(func));
                        }
                        return sb.ToString();
                    }
                    else {
                        return string.Empty;
                    }
                }
            }
        }

        //todo:这里只考虑了变量整体赋值的情形，对于矩阵、数组、和结构成员的赋值，在向量化后也可能存在值类型变引用类型的情形，目前这些没有处理，
        //不太好处理的原因是我们需要允许对 get 到的成员的 set 操作，所以 get 实际需要支持返回引用（可能需要一个 copy on write 的机制）
        //另外，对float3.x 这类 swizzle 操作，向量化后也涉及值类型变引用类型的情形，目前是在 swizzle 实现里处理的，对于向量化后单一的 xyzw
        //返回，都拷贝一份新数组返回（虽然语义上与原 shader 是一致的，但向量化后的运行性能会有一定影响）
        internal static bool ExistsSetObj(string vname)
        {
            bool ret = false;
            /*
            var vinfo = GetVarInfo(vname, VarUsage.Find);
            if (null != vinfo) {
                var blockInfo = vinfo.OwnerBlock;
                if (null != blockInfo) {
                    ret = blockInfo.ExistsSetObjInBlockScope(0, 0, vname, false, blockInfo);
                }
                else if(vinfo.IsConst) {
                    ret = false;
                }
                else {
                    ret = true;
                }
            }
            */
            var blockInfo = CurBlockInfo();
            if (null != blockInfo) {
                ret = blockInfo.ExistsSetObjInCurBlockScope(vname);
            }
            else {
                var vinfo = GetVarInfo(vname, VarUsage.Find);
                if (null != vinfo) {
                    if (vinfo.IsConst) {
                        ret = false;
                    }
                    else {
                        ret = true;
                    }
                }
            }
            return ret;
        }
        internal static bool IsHlslBool(string val)
        {
            return val == "true" || val == "false";
        }
        internal static string ConstToPython(string constVal)
        {
            if (constVal == "true")
                return "True";
            if (constVal == "false")
                return "False";
            return constVal;
        }
        internal static string GetDefaultValueInPython(string type, string writableBoolVal, Dsl.ISyntaxComponent syntax)
        {
            string ret;
            if (type == "bool")
                ret = "False";
            else if (type == "int" || type == "uint" || type == "dword")
                ret = "0";
            else if (type == "float" || type == "double" || type == "half") {

                ret = "0.0";
            }
            else {
                string typeWithoutArrTag = GetTypeRemoveArrTag(type, out var isTuple, out var isStruct, out var isVec, out var arrNums);
                string writableArg = string.Empty;
                if (isVec) {
                    writableArg = writableBoolVal;
                }
                if (isStruct) {
                    string fn = GetSimpleArrayTypeAbbr(type) + "_defval";
                    GenOrRecordDefValFunc(fn, typeWithoutArrTag, isTuple, isStruct, isVec, arrNums, syntax);
                    ret = fn + "(" + writableArg + ")";
                }
                else if (arrNums.Count > 0) {
                    string fn = "h_" + GetSimpleArrayTypeAbbr(type) + "_defval";
                    GenOrRecordDefValFunc(fn, typeWithoutArrTag, isTuple, isStruct, isVec, arrNums, syntax);
                    ret = fn + "(" + string.Join(", ", arrNums) + (isVec ? ", " : string.Empty) + writableArg + ")";
                }
                else {
                    string suffix = GetTypeSuffix(type);
                    if (suffix.Length > 0) {
                        ret = "h_" + GetTypeAbbr(type) + "_defval(" + writableArg + ")";
                    }
                    else {
                        string ty = GetTypeNoVec(type);
                        if (IsBaseType(ty)) {
                            ret = "h_" + GetTypeAbbr(type) + "_defval(" + writableArg + ")";
                        }
                        else {
                            ret = "None";
                        }
                    }
                }
            }
            return ret;
        }
        internal static string HlslType2Python(string type)
        {
            if (s_IsTorch) {
                if (!s_HlslType2TorchTypes.TryGetValue(type, out var ty)) {
                    s_HlslType2TorchTypes.TryGetValue("float", out ty);
                }
                Debug.Assert(null != ty);
                return ty;
            }
            else {
                if (!s_HlslType2NumpyTypes.TryGetValue(type, out var ty)) {
                    s_HlslType2NumpyTypes.TryGetValue("float", out ty);
                }
                Debug.Assert(null != ty);
                return ty;
            }
        }

    }
}