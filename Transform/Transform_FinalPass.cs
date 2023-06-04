using Hlsl2Numpy.Analysis;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Reflection.Emit;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Xml.Linq;
using static Hlsl2Numpy.Program;

namespace Hlsl2Numpy
{
    internal partial class ProgramTransform
    {
        internal static void TransformFunc(Dsl.ISyntaxComponent info)
        {
            var stmData = info as Dsl.StatementData;
            if (null != stmData) {
                var firstFunc = stmData.First.AsFunction;
                var secondFunc = stmData.Second.AsFunction;
                var lastFunc = stmData.Last.AsFunction;
                var retInfo = ParseVarInfo(firstFunc, stmData);
                string funcName = retInfo.Name;
                if (secondFunc.IsHighOrder)
                    secondFunc = secondFunc.LowerOrderFunction;

                if (!lastFunc.HaveStatement()) {
                    //forward declaration
                    return;
                }

                string signature = ParseFuncSignature(funcName, secondFunc);
                if (s_FuncInfos.TryGetValue(signature, out var funcInfo)) {
                    var blockInfo = funcInfo.ToplevelBlock;
                    Debug.Assert(null != blockInfo);
                    PushBlock(blockInfo);

                    if (!funcInfo.Transformed || s_IsVectorizing) {
                        var funcSb = NewStringBuilder();
                        int indent = 0;
                        GenFuncHead(funcSb, indent, signature, funcInfo);
                        if (lastFunc.GetParamNum() == 0 && !funcInfo.HasInOutOrOutParams) {
                            GenFuncPass(funcSb, indent + 1, funcInfo);
                        }
                        else {
                            ++indent;
                            GenFuncUsingGlobals(funcSb, indent, funcInfo);
                            Dsl.ISyntaxComponent? lastStm = null;
                            foreach (var stm in lastFunc.Params) {
                                TransformStatement(stm, funcSb, indent);
                                lastStm = stm;
                            }
                            GenVoidFuncReturn(funcSb, indent, lastStm, funcInfo, secondFunc);
                            --indent;
                        }
                        if (funcInfo.CodeGenerateEnabled) {
                            var sb = new StringBuilder();
                            sb.Append(funcSb);
                            if (s_IsVectorizing) {
                                var vecFuncCodeInfo = new VecFuncCodeInfo(funcInfo, sb);
                                s_VecFuncCodeStack.Push(vecFuncCodeInfo);
                            }
                            else {
                                if (s_AllFuncCodes.ContainsKey(signature)) {
                                    s_AllFuncCodes[signature] = sb;
                                }
                                else {
                                    s_AllFuncCodes.Add(signature, sb);
                                }
                            }
                        }
                        if (!s_IsVectorizing) {
                            if (!s_AllFuncSigs.Contains(signature)) {
                                s_AllFuncSigs.Add(signature);
                            }
                        }
                        RecycleStringBuilder(funcSb);
                    }
                    PopBlock();
                    funcInfo.Transformed = true;
                    funcInfo.VarRenamed = true;
                    funcInfo.BlockInfoConstructed = true;
                }
            }
        }
        private static void TransformVar(Dsl.FunctionData func, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            var varInfo = ParseVarInfo(func, null);
            if (TryRenameVar(varInfo)) {
                var v = func.GetParam(2);
                var vd = v as Dsl.ValueData;
                var fd = v as Dsl.FunctionData;
                if (null != vd) {
                    vd.SetId(varInfo.Name);
                }
                else if (null != fd) {
                    fd.Name.SetId(varInfo.Name);
                }
            }
            AddVar(varInfo);
            var curFunc = CurFuncInfo();
            semanticInfo.NameOrConst = varInfo.Name;
            semanticInfo.ResultType = varInfo.Type;
            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                var vgn = new ComputeGraphVarNode(curFunc, varInfo.Type, varInfo.Name);
                semanticInfo.GraphNode = vgn;
                AddComputeGraphVarNode(vgn);
            }

            if (null == curFunc) {
                AddInitGlobal(varInfo.Name);
            }
            GenDeclVarName(sb, indent, varInfo.Name);
        }
        private static void TransformVar(Dsl.StatementData stm, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            var func = stm.First.AsFunction;
            Debug.Assert(null != func);
            var varInfo = ParseVarInfo(func, null);
            if (TryRenameVar(varInfo)) {
                var v = func.GetParam(2);
                var vd = v as Dsl.ValueData;
                var fd = v as Dsl.FunctionData;
                if (null != vd) {
                    vd.SetId(varInfo.Name);
                }
                else if (null != fd) {
                    fd.Name.SetId(varInfo.Name);
                }
            }
            AddVar(varInfo);
            var semantic = stm.Second.AsFunction;
            Debug.Assert(null != semantic);
            varInfo.Semantic = semantic.GetParamId(0);
            var curFunc = CurFuncInfo();
            semanticInfo.NameOrConst = varInfo.Name;
            semanticInfo.ResultType = varInfo.Type;
            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                var vgn = new ComputeGraphVarNode(curFunc, varInfo.Type, varInfo.Name);
                semanticInfo.GraphNode = vgn;
                AddComputeGraphVarNode(vgn);
            }

            if (null == curFunc) {
                AddInitGlobal(varInfo.Name);
            }
            GenDeclVarName(sb, indent, varInfo.Name);
        }
        private static void TransformOperator(Dsl.FunctionData func, StringBuilder sb, in ParseContextInfo contextInfo, int indent, ref SemanticInfo semanticInfo)
        {
            //常量替换只替换运算结果，也就是只有操作数被替换，计算表达式仍然保留，计算结果为常量的会在使用结果的地方替换
            semanticInfo.IsVarValRef = false;
            semanticInfo.NameOrConst = string.Empty;
            string op = func.GetId();
            if (func.GetParamNum() == 1) {
                if (op == "++") {
                    if (contextInfo.IsInCondExp) {
                        Console.WriteLine("do operator '{0}' in condition expression ! please change to if-else. line: {1}", func.GetId(), func.GetLine());
                    }

                    var p0 = func.GetParam(0);
                    bool isMemberAccess = IsMemberAccess(p0, out Dsl.FunctionData? memAccess);
                    bool isElementAccess = IsElementAccess(p0, out Dsl.FunctionData? elementAccess);
                    if (isMemberAccess) {
                        Debug.Assert(null != memAccess);
                        TransformMemberCompoundSet(false, "+", memAccess, s_ConstDslValueOne, sb, indent, ref semanticInfo);
                    }
                    else if (isElementAccess) {
                        Debug.Assert(null != elementAccess);
                        TransformElementCompoundSet(false, "+", elementAccess, s_ConstDslValueOne, sb, indent, ref semanticInfo);
                    }
                    else {
                        var lhsBuilder = NewStringBuilder();
                        var argBuilder = NewStringBuilder();
                        var argSi = new SemanticInfo(false);
                        TransformSyntax(p0, argBuilder, contextInfo with { Usage = SyntaxUsage.Operator }, 0, ref argSi);
                        TransformSyntax(p0, lhsBuilder, contextInfo with { IsInAssignLHS = true }, 0, ref semanticInfo);
                        var vname = semanticInfo.NameOrConst;
                        string opd = argSi.ResultType;
                        bool constGenerated = false;
                        if (!string.IsNullOrEmpty(vname)) {
                            var blockInfo = CurBlockInfo();
                            var vinfo = GetVarInfo(vname, VarUsage.Find);
                            if (null != vinfo && null != blockInfo) {
                                if (blockInfo.TryGetCurVarConst(vname, out var val) && !string.IsNullOrEmpty(val)) {
                                    val = ConstCalc("++", vinfo.OriType, val);
                                    blockInfo.SetVarConst(vname, val);
                                    semanticInfo.NameOrConst = val;
                                    GenConstAssignExp(sb, indent, vname, val);
                                    constGenerated = true;
                                }
                                else if (CurFuncBlockInfoConstructed()) {
                                    blockInfo.SetVarConst(vname, string.Empty);
                                }
                            }
                        }
                        if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                            var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, op);
                            var vgn = semanticInfo.GraphNode;
                            Debug.Assert(null != vgn);
                            cgn.AddPrev(vgn);
                            vgn.AddNext(cgn);

                            vgn.AddPrev(cgn);
                            cgn.AddNext(vgn);
                            semanticInfo.GraphNode = vgn;
                        }
                        if (!constGenerated) {
                            GenIncInExp(sb, indent, lhsBuilder, argBuilder, opd);
                        }
                        RecycleStringBuilder(lhsBuilder);
                        RecycleStringBuilder(argBuilder);
                    }
                }
                else if (op == "--") {
                    if (contextInfo.IsInCondExp) {
                        Console.WriteLine("do operator '{0}' in condition expression ! please change to if-else. line: {1}", func.GetId(), func.GetLine());
                    }

                    var p0 = func.GetParam(0);
                    bool isMemberAccess = IsMemberAccess(p0, out Dsl.FunctionData? memAccess);
                    bool isElementAccess = IsElementAccess(p0, out Dsl.FunctionData? elementAccess);
                    if (isMemberAccess) {
                        Debug.Assert(null != memAccess);
                        TransformMemberCompoundSet(false, "-", memAccess, s_ConstDslValueOne, sb, indent, ref semanticInfo);
                    }
                    else if (isElementAccess) {
                        Debug.Assert(null != elementAccess);
                        TransformElementCompoundSet(false, "-", elementAccess, s_ConstDslValueOne, sb, indent, ref semanticInfo);
                    }
                    else {
                        var lhsBuilder = NewStringBuilder();
                        var argBuilder = NewStringBuilder();
                        var argSi = new SemanticInfo(false);
                        TransformSyntax(p0, argBuilder, contextInfo with { Usage = SyntaxUsage.Operator }, 0, ref argSi);
                        TransformSyntax(p0, lhsBuilder, contextInfo with { IsInAssignLHS = true }, 0, ref semanticInfo);
                        var vname = semanticInfo.NameOrConst;
                        string opd = argSi.ResultType;
                        bool constGenerated = false;
                        if (!string.IsNullOrEmpty(vname)) {
                            var blockInfo = CurBlockInfo();
                            var vinfo = GetVarInfo(vname, VarUsage.Find);
                            if (null != vinfo && null != blockInfo) {
                                if (blockInfo.TryGetCurVarConst(vname, out var val) && !string.IsNullOrEmpty(val)) {
                                    val = ConstCalc("--", vinfo.OriType, val);
                                    blockInfo.SetVarConst(vname, val);
                                    semanticInfo.NameOrConst = val;
                                    GenConstAssignExp(sb, indent, vname, val);
                                    constGenerated = true;
                                }
                                else if (CurFuncBlockInfoConstructed()) {
                                    blockInfo.SetVarConst(vname, string.Empty);
                                }
                            }
                        }
                        if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                            var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, op);
                            var vgn = semanticInfo.GraphNode;
                            Debug.Assert(null != vgn);
                            cgn.AddPrev(vgn);
                            vgn.AddNext(cgn);

                            vgn.AddPrev(cgn);
                            cgn.AddNext(vgn);
                            semanticInfo.GraphNode = vgn;
                        }
                        if (!constGenerated) {
                            GenDecInExp(sb, indent, lhsBuilder, argBuilder, opd);
                        }
                        RecycleStringBuilder(lhsBuilder);
                        RecycleStringBuilder(argBuilder);
                    }
                }
                else {
                    var p0 = func.GetParam(0);
                    var argBuilder = NewStringBuilder();
                    var argSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                    TransformSyntax(p0, argBuilder, contextInfo with { Usage = SyntaxUsage.Operator }, 0, ref argSi);
                    string opd = argSi.ResultType;
                    var opdIsVarValRef = argSi.IsVarValRef;
                    var cres = argSi.NameOrConst;
                    semanticInfo.ResultType = OperatorTypeInference(op, opd);
                    if (!opdIsVarValRef && !string.IsNullOrEmpty(cres)) {
                        semanticInfo.NameOrConst = ConstCalc(op, opd, cres);
                    }
                    if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                        var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, op);
                        var agn = argSi.GraphNode;
                        Debug.Assert(null != agn);
                        cgn.AddPrev(agn);
                        agn.AddNext(cgn);
                        semanticInfo.GraphNode = cgn;
                    }
                    GenUnaryOp(sb, indent, op, argBuilder, opd);
                    RecycleStringBuilder(argBuilder);
                }
            }
            else {
                if (op.Length > 1 && op[op.Length - 1] == '=' && op != "==" && op != "!=" && op != ">=" && op != "<=") {
                    if (contextInfo.IsInCondExp) {
                        Console.WriteLine("do operator '{0}' in condition expression ! please change to if-else. line: {1}", func.GetId(), func.GetLine());
                    }

                    string nop = op.Substring(0, op.Length - 1);
                    var lhs = func.GetParam(0);
                    var rhs = func.GetParam(1);
                    //考虑到矢量化（或numpy的broadcast），out参数先处理后再处理赋值，这里不用处理out参数的情形
                    bool isMemberAccess = IsMemberAccess(lhs, out Dsl.FunctionData? memAccess);
                    bool isElementAccess = IsElementAccess(lhs, out Dsl.FunctionData? elementAccess);
                    if (isMemberAccess) {
                        Debug.Assert(null != memAccess);
                        TransformMemberCompoundSet(false, nop, memAccess, rhs, sb, indent, ref semanticInfo);
                    }
                    else if (isElementAccess) {
                        Debug.Assert(null != elementAccess);
                        TransformElementCompoundSet(false, nop, elementAccess, rhs, sb, indent, ref semanticInfo);
                    }
                    else {
                        var lhsBuilder = NewStringBuilder();
                        var arg1Builder = NewStringBuilder();
                        var arg2Builder = NewStringBuilder();
                        var arg1Si = new SemanticInfo(false);
                        var arg2Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
                        TransformSyntax(lhs, arg1Builder, contextInfo with { Usage = SyntaxUsage.Operator }, 0, ref arg1Si);
                        TransformSyntax(rhs, arg2Builder, contextInfo with { Usage = SyntaxUsage.Operator }, 0, ref arg2Si);
                        TransformSyntax(lhs, lhsBuilder, contextInfo with { IsInAssignLHS = true }, indent, ref semanticInfo);
                        var vname = semanticInfo.NameOrConst;
                        string opd1 = arg1Si.ResultType;
                        string opd2 = arg2Si.ResultType;
                        var opdIsVarValRef = arg2Si.IsVarValRef;
                        var cres = arg2Si.NameOrConst;
                        string tmp = OperatorTypeInference(nop, opd1, opd2);
                        if (!string.IsNullOrEmpty(vname)) {
                            var curBlockInfo = CurBlockInfo();
                            var vinfo = GetVarInfo(vname, VarUsage.Find);
                            if (null != curBlockInfo && null != vinfo) {
                                bool biCon = CurFuncBlockInfoConstructed();
                                if (opdIsVarValRef || string.IsNullOrEmpty(cres)) {
                                    if (biCon)
                                        curBlockInfo.SetVarConst(vname, string.Empty);
                                }
                                else {
                                    if (curBlockInfo.TryGetCurVarConst(vname, out var val)) {
                                        string nres = ConstCalc(nop, opd1, val, opd2, cres);
                                        curBlockInfo.SetVarConst(vname, nres);
                                        semanticInfo.NameOrConst = nres;
                                    }
                                    else if (biCon) {
                                        curBlockInfo.SetVarConst(vname, string.Empty);
                                    }
                                }
                            }
                        }
                        if (s_EnableConstPropagation && !opdIsVarValRef && !string.IsNullOrEmpty(cres)) {
                            var newVal = new Dsl.ValueData(cres);
                            newVal.SetLine(rhs.GetLine());
                            newVal.SetSeparator(rhs.GetSeparator());
                            func.SetParam(1, newVal);
                            if (CurFuncCodeGenerateEnabled()) {
                                arg2Builder.Length = 0;
                                arg2Builder.Append(ConstToPython(cres));
                            }
                        }
                        if (s_IsVectorizing) {
                            if (IsTypeVec(tmp)) {
                                semanticInfo.ResultType = GetTypeVec(semanticInfo.ResultType, out var isTuple, out var isStruct, out var isVecBefore);
                                if (!isVecBefore && VectorizeVar(lhs, out var _, out var needBroadCast)) {
                                    if (needBroadCast) {
                                        Console.WriteLine("[Error]: obj '{0}' cannot be broadcast in an assignment embedded in an expression, line: {1}", lhs.GetId(), lhs.GetLine());
                                    }
                                }
                            }
                        }
                        if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                            var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, op);
                            var vgn = semanticInfo.GraphNode;
                            var agn = arg2Si.GraphNode;
                            Debug.Assert(null != vgn);
                            Debug.Assert(null != agn);
                            cgn.AddPrev(vgn);
                            cgn.AddPrev(agn);
                            vgn.AddNext(cgn);
                            agn.AddNext(cgn);

                            vgn.AddPrev(cgn);
                            cgn.AddNext(vgn);
                            semanticInfo.GraphNode = vgn;
                        }
                        GenCompoundAssignInExp(sb, indent, nop, lhsBuilder, arg1Builder, arg2Builder, semanticInfo.ResultType, opd1, opd2, tmp, func);
                        RecycleStringBuilder(lhsBuilder);
                        RecycleStringBuilder(arg1Builder);
                        RecycleStringBuilder(arg2Builder);
                    }
                }
                else if (op == "=") {
                    if (contextInfo.IsInCondExp) {
                        Console.WriteLine("do operator '{0}' in condition expression ! please change to if-else. line: {1}", func.GetId(), func.GetLine());
                    }

                    var lhs = func.GetParam(0);
                    var rhs = func.GetParam(1);
                    //考虑到矢量化（或numpy的broadcast），out参数先处理后再处理赋值，这里不用处理out参数的情形
                    bool isMemberAccess = IsMemberAccess(lhs, out Dsl.FunctionData? memAccess);
                    bool isElementAccess = IsElementAccess(lhs, out Dsl.FunctionData? elementAccess);
                    if (isMemberAccess) {
                        Debug.Assert(null != memAccess);
                        TransformMemberSet(false, memAccess, rhs, sb, indent, ref semanticInfo);
                    }
                    else if (isElementAccess) {
                        Debug.Assert(null != elementAccess);
                        TransformElementSet(false, elementAccess, rhs, sb, indent, ref semanticInfo);
                    }
                    else {
                        var lhsBuilder = NewStringBuilder();
                        var argBuilder = NewStringBuilder();
                        var varSi = new SemanticInfo(false);
                        var argSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                        TransformSyntax(lhs, lhsBuilder, contextInfo with { IsInAssignLHS = true }, 0, ref varSi);
                        TransformSyntax(rhs, argBuilder, contextInfo, 0, ref argSi);
                        semanticInfo.CopyResultFrom(varSi);
                        var vname = semanticInfo.NameOrConst;
                        string opd = argSi.ResultType;
                        var rhsIsVarValRef = argSi.IsVarValRef;
                        var cres = argSi.NameOrConst;
                        if (!string.IsNullOrEmpty(vname) && (!s_IsVectorizing || !IsTypeVec(semanticInfo.ResultType))) {
                            var curBlockInfo = CurBlockInfo();
                            var vinfo = GetVarInfo(vname, VarUsage.Find);
                            if (null != curBlockInfo && null != vinfo) {
                                if (rhsIsVarValRef || string.IsNullOrEmpty(cres)) {
                                    curBlockInfo.SetVarConst(vname, string.Empty);
                                }
                                else {
                                    curBlockInfo.SetVarConst(vname, cres);
                                    semanticInfo.NameOrConst = cres;
                                }
                            }
                        }
                        if (s_EnableConstPropagation && !rhsIsVarValRef && !string.IsNullOrEmpty(cres)) {
                            var newVal = new Dsl.ValueData(cres);
                            newVal.SetLine(rhs.GetLine());
                            newVal.SetSeparator(rhs.GetSeparator());
                            func.SetParam(1, newVal);
                            if (CurFuncCodeGenerateEnabled()) {
                                argBuilder.Length = 0;
                                argBuilder.Append(ConstToPython(cres));
                            }
                        }
                        if (s_IsVectorizing) {
                            if (IsTypeVec(opd)) {
                                semanticInfo.ResultType = GetTypeVec(semanticInfo.ResultType, out var isTuple, out var isStruct, out var isVecBefore);
                                if (!isVecBefore && VectorizeVar(lhs, out var _, out var needBroadCast)) {
                                    if (needBroadCast) {
                                        Console.WriteLine("[Error]: obj '{0}' cannot be broadcast in an assignment embedded in an expression, line: {1}", lhs.GetId(), lhs.GetLine());
                                    }
                                }
                            }
                        }
                        if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                            var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, op);
                            var agn = argSi.GraphNode;
                            Debug.Assert(null != agn);
                            cgn.AddPrev(agn);
                            agn.AddNext(cgn);

                            var vgn = FindComputeGraphVarNode(vname);
                            Debug.Assert(null != vgn);
                            vgn.AddPrev(cgn);
                            cgn.AddNext(vgn);
                            semanticInfo.GraphNode = vgn;
                        }
                        GenAssignInExp(sb, indent, lhsBuilder, argBuilder, semanticInfo.ResultType, opd, vname, cres, rhsIsVarValRef, func);
                        RecycleStringBuilder(lhsBuilder);
                        RecycleStringBuilder(argBuilder);
                    }
                }
                else {
                    var arg1Builder = NewStringBuilder();
                    var arg2Builder = NewStringBuilder();
                    var arg1 = func.GetParam(0);
                    var arg2 = func.GetParam(1);
                    var arg1Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
                    var arg2Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
                    TransformSyntax(arg1, arg1Builder, contextInfo with { Usage = SyntaxUsage.Operator }, 0, ref arg1Si);
                    TransformSyntax(arg2, arg2Builder, contextInfo with { Usage = SyntaxUsage.Operator }, 0, ref arg2Si);
                    string opd1 = arg1Si.ResultType;
                    var opd1IsVarValRef = arg1Si.IsVarValRef;
                    var cres1 = arg1Si.NameOrConst;
                    string opd2 = arg2Si.ResultType;
                    var opd2IsVarValRef = arg2Si.IsVarValRef;
                    var cres2 = arg2Si.NameOrConst;
                    semanticInfo.ResultType = OperatorTypeInference(op, opd1, opd2);
                    //非赋值语句不用检查变量的常量值（应该在参数解析时已经得到常量值）
                    if (s_EnableConstPropagation) {
                        if (!opd1IsVarValRef && !opd2IsVarValRef && !string.IsNullOrEmpty(cres1) && !string.IsNullOrEmpty(cres2)) {
                            semanticInfo.NameOrConst = ConstCalc(op, opd1, cres1, opd2, cres2);
                        }
                        if (!opd1IsVarValRef && !string.IsNullOrEmpty(cres1)) {
                            var newVal = new Dsl.ValueData(cres1);
                            newVal.SetLine(arg1.GetLine());
                            newVal.SetSeparator(arg1.GetSeparator());
                            func.SetParam(0, newVal);
                            if (CurFuncCodeGenerateEnabled()) {
                                arg1Builder.Length = 0;
                                arg1Builder.Append(ConstToPython(cres1));
                            }
                        }
                        if (!opd2IsVarValRef && !string.IsNullOrEmpty(cres2)) {
                            var newVal = new Dsl.ValueData(cres2);
                            newVal.SetLine(arg2.GetLine());
                            newVal.SetSeparator(arg2.GetSeparator());
                            func.SetParam(1, newVal);
                            if (CurFuncCodeGenerateEnabled()) {
                                arg2Builder.Length = 0;
                                arg2Builder.Append(ConstToPython(cres2));
                            }
                        }
                    }
                    if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                        var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, op);
                        var a1gn = arg1Si.GraphNode;
                        var a2gn = arg2Si.GraphNode;
                        Debug.Assert(null != a1gn);
                        Debug.Assert(null != a2gn);
                        cgn.AddPrev(a1gn);
                        cgn.AddPrev(a2gn);
                        a1gn.AddNext(cgn);
                        a2gn.AddNext(cgn);

                        semanticInfo.GraphNode = cgn;
                    }
                    GenBinaryOp(sb, indent, op, arg1Builder, arg2Builder, opd1, opd2);
                    RecycleStringBuilder(arg1Builder);
                    RecycleStringBuilder(arg2Builder);
                }
            }
        }
        private static void TransformMemberCompoundSet(bool isStatement, string op, Dsl.FunctionData lhs, Dsl.ISyntaxComponent rhs, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            semanticInfo.NameOrConst = string.Empty;
            var arg1Builder = NewStringBuilder();
            var arg2Builder = NewStringBuilder();
            var arg1Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
            var arg2Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
            TransformSyntax(lhs, arg1Builder, new ParseContextInfo() { Usage = SyntaxUsage.Operator }, 0, ref arg1Si);
            TransformSyntax(rhs, arg2Builder, new ParseContextInfo() { Usage = SyntaxUsage.Operator }, 0, ref arg2Si);
            string opd1 = arg1Si.ResultType;
            string opd2 = arg2Si.ResultType;

            var objBuilder = NewStringBuilder();
            var objSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            if (lhs.IsHighOrder)
                TransformSyntax(lhs.LowerOrderFunction, objBuilder, new ParseContextInfo { IsObjInAssignLHS = true }, 0, ref objSi);
            else
                TransformSyntax(lhs.Name, objBuilder, new ParseContextInfo { IsObjInAssignLHS = true }, 0, ref objSi);
            string objType = objSi.ResultType;
            var memberBuilder = NewStringBuilder();
            var memberSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            TransformSyntax(lhs.GetParam(0), memberBuilder, new ParseContextInfo() { Usage = SyntaxUsage.MemberName }, 0, ref memberSi);

            string mname = lhs.GetParamId(0);
            string mtype = MemberTypeInference(".", objType, string.Empty, mname);
            string restype = OperatorTypeInference(op, opd1, opd2);

            bool needBroadcast = false;
            bool isHighOrder = false;
            bool genGetOutAndEndRet = false;
            string outVar = string.Empty;
            if (s_IsVectorizing) {
                if (IsTypeVec(restype)) {
                    mtype = GetTypeVec(mtype, out var isTuple, out var isStruct, out var isVecBefore);
                    if (!isVecBefore) {
                        if (lhs.IsHighOrder) {
                            needBroadcast = true;
                            isHighOrder = true;
                            isStatement = false;
                        }
                        else {
                            //这里不修改生成的赋值函数的对象类型标记，以允许赋值函数实现broadcast并返回broadcast后的对象
                            if (VectorizeVar(lhs, out var varName, out needBroadcast)) {
                                if (needBroadcast) {
                                    outVar = varName;
                                    if (!isStatement) {
                                        genGetOutAndEndRet = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            semanticInfo.ResultType = mtype;
            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, ".=" + op);
                var ogn = objSi.GraphNode;
                var mgn = memberSi.GraphNode;
                var a1gn = arg1Si.GraphNode;
                var a2gn = arg2Si.GraphNode;
                Debug.Assert(null != ogn);
                Debug.Assert(null != mgn);
                Debug.Assert(null != a1gn);
                Debug.Assert(null != a2gn);
                cgn.AddPrev(ogn);
                cgn.AddPrev(mgn);
                cgn.AddPrev(a1gn);
                cgn.AddPrev(a2gn);
                ogn.AddNext(cgn);
                mgn.AddNext(cgn);
                a1gn.AddNext(cgn);
                a2gn.AddNext(cgn);

                var objvgn = GetObjectVarNode(ogn);
                if (null != objvgn) {
                    cgn.AddOut(objvgn);
                    objvgn.AddPrev(cgn);
                }

                semanticInfo.GraphNode = cgn;
            }

            string retVar = GenMemberCompoundSet(sb, indent, op, objBuilder, memberBuilder, arg1Builder, arg2Builder, objType, mtype, opd1, opd2, restype, needBroadcast, genGetOutAndEndRet, outVar, isStatement, lhs);
            if (isHighOrder) {
                var lovBuilder = NewStringBuilder();
                GenAppend(sb, ", ");
                GenGetOutParam(retVar, 1, lovBuilder);

                var p = lhs.LowerOrderFunction;
                string paramType = GetTypeVec(objType);
                bool isMemberAccess = IsMemberAccess(p, out Dsl.FunctionData? memAccess);
                bool isElementAccess = IsElementAccess(p, out Dsl.FunctionData? elementAccess);
                if (isMemberAccess) {
                    Debug.Assert(null != memAccess);
                    var tempSi = new SemanticInfo(false);
                    TransformMemberSet(false, memAccess, lovBuilder, paramType, false, null, sb, 0, ref tempSi);
                }
                else if (isElementAccess) {
                    Debug.Assert(null != elementAccess);
                    var tempSi = new SemanticInfo(false);
                    TransformElementSet(false, elementAccess, lovBuilder, paramType, false, null, sb, 0, ref tempSi);
                }
                else {
                    Debug.Assert(false);
                }
                GenGetRetValEnd(sb);
                RecycleStringBuilder(lovBuilder);
            }
            RecycleStringBuilder(objBuilder);
            RecycleStringBuilder(memberBuilder);
            RecycleStringBuilder(arg1Builder);
            RecycleStringBuilder(arg2Builder);
        }
        private static void TransformMemberSet(bool isStatement, Dsl.FunctionData lhs, Dsl.ISyntaxComponent rhs, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            var rhsBuilder = NewStringBuilder();
            var rhsSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            TransformSyntax(rhs, rhsBuilder, 0, ref rhsSi);
            TransformMemberSet(isStatement, lhs, rhsBuilder, rhsSi.ResultType, rhsSi.IsVarValRef, rhsSi.GraphNode, sb, indent, ref semanticInfo);
            RecycleStringBuilder(rhsBuilder);
        }
        private static void TransformMemberSet(bool isStatement, Dsl.FunctionData lhs, StringBuilder rhsBuilder, string rhsType, bool rhsIsVarValRef, ComputeGraphNode? rgn, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            semanticInfo.NameOrConst = string.Empty;
            var objBuilder = NewStringBuilder();
            var objSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            if (lhs.IsHighOrder)
                TransformSyntax(lhs.LowerOrderFunction, objBuilder, new ParseContextInfo { IsObjInAssignLHS = true }, 0, ref objSi);
            else
                TransformSyntax(lhs.Name, objBuilder, new ParseContextInfo { IsObjInAssignLHS = true }, 0, ref objSi);
            string objType = objSi.ResultType;
            var memberBuilder = NewStringBuilder();
            var memberSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            TransformSyntax(lhs.GetParam(0), memberBuilder, new ParseContextInfo() { Usage = SyntaxUsage.MemberName }, 0, ref memberSi);
            string mname = lhs.GetParamId(0);
            string mtype = MemberTypeInference(".", objType, string.Empty, mname);

            bool needBroadcast = false;
            bool isHighOrder = false;
            bool genGetOutAndEndRet = false;
            string outVar = string.Empty;
            if (s_IsVectorizing) {
                if (IsTypeVec(rhsType)) {
                    mtype = GetTypeVec(mtype, out var isTuple, out var isStruct, out var isVecBefore);
                    if (!isVecBefore) {
                        if (lhs.IsHighOrder) {
                            needBroadcast = true;
                            isHighOrder = true;
                            isStatement = false;
                        }
                        else {
                            //这里不修改生成的赋值函数的对象类型标记，以允许赋值函数实现broadcast并返回broadcast后的对象
                            if (VectorizeVar(lhs, out var varName, out needBroadcast)) {
                                if (needBroadcast) {
                                    outVar = varName;
                                    if (!isStatement) {
                                        genGetOutAndEndRet = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            semanticInfo.ResultType = mtype;
            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                Debug.Assert(null != rgn);
                var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, ".=");
                var ogn = objSi.GraphNode;
                var mgn = memberSi.GraphNode;
                Debug.Assert(null != ogn);
                Debug.Assert(null != mgn);
                cgn.AddPrev(ogn);
                cgn.AddPrev(mgn);
                cgn.AddPrev(rgn);
                ogn.AddNext(cgn);
                mgn.AddNext(cgn);
                rgn.AddNext(cgn);

                var objvgn = GetObjectVarNode(ogn);
                if (null != objvgn) {
                    cgn.AddOut(objvgn);
                    objvgn.AddPrev(cgn);
                }

                semanticInfo.GraphNode = cgn;
            }

            string retVar = GenMemberSet(sb, indent, objBuilder, memberBuilder, rhsBuilder, objType, mtype, rhsType, rhsIsVarValRef, needBroadcast, genGetOutAndEndRet, outVar, isStatement, lhs);
            if (isHighOrder) {
                var lovBuilder = NewStringBuilder();
                GenAppend(sb, ", ");
                GenGetOutParam(retVar, 1, lovBuilder);

                var p = lhs.LowerOrderFunction;
                string paramType = GetTypeVec(objType);
                bool isMemberAccess = IsMemberAccess(p, out Dsl.FunctionData? memAccess);
                bool isElementAccess = IsElementAccess(p, out Dsl.FunctionData? elementAccess);
                if (isMemberAccess) {
                    Debug.Assert(null != memAccess);
                    var tempSi = new SemanticInfo(false);
                    TransformMemberSet(false, memAccess, lovBuilder, paramType, false, null, sb, 0, ref tempSi);
                }
                else if (isElementAccess) {
                    Debug.Assert(null != elementAccess);
                    var tempSi = new SemanticInfo(false);
                    TransformElementSet(false, elementAccess, lovBuilder, paramType, false, null, sb, 0, ref tempSi);
                }
                else {
                    Debug.Assert(false);
                }
                GenGetRetValEnd(sb);
                RecycleStringBuilder(lovBuilder);
            }
            RecycleStringBuilder(objBuilder);
            RecycleStringBuilder(memberBuilder);
        }
        private static void TransformMemberGet(Dsl.FunctionData func, StringBuilder sb, in ParseContextInfo contextInfo, int indent, ref SemanticInfo semanticInfo)
        {
            semanticInfo.IsVarValRef = false;
            semanticInfo.NameOrConst = string.Empty;
            string mname = string.Empty;
            var objBuilder = NewStringBuilder();
            var objSi = new SemanticInfo(semanticInfo.NeedComputeGraph && contextInfo.Usage != SyntaxUsage.TypeName);
            bool isObjInAssignLHS = contextInfo.IsObjInAssignLHS;
            ParseContextInfo pci;
            if (isObjInAssignLHS) {
                pci = new ParseContextInfo { IsObjInAssignLHS = true };
            }
            else {
                pci = new ParseContextInfo();
            }
            if (func.IsHighOrder)
                TransformSyntax(func.LowerOrderFunction, objBuilder, pci, 0, ref objSi);
            else
                TransformSyntax(func.Name, objBuilder, pci, 0, ref objSi);
            string objType = objSi.ResultType;
            var memberBuilder = NewStringBuilder();
            var memberSi = new SemanticInfo(semanticInfo.NeedComputeGraph && contextInfo.Usage != SyntaxUsage.TypeName);
            TransformSyntax(func.GetParam(0), memberBuilder, new ParseContextInfo() { Usage = SyntaxUsage.MemberName }, 0, ref memberSi);

            if (contextInfo.Usage == SyntaxUsage.TypeName) {
                semanticInfo.ResultType = GetNamespaceName(func);
                GenAppend(sb, semanticInfo.ResultType);
                RecycleStringBuilder(objBuilder);
                RecycleStringBuilder(memberBuilder);
                return;
            }
            else {
                mname = func.GetParamId(0); //这里必须这样读取成员名，因为代码生成可能没有打开
                semanticInfo.ResultType = MemberTypeInference(".", objType, semanticInfo.ResultType, mname);
                if (string.IsNullOrEmpty(semanticInfo.ResultType)) {
                    Console.WriteLine("unknown obj '{0}' or member '{1}', line: {2}", objType, mname, func.GetLine());
                }
            }

            int fieldIndex = -1;
            StructInfo? struInfo = null;
            string struName = GetTypeNoVecPrefix(objType);
            if (s_StructInfos.TryGetValue(struName, out struInfo)) {
                if (struInfo.FieldName2Indexes.TryGetValue(mname, out var ix)) {
                    fieldIndex = ix;
                    string ty = struInfo.Fields[ix].Type;
                    if (!IsBaseType(ty)) {
                        semanticInfo.IsVarValRef = true;
                    }
                }
            }

            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, ".");
                var ogn = objSi.GraphNode;
                var mgn = memberSi.GraphNode;
                Debug.Assert(null != ogn);
                Debug.Assert(null != mgn);
                cgn.AddPrev(ogn);
                cgn.AddPrev(mgn);
                ogn.AddNext(cgn);
                mgn.AddNext(cgn);

                semanticInfo.GraphNode = cgn;
            }

            GenMemberGet(sb, indent, objBuilder, memberBuilder, objType, mname, fieldIndex, struInfo, func);
            RecycleStringBuilder(objBuilder);
            RecycleStringBuilder(memberBuilder);
        }
        private static void TransformElementCompoundSet(bool isStatement, string op, Dsl.FunctionData lhs, Dsl.ISyntaxComponent rhs, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            semanticInfo.NameOrConst = string.Empty;
            Debug.Assert(null != lhs);

            var arg1Builder = NewStringBuilder();
            var arg2Builder = NewStringBuilder();
            var arg1Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
            var arg2Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
            TransformSyntax(lhs, arg1Builder, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref arg1Si);
            TransformSyntax(rhs, arg2Builder, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref arg2Si);
            string opd1 = arg1Si.ResultType;
            string opd2 = arg2Si.ResultType;

            var objBuilder = NewStringBuilder();
            var argBuilder = NewStringBuilder();
            var objSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            if (lhs.IsHighOrder)
                TransformSyntax(lhs.LowerOrderFunction, objBuilder, new ParseContextInfo { IsObjInAssignLHS = true }, 0, ref objSi);
            else
                TransformSyntax(lhs.Name, objBuilder, new ParseContextInfo { IsObjInAssignLHS = true }, 0, ref objSi);
            string objType = objSi.ResultType;

            var argSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            TransformSyntax(lhs.GetParam(0), argBuilder, 0, ref argSi);
            string argType = argSi.ResultType;
            string lhsType = string.Empty;
            lhsType = MemberTypeInference("[]", objType, lhsType, argType);
            if (string.IsNullOrEmpty(lhsType)) {
                Console.WriteLine("unknown obj '{0}' or member '{0}[{1}]', line: {2}", objType, argType, lhs.GetLine());
            }
            string restype = OperatorTypeInference(op, opd1, opd2);

            bool needBroadcast = false;
            bool isHighOrder = false;
            bool genGetOutAndEndRet = false;
            string outVar = string.Empty;
            if (s_IsVectorizing) {
                if (IsTypeVec(restype)) {
                    lhsType = GetTypeVec(lhsType, out var isTuple, out var isStruct, out var isVecBefore);
                    if (!isVecBefore) {
                        if (lhs.IsHighOrder) {
                            needBroadcast = true;
                            isHighOrder = true;
                            isStatement = false;
                        }
                        else {
                            if (VectorizeVar(lhs, out var varName, out needBroadcast)) {
                                if (needBroadcast) {
                                    outVar = varName;
                                    if (!isStatement) {
                                        genGetOutAndEndRet = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            semanticInfo.ResultType = lhsType;
            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, "[]=" + op);
                var ogn = objSi.GraphNode;
                var agn = argSi.GraphNode;
                var a1gn = arg1Si.GraphNode;
                var a2gn = arg2Si.GraphNode;
                Debug.Assert(null != ogn);
                Debug.Assert(null != agn);
                Debug.Assert(null != a1gn);
                Debug.Assert(null != a2gn);
                cgn.AddPrev(ogn);
                cgn.AddPrev(agn);
                cgn.AddPrev(a1gn);
                cgn.AddPrev(a2gn);
                ogn.AddNext(cgn);
                agn.AddNext(cgn);
                a1gn.AddNext(cgn);
                a2gn.AddNext(cgn);

                var objvgn = GetObjectVarNode(ogn);
                if (null != objvgn) {
                    cgn.AddOut(objvgn);
                    objvgn.AddPrev(cgn);
                }

                semanticInfo.GraphNode = cgn;
            }

            string retVar = GenCompoundElementSet(sb, indent, op, objBuilder, argBuilder, arg1Builder, arg2Builder, objType, argType, lhsType, opd1, opd2, restype, needBroadcast, genGetOutAndEndRet, outVar, isStatement, lhs);
            if (isHighOrder) {
                var lovBuilder = NewStringBuilder();
                GenAppend(sb, ", ");
                GenGetOutParam(retVar, 1, lovBuilder);

                var p = lhs.LowerOrderFunction;
                string paramType = GetTypeVec(objType);
                bool isMemberAccess = IsMemberAccess(p, out Dsl.FunctionData? memAccess);
                bool isElementAccess = IsElementAccess(p, out Dsl.FunctionData? elementAccess);
                if (isMemberAccess) {
                    Debug.Assert(null != memAccess);
                    var tempSi = new SemanticInfo(false);
                    TransformMemberSet(false, memAccess, lovBuilder, paramType, false, null, sb, 0, ref tempSi);
                }
                else if (isElementAccess) {
                    Debug.Assert(null != elementAccess);
                    var tempSi = new SemanticInfo(false);
                    TransformElementSet(false, elementAccess, lovBuilder, paramType, false, null, sb, 0, ref tempSi);
                }
                else {
                    Debug.Assert(false);
                }
                GenGetRetValEnd(sb);
                RecycleStringBuilder(lovBuilder);
            }
            RecycleStringBuilder(objBuilder);
            RecycleStringBuilder(argBuilder);
            RecycleStringBuilder(arg1Builder);
            RecycleStringBuilder(arg2Builder);
        }
        private static void TransformElementSet(bool isStatement, Dsl.FunctionData lhs, Dsl.ISyntaxComponent rhs, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            var rhsBuilder = NewStringBuilder();
            var rhsSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            TransformSyntax(rhs, rhsBuilder, 0, ref rhsSi);
            TransformElementSet(isStatement, lhs, rhsBuilder, rhsSi.ResultType, rhsSi.IsVarValRef, rhsSi.GraphNode, sb, indent, ref semanticInfo);
            RecycleStringBuilder(rhsBuilder);
        }
        private static void TransformElementSet(bool isStatement, Dsl.FunctionData lhs, StringBuilder rhsBuilder, string rhsType, bool rhsIsVarValRef, ComputeGraphNode? rgn, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            semanticInfo.NameOrConst = string.Empty;
            var objBuilder = NewStringBuilder();
            var argBuilder = NewStringBuilder();
            var objSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            if (lhs.IsHighOrder)
                TransformSyntax(lhs.LowerOrderFunction, objBuilder, new ParseContextInfo { IsObjInAssignLHS = true }, 0, ref objSi);
            else
                TransformSyntax(lhs.Name, objBuilder, new ParseContextInfo { IsObjInAssignLHS = true }, 0, ref objSi);
            string objType = objSi.ResultType;

            var argSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
            TransformSyntax(lhs.GetParam(0), argBuilder, 0, ref argSi);
            string argType = argSi.ResultType;
            string lhsType = string.Empty;
            lhsType = MemberTypeInference("[]", objType, lhsType, argType);
            if (string.IsNullOrEmpty(lhsType)) {
                Console.WriteLine("unknown obj '{0}' or member '{0}[{1}]', line: {2}", objType, argType, lhs.GetLine());
            }
            var varBuilder = NewStringBuilder();
            var varSi = new SemanticInfo(false);
            TransformSyntax(lhs, varBuilder, 0, ref varSi);

            bool needBroadcast = false;
            bool isHighOrder = false;
            bool genGetOutAndEndRet = false;
            string outVar = string.Empty;
            if (s_IsVectorizing) {
                if (IsTypeVec(rhsType)) {
                    lhsType = GetTypeVec(lhsType, out var isTuple, out var isStruct, out var isVecBefore);
                    if (!isVecBefore) {
                        if (lhs.IsHighOrder) {
                            needBroadcast = true;
                            isHighOrder = true;
                            isStatement = false;
                        }
                        else {
                            if (VectorizeVar(lhs, out var varName, out needBroadcast)) {
                                if (needBroadcast) {
                                    outVar = varName;
                                    if (!isStatement) {
                                        genGetOutAndEndRet = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            semanticInfo.ResultType = lhsType;
            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                Debug.Assert(null != rgn);
                var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, "[]=");
                var ogn = objSi.GraphNode;
                var agn = argSi.GraphNode;
                Debug.Assert(null != ogn);
                Debug.Assert(null != agn);
                cgn.AddPrev(ogn);
                cgn.AddPrev(agn);
                cgn.AddPrev(rgn);
                ogn.AddNext(cgn);
                agn.AddNext(cgn);
                rgn.AddNext(cgn);

                var objvgn = GetObjectVarNode(ogn);
                if (null != objvgn) {
                    cgn.AddOut(objvgn);
                    objvgn.AddPrev(cgn);
                }

                semanticInfo.GraphNode = cgn;
            }

            string retVar = GenElementSet(sb, indent, objBuilder, argBuilder, varBuilder, rhsBuilder, objType, argType, lhsType, rhsType, rhsIsVarValRef, needBroadcast, genGetOutAndEndRet, outVar, isStatement, lhs);
            if (isHighOrder) {
                var lovBuilder = NewStringBuilder();
                GenAppend(sb, ", ");
                GenGetOutParam(retVar, 1, lovBuilder);

                var p = lhs.LowerOrderFunction;
                string paramType = GetTypeVec(objType);
                bool isMemberAccess = IsMemberAccess(p, out Dsl.FunctionData? memAccess);
                bool isElementAccess = IsElementAccess(p, out Dsl.FunctionData? elementAccess);
                if (isMemberAccess) {
                    Debug.Assert(null != memAccess);
                    var tempSi = new SemanticInfo(false);
                    TransformMemberSet(false, memAccess, lovBuilder, paramType, false, null, sb, 0, ref tempSi);
                }
                else if (isElementAccess) {
                    Debug.Assert(null != elementAccess);
                    var tempSi = new SemanticInfo(false);
                    TransformElementSet(false, elementAccess, lovBuilder, paramType, false, null, sb, 0, ref tempSi);
                }
                else {
                    Debug.Assert(false);
                }
                GenGetRetValEnd(sb);
                RecycleStringBuilder(lovBuilder);
            }
            RecycleStringBuilder(objBuilder);
            RecycleStringBuilder(argBuilder);
            RecycleStringBuilder(varBuilder);
        }
        private static void TransformElementGet(Dsl.FunctionData func, StringBuilder sb, in ParseContextInfo contextInfo, int indent, ref SemanticInfo semanticInfo)
        {
            semanticInfo.IsVarValRef = false;
            semanticInfo.NameOrConst = string.Empty;
            if (contextInfo.Usage == SyntaxUsage.TypeName) {
                var objBuilder = NewStringBuilder();
                var argBuilder = NewStringBuilder();
                var nameSi = new SemanticInfo(false);
                if (func.IsHighOrder)
                    TransformSyntax(func.LowerOrderFunction, objBuilder, 0, ref nameSi);
                else if (func.HaveId())
                    TransformSyntax(func.Name, objBuilder, 0, ref nameSi);
                if (func.GetParamNum() > 0) {
                    var argSi = new SemanticInfo(false);
                    TransformSyntax(func.GetParam(0), argBuilder, 0, ref argSi);
                    string argType = argSi.ResultType;
                }
                GenArrayName(sb, indent, objBuilder, argBuilder);
                semanticInfo.ResultType = GetNamespaceName(func) + "_x" + func.GetParamId(0);
                RecycleStringBuilder(objBuilder);
                RecycleStringBuilder(argBuilder);
            }
            else {
                bool isObjInAssignLHS = contextInfo.IsObjInAssignLHS;
                ParseContextInfo pci;
                if (isObjInAssignLHS) {
                    pci = new ParseContextInfo { IsObjInAssignLHS = true };
                }
                else {
                    pci = new ParseContextInfo();
                }
                var objBuilder = NewStringBuilder();
                var argBuilder = NewStringBuilder();
                var objSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                if (func.IsHighOrder)
                    TransformSyntax(func.LowerOrderFunction, objBuilder, pci, 0, ref objSi);
                else
                    TransformSyntax(func.Name, objBuilder, pci, 0, ref objSi);
                string objType = objSi.ResultType;
                var argSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                TransformSyntax(func.GetParam(0), argBuilder, 0, ref argSi);
                string argType = argSi.ResultType;
                semanticInfo.ResultType = MemberTypeInference("[]", objType, semanticInfo.ResultType, argType);
                if (string.IsNullOrEmpty(semanticInfo.ResultType)) {
                    Console.WriteLine("unknown obj '{0}' or member '{0}[{1}]', line: {2}", objType, argType, func.GetLine());
                }

                if (!IsBaseType(semanticInfo.ResultType)) {
                    semanticInfo.IsVarValRef = true;
                }
                if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                    var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, "[]");
                    var ogn = objSi.GraphNode;
                    var agn = argSi.GraphNode;
                    Debug.Assert(null != ogn);
                    Debug.Assert(null != agn);
                    cgn.AddPrev(ogn);
                    cgn.AddPrev(agn);
                    ogn.AddNext(cgn);
                    agn.AddNext(cgn);

                    semanticInfo.GraphNode = cgn;
                }

                GenElementGet(sb, indent, objBuilder, argBuilder, objType, argType, func);
                RecycleStringBuilder(objBuilder);
                RecycleStringBuilder(argBuilder);
            }
        }
        private static void TransformInitList(Dsl.FunctionData func, StringBuilder sb, in ParseContextInfo contextInfo, int indent, ref SemanticInfo semanticInfo)
        {
            var argsBuilder = NewStringBuilder();
            semanticInfo.NameOrConst = string.Empty;
            int num = func.GetParamNum();

            ComputeGraphCalcNode? cgn = null;
            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                cgn = new ComputeGraphCalcNode(CurFuncInfo(), string.Empty, "[a]");
            }
            string lhsType = contextInfo.LhsType;
            string typeWithoutArrTag = GetTypeRemoveArrTag(lhsType, out var isTuple, out var isStruct, out var isVec, out var arrNums);
            if (isStruct) {
                if (s_StructInfos.TryGetValue(GetTypeNoVecPrefix(typeWithoutArrTag), out var struInfo)) {
                    if (null != cgn) {
                        cgn.Operator = "{s}";
                    }
                    string argType = string.Empty;
                    string prestr = string.Empty;
                    var typeBuilder = NewStringBuilder();
                    typeBuilder.Append(c_TupleTypePrefix);
                    typeBuilder.Append(num);
                    for (int ix = 0; ix < func.GetParamNum(); ++ix) {
                        string ty = string.Empty;
                        if (ix < struInfo.Fields.Count) {
                            ty = struInfo.Fields[ix].Type;
                            if (isVec)
                                ty = GetTypeVec(ty);
                        }
                        var p = func.GetParam(ix);
                        GenAppend(argsBuilder, prestr);
                        var typeSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                        TransformSyntax(p, argsBuilder, new ParseContextInfo { LhsType = ty }, 0, ref typeSi);
                        string type = typeSi.ResultType;
                        if (null != cgn) {
                            var tgn = typeSi.GraphNode;
                            Debug.Assert(null != tgn);
                            cgn.AddPrev(tgn);
                            tgn.AddNext(cgn);
                        }
                        if (string.IsNullOrEmpty(argType))
                            argType = type;
                        typeBuilder.Append("__");
                        typeBuilder.Append(type);
                        prestr = ", ";
                    }
                    semanticInfo.ResultType = typeBuilder.ToString();
                    if (null != cgn) {
                        cgn.Type = semanticInfo.ResultType;
                        semanticInfo.GraphNode = cgn;
                    }
                    RecycleStringBuilder(typeBuilder);
                }
                else {
                    Debug.Assert(false);
                }
            }
            else if (arrNums.Count > 0) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, func.GetId(), func.GetLine());
                }
                string argType = string.Empty;
                string prestr = string.Empty;
                foreach (var p in func.Params) {
                    GenAppend(argsBuilder, prestr);
                    var typeSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                    TransformSyntax(p, argsBuilder, new ParseContextInfo { LhsType = typeWithoutArrTag }, 0, ref typeSi);
                    string type = typeSi.ResultType;
                    if (null != cgn) {
                        var tgn = typeSi.GraphNode;
                        Debug.Assert(null != tgn);
                        cgn.AddPrev(tgn);
                        tgn.AddNext(cgn);
                    }
                    if (string.IsNullOrEmpty(argType))
                        argType = type;
                    prestr = ", ";
                }
                semanticInfo.ResultType = argType + "_x" + num.ToString();
                if (null != cgn) {
                    cgn.Type = semanticInfo.ResultType;
                    semanticInfo.GraphNode = cgn;
                }
            }
            else {
                string argType = string.Empty;
                string prestr = string.Empty;
                foreach (var p in func.Params) {
                    GenAppend(argsBuilder, prestr);
                    var typeSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                    TransformSyntax(p, argsBuilder, new ParseContextInfo { LhsType = typeWithoutArrTag }, 0, ref typeSi);
                    string type = typeSi.ResultType;
                    if (null != cgn) {
                        var tgn = typeSi.GraphNode;
                        Debug.Assert(null != tgn);
                        cgn.AddPrev(tgn);
                        tgn.AddNext(cgn);
                    }
                    if (string.IsNullOrEmpty(argType))
                        argType = type;
                    prestr = ", ";
                }
                semanticInfo.ResultType = argType + "_x" + num.ToString();
                if (null != cgn) {
                    cgn.Type = semanticInfo.ResultType;
                    semanticInfo.GraphNode = cgn;
                }
            }

            GenInitListBegin(sb, indent, semanticInfo.ResultType, isStruct, func);
            GenAppend(sb, argsBuilder);
            RecycleStringBuilder(argsBuilder);
            GenInitListEnd(sb, isStruct);
        }
        private static FuncInfo? TransformFuncCall(Dsl.FunctionData func, StringBuilder sb, in ParseContextInfo contextInfo, int indent, ref SemanticInfo semanticInfo, out bool isVec)
        {
            semanticInfo.IsVarValRef = false;
            semanticInfo.NameOrConst = string.Empty;
            isVec = false;
            FuncInfo? funcInfo = null;
            string objType = string.Empty;
            string funcName = string.Empty;
            ComputeGraphCalcNode? cgn = null;
            var objBuilder = NewStringBuilder();
            if (func.IsHighOrder) {
                var objSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                var compoundFunc = func.LowerOrderFunction;
                Debug.Assert(compoundFunc.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_PERIOD);
                if (compoundFunc.IsHighOrder)
                    TransformSyntax(compoundFunc.LowerOrderFunction, objBuilder, 0, ref objSi);
                else
                    TransformSyntax(compoundFunc.Name, objBuilder, 0, ref objSi);
                funcName = compoundFunc.GetParamId(0);
                objType = objSi.ResultType;

                if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                    cgn = new ComputeGraphCalcNode(CurFuncInfo(), string.Empty, funcName);
                    var ogn = objSi.GraphNode;
                    Debug.Assert(null != ogn);
                    cgn.AddPrev(ogn);
                    ogn.AddNext(cgn);
                }
            }
            else if (func.HaveId()) {
                funcName = func.GetId();

                if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                    cgn = new ComputeGraphCalcNode(CurFuncInfo(), string.Empty, funcName);
                    var ogn = new ComputeGraphConstNode(CurFuncInfo(), string.Empty, string.Empty);
                    cgn.AddPrev(ogn);
                    ogn.AddNext(cgn);
                }
            }
            else {
                //括号内只有一个参数，不用输出括号了（操作符都翻译到函数调用或赋值表达式了，赋值表达式输出时已经加了括号）
                if (!func.HaveId() && func.GetParamNum() == 1 && func.GetParamClassUnmasked() == (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_PARENTHESIS) {
                    var pp = func.GetParam(0);
                    var innerCall = pp as Dsl.FunctionData;
                    if (null != innerCall) {
                        TransformCall(innerCall, sb, contextInfo, 0, ref semanticInfo);
                    }
                    else {
                        TransformSyntax(pp, sb, contextInfo, 0, ref semanticInfo);
                    }
                    return null;
                }
            }
            List<string> argTypes = new List<string>();
            List<bool> argIsVarRefs = new List<bool>();
            List<string> argNameOrConsts = new List<string>();
            List<StringBuilder> argBuilders = new List<StringBuilder>();
            for (int ix = 0; ix < func.GetParamNum(); ++ix) {
                var p = func.GetParam(ix);
                var argBuilder = NewStringBuilder();
                var argSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                TransformSyntax(p, argBuilder, 0, ref argSi);
                argTypes.Add(argSi.ResultType);
                argIsVarRefs.Add(argSi.IsVarValRef);
                argNameOrConsts.Add(argSi.NameOrConst);
                argBuilders.Add(argBuilder);

                if (null != cgn) {
                    var agn = argSi.GraphNode;
                    Debug.Assert(null != agn);
                    cgn.AddPrev(agn);
                    agn.AddNext(cgn);
                }
            }
            if (string.IsNullOrEmpty(funcName)) {
                semanticInfo.ResultType = (argTypes.Count > 0 ? argTypes[argTypes.Count - 1] : string.Empty);
            }
            else {
                semanticInfo.ResultType = FunctionTypeInference(objType, funcName, argTypes, out funcInfo, out isVec);
                if (null != funcInfo && funcInfo.HasInOutOrOutParams) {
                    for (int ix = 0; ix < funcInfo.Params.Count; ++ix) {
                        var p = funcInfo.Params[ix];
                        if (p.IsOut) {
                            //out参数在调用时传入默认值（避免忘记给out参数赋值，此情形dxc只会警告不报错，dxc此时与inout处理相同，我们还是按out的语义来处理，也就是out参数一定会输出一个值），参数类型与函数形参类型一致
                            argTypes[ix] = p.Type;
                            var argBuilder = argBuilders[ix];
                            if (CurFuncCodeGenerateEnabled()) {
                                bool modified = funcInfo.ModifiedParams.Contains(p.Name);
                                argBuilder.Length = 0;
                                argBuilder.Append(GetDefaultValueInPython(p.Type, modified ? "True" : "False", func.GetParam(ix)));
                            }
                            if (null != cgn) {
                                var agn = cgn.PrevNodes[1 + ix];
                                var vgn = agn as ComputeGraphVarNode;
                                if (null != vgn) {
                                    vgn.IsOut = true;
                                }
                                var ogn = new ComputeGraphNode(CurFuncInfo(), p.Type);
                                cgn.AddOut(ogn);
                                ogn.AddPrev(cgn);
                            }
                        }
                        else if (p.IsInOut) {
                            if (null != cgn) {
                                var agn = cgn.PrevNodes[1 + ix];
                                var vgn = agn as ComputeGraphVarNode;
                                if (null != vgn) {
                                    vgn.IsInOut = true;
                                }
                                var ogn = new ComputeGraphNode(CurFuncInfo(), p.Type);
                                cgn.AddOut(ogn);
                                ogn.AddPrev(cgn);
                            }
                        }
                    }
                }
            }

            if (null != cgn) {
                cgn.Type = semanticInfo.ResultType;
                if (null != funcInfo)
                    cgn.Operator = funcInfo.Signature;
                semanticInfo.GraphNode = cgn;
            }

            for (int ix = 0; ix < func.GetParamNum(); ++ix) {
                var p = func.GetParam(ix);
                var argBuilder = argBuilders[ix];
                var argIsVarValRef = argIsVarRefs[ix];
                var argNameOrConst = argNameOrConsts[ix];
                bool isInOutOrOut = false;
                if (null != funcInfo) {
                    var param = funcInfo.Params[ix];
                    isInOutOrOut = param.IsInOut || param.IsOut;
                }
                if (s_EnableConstPropagation && !isInOutOrOut && !argIsVarValRef && !string.IsNullOrEmpty(argNameOrConst)) {
                    var newArg = new Dsl.ValueData(argNameOrConst);
                    newArg.SetLine(p.GetLine());
                    newArg.SetSeparator(p.GetSeparator());
                    func.SetParam(ix, newArg);
                    if (CurFuncCodeGenerateEnabled()) {
                        argBuilder.Length = 0;
                        argBuilder.Append(ConstToPython(argNameOrConst));
                    }
                }
            }
            if (func.IsHighOrder) {
                if (string.IsNullOrEmpty(semanticInfo.ResultType)) {
                    Console.WriteLine("can't deduce function '{0}.{1}'s type, line: {2}, vectorizing: {3}", objType, funcName, func.GetLine(), s_IsVectorizing);
                }
            }
            else if (func.HaveId()) {
                if (string.IsNullOrEmpty(semanticInfo.ResultType)) {
                    Console.WriteLine("can't deduce function '{0}'s type, line: {1}, vectorizing: {2}", funcName, func.GetLine(), s_IsVectorizing);
                }
            }
            GenFuncCall(sb, indent, objBuilder, argBuilders, objType, funcName, semanticInfo.ResultType, argTypes, argIsVarRefs, argNameOrConsts, func, funcInfo, isVec);
            RecycleStringBuilder(objBuilder);
            foreach (var argBuilder in argBuilders) {
                RecycleStringBuilder(argBuilder);
            }
            return funcInfo;
        }
        private static void TransformCall(Dsl.FunctionData func, StringBuilder sb, in ParseContextInfo contextInfo, int indent, ref SemanticInfo semanticInfo)
        {
            switch (func.GetParamClass()) {
                case (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_OPERATOR:
                    TransformOperator(func, sb, contextInfo, indent, ref semanticInfo);
                    break;
                case (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_PERIOD:
                    TransformMemberGet(func, sb, contextInfo, indent, ref semanticInfo);
                    break;
                case (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_BRACKET:
                    TransformElementGet(func, sb, contextInfo, indent, ref semanticInfo);
                    break;
                case (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_STATEMENT:
                    TransformInitList(func, sb, contextInfo, indent, ref semanticInfo);
                    semanticInfo.IsVarValRef = false;
                    break;
                default: {
                        string tmp = string.Empty;
                        bool hasInOutOrOutParams = false;
                        var funcSb = NewStringBuilder();
                        var funcInfo = TransformFuncCall(func, funcSb, contextInfo, 0, ref semanticInfo, out var isVec);
                        if (null != funcInfo && funcInfo.HasInOutOrOutParams) {
                            if (contextInfo.IsInCondExp) {
                                Console.WriteLine("call function '{0}' with 'inout/out' params in condition expression ! please change to if-else. line: {1}", func.GetId(), func.GetLine());
                            }

                            hasInOutOrOutParams = true;
                            GenIndent(sb, indent);
                            bool isMultiVal = !funcInfo.IsVoid() || funcInfo.InOutOrOutParams.Count > 1;
                            string retVar = string.Empty;
                            if (isMultiVal) {
                                GenGetRetValBegin("_call_ret_", sb, out retVar);
                                GenAppend(sb, funcSb);
                            }
                            int outIx = funcInfo.IsVoid() ? 0 : 1;
                            int graphOutIx = 0;
                            for (int ix = 0; ix < funcInfo.Params.Count; ++ix) {
                                var param = funcInfo.Params[ix];
                                if (param.IsInOut || param.IsOut) {
                                    ComputeGraphNode? gn = null;
                                    if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                                        Debug.Assert(null != semanticInfo.GraphNode);
                                        gn = semanticInfo.GraphNode.OutNodes[graphOutIx];
                                    }
                                    ++graphOutIx;

                                    var p = func.GetParam(ix);
                                    var rhs = funcSb;
                                    if (isMultiVal) {
                                        GenAppend(sb, ", ");
                                        rhs = NewStringBuilder();
                                        GenGetOutParam(retVar, outIx, rhs);
                                    }
                                    string paramType = param.Type;
                                    if (isVec) {
                                        paramType = GetTypeVec(paramType);
                                    }
                                    bool isMemberAccess = IsMemberAccess(p, out Dsl.FunctionData? memAccess);
                                    bool isElementAccess = IsElementAccess(p, out Dsl.FunctionData? elementAccess);
                                    if (isMemberAccess) {
                                        Debug.Assert(null != memAccess);
                                        var tempSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                                        TransformMemberSet(false, memAccess, rhs, paramType, false, gn, sb, 0, ref tempSi);
                                    }
                                    else if (isElementAccess) {
                                        Debug.Assert(null != elementAccess);
                                        var tempSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                                        TransformElementSet(false, elementAccess, rhs, paramType, false, gn, sb, 0, ref tempSi);
                                    }
                                    else {
                                        if (contextInfo.Usage == SyntaxUsage.Operator)
                                            GenAppend(sb, "(");
                                        var lhsSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                                        TransformSyntax(p, sb, new ParseContextInfo { IsInAssignLHS = true }, 0, ref lhsSi);
                                        string lhsType = lhsSi.ResultType;
                                        string vname = lhsSi.NameOrConst;
                                        if (!string.IsNullOrEmpty(vname)) {
                                            var curBlockInfo = CurBlockInfo();
                                            var vinfo = GetVarInfo(vname, VarUsage.Find);
                                            if (null != curBlockInfo && null != vinfo) {
                                                curBlockInfo.SetVarConst(vname, string.Empty);
                                            }
                                        }
                                        if (s_IsVectorizing) {
                                            if (IsTypeVec(paramType)) {
                                                lhsType = GetTypeVec(lhsType, out var isTuple, out var isStruct, out var isVecBefore);
                                                if (!isVecBefore && VectorizeVar(p, out var _, out var needBroadCast)) {
                                                    if (needBroadCast) {
                                                        Console.WriteLine("[Error]: obj '{0}' cannot be broadcast in an assignment embedded in an expression, line: {1}", p.GetId(), p.GetLine());
                                                    }
                                                }
                                            }
                                        }
                                        if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                                            var vgn = FindComputeGraphVarNode(vname);
                                            var agn = gn;
                                            Debug.Assert(null != vgn);
                                            Debug.Assert(null != agn);
                                            var cgn = new ComputeGraphCalcNode(CurFuncInfo(), lhsType, "=");
                                            cgn.AddPrev(agn);
                                            agn.AddNext(cgn);

                                            cgn.AddNext(vgn);
                                            vgn.AddPrev(cgn);
                                        }
                                        if (!isMultiVal && contextInfo.IsTopLevelStatement)
                                            GenAppend(sb, " = ");
                                        else
                                            GenAppend(sb, " := ");
                                        GenAssignRHS(sb, rhs, lhsType, paramType, vname, string.Empty, false, p);
                                        if (contextInfo.Usage == SyntaxUsage.Operator)
                                            GenAppend(sb, ")");
                                    }
                                    if (isMultiVal) {
                                        RecycleStringBuilder(rhs);
                                    }
                                    ++outIx;
                                }
                            }
                            if (isMultiVal) {
                                GenGetRetValEnd(sb);
                            }
                        }
                        if (!hasInOutOrOutParams)
                            GenAppend(sb, funcSb);
                        RecycleStringBuilder(funcSb);
                    }
                    break;
            }
        }
        private static void TransformSyntax(Dsl.ISyntaxComponent info, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            TransformSyntax(info, sb, new ParseContextInfo(), indent, ref semanticInfo);
        }
        private static void TransformSyntax(Dsl.ISyntaxComponent info, StringBuilder sb, in ParseContextInfo contextInfo, int indent, ref SemanticInfo semanticInfo)
        {
            semanticInfo.IsVarValRef = false;
            semanticInfo.NameOrConst = string.Empty;
            var func = info as Dsl.FunctionData;
            if (null != func) {
                if (func.IsHighOrder) {
                    TransformCall(func, sb, contextInfo, indent, ref semanticInfo);
                }
                else if (func.GetParamClassUnmasked() != (int)Dsl.FunctionData.ParamClassEnum.PARAM_CLASS_PARENTHESIS) {
                    TransformCall(func, sb, contextInfo, indent, ref semanticInfo);
                }
                else {
                    string id = func.GetId();
                    if (id == "var") {
                        TransformVar(func, sb, indent, ref semanticInfo);
                        semanticInfo.IsVarValRef = true;
                    }
                    else if (id == "cast") {
                        var arg1Builder = NewStringBuilder();
                        var arg2Builder = NewStringBuilder();
                        var p0 = func.GetParam(0);
                        var p1 = func.GetParam(1);
                        var arg1Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
                        var arg2Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
                        TransformSyntax(p0, arg1Builder, contextInfo with { Usage = SyntaxUsage.TypeName }, 0, ref arg1Si);
                        TransformSyntax(p1, arg2Builder, 0, ref arg2Si);
                        semanticInfo.ResultType = arg1Si.ResultType;
                        if (!string.IsNullOrEmpty(arg2Si.NameOrConst) && semanticInfo.ResultType == "int") {
                            float v;
                            if (float.TryParse(arg2Si.NameOrConst, out v)) {
                                semanticInfo.NameOrConst = ((int)v).ToString();
                            }
                        }
                        GenCast(sb, indent, arg2Builder, semanticInfo.ResultType, arg2Si.ResultType, info);
                        if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                            var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, id);
                            var a1gn = arg1Si.GraphNode;
                            var a2gn = arg2Si.GraphNode;
                            Debug.Assert(null != a1gn);
                            Debug.Assert(null != a2gn);
                            cgn.AddPrev(a1gn);
                            cgn.AddPrev(a2gn);
                            a1gn.AddNext(cgn);
                            a2gn.AddNext(cgn);

                            semanticInfo.GraphNode = cgn;
                        }
                        RecycleStringBuilder(arg1Builder);
                        RecycleStringBuilder(arg2Builder);
                    }
                    else {
                        TransformCall(func, sb, contextInfo, indent, ref semanticInfo);
                    }
                }
            }
            else {
                var val = info as Dsl.ValueData;
                if (null != val) {
                    string id = val.GetId();
                    switch (val.GetIdType()) {
                        case (int)Dsl.ValueData.STRING_TOKEN:
                            semanticInfo.ResultType = "string";
                            semanticInfo.NameOrConst = id;
                            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                                var cgcn = new ComputeGraphConstNode(CurFuncInfo(), semanticInfo.ResultType, id);
                                semanticInfo.GraphNode = cgcn;
                            }
                            GenStringConst(sb, indent, id);
                            break;
                        case (int)Dsl.ValueData.NUM_TOKEN:
                            while (id.Length > 0) {
                                char c = id[id.Length - 1];
                                if (c == 'I' || c == 'L' || c == 'u' || c == 'U' || c == 'z' || c == 'Z')
                                    id = id.Substring(0, id.Length - 1);
                                else
                                    break;
                            }
                            if ((id.EndsWith('b') || id.EndsWith('B') || id.EndsWith('f') || id.EndsWith('F')) && !id.StartsWith("0x"))
                                id = id.Substring(0, id.Length - 1);
                            if (id.Contains('.')) {
                                semanticInfo.ResultType = "float";
                                semanticInfo.NameOrConst = id;
                            }
                            else {
                                semanticInfo.ResultType = "int";
                                semanticInfo.NameOrConst = id;
                            }
                            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                                var cgcn = new ComputeGraphConstNode(CurFuncInfo(), semanticInfo.ResultType, id);
                                semanticInfo.GraphNode = cgcn;
                            }
                            GenNumberConst(sb, indent, id);
                            break;
                        default:
                            if (val.HaveId()) {
                                var usage = VarUsage.Read;
                                if (contextInfo.IsInAssignLHS) {
                                    usage = VarUsage.Write;
                                    semanticInfo.NameOrConst = id;
                                    semanticInfo.IsVarValRef = true;
                                }
                                else if (contextInfo.IsObjInAssignLHS) {
                                    usage = VarUsage.ObjSet;
                                    semanticInfo.NameOrConst = id;
                                    semanticInfo.IsVarValRef = true;
                                }
                                bool isBoolConstOrVar = true;
                                var varInfo = GetVarInfo(id, usage);
                                if (contextInfo.Usage == SyntaxUsage.TypeName) {
                                    semanticInfo.ResultType = id;
                                    isBoolConstOrVar = false;
                                }
                                else if (contextInfo.Usage == SyntaxUsage.MemberName
                                    || contextInfo.Usage == SyntaxUsage.FuncName) {
                                    isBoolConstOrVar = false;
                                }
                                else if (null != varInfo) {
                                    if (varInfo.Name != id) {
                                        id = varInfo.Name;
                                        val.SetId(id);
                                    }
                                    semanticInfo.ResultType = varInfo.Type;
                                    if (!contextInfo.IsInAssignLHS) {
                                        if (varInfo.IsConst && !string.IsNullOrEmpty(varInfo.InitOrDefValueConst)) {
                                            semanticInfo.NameOrConst = varInfo.InitOrDefValueConst;
                                        }
                                        else {
                                            var blockInfo = CurBlockInfo();
                                            if (null != blockInfo && blockInfo.TryGetCurVarConst(varInfo.Name, out var cval) && !string.IsNullOrEmpty(cval)) {
                                                semanticInfo.NameOrConst = cval;
                                            }
                                            else {
                                                semanticInfo.NameOrConst = id;
                                                semanticInfo.IsVarValRef = true;
                                            }
                                        }
                                    }
                                }
                                else if (IsHlslBool(id)) {
                                    semanticInfo.ResultType = "bool";
                                    semanticInfo.NameOrConst = id;
                                }
                                else {
                                    Console.WriteLine("unknown type '{0}', line: {1}", id, info.GetLine());
                                }

                                if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                                    var cgvn = FindComputeGraphVarNode(id);
                                    if (null == cgvn) {
                                        var cgcn = new ComputeGraphConstNode(CurFuncInfo(), semanticInfo.ResultType, id);
                                        semanticInfo.GraphNode = cgcn;
                                    }
                                    else {
                                        semanticInfo.GraphNode = cgvn;
                                    }
                                }
                                GenBoolConstOrVarOrName(sb, indent, id, isBoolConstOrVar);
                            }
                            break;
                    }
                }
                else {
                    var stm = info as Dsl.StatementData;
                    if (null != stm) {
                        string id = stm.GetId();
                        if (id == "var") {
                            TransformVar(stm, sb, indent, ref semanticInfo);
                            semanticInfo.IsVarValRef = true;
                        }
                        else if (id == "?") {
                            var tfunc = stm.First.AsFunction;
                            var ffunc = stm.Second.AsFunction;
                            Debug.Assert(null != tfunc && null != ffunc);
                            var arg1Builder = NewStringBuilder();
                            var arg2Builder = NewStringBuilder();
                            var arg3Builder = NewStringBuilder();
                            var arg1Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
                            var arg2Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
                            var arg3Si = new SemanticInfo(semanticInfo.NeedComputeGraph);
                            string opd1 = string.Empty;
                            string opd2 = string.Empty;
                            string opd3 = string.Empty;
                            var arg1 = tfunc.LowerOrderFunction.GetParam(0);
                            var arg2 = tfunc.GetParam(0);
                            var arg3 = ffunc.GetParam(0);
                            TransformSyntax(arg1, arg1Builder, 0, ref arg1Si);
                            TransformSyntax(arg2, arg2Builder, new ParseContextInfo(contextInfo) with { IsInCondExp = true }, 0, ref arg2Si);
                            TransformSyntax(arg3, arg3Builder, new ParseContextInfo(contextInfo) with { IsInCondExp = true }, 0, ref arg3Si);
                            opd1 = arg1Si.ResultType;
                            var opd1IsVarValRef = arg1Si.IsVarValRef;
                            var cres0 = arg1Si.NameOrConst;
                            opd2 = arg2Si.ResultType;
                            var opd2IsVarValRef = arg2Si.IsVarValRef;
                            var cres1 = arg2Si.NameOrConst;
                            opd3 = arg3Si.ResultType;
                            var opd3IsVarValRef = arg3Si.IsVarValRef;
                            var cres2 = arg3Si.NameOrConst;
                            bool isVec = false;
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
                            semanticInfo.ResultType = GetMaxType(oriOpd2, oriOpd3);
                            if (isVec)
                                semanticInfo.ResultType = GetTypeVec(semanticInfo.ResultType);
                            if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                                var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, "?:");
                                var a1gn = arg1Si.GraphNode;
                                var a2gn = arg2Si.GraphNode;
                                var a3gn = arg3Si.GraphNode;
                                Debug.Assert(null != a1gn);
                                Debug.Assert(null != a2gn);
                                Debug.Assert(null != a3gn);
                                cgn.AddPrev(a1gn);
                                cgn.AddPrev(a2gn);
                                cgn.AddPrev(a3gn);
                                a1gn.AddNext(cgn);
                                a2gn.AddNext(cgn);
                                a3gn.AddNext(cgn);

                                semanticInfo.GraphNode = cgn;
                            }
                            if (s_EnableConstPropagation) {
                                if (!opd1IsVarValRef && !opd2IsVarValRef && !opd3IsVarValRef && !string.IsNullOrEmpty(cres0) && !string.IsNullOrEmpty(cres1) && !string.IsNullOrEmpty(cres2)) {
                                    semanticInfo.NameOrConst = ConstCondExpCalc(cres0, opd2, cres1, opd3, cres2);
                                }
                                else {
                                    if (!opd1IsVarValRef && !string.IsNullOrEmpty(cres0)) {
                                        var newVal = new Dsl.ValueData(cres0);
                                        newVal.SetLine(arg1.GetLine());
                                        newVal.SetSeparator(arg1.GetSeparator());
                                        tfunc.LowerOrderFunction.SetParam(0, newVal);
                                        if (CurFuncCodeGenerateEnabled()) {
                                            arg1Builder.Length = 0;
                                            arg1Builder.Append(ConstToPython(cres0));
                                        }
                                    }
                                    if (!opd2IsVarValRef && !string.IsNullOrEmpty(cres1)) {
                                        var newVal = new Dsl.ValueData(cres1);
                                        newVal.SetLine(arg2.GetLine());
                                        newVal.SetSeparator(arg2.GetSeparator());
                                        tfunc.SetParam(0, newVal);
                                        if (CurFuncCodeGenerateEnabled()) {
                                            arg2Builder.Length = 0;
                                            arg2Builder.Append(ConstToPython(cres1));
                                        }
                                    }
                                    if (!opd3IsVarValRef && !string.IsNullOrEmpty(cres2)) {
                                        var newVal = new Dsl.ValueData(cres2);
                                        newVal.SetLine(arg3.GetLine());
                                        newVal.SetSeparator(arg3.GetSeparator());
                                        ffunc.SetParam(0, newVal);
                                        if (CurFuncCodeGenerateEnabled()) {
                                            arg3Builder.Length = 0;
                                            arg3Builder.Append(ConstToPython(cres2));
                                        }
                                    }
                                }
                            }
                            GenCondExp(sb, indent, arg1Builder, arg2Builder, arg3Builder, opd1, opd2, opd3, info);
                            RecycleStringBuilder(arg1Builder);
                            RecycleStringBuilder(arg2Builder);
                            RecycleStringBuilder(arg3Builder);
                        }
                        else {
                            Console.WriteLine("unknown syntax '{0}', line: {1}, class: {2} !", info.GetId(), info.GetLine(), info.GetType());
                        }
                    }
                    else {
                        Console.WriteLine("unknown syntax '{0}', line: {1}, class: {2} !", info.GetId(), info.GetLine(), info.GetType());
                    }
                }
            }
        }
        internal static void TransformAssignmentStatement(string id, Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            var tempSi = new SemanticInfo(true);
            TransformAssignmentStatement(id, info, sb, indent, ref tempSi);
            if (null != tempSi.GraphNode)
                AddComputeGraphRootNode(tempSi.GraphNode);
        }
        internal static void TransformAssignmentStatement(string id, Dsl.ISyntaxComponent info, StringBuilder sb, int indent, ref SemanticInfo semanticInfo)
        {
            //常量替换只替换运算结果，也就是只有操作数被替换，同时顶层语句仍然保留（可能能方便与shader源码对应，额外开销应该不大）
            string tmp = string.Empty;
            var assignFunc = info as Dsl.FunctionData;
            Debug.Assert(null != assignFunc);
            var lhs = assignFunc.GetParam(0);
            var rhs = assignFunc.GetParam(1);
            //考虑到矢量化（或numpy的broadcast），out参数先处理后再处理赋值，这里不用处理out参数的情形
            bool isMemberAccess = IsMemberAccess(lhs, out Dsl.FunctionData? memAccess);
            bool isElementAccess = IsElementAccess(lhs, out Dsl.FunctionData? elementAccess);
            if (isMemberAccess) {
                Debug.Assert(null != memAccess);
                TransformMemberSet(true, memAccess, rhs, sb, indent, ref semanticInfo);
                GenAppendLine(sb);
            }
            else if (isElementAccess) {
                Debug.Assert(null != elementAccess);
                TransformElementSet(true, elementAccess, rhs, sb, indent, ref semanticInfo);
                GenAppendLine(sb);
            }
            else {
                var lhsBuilder = NewStringBuilder();
                TransformSyntax(lhs, lhsBuilder, new ParseContextInfo { IsInAssignLHS = true }, 0, ref semanticInfo);
                string lhsType = semanticInfo.ResultType;
                string vname = semanticInfo.NameOrConst;

                var rhsBuilder = NewStringBuilder();
                var rhsSi = new SemanticInfo(semanticInfo.NeedComputeGraph);
                TransformSyntax(rhs, rhsBuilder, new ParseContextInfo { LhsType = lhsType }, 0, ref rhsSi);
                string rhsType = rhsSi.ResultType;
                var rhsIsVarValRef = rhsSi.IsVarValRef;
                var cres = rhsSi.NameOrConst;

                if (!string.IsNullOrEmpty(vname) && (!s_IsVectorizing || !IsTypeVec(lhsType))) {
                    var curBlockInfo = CurBlockInfo();
                    var vinfo = GetVarInfo(vname, VarUsage.Find);
                    if (null != vinfo && vinfo.IsConst && !string.IsNullOrEmpty(cres)) {
                        vinfo.InitOrDefValueConst = cres;
                    }
                    if (null != curBlockInfo && null != vinfo) {
                        if (rhsIsVarValRef || string.IsNullOrEmpty(cres))
                            curBlockInfo.SetVarConst(vname, string.Empty);
                        else
                            curBlockInfo.SetVarConst(vname, cres);
                    }
                }
                if (s_EnableConstPropagation && !rhsIsVarValRef && !string.IsNullOrEmpty(cres)) {
                    var newVal = new Dsl.ValueData(cres);
                    newVal.SetLine(rhs.GetLine());
                    newVal.SetSeparator(rhs.GetSeparator());
                    assignFunc.SetParam(1, newVal);
                    if (CurFuncCodeGenerateEnabled()) {
                        rhsBuilder.Length = 0;
                        rhsBuilder.Append(ConstToPython(cres));
                    }
                }
                if (s_IsVectorizing) {
                    if (IsTypeVec(rhsType)) {
                        lhsType = GetTypeVec(lhsType, out var isTuple, out var isStruct, out var isVecBefore);
                        if (!isVecBefore && VectorizeVar(lhs, out var vn, out var needBroadcast)) {
                        }
                    }
                }
                semanticInfo.ResultType = lhsType;
                if (semanticInfo.NeedComputeGraph && !CurFuncBlockInfoConstructed()) {
                    var cgn = new ComputeGraphCalcNode(CurFuncInfo(), semanticInfo.ResultType, "=");
                    var agn = rhsSi.GraphNode;
                    Debug.Assert(null != agn);
                    cgn.AddPrev(agn);
                    agn.AddNext(cgn);

                    var vgn = semanticInfo.GraphNode;
                    Debug.Assert(null != vgn);
                    cgn.AddNext(vgn);
                    vgn.AddPrev(cgn);

                    semanticInfo.GraphNode = vgn;
                }

                GenAssignStatement(sb, indent, lhsBuilder, rhsBuilder, lhsType, rhsType, vname, cres, rhsIsVarValRef, info);
                RecycleStringBuilder(lhsBuilder);
                RecycleStringBuilder(rhsBuilder);
            }
        }
        private static void TransformCompoundAssignmentStatement(string id, Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            //常量替换只替换运算结果，也就是只有操作数被替换，同时顶层语句仍然保留（可能能方便与shader源码对应，额外开销应该不大）
            string tmp = string.Empty;
            var assignFunc = info as Dsl.FunctionData;
            Debug.Assert(null != assignFunc);
            var lhs = assignFunc.GetParam(0);
            var rhs = assignFunc.GetParam(1);
            bool isMemberAccess = IsMemberAccess(lhs, out Dsl.FunctionData? memAccess);
            bool isElementAccess = IsElementAccess(lhs, out Dsl.FunctionData? elementAccess);
            string op = id.Substring(0, id.Length - 1);
            if (isMemberAccess) {
                Debug.Assert(null != memAccess);
                var tempSi = new SemanticInfo(true);
                TransformMemberCompoundSet(true, op, memAccess, rhs, sb, indent, ref tempSi);
                if (null != tempSi.GraphNode)
                    AddComputeGraphRootNode(tempSi.GraphNode);
                GenAppendLine(sb);
            }
            else if (isElementAccess) {
                Debug.Assert(null != elementAccess);
                var tempSi = new SemanticInfo(true);
                TransformElementCompoundSet(true, op, elementAccess, rhs, sb, indent, ref tempSi);
                if (null != tempSi.GraphNode)
                    AddComputeGraphRootNode(tempSi.GraphNode);
                GenAppendLine(sb);
            }
            else {
                var arg1Builder = NewStringBuilder();
                var arg2Builder = NewStringBuilder();
                var arg1Si = new SemanticInfo(false);
                var arg2Si = new SemanticInfo(true);
                TransformSyntax(lhs, arg1Builder, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref arg1Si);
                TransformSyntax(rhs, arg2Builder, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref arg2Si);
                string opd1 = arg1Si.ResultType;
                string opd2 = arg2Si.ResultType;
                var rhsIsVarValRef = arg2Si.IsVarValRef;
                var cres = arg2Si.NameOrConst;

                var lhsBuilder = NewStringBuilder();
                var lhsSi = new SemanticInfo(true);
                TransformSyntax(lhs, lhsBuilder, new ParseContextInfo { IsInAssignLHS = true }, 0, ref lhsSi);
                string lhsType = lhsSi.ResultType;
                var lhsIsVarValRef = lhsSi.IsVarValRef;
                var vname = lhsSi.NameOrConst;

                string restype = OperatorTypeInference(op, opd1, opd2);
                if (!string.IsNullOrEmpty(vname)) {
                    var curBlockInfo = CurBlockInfo();
                    var vinfo = GetVarInfo(vname, VarUsage.Find);
                    if (null != curBlockInfo && null != vinfo) {
                        bool biCon = CurFuncBlockInfoConstructed();
                        if (rhsIsVarValRef || string.IsNullOrEmpty(cres)) {
                            if (biCon)
                                curBlockInfo.SetVarConst(vname, string.Empty);
                        }
                        else {
                            if (curBlockInfo.TryGetCurVarConst(vname, out var val)) {
                                string nres = ConstCalc(op, opd1, val, opd2, cres);
                                curBlockInfo.SetVarConst(vname, nres);
                            }
                            else if (biCon) {
                                curBlockInfo.SetVarConst(vname, string.Empty);
                            }
                        }
                    }
                }
                if (s_EnableConstPropagation && !rhsIsVarValRef && !string.IsNullOrEmpty(cres)) {
                    var newVal = new Dsl.ValueData(cres);
                    newVal.SetLine(rhs.GetLine());
                    newVal.SetSeparator(rhs.GetSeparator());
                    assignFunc.SetParam(1, newVal);
                    if (CurFuncCodeGenerateEnabled()) {
                        arg2Builder.Length = 0;
                        arg2Builder.Append(ConstToPython(cres));
                    }
                }
                if (s_IsVectorizing) {
                    if (IsTypeVec(restype)) {
                        lhsType = GetTypeVec(lhsType, out var isTuple, out var isStruct, out var isVecBefore);
                        if (!isVecBefore && VectorizeVar(lhs, out var varName, out var needBroadcast)) {
                        }
                    }
                }

                if (!CurFuncBlockInfoConstructed()) {
                    var cgn = new ComputeGraphCalcNode(CurFuncInfo(), lhsType, id);

                    var vgn = lhsSi.GraphNode;
                    Debug.Assert(null != vgn);
                    cgn.AddPrev(vgn);
                    vgn.AddNext(cgn);

                    var agn = arg2Si.GraphNode;
                    Debug.Assert(null != agn);
                    cgn.AddPrev(agn);
                    agn.AddNext(cgn);

                    cgn.AddNext(vgn);
                    vgn.AddPrev(cgn);

                    AddComputeGraphRootNode(cgn);
                }

                GenCompoundAssignStatement(sb, indent, op, lhsBuilder, arg1Builder, arg2Builder, lhsType, opd1, opd2, restype, info);
                RecycleStringBuilder(lhsBuilder);
                RecycleStringBuilder(arg1Builder);
                RecycleStringBuilder(arg2Builder);
            }
        }
        private static void TransformIncStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            //常量替换只替换运算结果，也就是只有操作数被替换，同时顶层语句仍然保留（可能能方便与shader源码对应，额外开销应该不大）
            string tmp = string.Empty;
            var incFunc = info as Dsl.FunctionData;
            Debug.Assert(null != incFunc);
            var arg = incFunc.GetParam(0);
            bool isMemberAccess = IsMemberAccess(arg, out Dsl.FunctionData? memAccess);
            bool isElementAccess = IsElementAccess(arg, out Dsl.FunctionData? elementAccess);
            if (isMemberAccess) {
                Debug.Assert(null != memAccess);
                var tempSi = new SemanticInfo(true);
                TransformMemberCompoundSet(true, "+", memAccess, s_ConstDslValueOne, sb, indent, ref tempSi);
                if (null != tempSi.GraphNode)
                    AddComputeGraphRootNode(tempSi.GraphNode);
                GenAppendLine(sb);
            }
            else if (isElementAccess) {
                Debug.Assert(null != elementAccess);
                var tempSi = new SemanticInfo(true);
                TransformElementCompoundSet(true, "+", elementAccess, s_ConstDslValueOne, sb, indent, ref tempSi);
                if (null != tempSi.GraphNode)
                    AddComputeGraphRootNode(tempSi.GraphNode);
                GenAppendLine(sb);
            }
            else {
                var argBuilder = NewStringBuilder();
                var argSi = new SemanticInfo(false);
                TransformSyntax(arg, argBuilder, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref argSi);
                string opd = argSi.ResultType;

                var varBuilder = NewStringBuilder();
                var varSi = new SemanticInfo(true);
                TransformSyntax(arg, varBuilder, new ParseContextInfo { IsInAssignLHS = true }, 0, ref varSi);
                var vname = varSi.NameOrConst;

                bool constGenerated = false;
                if (!string.IsNullOrEmpty(vname)) {
                    var blockInfo = CurBlockInfo();
                    var vinfo = GetVarInfo(vname, VarUsage.Find);
                    if (null != vinfo && null != blockInfo) {
                        if (blockInfo.TryGetCurVarConst(vname, out var val) && !string.IsNullOrEmpty(val)) {
                            val = ConstCalc("++", vinfo.OriType, val);
                            blockInfo.SetVarConst(vname, val);
                            GenConstAssign(sb, indent, vname, val);
                            constGenerated = true;
                        }
                        else if (CurFuncBlockInfoConstructed()) {
                            blockInfo.SetVarConst(vname, string.Empty);
                        }
                    }
                }

                if (!CurFuncBlockInfoConstructed()) {
                    var cgn = new ComputeGraphCalcNode(CurFuncInfo(), varSi.ResultType, "++");

                    var vgn = varSi.GraphNode;
                    Debug.Assert(null != vgn);
                    cgn.AddPrev(vgn);
                    vgn.AddNext(cgn);

                    cgn.AddNext(vgn);
                    vgn.AddPrev(cgn);

                    AddComputeGraphRootNode(cgn);
                }

                if (!constGenerated) {
                    GenIncStatement(sb, indent, varBuilder, argBuilder, opd);
                }
                RecycleStringBuilder(varBuilder);
                RecycleStringBuilder(argBuilder);
            }
        }
        private static void TransformDecStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            //常量替换只替换运算结果，也就是只有操作数被替换，同时顶层语句仍然保留（可能能方便与shader源码对应，额外开销应该不大）
            string tmp = string.Empty;
            var decFunc = info as Dsl.FunctionData;
            Debug.Assert(null != decFunc);
            var arg = decFunc.GetParam(0);
            bool isMemberAccess = IsMemberAccess(arg, out Dsl.FunctionData? memAccess);
            bool isElementAccess = IsElementAccess(arg, out Dsl.FunctionData? elementAccess);
            if (isMemberAccess) {
                Debug.Assert(null != memAccess);
                var tempSi = new SemanticInfo(true);
                TransformMemberCompoundSet(true, "-", memAccess, s_ConstDslValueOne, sb, indent, ref tempSi);
                if (null != tempSi.GraphNode)
                    AddComputeGraphRootNode(tempSi.GraphNode);
                GenAppendLine(sb);
            }
            else if (isElementAccess) {
                Debug.Assert(null != elementAccess);
                var tempSi = new SemanticInfo(true);
                TransformElementCompoundSet(true, "-", elementAccess, s_ConstDslValueOne, sb, indent, ref tempSi);
                if (null != tempSi.GraphNode)
                    AddComputeGraphRootNode(tempSi.GraphNode);
                GenAppendLine(sb);
            }
            else {
                var argBuilder = NewStringBuilder();
                var argSi = new SemanticInfo(false);
                TransformSyntax(arg, argBuilder, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref argSi);
                string opd = argSi.ResultType;

                var varBuilder = NewStringBuilder();
                var varSi = new SemanticInfo(true);
                TransformSyntax(arg, varBuilder, new ParseContextInfo { IsInAssignLHS = true }, 0, ref varSi);
                var vname = varSi.NameOrConst;

                bool constGenerated = false;
                if (!string.IsNullOrEmpty(vname)) {
                    var blockInfo = CurBlockInfo();
                    var vinfo = GetVarInfo(vname, VarUsage.Find);
                    if (null != vinfo && null != blockInfo) {
                        if (blockInfo.TryGetCurVarConst(vname, out var val) && !string.IsNullOrEmpty(val)) {
                            val = ConstCalc("--", vinfo.OriType, val);
                            blockInfo.SetVarConst(vname, val);
                            GenConstAssign(sb, indent, vname, val);
                            constGenerated = true;
                        }
                        else if (CurFuncBlockInfoConstructed()) {
                            blockInfo.SetVarConst(vname, string.Empty);
                        }
                    }
                }

                if (!CurFuncBlockInfoConstructed()) {
                    var cgn = new ComputeGraphCalcNode(CurFuncInfo(), varSi.ResultType, "--");

                    var vgn = varSi.GraphNode;
                    Debug.Assert(null != vgn);
                    cgn.AddPrev(vgn);
                    vgn.AddNext(cgn);

                    cgn.AddNext(vgn);
                    vgn.AddPrev(cgn);

                    AddComputeGraphRootNode(cgn);
                }

                if (!constGenerated) {
                    GenDecStatement(sb, indent, varBuilder, argBuilder, opd);
                }
                RecycleStringBuilder(varBuilder);
                RecycleStringBuilder(argBuilder);
            }
        }
        private static void TransformReturnStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            var retFunc = info as Dsl.FunctionData;
            Debug.Assert(null != retFunc);
            Dsl.ISyntaxComponent? retVal = null;
            if (retFunc.GetParamNum() > 0)
                retVal = retFunc.GetParam(0);
            TransformReturn(retVal, sb, indent, info);
        }
        private static void TransformRetExpStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            string tmp = string.Empty;
            var retFunc = info as Dsl.FunctionData;
            Debug.Assert(null != retFunc);
            var retVal = retFunc.GetParam(1);
            TransformReturn(retVal, sb, indent, info);
        }
        private static void TransformReturn(Dsl.ISyntaxComponent? retVal, StringBuilder sb, int indent, Dsl.ISyntaxComponent syntax)
        {
            var argBuilder = NewStringBuilder();
            string opd = string.Empty;
            if (null != retVal) {
                var tempSi = new SemanticInfo(true);
                TransformSyntax(retVal, argBuilder, 0, ref tempSi);
                opd = tempSi.ResultType;

                if (null != tempSi.GraphNode)
                    AddComputeGraphRootNode(tempSi.GraphNode);
            }

            GenReturnStatement(sb, indent, argBuilder, opd, retVal, syntax);
            RecycleStringBuilder(argBuilder);
        }
        private static void TransformIfStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            var nodes = new List<ComputeGraphNode>();
            var vars = new List<HashSet<string>>();
            var ifStm = info as Dsl.StatementData;
            if (null != ifStm) {
                var firstFunc = ifStm.First.AsFunction;
                var second = ifStm.Second;
                string secondId = second.GetId();
                var curFunc = CurFuncInfo();
                Debug.Assert(null != curFunc);
                for (int ix = 0; ix < ifStm.GetFunctionNum(); ++ix) {
                    var ifOrElse = ifStm.GetFunction(ix);
                    var func = ifOrElse.AsFunction;
                    if (null != func) {
                        if (ix > 0) {
                            var blocInfo = CurBlockInfo();
                            Debug.Assert(null != blocInfo);
                            blocInfo.SetOrAddCurStatement(func);
                        }
                        string ifId = func.GetId();
                        if (func.IsHighOrder) {
                            var argBuilder = NewStringBuilder();
                            var argSi = new SemanticInfo(true);
                            TransformSyntax(func.LowerOrderFunction.GetParam(0), argBuilder, 0, ref argSi);
                            if (null != argSi.GraphNode)
                                nodes.Add(argSi.GraphNode);
                            if (ifId == "elseif")
                                GenElif(sb, indent, argBuilder);
                            else
                                GenIf(sb, indent, argBuilder);
                            RecycleStringBuilder(argBuilder);
                            ++indent;
                            var blockInfo = GetOrNewBlockInfo(info, ix);
                            Debug.Assert(null != blockInfo);
                            PushBlock(blockInfo);
                            if (func.GetParamNum() > 0) {
                                foreach (var p in func.Params) {
                                    TransformStatement(p, sb, indent);
                                }
                            }
                            else {
                                GenPass(sb, indent);
                            }
                            if (!CurFuncBlockInfoConstructed()) {
                                var vs = CollectModifiedVarsInBlock(blockInfo);
                                vars.Add(vs);
                            }
                            PopBlock(ix < ifStm.GetFunctionNum() - 1);
                            --indent;
                        }
                        else if (ifId == "else" || curFunc.HasLoop && ifId == "else_all_if_false_in_loop") {
                            GenElse(sb, indent);
                            ++indent;
                            var blockInfo = GetOrNewBlockInfo(info, ix);
                            Debug.Assert(null != blockInfo);
                            PushBlock(blockInfo);
                            if (func.GetParamNum() > 0) {
                                foreach (var p in func.Params) {
                                    TransformStatement(p, sb, indent);
                                }
                            }
                            else {
                                GenPass(sb, indent);
                            }
                            if (!CurFuncBlockInfoConstructed()) {
                                var vs = CollectModifiedVarsInBlock(blockInfo);
                                vars.Add(vs);
                            }
                            PopBlock();
                            --indent;
                        }
                        else {
                            Debug.Assert(!curFunc.HasLoop && ifId == "else_all_if_false_in_loop");
                            var curBlock = CurBlockInfo();
                            if (null != curBlock) {
                                curBlock.ResetCurBasicBlock(curBlock.CurBasicBlockIndex + 1);
                            }
                        }
                    }
                    else {
                        Debug.Assert(false);
                    }
                }
            }
            else {
                var ifFunc = info as Dsl.FunctionData;
                Debug.Assert(null != ifFunc);
                if (ifFunc.IsHighOrder) {
                    var argBuilder = NewStringBuilder();
                    var argSi = new SemanticInfo(true);
                    TransformSyntax(ifFunc.LowerOrderFunction.GetParam(0), argBuilder, 0, ref argSi);
                    if (null != argSi.GraphNode)
                        nodes.Add(argSi.GraphNode);
                    GenIf(sb, indent, argBuilder);
                    RecycleStringBuilder(argBuilder);
                    ++indent;
                    var blockInfo = GetOrNewBlockInfo(info, 0);
                    Debug.Assert(null != blockInfo);
                    PushBlock(blockInfo);
                    if (ifFunc.GetParamNum() > 0) {
                        foreach (var p in ifFunc.Params) {
                            TransformStatement(p, sb, indent);
                        }
                    }
                    else {
                        GenPass(sb, indent);
                    }
                    if (!CurFuncBlockInfoConstructed()) {
                        var vs = CollectModifiedVarsInBlock(blockInfo);
                        vars.Add(vs);
                    }
                    PopBlock();
                    --indent;
                }
                else {
                    Debug.Assert(false);
                }
            }
            if (!CurFuncBlockInfoConstructed()) {
                BuildIfComputeGraph("if", nodes, vars);
            }
        }
        private static void TransformVecIfStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            var nodes = new List<ComputeGraphNode>();
            var vars = new List<HashSet<string>>();
            string varPrefix = string.Empty;
            if (CurFuncCodeGenerateEnabled()) {
                int uid = GenUniqueNumber();
                varPrefix = string.Format("_vecif_{0}_", uid);
            }
            string tmp = string.Empty;
            var ifStm = info as Dsl.StatementData;
            if (null != ifStm) {
                var curFunc = CurFuncInfo();
                Debug.Assert(null != curFunc);
                var firstFunc = ifStm.First.AsFunction;
                var second = ifStm.Second;
                string secondId = second.GetId();
                List<string> expVars = new List<string>();
                List<string> expTypes = new List<string>();
                for (int ix = 0; ix < ifStm.GetFunctionNum(); ++ix) {
                    var ifOrElse = ifStm.GetFunction(ix);
                    var func = ifOrElse.AsFunction;
                    if (null != func) {
                        if (ix > 0) {
                            var blocInfo = CurBlockInfo();
                            Debug.Assert(null != blocInfo);
                            blocInfo.SetOrAddCurStatement(func);
                        }
                        string ifId = func.GetId();
                        if (func.IsHighOrder) {
                            var argOrOnSkipBuilder = NewStringBuilder();
                            var argSi = new SemanticInfo(true);
                            TransformSyntax(func.LowerOrderFunction.GetParam(0), argOrOnSkipBuilder, 0, ref argSi);
                            tmp = argSi.ResultType;
                            if (null != argSi.GraphNode)
                                nodes.Add(argSi.GraphNode);
                            GenVecIfWithElseHead(sb, indent, varPrefix, ix, tmp, argOrOnSkipBuilder, out var ifExpVar);
                            expVars.Add(ifExpVar);
                            expTypes.Add(tmp);
                            argOrOnSkipBuilder.Length = 0;
                            ++indent;
                            var blockInfo = GetOrNewBlockInfo(info, ix);
                            Debug.Assert(null != blockInfo);
                            PushBlock(blockInfo);
                            if (func.GetParamNum() > 0) {
                                GenVecIfElseBlockPrologue(blockInfo, varPrefix, sb, indent, func);
                                foreach (var p in func.Params) {
                                    TransformStatement(p, sb, indent);
                                }
                                GenVecIfBlockEpilogue(blockInfo, ifExpVar, tmp, sb, indent, argOrOnSkipBuilder, func);
                            }
                            else {
                                GenPass(sb, indent);
                            }
                            if (!CurFuncBlockInfoConstructed()) {
                                var vs = CollectModifiedVarsInBlock(blockInfo);
                                vars.Add(vs);
                            }
                            PopBlock(ix < ifStm.GetFunctionNum() - 1);
                            --indent;
                            if (argOrOnSkipBuilder.Length > 0) {
                                GenElse(sb, indent);
                                GenAppend(sb, argOrOnSkipBuilder);
                            }
                            RecycleStringBuilder(argOrOnSkipBuilder);
                        }
                        else if (ifId == "else") {
                            var argOrOnSkipBuilder = NewStringBuilder();
                            GenVecElseHead(sb, indent, expVars, expTypes);
                            ++indent;
                            var blockInfo = GetOrNewBlockInfo(info, ix);
                            Debug.Assert(null != blockInfo);
                            PushBlock(blockInfo);
                            if (func.GetParamNum() > 0) {
                                GenVecIfElseBlockPrologue(blockInfo, varPrefix, sb, indent, func);
                                foreach (var p in func.Params) {
                                    TransformStatement(p, sb, indent);
                                }
                                GenVecElseBlockEpilogue(blockInfo, expVars, expTypes, sb, indent, argOrOnSkipBuilder, func);
                            }
                            else {
                                GenPass(sb, indent);
                            }
                            if (!CurFuncBlockInfoConstructed()) {
                                var vs = CollectModifiedVarsInBlock(blockInfo);
                                vars.Add(vs);
                            }
                            PopBlock();
                            --indent;
                            if (argOrOnSkipBuilder.Length > 0) {
                                GenElse(sb, indent);
                                GenAppend(sb, argOrOnSkipBuilder);
                            }
                            RecycleStringBuilder(argOrOnSkipBuilder);
                        }
                        else if (curFunc.HasLoop && ifId == "else_all_if_false_in_loop") {
                            var argOrOnSkipBuilder = NewStringBuilder();
                            GenVecElseAllFalseHead(sb, indent, expVars, expTypes);
                            ++indent;
                            var blockInfo = GetOrNewBlockInfo(info, ix);
                            Debug.Assert(null != blockInfo);
                            PushBlock(blockInfo);
                            if (func.GetParamNum() > 0) {
                                GenVecIfElseBlockPrologue(blockInfo, varPrefix, sb, indent, func);
                                foreach (var p in func.Params) {
                                    TransformStatement(p, sb, indent);
                                }
                                GenVecElseBlockEpilogue(blockInfo, expVars, expTypes, sb, indent, argOrOnSkipBuilder, func);
                            }
                            else {
                                GenPass(sb, indent);
                            }
                            if (!CurFuncBlockInfoConstructed()) {
                                var vs = CollectModifiedVarsInBlock(blockInfo);
                                vars.Add(vs);
                            }
                            PopBlock();
                            --indent;
                            if (argOrOnSkipBuilder.Length > 0) {
                                GenElse(sb, indent);
                                GenAppend(sb, argOrOnSkipBuilder);
                            }
                            RecycleStringBuilder(argOrOnSkipBuilder);
                        }
                        else {
                            Debug.Assert(!curFunc.HasLoop && ifId == "else_all_if_false_in_loop");
                            //ignore
                            var curBlock = CurBlockInfo();
                            if (null != curBlock) {
                                curBlock.ResetCurBasicBlock(curBlock.CurBasicBlockIndex + 1);
                            }
                        }
                    }
                    else {
                        Debug.Assert(false);
                    }
                }
            }
            else {
                var ifFunc = info as Dsl.FunctionData;
                Debug.Assert(null != ifFunc);
                if (ifFunc.IsHighOrder) {
                    var argOrOnSkipBuilder = NewStringBuilder();
                    var argSi = new SemanticInfo(true);
                    TransformSyntax(ifFunc.LowerOrderFunction.GetParam(0), argOrOnSkipBuilder, 0, ref argSi);
                    tmp = argSi.ResultType;
                    if (null != argSi.GraphNode)
                        nodes.Add(argSi.GraphNode);
                    GenVecIfWithoutElseHead(sb, indent, varPrefix, tmp, argOrOnSkipBuilder, out var ifExpVar);
                    argOrOnSkipBuilder.Length = 0;
                    ++indent;
                    var blockInfo = GetOrNewBlockInfo(info, 0);
                    Debug.Assert(null != blockInfo);
                    PushBlock(blockInfo);
                    if (ifFunc.GetParamNum() > 0) {
                        GenVecIfElseBlockPrologue(blockInfo, varPrefix, sb, indent, ifFunc);
                        foreach (var p in ifFunc.Params) {
                            TransformStatement(p, sb, indent);
                        }
                        GenVecIfBlockEpilogue(blockInfo, ifExpVar, tmp, sb, indent, argOrOnSkipBuilder, ifFunc);
                    }
                    else {
                        GenPass(sb, indent);
                    }
                    if (!CurFuncBlockInfoConstructed()) {
                        var vs = CollectModifiedVarsInBlock(blockInfo);
                        vars.Add(vs);
                    }
                    PopBlock();
                    --indent;
                    if (argOrOnSkipBuilder.Length > 0) {
                        GenElse(sb, indent);
                        GenAppend(sb, argOrOnSkipBuilder);
                    }
                    RecycleStringBuilder(argOrOnSkipBuilder);
                }
                else {
                    Debug.Assert(false);
                }
            }
            if (!CurFuncBlockInfoConstructed()) {
                BuildIfComputeGraph("vecif", nodes, vars);
            }
        }
        private static void TransformSwitchStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            var switchFunc = info as Dsl.FunctionData;
            Debug.Assert(null != switchFunc);
            var argBuilder = NewStringBuilder();
            var argSi = new SemanticInfo(true);
            TransformSyntax(switchFunc.LowerOrderFunction.GetParam(0), argBuilder, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref argSi);
            GenSwitchBegin(sb, indent, argBuilder, out var switchVar);
            RecycleStringBuilder(argBuilder);
            var blockInfo = GetOrNewBlockInfo(info, 0);
            Debug.Assert(null != blockInfo);
            PushBlock(blockInfo);
            ++indent;
            bool hasDefault = false;
            List<CaseInfo> caseInfos = new List<CaseInfo>();
            List<CaseInfo>? defaultInfos = null;
            foreach (var p in switchFunc.Params) {
                string key = p.GetId();
                if (key == "case") {
                    CacheCaseInfo(p, caseInfos, out bool hasDef);
                    hasDefault = hasDef || hasDefault;
                }
                else if (key == "default") {
                    CacheCaseInfo(p, caseInfos, out bool hasDef);
                    hasDefault = hasDef || hasDefault;
                }
                else if (key == "break") {
                    if (hasDefault) {
                        defaultInfos = new List<CaseInfo>();
                        defaultInfos.AddRange(caseInfos);
                    }
                    else {
                        TransformCaseBlock(caseInfos, false, switchVar, sb, indent);
                    }
                    caseInfos.Clear();
                    hasDefault = false;
                }
            }
            if (caseInfos.Count > 0) {
                if (hasDefault) {
                    Debug.Assert(null == defaultInfos);
                    defaultInfos = new List<CaseInfo>();
                    defaultInfos.AddRange(caseInfos);
                }
                else {
                    TransformCaseBlock(caseInfos, null == defaultInfos, switchVar, sb, indent);
                }
            }
            if (null != defaultInfos) {
                TransformCaseBlock(defaultInfos, true, switchVar, sb, indent);
            }
            GenSwitchEnd(sb, indent);
            foreach (var ci in caseInfos) {
                foreach (var csb in ci.Exps) {
                    RecycleStringBuilder(csb);
                }
            }
            caseInfos.Clear();
            --indent;
            PopBlock();
            if (!CurFuncBlockInfoConstructed()) {
                Debug.Assert(null != argSi.GraphNode);
                var vs = CollectModifiedVarsInBlock(blockInfo);
                BuildSwitchComputeGraph("switch", argSi.GraphNode, vs);
            }
        }
        private static void TransformVecSwitchStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            string tmp = string.Empty;
            var switchFunc = info as Dsl.FunctionData;
            Debug.Assert(null != switchFunc);
            var argBuilder = NewStringBuilder();
            var argSi = new SemanticInfo(true);
            TransformSyntax(switchFunc.LowerOrderFunction.GetParam(0), argBuilder, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref argSi);
            tmp = argSi.ResultType;
            GenVecSwitchHead(sb, indent, argBuilder, out var switchVar);
            RecycleStringBuilder(argBuilder);
            var blockInfo = GetOrNewBlockInfo(info, 0);
            Debug.Assert(null != blockInfo);
            PushBlock(blockInfo);
            bool hasDefault = false;
            List<StringBuilder> caseExps = new List<StringBuilder>();
            List<CaseInfo> caseInfos = new List<CaseInfo>();
            List<CaseInfo>? defaultInfos = null;
            foreach (var p in switchFunc.Params) {
                string key = p.GetId();
                if (key == "case") {
                    CacheCaseInfo(p, caseInfos, out bool hasDef);
                    hasDefault = hasDef || hasDefault;
                }
                else if (key == "default") {
                    CacheCaseInfo(p, caseInfos, out bool hasDef);
                    hasDefault = hasDef || hasDefault;
                }
                else if (key == "break") {
                    if (hasDefault) {
                        defaultInfos = new List<CaseInfo>();
                        defaultInfos.AddRange(caseInfos);
                    }
                    else {
                        foreach (var caseInfo in caseInfos) {
                            caseExps.AddRange(caseInfo.Exps);
                        }
                        TransformVecCaseBlock(caseInfos, switchVar, tmp, sb, indent, p);
                    }
                    caseInfos.Clear();
                    hasDefault = false;
                }
            }
            if (caseInfos.Count > 0) {
                if (null == defaultInfos) {
                    defaultInfos = new List<CaseInfo>();
                    defaultInfos.AddRange(caseInfos);
                }
                else {
                    TransformVecCaseBlock(caseInfos, switchVar, tmp, sb, indent, info);
                }
            }
            if (null != defaultInfos) {
                TransformVecCaseBlock(defaultInfos, switchVar, tmp, sb, indent, info, caseExps);
            }
            foreach (var ci in caseInfos) {
                foreach (var csb in ci.Exps) {
                    RecycleStringBuilder(csb);
                }
            }
            caseInfos.Clear();
            PopBlock();
            if (!CurFuncBlockInfoConstructed()) {
                Debug.Assert(null != argSi.GraphNode);
                var vs = CollectModifiedVarsInBlock(blockInfo);
                BuildSwitchComputeGraph("vecswitch", argSi.GraphNode, vs);
            }
        }
        private static void TransformForStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            var forBody = info as Dsl.FunctionData;
            Debug.Assert(null != forBody && forBody.IsHighOrder);
            var forFunc = forBody.LowerOrderFunction;
            int forNum = forFunc.GetParamNum();
            Debug.Assert(forNum == 3);
            var forInits = forFunc.GetParam(0) as Dsl.FunctionData;
            Debug.Assert(null != forInits);
            var blockInfo = GetOrNewBlockInfo(info, 0);
            Debug.Assert(null != blockInfo);
            PushBlock(blockInfo);
            foreach (var init in forInits.Params) {
                TransformStatement(init, sb, indent);
            }
            var forConds = forFunc.GetParam(1) as Dsl.FunctionData;
            Debug.Assert(null != forConds);
            if (forConds.GetParamNum() > 0) {
                var argBuilder = NewStringBuilder();
                var argSi = new SemanticInfo(true);
                var condExp = forConds.GetParam(0);
                var curFunc = CurFuncInfo();
                if (null != curFunc)
                    blockInfo.SetOrAddCurStatement(condExp, curFunc.LastAttribute);
                else
                    blockInfo.SetOrAddCurStatement(condExp);
                TransformSyntax(condExp, argBuilder, 0, ref argSi);
                if (null != argSi.GraphNode)
                    AddComputeGraphRootNode(argSi.GraphNode);
                blockInfo.SetOrAddCurStatement(forConds);
                GenWhile(sb, indent, argBuilder);
                RecycleStringBuilder(argBuilder);
            }
            else {
                GenWhileTrue(sb, indent);
            }
            ++indent;
            var forIncs = forFunc.GetParam(2) as Dsl.FunctionData;
            Debug.Assert(null != forIncs);
            if (forIncs.GetParamNum() > 0) {
                GenTry(sb, indent);
                ++indent;
            }
            if (forBody.GetParamNum() > 0) {
                foreach (var p in forBody.Params) {
                    TransformStatement(p, sb, indent);
                }
            }
            else {
                GenPass(sb, indent);
            }
            --indent;
            if (forIncs.GetParamNum() > 0) {
                GenFinally(sb, indent);
                ++indent;
                foreach (var inc in forIncs.Params) {
                    TransformStatement(inc, sb, indent);
                }
                --indent;
                --indent;
            }
            PopBlock();
        }
        private static void TransformWhileStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            var whileFunc = info as Dsl.FunctionData;
            Debug.Assert(null != whileFunc);
            if (whileFunc.IsHighOrder) {
                var argBuilder = NewStringBuilder();
                var argSi = new SemanticInfo(true);
                TransformSyntax(whileFunc.LowerOrderFunction.GetParam(0), argBuilder, 0, ref argSi);
                if (null != argSi.GraphNode)
                    AddComputeGraphRootNode(argSi.GraphNode);
                GenWhile(sb, indent, argBuilder);
                RecycleStringBuilder(argBuilder);
                ++indent;
                var blockInfo = GetOrNewBlockInfo(info, 0);
                Debug.Assert(null != blockInfo);
                PushBlock(blockInfo);
                if (whileFunc.GetParamNum() > 0) {
                    foreach (var p in whileFunc.Params) {
                        TransformStatement(p, sb, indent);
                    }
                }
                else {
                    GenPass(sb, indent);
                }
                PopBlock();
                --indent;
            }
            else {
                Debug.Assert(false);
            }
        }
        private static void TransformDoWhileStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            var doStm = info as Dsl.StatementData;
            Debug.Assert(null != doStm);
            var doFunc = doStm.First.AsFunction;
            var whileFunc = doStm.Second.AsFunction;
            if (null != doFunc && null != whileFunc) {
                GenWhileTrue(sb, indent);
                ++indent;
                GenIfTrue(sb, indent);
                ++indent;
                var blockInfo = GetOrNewBlockInfo(info, 0);
                Debug.Assert(null != blockInfo);
                PushBlock(blockInfo);
                if (doFunc.GetParamNum() > 0) {
                    foreach (var p in doFunc.Params) {
                        TransformStatement(p, sb, indent);
                    }
                }
                else {
                    GenPass(sb, indent);
                }
                PopBlock();
                --indent;
                var blockInfo2 = CurBlockInfo();
                Debug.Assert(null != blockInfo2);
                blockInfo2.SetOrAddCurStatement(whileFunc);
                var argBuilder = NewStringBuilder();
                var argSi = new SemanticInfo(true);
                TransformSyntax(whileFunc.GetParam(0), argBuilder, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref argSi);
                if (null != argSi.GraphNode)
                    AddComputeGraphRootNode(argSi.GraphNode);
                GenIfNot(sb, indent, argBuilder);
                RecycleStringBuilder(argBuilder);
                ++indent;
                GenBreak(sb, indent);
                --indent;
                --indent;
            }
            else {
                Debug.Assert(false);
            }
        }
        private static void TransformBlockStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            var blockFunc = info as Dsl.FunctionData;
            Debug.Assert(null != blockFunc);
            var blockInfo = GetOrNewBlockInfo(info, 0);
            Debug.Assert(null != blockInfo);
            PushBlock(blockInfo);
            GenIfTrue(sb, indent);
            ++indent;
            foreach (var p in blockFunc.Params) {
                var argBuilder = NewStringBuilder();
                TransformStatement(p, sb, indent);
                GenAppend(sb, argBuilder);
                RecycleStringBuilder(argBuilder);
            }
            --indent;
            PopBlock();
        }
        private static void TransformOtherStatement(Dsl.FunctionData funcCall, StringBuilder sb, int indent)
        {
            var stmBuilder = NewStringBuilder();
            var tempSi = new SemanticInfo(true);
            TransformSyntax(funcCall, stmBuilder, new ParseContextInfo { IsTopLevelStatement = true }, 0, ref tempSi);
            if (null != tempSi.GraphNode)
                AddComputeGraphRootNode(tempSi.GraphNode);
            GenOtherStatement(sb, indent, stmBuilder);
            RecycleStringBuilder(stmBuilder);
        }
        private static void TransformStatement(Dsl.ISyntaxComponent info, StringBuilder sb, int indent)
        {
            bool needVectorize = false;
            if (s_IsVectorizing) {
                needVectorize = true;
            }
            var curFunc = CurFuncInfo();
            var blockInfo = CurBlockInfo();
            Debug.Assert(null != blockInfo);
            if (null != curFunc)
                blockInfo.SetOrAddCurStatement(info, curFunc.LastAttribute);
            else
                blockInfo.SetOrAddCurStatement(info);
            bool consumeAttr = false;
            string id = info.GetId();
            if (id == "var") {
                var vinfo = ParseVarDecl(info);
                if (null != vinfo) {
                    GenDeclVar(sb, indent, vinfo, false, info);
                }
            }
            else if (id == "=") {
                TransformAssignmentStatement(id, info, sb, indent);
            }
            else if (id.Length > 1 && id[id.Length - 1] == '=' && id != "==" && id != "!=" && id != ">=" && id != "<=") {
                TransformCompoundAssignmentStatement(id, info, sb, indent);
            }
            else if (id == "++") {
                TransformIncStatement(info, sb, indent);
            }
            else if (id == "--") {
                TransformDecStatement(info, sb, indent);
            }
            else if (id == "return") {
                TransformReturnStatement(info, sb, indent);
            }
            else if (id == "<-") {
                TransformRetExpStatement(info, sb, indent);
            }
            else if (id == "if") {
                if (needVectorize)
                    TransformVecIfStatement(info, sb, indent);
                else
                    TransformIfStatement(info, sb, indent);
                consumeAttr = true;
            }
            else if (id == "switch") {
                if (needVectorize)
                    TransformVecSwitchStatement(info, sb, indent);
                else
                    TransformSwitchStatement(info, sb, indent);
                consumeAttr = true;
            }
            else if (id == "for") {
                TransformForStatement(info, sb, indent);
                consumeAttr = true;
            }
            else if (id == "while") {
                TransformWhileStatement(info, sb, indent);
                consumeAttr = true;
            }
            else if (id == "do") {
                TransformDoWhileStatement(info, sb, indent);
                consumeAttr = true;
            }
            else if (id == "break") {
                GenBreak(sb, indent);
            }
            else if (id == "continue") {
                GenContinue(sb, indent);
            }
            else if (id == "block") {
                TransformBlockStatement(info, sb, indent);
            }
            else if (id == "typedef") {
                ParseTypeDef(info);
            }
            else if (id == "attrs") {
                if (null != curFunc) {
                    curFunc.LastAttribute = info;
                }
            }
            else if (id == "ignorable_break_in_switch") {

            }
            else {
                var funcCall = info as Dsl.FunctionData;
                if (funcCall != null) {
                    TransformOtherStatement(funcCall, sb, indent);
                }
                else if(info.IsValid()) {
                    Console.WriteLine("unknown statement '{0}', line: {1}, class: {2} !", id, info.GetLine(), info.GetType());
                }
            }
            if (consumeAttr) {
                if (null != curFunc) {
                    curFunc.LastAttribute = null;
                }
            }
        }

        private static void TransformCaseBlock(List<CaseInfo> caseInfos, bool isLastCase, string switchVar, StringBuilder sb, int indent)
        {
            List<StringBuilder> caseExps = new List<StringBuilder>();
            foreach (var caseInfo in caseInfos) {
                Debug.Assert(null != caseInfo.CaseBlock);
                GenCaseBegin(sb, indent, switchVar, caseInfo, caseExps);
                ++indent;
                var cblockInfo = GetOrNewBlockInfo(caseInfo.CaseBlock, 0);
                Debug.Assert(null != cblockInfo);
                PushBlock(cblockInfo);
                foreach (var cp in caseInfo.Statements) {
                    TransformStatement(cp, sb, indent);
                }
                PopBlock();
                if (!isLastCase && caseInfos.Count == 1)
                    GenBreak(sb, indent);
                --indent;
            }
            if (!isLastCase && caseInfos.Count > 1 && caseExps.Count > 0) {
                GenCaseEnd(sb, indent, switchVar, caseExps);
            }
        }
        private static void TransformVecCaseBlock(List<CaseInfo> caseInfos, string switchVar, string switchVarType, StringBuilder sb, int indent, Dsl.ISyntaxComponent syntax, List<StringBuilder>? otherCaseExps = null)
        {
            List<StringBuilder> caseExps = new List<StringBuilder>();
            foreach (var caseInfo in caseInfos) {
                Debug.Assert(null != caseInfo.CaseBlock);
                if (caseInfo.Exps.Count > 0) {
                    caseExps.AddRange(caseInfo.Exps);
                }
                bool isDef = false;
                if (null != otherCaseExps && caseExps.Count == 0) {
                    isDef = true;
                }
                if (isDef) {
                    Debug.Assert(null != otherCaseExps);
                    GenVecDefaultHead(sb, indent, switchVar, switchVarType, otherCaseExps);
                }
                else {
                    GenVecCaseHead(sb, indent, switchVar, switchVarType, caseExps);
                }
                var onSkipBuilder = NewStringBuilder();
                ++indent;
                var cblockInfo = GetOrNewBlockInfo(caseInfo.CaseBlock, 0);
                Debug.Assert(null != cblockInfo);
                PushBlock(cblockInfo);
                GenVecCaseDefBlockPrologue(cblockInfo, switchVar, sb, indent, syntax);
                foreach (var cp in caseInfo.Statements) {
                    TransformStatement(cp, sb, indent);
                }
                if (isDef) {
                    Debug.Assert(null != otherCaseExps);
                    GenVecDefaultBlockEpilogue(cblockInfo, switchVar, switchVarType, otherCaseExps, sb, indent, onSkipBuilder, syntax);
                }
                else {
                    GenVecCaseBlockEpilogue(cblockInfo, switchVar, switchVarType, caseExps, sb, indent, onSkipBuilder, syntax);
                }
                PopBlock();
                --indent;
                if (onSkipBuilder.Length > 0) {
                    GenElse(sb, indent);
                    GenAppend(sb, onSkipBuilder);
                }
                RecycleStringBuilder(onSkipBuilder);
            }
        }

        private static void CacheCaseInfo(Dsl.ISyntaxComponent p, List<CaseInfo> caseInfos, out bool hasDef)
        {
            hasDef = false;
            var caseInfo = new CaseInfo();
            caseInfos.Add(caseInfo);
            caseInfo.CaseBlock = p;

            var caseFunc = p as Dsl.FunctionData;
            while (null != caseFunc) {
                string caseId = caseFunc.GetId();
                if (caseId == "case" || caseId == "default") {
                    if (caseId == "case" && !hasDef) {
                        var caseSb = NewStringBuilder();
                        var tempSi = new SemanticInfo(false);
                        TransformSyntax(caseFunc.LowerOrderFunction.GetParam(0), caseSb, new ParseContextInfo { Usage = SyntaxUsage.Operator }, 0, ref tempSi);
                        caseInfo.Exps.Add(caseSb);
                    }
                    if (caseId == "default") {
                        caseInfo.Exps.Clear();
                        hasDef = true;
                    }

                    if (caseFunc.GetParamNum() == 1) {
                        var innerCase = caseFunc.GetParam(0);
                        caseFunc = innerCase as Dsl.FunctionData;
                        if (null == caseFunc) {
                            caseInfo.Statements.Add(innerCase);
                            break;
                        }
                    }
                    else {
                        caseInfo.Statements.AddRange(caseFunc.Params);
                        break;
                    }
                }
                else {
                    caseInfo.Statements.Add(caseFunc);
                    break;
                }
            }
        }
        private static bool VecAdjustTypeToWhereResult(VarInfo vinfo, string expType)
        {
            string resultType = GetWhereResultType(expType, vinfo.Type, vinfo.Type);
            return VecAdjustType(vinfo, resultType);
        }
        private static bool VecAdjustType(VarInfo vinfo, string resultType)
        {
            bool ret = false;
            if (IsTypeVec(resultType)) {
                vinfo.Type = GetTypeVec(vinfo.Type, out var isTuple, out var isStruct, out var isVecBefore);
                if (!isVecBefore) {
                    if (null == vinfo.OwnerBlock) {
                        Console.WriteLine("[Error]: vectorize global var '{0}', please change it to a local var, from if/switch", vinfo.Name);
                    }
                    ret = true;
                }
            }
            return ret;
        }

        private static HashSet<string> CollectModifiedVarsInBlock(BlockInfo blockInfo)
        {
            var vars = new HashSet<string>();
            foreach (var pair in blockInfo.GetSetOuterObjsInBlockScope(true)) {
                var key = pair.Key;
                if (!vars.Contains(key))
                    vars.Add(key);
            }
            foreach (var pair in blockInfo.GetSetOuterVarsInBlockScope(true)) {
                var key = pair.Key;
                if (!vars.Contains(key))
                    vars.Add(key);
            }
            return vars;
        }
        private static void BuildIfComputeGraph(string op, List<ComputeGraphNode> nodes, List<HashSet<string>> vars)
        {
            var tcgn = new ComputeGraphCalcNode(CurFuncInfo(), "bool", op);
            for (int ix = 0; ix < nodes.Count; ++ix) {
                var node = nodes[ix];
                var cgn = new ComputeGraphCalcNode(CurFuncInfo(), "bool", op);
                cgn.AddPrev(node);
                node.AddNext(cgn);

                var vs = vars[ix];
                foreach (var v in vs) {
                    var vnode = FindComputeGraphVarNode(v);
                    if (null != vnode) {
                        vnode.AddPrev(cgn);
                        cgn.AddOut(vnode);
                    }
                }

                tcgn.AddPrev(cgn);
                cgn.AddNext(tcgn);
            }

            for (int ix = nodes.Count; ix < vars.Count; ++ix) {
                var vs = vars[ix];
                foreach (var v in vs) {
                    var vnode = FindComputeGraphVarNode(v);
                    if (null != vnode) {
                        vnode.AddPrev(tcgn);
                        tcgn.AddOut(vnode);
                    }
                }
            }

            AddComputeGraphRootNode(tcgn);
        }
        private static void BuildSwitchComputeGraph(string op, ComputeGraphNode node, HashSet<string> vars)
        {
            var cgn = new ComputeGraphCalcNode(CurFuncInfo(), "bool", op);
            cgn.AddPrev(node);
            node.AddNext(cgn);

            foreach (var v in vars) {
                var vnode = FindComputeGraphVarNode(v);
                if (null != vnode) {
                    vnode.AddPrev(cgn);
                    cgn.AddOut(vnode);
                }
            }

            AddComputeGraphRootNode(cgn);
        }
        private static ComputeGraphVarNode? GetObjectVarNode(ComputeGraphNode objExpNode)
        {
            var onode = objExpNode;
            while (null != onode && onode is ComputeGraphCalcNode) {
                if (onode.PrevNodes.Count > 0) {
                    onode = onode.PrevNodes[0];
                }
                else {
                    break;
                }
            }
            var vnode = onode as ComputeGraphVarNode;
            return vnode;
        }

        private static string ConstCalc(string op, string type, string val)
        {
            string ret = string.Empty;
            if (type == "int") {
                if (int.TryParse(val, out var ival)) {
                    if (op == "++")
                        ret = (ival + 1).ToString();
                    else if (op == "--")
                        ret = (ival - 1).ToString();
                    else if (op == "+")
                        ret = val;
                    else if (op == "-")
                        ret = (-ival).ToString();
                    else if (op == "~")
                        ret = (~ival).ToString();
                    else if (op == "!")
                        ret = (ival == 0 ? "true" : "false");

                }
            }
            else if (type == "uint" || type == "dword") {
                if (uint.TryParse(val, out var uval)) {
                    if (op == "++")
                        ret = (uval + 1).ToString();
                    else if (op == "--")
                        ret = (uval - 1).ToString();
                    else if (op == "+")
                        ret = val;
                    else if (op == "-")
                        ret = (-uval).ToString();
                    else if (op == "~")
                        ret = (~uval).ToString();
                    else if (op == "!")
                        ret = (uval == 0 ? "true" : "false");
                }
            }
            else if (type == "bool") {
                if (op == "!" || op == "~") {
                    if (val == "true")
                        ret = "false";
                    else
                        ret = "true";
                }
                else {
                    ret = val;
                }
            }
            else if (type == "double") {
                if (double.TryParse(val, out var dval)) {
                    if (op == "++")
                        ret = (dval + 1).ToString(s_DoubleFormat);
                    else if (op == "--")
                        ret = (dval - 1).ToString(s_DoubleFormat);
                    else if (op == "+")
                        ret = val;
                    else if (op == "-")
                        ret = (-dval).ToString(s_DoubleFormat);
                    else if (op == "!")
                        ret = (dval == 0 ? "true" : "false");
                }
            }
            else {
                if (float.TryParse(val, out var fval)) {
                    if (op == "++")
                        ret = (fval + 1).ToString(s_FloatFormat);
                    else if (op == "--")
                        ret = (fval - 1).ToString(s_FloatFormat);
                    else if (op == "+")
                        ret = val;
                    else if (op == "-")
                        ret = (-fval).ToString(s_FloatFormat);
                    else if (op == "!")
                        ret = (fval == 0 ? "true" : "false");
                }
            }
            return ret;
        }
        private static string ConstCalc(string op, string type1, string val1, string type2, string val2)
        {
            string ret = string.Empty;
            if (op == "+") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 + v2).ToString();
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 + v2).ToString(s_FloatFormat);
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 + v2).ToString(s_DoubleFormat);
                    }
                }
            }
            else if (op == "-") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 - v2).ToString();
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 - v2).ToString(s_FloatFormat);
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 - v2).ToString(s_DoubleFormat);
                    }
                }
            }
            else if (op == "*") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 * v2).ToString();
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 * v2).ToString(s_FloatFormat);
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 * v2).ToString(s_DoubleFormat);
                    }
                }
            }
            else if (op == "/") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 / v2).ToString();
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 / v2).ToString(s_FloatFormat);
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 / v2).ToString(s_DoubleFormat);
                    }
                }
            }
            else if (op == "%") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 % v2).ToString();
                    }
                }
            }
            else if (op == "&") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 & v2).ToString();
                    }
                }
            }
            else if (op == "|") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 | v2).ToString();
                    }
                }
            }
            else if (op == "^") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 ^ v2).ToString();
                    }
                }
            }
            else if (op == "<<") {
                if (type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 << v2).ToString();
                    }
                }
            }
            else if (op == ">>") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 >> v2).ToString();
                    }
                }
            }
            else if (op == ">") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 > v2 ? "true" : "false");
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 > v2 ? "true" : "false");
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 > v2 ? "true" : "false");
                    }
                }
            }
            else if (op == ">=") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 >= v2 ? "true" : "false");
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 >= v2 ? "true" : "false");
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 >= v2 ? "true" : "false");
                    }
                }
            }
            else if (op == "<") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 < v2 ? "true" : "false");
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 < v2 ? "true" : "false");
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 < v2 ? "true" : "false");
                    }
                }
            }
            else if (op == "<=") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 <= v2 ? "true" : "false");
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 <= v2 ? "true" : "false");
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 <= v2 ? "true" : "false");
                    }
                }
            }
            else if (op == "==") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 == v2 ? "true" : "false");
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 == v2 ? "true" : "false");
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 == v2 ? "true" : "false");
                    }
                }
            }
            else if (op == "!=") {
                if (type1 == type2 && type1 == "int") {
                    if (int.TryParse(val1, out var v1) && int.TryParse(val2, out var v2)) {
                        ret = (v1 != v2 ? "true" : "false");
                    }
                }
                else if (type1 == "float" || type2 == "float") {
                    if (float.TryParse(val1, out var v1) && float.TryParse(val2, out var v2)) {
                        ret = (v1 != v2 ? "true" : "false");
                    }
                }
                else if (type1 == "double" || type2 == "double") {
                    if (double.TryParse(val1, out var v1) && double.TryParse(val2, out var v2)) {
                        ret = (v1 != v2 ? "true" : "false");
                    }
                }
            }
            return ret;
        }
        private static string ConstCondExpCalc(string condVal, string type1, string val1, string type2, string val2)
        {
            string ret = string.Empty;
            if (bool.TryParse(condVal, out var bval)) {
                if (type1 == type2) {
                    if (bval)
                        ret = val1;
                    else
                        ret = val2;
                }
            }
            return ret;
        }

        private static string TryRenameTemporary(string varName)
        {
            var blockInfo = CurBlockInfo();
            if (null != blockInfo && blockInfo.TryGetTemporary(varName, out var tmpName) && null != tmpName) {
                return tmpName;
            }
            else
                return varName;
        }
        private static string OperatorTypeInference(string op, string opd)
        {
            string resultType = string.Empty;
            if (op == "+" || op == "-" || op == "~")
                resultType = opd;
            else if (op == "!") {
                if (s_IsVectorizing && IsTypeVec(opd))
                    resultType = GetTypeVec("bool");
                else
                    resultType = "bool";
            }
            return resultType;
        }
        private static string OperatorTypeInference(string op, string opd1, string opd2)
        {
            bool isVec = false;
            if (s_IsVectorizing) {
                opd1 = GetTypeNoVec(opd1, out var isTuple1, out var isStruct1, out var isVecBefore1);
                if (isVecBefore1) {
                    isVec = true;
                }
                opd2 = GetTypeNoVec(opd2, out var isTuple2, out var isStruct2, out var isVecBefore2);
                if (isVecBefore2) {
                    isVec = true;
                }
            }
            string resultType = string.Empty;
            if (op == "*") {
                if (opd1 == opd2) {
                    resultType = opd1;
                }
                else {
                    string suffix1 = GetTypeSuffix(opd1);
                    string suffix2 = GetTypeSuffix(opd2);
                    if (suffix1.Length == 3) {
                        resultType = opd1;
                    }
                    else if (suffix2.Length == 3) {
                        resultType = opd2;
                    }
                    else {
                        resultType = opd1.Length >= opd2.Length ? opd1 : opd2;
                    }
                }
            }
            else if (op == "+" || op == "-" || op == "/" || op == "%") {
                resultType = opd1.Length >= opd2.Length ? opd1 : opd2;
            }
            else if (op == "&&" || op == "||" || op == ">=" || op == "==" || op == "!=" || op == "<=" || op == ">" || op == "<") {
                string suffix1 = GetTypeSuffix(opd1);
                string suffix2 = GetTypeSuffix(opd2);
                if (suffix1.Length == 3) {
                    resultType = "bool" + suffix1;
                }
                else if (suffix2.Length == 3) {
                    resultType = "bool" + suffix2;
                }
                else if (suffix1.Length > 0) {
                    resultType = "bool" + suffix1;
                }
                else if (suffix2.Length > 0) {
                    resultType = "bool" + suffix2;
                }
                else {
                    resultType = "bool";
                }
            }
            else if (op == "&" || op == "|" || op == "^" || op == "<<" || op == ">>") {
                resultType = opd1.Length >= opd2.Length ? opd1 : opd2;
            }
            if (isVec)
                resultType = GetTypeVec(resultType);
            return resultType;
        }
        private static string FunctionTypeInference(string objType, string func, IList<string> args, out FuncInfo? funcInfo, out bool isVec)
        {
            funcInfo = null;
            var oriArgs = args;
            isVec = false;
            if (s_IsVectorizing) {
                oriArgs = new List<string>();
                foreach (var arg in args) {
                    var oriArg = GetTypeNoVec(arg, out var isTuple, out var isStruct, out var isVecBefore);
                    oriArgs.Add(oriArg);
                    if (isVecBefore) {
                        isVec = true;
                    }
                }
            }
            string callSig = GetFullTypeFuncSig(func, oriArgs);
            if (string.IsNullOrEmpty(objType)) {
                if (s_FuncOverloads.TryGetValue(func, out var overloads)) {
                    foreach (var sig in overloads) {
                        if (sig.StartsWith(callSig)) {
                            if (s_FuncInfos.TryGetValue(sig, out var tmpInfo)) {
                                if (args.Count == tmpInfo.Params.Count && sig == callSig || args.Count < tmpInfo.Params.Count && null != tmpInfo.Params[args.Count].DefaultValueSyntax) {
                                    funcInfo = tmpInfo;
                                    if (isVec)
                                        VectorizeFunc(funcInfo, args);
                                    else
                                        MarkCalledScalarFunc(funcInfo);
                                    return funcInfo.RetInfo.Type;
                                }
                            }
                        }
                    }
                    //find nearst match
                    int curScore = -1;
                    foreach (var sig in overloads) {
                        if (s_FuncInfos.TryGetValue(sig, out var tmpInfo)) {
                            if (IsArgsMatch(oriArgs, tmpInfo, out int newScore) && curScore < newScore) {
                                curScore = newScore;
                                funcInfo = tmpInfo;
                            }
                        }
                    }
                    if (null != funcInfo) {
                        if (isVec)
                            VectorizeFunc(funcInfo, args);
                        else
                            MarkCalledScalarFunc(funcInfo);
                        return funcInfo.RetInfo.Type;
                    }
                }
                else {
                    //built-in function
                    if (func == "mul") {
                        string ret = GetMatmulType(oriArgs[0], oriArgs[1], isVec);
                        return ret;
                    }
                    else if (s_BuiltInFuncs.TryGetValue(func, out var resTypeTag)) {
                        string ret = GetFuncResultType(resTypeTag, func, args, oriArgs, isVec);
                        return ret;
                    }
                }
            }
            else {
                //built-in member function
                if (s_BuiltInMemFuncs.TryGetValue(objType, out var funcs)) {
                    if (funcs.TryGetValue(func, out var resTypeTag)) {
                        string ret = GetFuncResultType(resTypeTag, objType, args, oriArgs, isVec);
                        return ret;
                    }
                }
            }
            return string.Empty;
        }
        private static string MemberTypeInference(string op, string objType, string resultType, string memberOrType)
        {
            string oriObjType = objType;
            bool isVec = false;
            if (s_IsVectorizing) {
                oriObjType = GetTypeNoVec(objType, out var isTuple, out var isStruct, out var isVecBefore);
                if (isVecBefore) {
                    isVec = true;
                }
                if (IsTypeVec(memberOrType)) {
                    isVec = true;
                }
            }
            if (op == ".") {
                if (s_StructInfos.TryGetValue(GetTypeNoVecPrefix(oriObjType), out var info)) {
                    foreach (var field in info.Fields) {
                        if (field.Name == memberOrType) {
                            resultType = field.Type;
                            break;
                        }
                    }
                }
                else if (s_BuiltInMembers.TryGetValue(oriObjType, out var members)) {
                    if (members.TryGetValue(memberOrType, out var resTypeTag)) {
                        resultType = GetMemberResultType(resTypeTag, oriObjType, memberOrType);
                    }
                }
                else {
                    string baseType = GetTypeRemoveSuffix(oriObjType);
                    string suffix = GetTypeSuffix(oriObjType);
                    if (string.IsNullOrEmpty(resultType)) {
                        if (IsBaseType(oriObjType)) {
                            if (memberOrType.Length == 1) {
                                resultType = baseType;
                            }
                            else {
                                resultType = baseType + memberOrType.Length.ToString();
                            }
                        }
                        else if (suffix.Length == 1) {
                            if (memberOrType.Length == 1) {
                                resultType = baseType;
                            }
                            else {
                                resultType = baseType + memberOrType.Length.ToString();
                            }
                        }
                        else if (suffix.Length == 3) {
                            int ct = GetMemberCount(memberOrType);
                            if (ct == 1) {
                                resultType = baseType;
                            }
                            else {
                                resultType = baseType + ct.ToString();
                            }
                        }
                    }
                }
            }
            else if (op == "[]") {
                if (oriObjType == "ByteAddressBuffer" || oriObjType == "RWByteAddressBuffer") {
                    resultType = "uint";
                }
                else if (oriObjType.StartsWith("RWTexture2D|")) {
                    resultType = oriObjType.Substring("RWTexture2D|".Length);
                }
                else if (oriObjType.StartsWith("Texture2D|")) {
                    resultType = oriObjType.Substring("Texture2D|".Length);
                }
                else {
                    resultType = GetTypeRemoveArrTag(oriObjType, out var isTuple, out var isStruct, out var IsArr, out var arrNums);
                    if (arrNums.Count == 0) {
                        string suffix = GetTypeSuffix(resultType);
                        if (suffix.Length == 3) {
                            resultType = resultType.Substring(0, resultType.Length - 2);
                        }
                        else if (suffix.Length == 1) {
                            resultType = resultType.Substring(0, resultType.Length - 1);
                        }
                        else {
                            Debug.Assert(false);
                        }
                    }
                }
            }
            if (isVec)
                resultType = GetTypeVec(resultType);
            return resultType;
        }

        private static void GenVecIfElseBlockPrologue(BlockInfo blockInfo, string varPrefix, StringBuilder sb, int indent, Dsl.ISyntaxComponent syntax)
        {
            blockInfo.ClearTemporaryInfo();
            foreach (var pair in blockInfo.GetSetOuterObjsInBlockScope(true)) {
                var key = pair.Key;
                var val = pair.Value;
                if (null == val.OwnerBlock || blockInfo != val.OwnerBlock) {
                    blockInfo.AddCopyTemporary(key, string.IsNullOrEmpty(varPrefix) ? key : varPrefix + key);
                }
            }
            foreach (var pair in blockInfo.GetSetOuterVarsInBlockScope(true)) {
                var key = pair.Key;
                var val = pair.Value;
                if (null == val.OwnerBlock || blockInfo != val.OwnerBlock) {
                    blockInfo.AddTemporary(key, string.IsNullOrEmpty(varPrefix) ? key : varPrefix + key);
                }
            }
            if (CurFuncCodeGenerateEnabled()) {
                foreach (var pair in blockInfo.VarCopyTemporaries) {
                    string key = pair.Key;
                    if (blockInfo.TryGetTemporaryInParent(key, out var newKey) && null != newKey)
                        key = newKey;
                    if (blockInfo.VarTypesOnPrologue.TryGetValue(pair.Key, out var keyType)) {
                        sb.Append("{0}{1} = ", Literal.GetIndentString(indent), pair.Value);
                        bool vecCopy = GenVecCopyBegin(sb, keyType, syntax);
                        sb.Append(key);
                        if (vecCopy)
                            GenVecCopyEnd(sb);
                        sb.AppendLine();
                    }
                    else {
                        Debug.Assert(false);
                    }
                }
                foreach (var pair in blockInfo.VarTemporaries) {
                    string key = pair.Key;
                    if (blockInfo.TryGetTemporaryInParent(key, out var newKey) && null != newKey)
                        key = newKey;
                    sb.AppendLine("{0}{1} = {2}", Literal.GetIndentString(indent), pair.Value, key);
                }
            }
        }
        private static void GenVecIfBlockEpilogue(BlockInfo blockInfo, string expVar, string expType, StringBuilder sb, int indent, StringBuilder broadcastsOnSkip, Dsl.ISyntaxComponent syntax)
        {
            foreach (var pair in blockInfo.AllVarTemporaries) {
                var vinfo = GetVarInfo(pair.Key, VarUsage.Find);
                if (null != vinfo) {
                    string oldType = vinfo.Type;
                    string varName = vinfo.Name;
                    if (CurFuncCodeGenerateEnabled()) {
                        string key = pair.Key;
                        if (blockInfo.TryGetTemporaryInParent(key, out var newKey) && null != newKey)
                            key = newKey;

                        if (!blockInfo.VarTypesOnPrologue.TryGetValue(vinfo.Name, out var typeOnPrologue)) {
                            typeOnPrologue = vinfo.Type;
                        }

                        oldType = typeOnPrologue;
                        varName = key;
                        string funcName = "h_where";
                        string fullFuncName = funcName + GetFuncArgsTag(funcName, expType, vinfo.Type, typeOnPrologue);
                        GenOrRecordWhereFunc(fullFuncName, expType, vinfo.Type, typeOnPrologue, syntax);
                        sb.Append("{0}{1} = ", Literal.GetIndentString(indent), key);
                        sb.Append(fullFuncName);
                        sb.Append("(");
                        sb.Append(expVar);
                        sb.Append(", ");
                        sb.Append(pair.Value);
                        sb.Append(", ");
                        sb.Append(key);
                        sb.AppendLine(")");
                    }

                    bool adjust = VecAdjustTypeToWhereResult(vinfo, expType);
                    if (CurFuncCodeGenerateEnabled()) {
                        if (adjust || vinfo.Type != oldType) {
                            broadcastsOnSkip.Append(Literal.GetIndentString(indent));
                            broadcastsOnSkip.Append(varName);
                            broadcastsOnSkip.Append(" = ");
                            GenBroadcast(broadcastsOnSkip, oldType, varName, "True", syntax);
                            broadcastsOnSkip.AppendLine();
                        }
                    }
                }
            }
        }
        private static void GenVecElseBlockEpilogue(BlockInfo blockInfo, List<string> expVars, List<string> expTypes, StringBuilder sb, int indent, StringBuilder broadcastsOnSkip, Dsl.ISyntaxComponent syntax)
        {
            Debug.Assert(expVars.Count == expTypes.Count);
            foreach (var pair in blockInfo.AllVarTemporaries) {
                var vinfo = GetVarInfo(pair.Key, VarUsage.Find);
                if (null != vinfo) {
                    string key = pair.Key;
                    if (blockInfo.TryGetTemporaryInParent(key, out var newKey) && null != newKey)
                        key = newKey;

                    if (CurFuncCodeGenerateEnabled()) {
                        sb.Append("{0}#condition: not ", Literal.GetIndentString(indent));
                        VecInferAndGenOr(expVars, expTypes, 0, sb);
                        sb.AppendLine();

                        sb.Append("{0}{1} = ", Literal.GetIndentString(indent), key);
                    }
                    if (!blockInfo.VarTypesOnPrologue.TryGetValue(vinfo.Name, out var typeOnPrologue)) {
                        typeOnPrologue = vinfo.Type;
                    }
                    string resultType = VecInferAndGenWhere(key, typeOnPrologue, pair.Value, vinfo.Type, expVars, expTypes, 0, sb, syntax);
                    string oldType = typeOnPrologue;
                    string varName = key;
                    bool adjust = VecAdjustType(vinfo, resultType);
                    GenAppendLine(sb);
                    if (CurFuncCodeGenerateEnabled()) {
                        if (adjust || vinfo.Type != oldType) {
                            broadcastsOnSkip.Append(Literal.GetIndentString(indent));
                            broadcastsOnSkip.Append(varName);
                            broadcastsOnSkip.Append(" = ");
                            GenBroadcast(broadcastsOnSkip, oldType, varName, "True", syntax);
                            broadcastsOnSkip.AppendLine();
                        }
                    }
                }
            }
        }
        private static void GenVecCaseDefBlockPrologue(BlockInfo blockInfo, string switchVar, StringBuilder sb, int indent, Dsl.ISyntaxComponent syntax)
        {
            blockInfo.ClearTemporaryInfo();
            string varPrefix = string.Empty;
            if (CurFuncCodeGenerateEnabled()) {
                varPrefix = switchVar + "_";
            }
            foreach (var pair in blockInfo.GetSetOuterObjsInBlockScope(true)) {
                var key = pair.Key;
                var val = pair.Value;
                if (null == val.OwnerBlock || blockInfo != val.OwnerBlock) {
                    blockInfo.AddCopyTemporary(key, string.IsNullOrEmpty(varPrefix) ? key : varPrefix + key);
                }
            }
            foreach (var pair in blockInfo.GetSetOuterVarsInBlockScope(true)) {
                var key = pair.Key;
                var val = pair.Value;
                if (null == val.OwnerBlock || blockInfo != val.OwnerBlock) {
                    blockInfo.AddTemporary(key, string.IsNullOrEmpty(varPrefix) ? key : varPrefix + key);
                }
            }
            if (CurFuncCodeGenerateEnabled()) {
                foreach (var pair in blockInfo.VarCopyTemporaries) {
                    string key = pair.Key;
                    if (blockInfo.TryGetTemporaryInParent(key, out var newKey) && null != newKey)
                        key = newKey;
                    if (blockInfo.VarTypesOnPrologue.TryGetValue(pair.Key, out var keyType)) {
                        sb.Append("{0}{1} = ", Literal.GetIndentString(indent), pair.Value);
                        bool vecCopy = GenVecCopyBegin(sb, keyType, syntax);
                        sb.Append(key);
                        if (vecCopy)
                            GenVecCopyEnd(sb);
                        sb.AppendLine();
                    }
                    else {
                        Debug.Assert(false);
                    }
                }
                foreach (var pair in blockInfo.VarTemporaries) {
                    string key = pair.Key;
                    if (blockInfo.TryGetTemporaryInParent(key, out var newKey) && null != newKey)
                        key = newKey;
                    sb.AppendLine("{0}{1} = {2}", Literal.GetIndentString(indent), pair.Value, key);
                }
            }
        }
        private static void GenVecCaseBlockEpilogue(BlockInfo blockInfo, string switchVar, string switchVarType, List<StringBuilder> caseExps, StringBuilder sb, int indent, StringBuilder broadcastsOnSkip, Dsl.ISyntaxComponent syntax)
        {
            foreach (var pair in blockInfo.AllVarTemporaries) {
                var vinfo = GetVarInfo(pair.Key, VarUsage.Find);
                if (null != vinfo) {
                    string key = pair.Key;
                    if (blockInfo.TryGetTemporaryInParent(key, out var newKey) && null != newKey)
                        key = newKey;

                    if (CurFuncCodeGenerateEnabled()) {
                        sb.Append("{0}#condition: ", Literal.GetIndentString(indent));
                        VecInferAndGenEqualIntOr(switchVar, switchVarType, caseExps, 0, sb);
                        sb.AppendLine();

                        sb.Append("{0}{1} = ", Literal.GetIndentString(indent), key);
                    }
                    if (!blockInfo.VarTypesOnPrologue.TryGetValue(vinfo.Name, out var typeOnPrologue)) {
                        typeOnPrologue = vinfo.Type;
                    }
                    string resultType = VecInferAndGenWhereEqualInt(pair.Value, vinfo.Type, key, typeOnPrologue, switchVar, switchVarType, caseExps, 0, sb, syntax);
                    string oldType = typeOnPrologue;
                    string varName = key;
                    bool adjust = VecAdjustType(vinfo, resultType);
                    GenAppendLine(sb);
                    if (CurFuncCodeGenerateEnabled()) {
                        if (adjust || vinfo.Type != oldType) {
                            broadcastsOnSkip.Append(Literal.GetIndentString(indent));
                            broadcastsOnSkip.Append(varName);
                            broadcastsOnSkip.Append(" = ");
                            GenBroadcast(broadcastsOnSkip, oldType, varName, "True", syntax);
                            broadcastsOnSkip.AppendLine();
                        }
                    }
                }
            }
        }
        private static void GenVecDefaultBlockEpilogue(BlockInfo blockInfo, string switchVar, string switchVarType, List<StringBuilder> caseExps, StringBuilder sb, int indent, StringBuilder broadcastsOnSkip, Dsl.ISyntaxComponent syntax)
        {
            foreach (var pair in blockInfo.AllVarTemporaries) {
                var vinfo = GetVarInfo(pair.Key, VarUsage.Find);
                if (null != vinfo) {
                    string key = pair.Key;
                    if (blockInfo.TryGetTemporaryInParent(key, out var newKey) && null != newKey)
                        key = newKey;

                    if (CurFuncCodeGenerateEnabled()) {
                        sb.Append("{0}#condition: not ", Literal.GetIndentString(indent));
                        VecInferAndGenEqualIntOr(switchVar, switchVarType, caseExps, 0, sb);
                        sb.AppendLine();

                        sb.Append("{0}{1} = ", Literal.GetIndentString(indent), key);
                    }
                    if (!blockInfo.VarTypesOnPrologue.TryGetValue(vinfo.Name, out var typeOnPrologue)) {
                        typeOnPrologue = vinfo.Type;
                    }
                    string resultType = VecInferAndGenWhereEqualInt(key, typeOnPrologue, pair.Value, vinfo.Type, switchVar, switchVarType, caseExps, 0, sb, syntax);
                    string oldType = typeOnPrologue;
                    string varName = key;
                    bool adjust = VecAdjustType(vinfo, resultType);
                    GenAppendLine(sb);
                    if (CurFuncCodeGenerateEnabled()) {
                        if (adjust || vinfo.Type != oldType) {
                            broadcastsOnSkip.Append(Literal.GetIndentString(indent));
                            broadcastsOnSkip.Append(varName);
                            broadcastsOnSkip.Append(" = ");
                            GenBroadcast(broadcastsOnSkip, oldType, varName, "True", syntax);
                            broadcastsOnSkip.AppendLine();
                        }
                    }
                }
            }
        }
    }
}