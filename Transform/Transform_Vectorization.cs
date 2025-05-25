using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml.Linq;

namespace Hlsl2Numpy
{
    internal partial class ProgramTransform
    {
        internal static void GenerateScalarFuncCode()
        {
            foreach (var pair in s_FuncInfos) {
                GenerateScalarFuncCode(pair.Value);
            }
        }
        internal static void TryUnrollLoops(int maxLoop)
        {
            if (s_AutoUnrollLoops) {
                ComputeGraph.ResetStatic();
                foreach (var pair in s_FuncInfos) {
                    TryUnrollLoops(maxLoop, pair.Value);
                }
            }
        }
        internal static void Vectorizing(StringBuilder sb)
        {
            //s_AllUsingFuncOrApis.Clear();
            //s_AutoGenCodes.Clear();
            //s_CalledScalarFuncs.Clear();
            SwapScalarCallInfo();
            MergeGlobalCallInfo();
            s_DeducingVecFuncQueue.Clear();
            s_VecFuncCodeStack.Clear();
            foreach (var pair in s_EntryFuncs) {
                var entryFunc = pair.Key;
                if (s_FuncInfos.TryGetValue(entryFunc, out var funcInfo)) {
                    var argTypes = new List<string>();
                    foreach (var p in funcInfo.Params) {
                        argTypes.Add(GetTypeVec(p.Type));
                    }
                    VectorizeFunc(funcInfo, argTypes, s_DeducingVecFuncQueue);
                }
            }
            //According to the parameter information of the vectorized entry function, the variables and global variables
            //that need to be vectorized in the function are deduced
            while (s_DeducingVecFuncQueue.Count > 0) {
                var vecInfo = s_DeducingVecFuncQueue.Dequeue();
                vecInfo.ModifyFuncInfo();
                Debug.Assert(null != vecInfo.VecFuncInfo);
                DeduceVecFunc(vecInfo.VecFuncInfo);
            }
            //Spread the influence of vectorized global variables to related variables throughout the program
            DeduceGlobalVecVar();
            //Reset function vectorization information but retain information about vectorized variables
            foreach (var pair in s_FuncInfos) {
                var funcInfo = pair.Value;
                funcInfo.Vectorizations.Clear();
                funcInfo.ResetScalarFuncInfo();
            }
            //Revectorize entry function
            foreach (var pair in s_EntryFuncs) {
                var entryFunc = pair.Key;
                if (s_FuncInfos.TryGetValue(entryFunc, out var funcInfo)) {
                    var argTypes = new List<string>();
                    foreach (var p in funcInfo.Params) {
                        argTypes.Add(GetTypeVec(p.Type));
                    }
                    VectorizeFunc(funcInfo, argTypes);
                }
            }
            //Perform vectorized derivation and generate vectorized function code
            //(all variables should be fully vectorized at this point)
            while (s_CalledVecFuncQueue.Count > 0) {
                var vecInfo = s_CalledVecFuncQueue.Dequeue();
                if (s_AllFuncDsls.TryGetValue(vecInfo.FuncSignature, out var stmData)) {
                    vecInfo.ModifyFuncInfo();
                    TransformFunc(stmData);
                }
            }
            s_IsVectorizing = false;
            //Regenerate non-vectorized function code affected by vectorized global variables
            foreach (var pair in s_FuncInfos) {
                var funcInfo = pair.Value;
                if (funcInfo.Vectorizations.Count <= 0) {
                    bool hasVec = false;
                    foreach (var name in funcInfo.UsingGlobals) {
                        if (s_VecGlobals.Contains(name)) {
                            hasVec = true;
                            break;
                        }
                    }
                    if (hasVec) {
                        if (s_AllFuncDsls.TryGetValue(funcInfo.Signature, out var stmData)) {
                            funcInfo.ClearForReTransform();
                            funcInfo.CodeGenerateEnabled = true;
                            TransformFunc(stmData);
                        }
                    }
                }
            }
            //Output source code
            foreach (var sig in s_AllFuncSigs) {
                if (s_CalledScalarFuncs.Contains(sig)) {
                    if (s_AllFuncCodes.TryGetValue(sig, out var fsb)) {
                        sb.Append(fsb);
                        if (s_FuncInfos.TryGetValue(sig, out var fi)) {
                            sb.AppendLine();
                        }
                    }
                }
            }
            while (s_VecFuncCodeStack.Count > 0) {
                var vfc = s_VecFuncCodeStack.Pop();
                sb.AppendLine();
                sb.Append(vfc.VecFuncStringBuilder);
            }
            foreach (var fn in s_CalledScalarFuncs) {
                if (s_FuncInfos.TryGetValue(fn, out var fi)) {
                    foreach (var f in fi.UsingFuncOrApis) {
                        if (s_ScalarAutoGenCodes.TryGetValue(f, out var fsb)) {
                            if (!s_AutoGenCodes.ContainsKey(f))
                                s_AutoGenCodes.Add(f, fsb);
                        }
                    }
                }
            }
        }

        private static void GenerateScalarFuncCode(FuncInfo funcInfo)
        {
            string sig = funcInfo.Signature;
            if (s_AllFuncDsls.TryGetValue(sig, out var syntax)) {
                //reparse: calc const
                funcInfo.ClearForReTransform();
                if (funcInfo.HasLoop && s_AutoUnrollLoops) {
                    funcInfo.CodeGenerateEnabled = false;
                }
                else {
                    funcInfo.CodeGenerateEnabled = true;
                }
                TransformFunc(syntax);
            }
        }
        private static bool TryUnrollLoops(int maxLoop, FuncInfo funcInfo)
        {
            bool r = true;
            if (funcInfo.HasLoop) {
                var blockInfo = funcInfo.ToplevelBlock;
                Debug.Assert(null != blockInfo);

                string sig = funcInfo.Signature;
                if (s_AllFuncDsls.TryGetValue(sig, out var syntax)) {
                    r = TryUnrollLoopsRecursively(maxLoop, blockInfo);
                    if (r) {
                        funcInfo.HasLoop = false;
                        if (!s_VectorizableFuncs.Contains(sig))
                            s_VectorizableFuncs.Add(sig);

                        //reparse1: construct new block info
                        funcInfo.ClearForReTransform();
                        funcInfo.ClearBlockInfo();
                        AddFuncParamsToComputeGraph(funcInfo);
                        TransformFunc(syntax);

                        //reparse2: gen scalar code
                        funcInfo.ClearForReTransform();
                        funcInfo.CodeGenerateEnabled = true;
                        TransformFunc(syntax);
                    }
                    else {
                        funcInfo.HasLoop = true;
                        if (!s_VectorizableFuncs.Contains(sig))
                            s_VectorizableFuncs.Add(sig);
                        //reparse1: construct new block info
                        funcInfo.ClearForReTransform();
                        funcInfo.ClearBlockInfo();
                        AddFuncParamsToComputeGraph(funcInfo);
                        TransformFunc(syntax);

                        //reparse2: gen scalar code
                        funcInfo.ClearForReTransform();
                        funcInfo.CodeGenerateEnabled = true;
                        TransformFunc(syntax);
                    }
                }
            }
            return r;
        }
        private static bool TryUnrollLoopsRecursively(int maxLoop, BlockInfo blockInfo)
        {
            var syntax = blockInfo.Syntax;
            Debug.Assert(null != syntax);

            bool ret = true;
            foreach (var scb in blockInfo.SubsequentBlocks) {
                ret = TryUnrollLoopsRecursively(maxLoop, scb) && ret;
            }
            foreach (var cb in blockInfo.ChildBlocks) {
                ret = TryUnrollLoopsRecursively(maxLoop, cb) && ret;
            }
            string id = syntax.GetId();
            var tsyntax = syntax;
            bool cret = true;
            if (id == "for") {
                cret = TryUnrollFor(ref tsyntax, blockInfo, maxLoop);
            }
            else if (id == "while") {
                cret = TryUnrollWhile(ref tsyntax, blockInfo, maxLoop);
            }
            else if (id == "do") {
                cret = TryUnrollDoWhile(ref tsyntax, blockInfo, maxLoop);
            }
            if (cret && tsyntax != syntax) {
                var parent = blockInfo.Parent;
                blockInfo.Syntax = tsyntax;
                Debug.Assert(null != parent && blockInfo.FuncSyntaxIndex >= 0);
                var pfunc = parent.Syntax as Dsl.FunctionData;
                var pstm = parent.Syntax as Dsl.StatementData;
                if (null != pstm) {
                    pfunc = pstm.GetFunction(parent.FuncSyntaxIndex).AsFunction;
                    Debug.Assert(null != pfunc);
                }
                if (null != pfunc) {
                    int ix = pfunc.Params.IndexOf(syntax);
                    Debug.Assert(ix >= 0);
                    pfunc.SetParam(ix, tsyntax);
                }
            }
            return ret && cret;
        }
        private static bool TryUnrollFor(ref Dsl.ISyntaxComponent forSyntax, BlockInfo blockInfo, int maxLoop)
        {
            bool canUnroll = false;
            string tmp = string.Empty;
            var forBody = forSyntax as Dsl.FunctionData;
            Debug.Assert(null != forBody && forBody.IsHighOrder);
            var forFunc = forBody.LowerOrderFunction;
            if (forFunc.GetParamNum() == 3) {
                var forInits = forFunc.GetParam(0) as Dsl.FunctionData;
                Debug.Assert(null != forInits);
                var forConds = forFunc.GetParam(1) as Dsl.FunctionData;
                Debug.Assert(null != forConds);
                var forIncs = forFunc.GetParam(2) as Dsl.FunctionData;
                Debug.Assert(null != forIncs);
                if (forInits.GetParamNum() == 1 && forConds.GetParamNum() == 1 && forIncs.GetParamNum() == 1) {
                    var initFunc = forInits.GetParam(0) as Dsl.FunctionData;
                    var condFunc = forConds.GetParam(0) as Dsl.FunctionData;
                    var incFunc = forIncs.GetParam(0) as Dsl.FunctionData;
                    if (null != initFunc && null != condFunc && null != incFunc) {
                        var initLhs = initFunc.GetParam(0);
                        var initLhsFunc = initLhs as Dsl.FunctionData;
                        var initLhsStm = initLhs as Dsl.StatementData;
                        if (null != initLhsStm) {
                            initLhsFunc = initLhsStm.First.AsFunction;
                        }
                        string initVarType = string.Empty;
                        string initVar;
                        if (null != initLhsFunc) {
                            var varInfo = ParseVarInfo(initLhsFunc, initLhsStm);
                            initVar = varInfo.Name;
                            if (!string.IsNullOrEmpty(varInfo.Type)) {
                                initVarType = varInfo.Type;
                            }
                        }
                        else {
                            initVar = initLhs.GetId();
                        }
                        var initVal = initFunc.GetParam(1) as Dsl.ValueData;
                        string condOp = condFunc.GetId();
                        var condVal = condFunc.GetParam(1) as Dsl.ValueData;
                        string incOp = incFunc.GetId();
                        Dsl.ValueData? incVal = null;
                        int incNum = incFunc.GetParamNum();
                        if (incNum == 2) {
                            incVal = incFunc.GetParam(1) as Dsl.ValueData;
                        }
                        if (null != initVal && initVal.GetIdType() == Dsl.ValueData.NUM_TOKEN &&
                            null != condVal && condVal.GetIdType() == Dsl.ValueData.NUM_TOKEN &&
                            (null == incVal || incVal.GetIdType() == Dsl.ValueData.NUM_TOKEN)) {
                            if (string.IsNullOrEmpty(initVarType) && blockInfo.FindVarInfo(initVar, out var bi, out var bbi, out var bbsi, out var bvi)) {
                                Debug.Assert(null != bvi);
                                initVarType = bvi.Type;
                            }
                            int init = 0;
                            float fInit = 0.0f;
                            int cond = 0;
                            float fCond = 0.0f;
                            bool isFloat = initVarType == "float" || initVarType == "double";
                            bool isInt = initVarType == "int" || initVarType == "uint";
                            if (((isInt && int.TryParse(initVal.GetId(), out init)) ||
                                (isFloat && float.TryParse(initVal.GetId(), out fInit))) &&
                                ((isInt && int.TryParse(condVal.GetId(), out cond)) ||
                                (isFloat && float.TryParse(condVal.GetId(), out fCond))) &&
                                (condOp == "<" || condOp == "<=" || condOp == ">" || condOp == ">=") &&
                                (incOp == "++" || incOp == "+=" || incOp == "--" || incOp == "-=")) {
                                int inc = 0;
                                float fInc = 0.0f;
                                if (condOp == "<=" || condOp == ">=") {
                                    if (isInt) {
                                        if (incOp == "+=" || incOp == "++")
                                            ++cond;
                                        else
                                            --cond;
                                    }
                                    else if (isFloat) {
                                        if (incOp == "+=" || incOp == "++")
                                            ++fCond;
                                        else
                                            --fCond;
                                    }
                                }
                                if (null != incVal) {
                                    if (isInt) {
                                        int.TryParse(incVal.GetId(), out inc);
                                        if (incOp == "-=") {
                                            inc = -inc;
                                        }
                                    }
                                    else if (isFloat) {
                                        float.TryParse(incVal.GetId(), out fInc);
                                        if (incOp == "-=") {
                                            fInc = -fInc;
                                        }
                                    }
                                }
                                else if (isInt) {
                                    inc = incOp == "++" ? 1 : -1;
                                }
                                else if (isFloat) {
                                    fInc = incOp == "++" ? 1.0f : -1.0f;
                                }
                                if ((isInt && inc != 0) || (isFloat && Math.Abs(fInc) > float.Epsilon)) {
                                    int loopCount = isInt ? (cond - init) / inc : (isFloat ? (int)((fCond - fInit) / fInc) : 0);
                                    if (loopCount <= 0 || loopCount > 512) {
                                        Console.WriteLine("for loop {0} must be in (0, 512] !!! line: {1}", loopCount, forFunc.GetLine());
                                    }
                                    else {
                                        bool find = SyntaxSearcher.Search(forBody, (syntax, six, syntaxStack) => VarAssignmentPred(syntax, six, syntaxStack, initVar));
                                        if (!find) {
                                            canUnroll = true;
                                            int stmCt = forBody.GetParamNum();
                                            for (int i = 1; i < loopCount; ++i) {
                                                var assignStm = new Dsl.FunctionData();
                                                assignStm.Name = new Dsl.ValueData("=", Dsl.ValueData.ID_TOKEN);
                                                assignStm.SetParamClass((int)Dsl.ParamClassEnum.PARAM_CLASS_OPERATOR);
                                                assignStm.AddParam(initVar);
                                                if (isInt) {
                                                    string val = (init + inc * i).ToString();
                                                    assignStm.AddParam(val, Dsl.ValueData.NUM_TOKEN);
                                                }
                                                else if (isFloat) {
                                                    string fVal = (fInit + fInc * i).ToString();
                                                    if (fVal.IndexOf('.') < 0)
                                                        fVal = fVal + ".0";
                                                    assignStm.AddParam(fVal, Dsl.ValueData.NUM_TOKEN);
                                                }
                                                else {
                                                    Debug.Assert(false);
                                                }
                                                assignStm.SetSeparator(Dsl.AbstractSyntaxComponent.SEPARATOR_SEMICOLON);
                                                forBody.AddParam(assignStm);
                                                for (int ii = 0; ii < stmCt; ++ii) {
                                                    var stm = forBody.GetParam(ii);
                                                    forBody.AddParam(Dsl.Utility.CloneDsl(stm));
                                                }
                                            }
                                            initFunc.SetSeparator(Dsl.AbstractSyntaxComponent.SEPARATOR_SEMICOLON);
                                            forBody.Name = new Dsl.ValueData("block");
                                            forBody.Params.Insert(0, initFunc);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (!canUnroll) {
                    int loopCt = maxLoop;
                    var attrsFunc = blockInfo.Attribute as Dsl.FunctionData;
                    if (null != attrsFunc) {
                        foreach (var p in attrsFunc.Params) {
                            var attr = p as Dsl.FunctionData;
                            if (null != attr && attr.GetParamClassUnmasked() == (int)Dsl.ParamClassEnum.PARAM_CLASS_BRACKET) {
                                var attrfd = attr.GetParam(0) as Dsl.FunctionData;
                                if (null != attrfd && attrfd.GetId() == "unroll") {
                                    if (int.TryParse(attrfd.GetParamId(0), out var ct) && ct >= 0) {
                                        loopCt = ct;
                                    }
                                }
                            }
                        }
                    }
                    if (loopCt > 0) {
                        canUnroll = true;
                        var newLoop = new Dsl.FunctionData();
                        newLoop.Name = new Dsl.ValueData("block");
                        newLoop.SetParamClass((int)Dsl.ParamClassEnum.PARAM_CLASS_STATEMENT);
                        Dsl.ISyntaxComponent? last = null;
                        foreach (var p in forInits.Params) {
                            newLoop.AddParam(p);
                            last = p;
                        }
                        if (null != last) {
                            last.SetSeparator(Dsl.AbstractSyntaxComponent.SEPARATOR_SEMICOLON);
                        }
                        var ifFunc = new Dsl.FunctionData();
                        ifFunc.Name = new Dsl.ValueData("if");
                        ifFunc.SetParamClass((int)Dsl.ParamClassEnum.PARAM_CLASS_PARENTHESIS);
                        if (forConds.GetParamNum() == 1) {
                            ifFunc.AddParam(forConds.GetParam(0));
                        }
                        else {
                            ifFunc.AddParam(new Dsl.ValueData("true", Dsl.ValueData.ID_TOKEN));
                        }
                        forBody.LowerOrderFunction = ifFunc;
                        newLoop.AddParam(forBody);
                        for (int i = 1; i < loopCt; ++i) {
                            foreach (var p in forIncs.Params) {
                                newLoop.AddParam(p);
                                p.SetSeparator(Dsl.AbstractSyntaxComponent.SEPARATOR_SEMICOLON);
                            }
                            var addBody = Dsl.Utility.CloneDsl(forBody);
                            newLoop.AddParam(addBody);
                        }
                        forSyntax = newLoop;
                    }
                }
            }
            if (!canUnroll) {
                Console.WriteLine("[Info]: Cant unroll statement '{0}', line: {1}", forSyntax.GetId(), forSyntax.GetLine());
                ChangeForCondToIf(forFunc, forBody);
            }
            return canUnroll;
        }
        private static bool TryUnrollWhile(ref Dsl.ISyntaxComponent whileSyntax, BlockInfo blockInfo, int maxLoop)
        {
            bool canUnroll = false;
            string tmp = string.Empty;
            var whileBody = whileSyntax as Dsl.FunctionData;
            Debug.Assert(null != whileBody && whileBody.IsHighOrder);
            var whileFunc = whileBody.LowerOrderFunction;
            if (whileFunc.GetParamNum() == 1) {
                var condFunc = whileFunc.GetParam(0) as Dsl.FunctionData;
                if (null != condFunc) {
                    string condOp = condFunc.GetId();
                    var condVar = condFunc.GetParam(0) as Dsl.ValueData;
                    var condVal = condFunc.GetParam(1) as Dsl.ValueData;
                    if (null != condVar && null != condVal && condVal.GetIdType() == Dsl.ValueData.NUM_TOKEN) {
                        string vname = condVar.GetId();
                        string vtype = string.Empty;
                        if (blockInfo.FindVarInfo(vname, out var bi, out var bbi, out var bbsi, out var bvi)) {
                            Debug.Assert(null != bvi);
                            vtype = bvi.Type;
                        }
                        int cond = 0;
                        float fCond = 0.0f;
                        bool isFloat = vtype == "float" || vtype == "double";
                        bool isInt = vtype == "int" || vtype == "uint";
                        if (((isInt && int.TryParse(condVal.GetId(), out cond)) ||
                            (isFloat && float.TryParse(condVal.GetId(), out fCond))) &&
                            (condOp == "<" || condOp == "<=" || condOp == ">" || condOp == ">=")) {
                            string incOp = string.Empty;
                            Dsl.ValueData? incVal = null;
                            var parent = blockInfo.Parent;
                            Debug.Assert(null != parent);
                            int init = 0;
                            float fInit = 0.0f;
                            int ix = parent.FindChildIndex(blockInfo, out var six);
                            if (parent.TryGetVarConstInBasicBlock(ix, -1, -1, vname, out var vval) && !string.IsNullOrEmpty(vval) &&
                                ((isInt && int.TryParse(vval, out init)) ||
                                (isFloat && float.TryParse(vval, out fInit)))) {
                                int assignCt = 0;
                                Dsl.ISyntaxComponent? assignExp = null;
                                SyntaxSearcher.Search(whileBody, (syntax, six, syntaxStack) => VarAssignmentPredAndGetAssignExp(syntax, six, syntaxStack, vname, ref assignCt, out assignExp));
                                if (assignCt == 1 && null != assignExp) {
                                    var incFunc = assignExp as Dsl.FunctionData;
                                    Debug.Assert(null != incFunc);

                                    incOp = incFunc.GetId();
                                    int incNum = incFunc.GetParamNum();
                                    if (incNum == 2) {
                                        incVal = incFunc.GetParam(1) as Dsl.ValueData;
                                    }
                                }
                                int inc = 0;
                                float fInc = 0.0f;
                                if (condOp == "<=" || condOp == ">=") {
                                    if (isInt) {
                                        if (incOp == "+=" || incOp == "++")
                                            ++cond;
                                        else
                                            --cond;
                                    }
                                    else if (isFloat) {
                                        if (incOp == "+=" || incOp == "++")
                                            ++fCond;
                                        else
                                            --fCond;
                                    }
                                }
                                if ((null == incVal || incVal.GetIdType() == Dsl.ValueData.NUM_TOKEN) &&
                                    (incOp == "++" || incOp == "+=" || incOp == "--" || incOp == "-=")) {
                                    if (null != incVal) {
                                        if (isInt) {
                                            int.TryParse(incVal.GetId(), out inc);
                                            if (incOp == "-=") {
                                                inc = -inc;
                                            }
                                        }
                                        else if (isFloat) {
                                            float.TryParse(incVal.GetId(), out fInc);
                                            if (incOp == "-=") {
                                                fInc = -fInc;
                                            }
                                        }
                                    }
                                    else if (isInt) {
                                        inc = incOp == "++" ? 1 : -1;
                                    }
                                    else if (isFloat) {
                                        fInc = incOp == "++" ? 1.0f : -1.0f;
                                    }
                                }
                                if ((isInt && inc != 0) || (isFloat && Math.Abs(fInc) > float.Epsilon)) {
                                    int loopCount = isInt ? (cond - init) / inc : (isFloat ? (int)((fCond - fInit) / fInc) : 0);
                                    if (loopCount <= 0 || loopCount > 512) {
                                        Console.WriteLine("while loop {0} must be in (0, 512] !!! line: {1}", loopCount, whileFunc.GetLine());
                                    }
                                    else {
                                        canUnroll = true;
                                        int stmCt = whileBody.GetParamNum();
                                        for (int i = 1; i < loopCount; ++i) {
                                            for (int ii = 0; ii < stmCt; ++ii) {
                                                var stm = whileBody.GetParam(ii);
                                                whileBody.AddParam(Dsl.Utility.CloneDsl(stm));
                                            }
                                        }
                                        whileBody.Name = new Dsl.ValueData("block");
                                    }
                                }
                            }
                        }
                    }
                }
                if (!canUnroll) {
                    int loopCt = maxLoop;
                    var attrsFunc = blockInfo.Attribute as Dsl.FunctionData;
                    if (null != attrsFunc) {
                        foreach (var p in attrsFunc.Params) {
                            var attr = p as Dsl.FunctionData;
                            if (null != attr && attr.GetParamClassUnmasked() == (int)Dsl.ParamClassEnum.PARAM_CLASS_BRACKET) {
                                var attrfd = attr.GetParam(0) as Dsl.FunctionData;
                                if (null != attrfd && attrfd.GetId() == "unroll") {
                                    if (int.TryParse(attrfd.GetParamId(0), out var ct) && ct >= 0) {
                                        loopCt = ct;
                                    }
                                }
                            }
                        }
                    }
                    if (loopCt > 0) {
                        canUnroll = true;
                        var newLoop = new Dsl.FunctionData();
                        newLoop.Name = new Dsl.ValueData("block");
                        newLoop.SetParamClass((int)Dsl.ParamClassEnum.PARAM_CLASS_STATEMENT);
                        whileFunc.Name.SetId("if");
                        newLoop.AddParam(whileBody);
                        for (int i = 1; i < loopCt; ++i) {
                            var addBody = Dsl.Utility.CloneDsl(whileBody);
                            newLoop.AddParam(addBody);
                        }
                        whileSyntax = newLoop;
                    }
                }
            }
            if (!canUnroll) {
                Console.WriteLine("[Info]: Cant unroll statement '{0}', line: {1}", whileSyntax.GetId(), whileSyntax.GetLine());
                ChangeWhileCondToIf(whileFunc, whileBody);
            }
            return canUnroll;
        }
        private static bool TryUnrollDoWhile(ref Dsl.ISyntaxComponent dowhileSyntax, BlockInfo blockInfo, int maxLoop)
        {
            bool canUnroll = false;
            string tmp = string.Empty;
            var loopStm = dowhileSyntax as Dsl.StatementData;
            Debug.Assert(null != loopStm);
            var doBody = loopStm.First.AsFunction;
            var whileFunc = loopStm.Second.AsFunction;
            Debug.Assert(null != doBody && null != whileFunc);
            if (whileFunc.GetParamNum() == 1) {
                var condFunc = whileFunc.GetParam(0) as Dsl.FunctionData;
                if (null != condFunc) {
                    string condOp = condFunc.GetId();
                    var condVar = condFunc.GetParam(0) as Dsl.ValueData;
                    var condVal = condFunc.GetParam(1) as Dsl.ValueData;
                    if (null != condVar && null != condVal && condVal.GetIdType() == Dsl.ValueData.NUM_TOKEN) {
                        string vname = condVar.GetId();
                        string vtype = string.Empty;
                        if (blockInfo.FindVarInfo(vname, out var bi, out var bbi, out var bbsi, out var bvi)) {
                            Debug.Assert(null != bvi);
                            vtype = bvi.Type;
                        }
                        int cond = 0;
                        float fCond = 0.0f;
                        bool isFloat = vtype == "float" || vtype == "double";
                        bool isInt = vtype == "int" || vtype == "uint";
                        if (((isInt && int.TryParse(condVal.GetId(), out cond)) ||
                            (isFloat && float.TryParse(condVal.GetId(), out fCond))) &&
                            (condOp == "<" || condOp == "<=" || condOp == ">" || condOp == ">=")) {
                            string incOp = string.Empty;
                            Dsl.ValueData? incVal = null;
                            var parent = blockInfo.Parent;
                            Debug.Assert(null != parent);
                            int init = 0;
                            float fInit = 0.0f;
                            int ix = parent.FindChildIndex(blockInfo, out var six);
                            if (parent.TryGetVarConstInBasicBlock(ix, -1, -1, vname, out var vval) && !string.IsNullOrEmpty(vval) &&
                                ((isInt && int.TryParse(vval, out init)) ||
                                (isFloat && float.TryParse(vval, out fInit)))) {
                                int assignCt = 0;
                                Dsl.ISyntaxComponent? assignExp = null;
                                SyntaxSearcher.Search(doBody, (syntax, six, syntaxStack) => VarAssignmentPredAndGetAssignExp(syntax, six, syntaxStack, vname, ref assignCt, out assignExp));
                                if (assignCt == 1 && null != assignExp) {
                                    var incFunc = assignExp as Dsl.FunctionData;
                                    Debug.Assert(null != incFunc);

                                    incOp = incFunc.GetId();
                                    int incNum = incFunc.GetParamNum();
                                    if (incNum == 2) {
                                        incVal = incFunc.GetParam(1) as Dsl.ValueData;
                                    }
                                }
                                int inc = 0;
                                float fInc = 0.0f;
                                if (condOp == "<=" || condOp == ">=") {
                                    if (isInt) {
                                        if (incOp == "+=" || incOp == "++")
                                            ++cond;
                                        else
                                            --cond;
                                    }
                                    else if (isFloat) {
                                        if (incOp == "+=" || incOp == "++")
                                            ++fCond;
                                        else
                                            --fCond;
                                    }
                                }
                                if ((null == incVal || incVal.GetIdType() == Dsl.ValueData.NUM_TOKEN) &&
                                    (incOp == "++" || incOp == "+=" || incOp == "--" || incOp == "-=")) {
                                    if (null != incVal) {
                                        if (isInt) {
                                            int.TryParse(incVal.GetId(), out inc);
                                            if (incOp == "-=") {
                                                inc = -inc;
                                            }
                                        }
                                        else if (isFloat) {
                                            float.TryParse(incVal.GetId(), out fInc);
                                            if (incOp == "-=") {
                                                fInc = -fInc;
                                            }
                                        }
                                    }
                                    else if (isInt) {
                                        inc = incOp == "++" ? 1 : -1;
                                    }
                                    else if (isFloat) {
                                        fInc = incOp == "++" ? 1.0f : -1.0f;
                                    }
                                }
                                if ((isInt && inc != 0) || (isFloat && Math.Abs(fInc) > float.Epsilon)) {
                                    int loopCount = isInt ? (cond - init) / inc : (isFloat ? (int)((fCond - fInit) / fInc) : 0);
                                    if (loopCount <= 0 || loopCount > 512) {
                                        Console.WriteLine("while loop {0} must be in (0, 512] !!! line: {1}", loopCount, whileFunc.GetLine());
                                    }
                                    else {
                                        canUnroll = true;
                                        int stmCt = doBody.GetParamNum();
                                        for (int i = 1; i < loopCount; ++i) {
                                            for (int ii = 0; ii < stmCt; ++ii) {
                                                var stm = doBody.GetParam(ii);
                                                doBody.AddParam(Dsl.Utility.CloneDsl(stm));
                                            }
                                        }
                                        doBody.Name = new Dsl.ValueData("block");
                                        doBody.SetSeparator(Dsl.AbstractSyntaxComponent.SEPARATOR_SEMICOLON);
                                        dowhileSyntax = doBody;
                                    }
                                }
                            }
                        }
                    }
                }
                if (!canUnroll) {
                    int loopCt = maxLoop;
                    var attrsFunc = blockInfo.Attribute as Dsl.FunctionData;
                    if (null != attrsFunc) {
                        foreach (var p in attrsFunc.Params) {
                            var attr = p as Dsl.FunctionData;
                            if (null != attr && attr.GetParamClassUnmasked() == (int)Dsl.ParamClassEnum.PARAM_CLASS_BRACKET) {
                                var attrfd = attr.GetParam(0) as Dsl.FunctionData;
                                if (null != attrfd && attrfd.GetId() == "unroll") {
                                    if (int.TryParse(attrfd.GetParamId(0), out var ct) && ct >= 0) {
                                        loopCt = ct;
                                    }
                                }
                            }
                        }
                    }
                    if (loopCt > 0) {
                        canUnroll = true;
                        var newLoop = new Dsl.FunctionData();
                        newLoop.Name = new Dsl.ValueData("block");
                        newLoop.SetParamClass((int)Dsl.ParamClassEnum.PARAM_CLASS_STATEMENT);
                        whileFunc.Name.SetId("if");
                        var ifFunc = new Dsl.FunctionData();
                        ifFunc.Name = new Dsl.ValueData("if");
                        ifFunc.SetParamClass((int)Dsl.ParamClassEnum.PARAM_CLASS_PARENTHESIS);
                        ifFunc.AddParam(new Dsl.ValueData("true", Dsl.ValueData.ID_TOKEN));
                        var tmplBody = Dsl.Utility.CloneDsl(doBody) as Dsl.FunctionData;
                        Debug.Assert(null != tmplBody);
                        tmplBody.LowerOrderFunction = whileFunc;
                        doBody.LowerOrderFunction = ifFunc;
                        newLoop.AddParam(doBody);
                        for (int i = 1; i < loopCt; ++i) {
                            if (i == 1)
                                newLoop.AddParam(tmplBody);
                            else {
                                var addBody = Dsl.Utility.CloneDsl(tmplBody);
                                newLoop.AddParam(addBody);
                            }
                        }
                        dowhileSyntax = newLoop;
                    }
                }
            }
            if (!canUnroll) {
                Console.WriteLine("[Info]: Cant unroll statement '{0}', line: {1}", dowhileSyntax.GetId(), dowhileSyntax.GetLine());
                ChangeDoWhileCondToUntilIf(whileFunc, doBody);
            }
            return canUnroll;
        }
        private static bool VarAssignmentPred(Dsl.ISyntaxComponent syntax, int index, IEnumerable<SyntaxStackInfo> syntaxStack, string varName)
        {
            bool ret = false;
            if (IsVarAssignment(syntax, index, syntaxStack, varName, out var assignExp)) {
                ret = true;
                foreach (var p in syntaxStack) {
                    if (p.Syntax.GetId() == "for" && p.Index == -1) {
                        ret = false;
                        break;
                    }
                }
            }
            return ret;
        }
        private static bool VarAssignmentPredAndGetAssignExp(Dsl.ISyntaxComponent syntax, int index, IEnumerable<SyntaxStackInfo> syntaxStack, string varName, ref int ct, out Dsl.ISyntaxComponent? assignExp)
        {
            bool ret = false;
            if (IsVarAssignment(syntax, index, syntaxStack, varName, out assignExp)) {
                ++ct;
                ret = true;
            }
            return ret;
        }
        private static bool IsVarAssignment(Dsl.ISyntaxComponent syntax, int index, IEnumerable<SyntaxStackInfo> syntaxStack, string varName, out Dsl.ISyntaxComponent? assignExp)
        {
            bool ret = false;
            assignExp = null;
            if (syntax.GetId() == varName) {
                var ps = GetOuterSyntax(syntaxStack);
                if (null != ps) {
                    string pid = ps.GetId();
                    bool isLHS = false;
                    var assignFunc = ps as Dsl.FunctionData;
                    if (null != assignFunc) {
                        string leftId = assignFunc.GetParamId(0);
                        isLHS = leftId == varName;
                    }
                    if (isLHS && (pid == "++" || pid == "--" || pid == "=" || (pid[pid.Length - 1] == '=' && pid != ">=" && pid != "<=" && pid != "==" && pid != "!=" && pid != ">>=" && pid != "<<="))) {
                        assignExp = ps;
                        ret = true;
                    }
                }
            }
            return ret;
        }

        private static void VectorizeFunc(FuncInfo funcInfo, IList<string> args)
        {
            VectorizeFunc(funcInfo, args, null);
        }
        private static void VectorizeFunc(FuncInfo funcInfo, IList<string> args, Queue<VectorialFuncInfo>? queue)
        {
            bool find = false;
            foreach (var vinfo in funcInfo.Vectorizations) {
                var vf = vinfo.VecFuncInfo;
                Debug.Assert(null != vf);
                if (vinfo.VecArgTypes.Count == args.Count) {
                    bool same = true;
                    for (int ix = 0; ix < vinfo.VecArgTypes.Count; ++ix) {
                        string t1 = vinfo.VecArgTypes[ix];
                        string t2 = args[ix];
                        var p = vf.Params[ix];
                        bool isInOut = p.IsInOut;
                        bool isOut = p.IsOut;
                        if (isInOut || isOut) {
                            //Since inout and out parameters are always vectorized, they are not used as a basis for judgment.
                            continue;
                        }
                        if (t1 != t2) {
                            same = false;
                            break;
                        }
                    }
                    if (same) {
                        find = true;
                        vinfo.ModifyFuncInfo();
                        break;
                    }
                }
            }
            if (find)
                return;
            var vecInfo = new VectorialFuncInfo();
            for (int ix = 0; ix < funcInfo.Params.Count; ++ix) {
                var p = funcInfo.Params[ix];
                if (ix < args.Count) {
                    string realType = args[ix];
                    bool isInOut = p.IsInOut;
                    bool isOut = p.IsOut;
                    bool realTypeIsVec = false;
                    if (IsTypeVec(realType)) {
                        realTypeIsVec = true;
                    }
                    if (isInOut || isOut) {
                        //inout and out parameters are always vectorized
                        p.Type = GetTypeVec(p.Type);
                    }
                    else {
                        if (realTypeIsVec) {
                            p.Type = GetTypeVec(p.Type);
                        }
                        else if (realType != p.Type) {
                            p.Type = realType;
                        }
                    }
                }
                else if (null != p.DefaultValueSyntax) {

                }
                else {
                    Debug.Assert(false);
                }
                vecInfo.VecArgTypes.Add(p.Type);
            }
            vecInfo.FuncSignature = funcInfo.Signature;
            vecInfo.VecFuncInfo = funcInfo;
            vecInfo.VectorizeNo = funcInfo.Vectorizations.Count;

            if (!funcInfo.IsVoid()) {
                string retType = funcInfo.RetInfo.Type;
                funcInfo.RetInfo.Type = GetTypeVec(retType);
                vecInfo.VecRetType = funcInfo.RetInfo.Type;
            }
            funcInfo.ClearForReTransform();
            funcInfo.VectorizeNo = vecInfo.VectorizeNo;
            funcInfo.Vectorizations.Add(vecInfo);
            if (null != queue)
                queue.Enqueue(vecInfo);
            else
                s_CalledVecFuncQueue.Enqueue(vecInfo);
        }
        private static bool VectorizeVar(Dsl.ISyntaxComponent info, out string broadcastVarName, out bool needBroadcastObj)
        {
            //Array vectorization is the vectorization of array elements, and the vectorization
            //of structures is the vectorization of structure fields.
            //When struct is vectorized, all fields are vectorized together, which is consistent
            //with ordinary variables (arrays are also vectorized with all elements in one piece,
            //otherwise it would not be an array), which will make the processing much simpler.
            //(When used as a function parameter, there will be many vectorized versions of the
            //function; if it is also used as a function return value, the return value can only
            //be vectorized. Otherwise, when the function is vectorized, the signature of function
            //vectorization cannot be obtained before the function body derivation is completed.
            //Conversion between versions of partial vectorization will also be troublesome; and
            //the structure may also be nested, and nesting may need to be avoided in actual use)
            bool ret = false;
            needBroadcastObj = false;
            broadcastVarName = string.Empty;
            var vd = info as Dsl.ValueData;
            if (null != vd) {
                var varInfo = GetVarInfo(vd.GetId(), VarUsage.Find);
                if (null != varInfo) {
                    varInfo.Type = GetTypeVec(varInfo.Type, out var isTuple, out var isStruct, out var isVecBefore);
                    if (!isVecBefore) {
                        broadcastVarName = varInfo.Name;
                        ret = true;

                        if (null == varInfo.OwnerBlock) {
                            Console.WriteLine("[Error]: vectorize global var '{0}', please change it to a local var, line: {1}", info.GetId(), info.GetLine());
                        }
                    }
                }
                else {
                    Console.WriteLine("[Error]: can't vectorize var '{0}', line: {1}", info.GetId(), info.GetLine());
                }
            }
            else {
                var func = info as Dsl.FunctionData;
                if (null != func) {
                    if (func.GetParamClassUnmasked() == (int)Dsl.ParamClassEnum.PARAM_CLASS_PERIOD) {
                        //object vectorization
                        needBroadcastObj = true;
                        if (func.IsHighOrder) {
                            ret = VectorizeVar(func.LowerOrderFunction, out broadcastVarName, out var _);
                        }
                        else {
                            ret = VectorizeVar(func.Name, out broadcastVarName, out var _);
                        }
                    }
                    else if (func.GetParamClassUnmasked() == (int)Dsl.ParamClassEnum.PARAM_CLASS_BRACKET) {
                        //Array vectorization
                        needBroadcastObj = true;
                        if (func.IsHighOrder) {
                            ret = VectorizeVar(func.LowerOrderFunction, out broadcastVarName, out var _);
                        }
                        else {
                            ret = VectorizeVar(func.Name, out broadcastVarName, out var _);
                        }
                    }
                    else {
                        var varInfo = ParseVarInfo(func, null);
                        if (!string.IsNullOrEmpty(varInfo.Name)) {
                            varInfo = GetVarInfo(varInfo.Name, VarUsage.Find);
                            if (null != varInfo) {
                                varInfo.Type = GetTypeVec(varInfo.Type, out var isTuple, out var isStruct, out var isVecBefore);
                                if (!isVecBefore) {
                                    broadcastVarName = varInfo.Name;
                                    ret = true;

                                    if (null == varInfo.OwnerBlock) {
                                        Console.WriteLine("[Error]: vectorize global var '{0}', please change it to a local var, line: {1}", info.GetId(), info.GetLine());
                                    }
                                }
                            }
                        }
                        else {
                            Console.WriteLine("[Error]: can't vectorize var '{0}', line: {1}", info.GetId(), info.GetLine());
                        }
                    }
                }
                else {
                    var stm = info as Dsl.StatementData;
                    if (null != stm) {
                        func = stm.First.AsFunction;
                        Debug.Assert(null != func);
                        var varInfo = ParseVarInfo(func, stm);
                        if (!string.IsNullOrEmpty(varInfo.Name)) {
                            varInfo = GetVarInfo(varInfo.Name, VarUsage.Find);
                            if (null != varInfo) {
                                varInfo.Type = GetTypeVec(varInfo.Type, out var isTuple, out var isStruct, out var isVecBefore);
                                if (!isVecBefore) {
                                    broadcastVarName = varInfo.Name;
                                    ret = true;

                                    if (null == varInfo.OwnerBlock) {
                                        Console.WriteLine("[Error]: vectorize global var '{0}', please change it to a local var, line: {1}", info.GetId(), info.GetLine());
                                    }
                                }
                            }
                        }
                        else {
                            Console.WriteLine("[Error]: can't vectorize var '{0}', line: {1}", info.GetId(), info.GetLine());
                        }
                    }
                    else {
                        Console.WriteLine("[Error]: can't vectorize var '{0}', line: {1}", info.GetId(), info.GetLine());
                    }
                }
            }
            return ret;
        }
        private static void DeduceGlobalVecVar()
        {
            if (s_PrintVectorizedVars)
                Console.WriteLine("===[deduce global vec var]===");
            var graph = s_GlobalComputeGraph;
            foreach (var pair in graph.VarNodes) {
                var node = pair.Value;
                if (IsTypeVec(node.Type)) {
                    if (s_PrintVectorizedVars)
                        Console.WriteLine(">>> from vec global var:{0}", node.VarName);
                    graph.VisitAllNext(node, ChangeTypeCallback);
                }
                else {
                    if (s_PrintVectorizedVars)
                        Console.WriteLine("*** skip novec global var:{0}", node.VarName);
                }
            }
            s_VecGlobals.Clear();
            foreach (var pair in graph.VarNodes) {
                var key = pair.Key;
                var node = pair.Value;
                if (IsTypeVec(node.Type)) {
                    s_VecGlobals.Add(key);
                }
            }
        }
        private static void DeduceVecFunc(FuncInfo funcInfo)
        {
            if (s_PrintVectorizedVars)
                Console.WriteLine("===[deduce vec func:{0}]===", funcInfo.Signature);
            var graph = funcInfo.FuncComputeGraph;
            foreach (var p in funcInfo.Params) {
                if (IsTypeVec(p.Type)) {
                    if (s_PrintVectorizedVars)
                        Console.WriteLine(">>> from vec param:{0}", p.Name);
                    graph.VisitNext(funcInfo, p.Name, ChangeTypeCallback);
                }
                else {
                    if (s_PrintVectorizedVars)
                        Console.WriteLine("*** skip novec param:{0}", p.Name);
                }
            }
            foreach (var p in funcInfo.Params) {
                if (IsTypeVec(p.Type)) {
                    graph.VisitNext(funcInfo, p.Name, VecFuncCallback);
                }
            }
        }
        private static bool ChangeTypeCallback(ComputeGraphNode node)
        {
            var nodeFunc = node.OwnFunc;
            if (IsTypeVec(node.Type)) {
                if (s_PrintVectorizedVars) {
                    var vnode = node as ComputeGraphVarNode;
                    var cnode = node as ComputeGraphCalcNode;
                    var cvnode = node as ComputeGraphConstNode;
                    if(null!=vnode) {
                        Console.WriteLine("*** skip var node:{0} type:{1} name:{2} func:{3}", node.Id, node.Type, vnode.VarName, null != nodeFunc ? nodeFunc.Signature : "global");
                    }
                    else if (null != cnode) {
                        Console.WriteLine("*** skip calc node:{0} type:{1} op:{2} func:{3}", node.Id, node.Type, cnode.Operator, null != nodeFunc ? nodeFunc.Signature : "global");
                    }
                    else if (null != cvnode) {
                        Console.WriteLine("*** skip const node:{0} type:{1} val:{2} func:{3}", node.Id, node.Type, cvnode.Value, null != nodeFunc ? nodeFunc.Signature : "global");
                    }
                    else {
                        Console.WriteLine("*** skip node:{0} type:{1} node type:{2} func:{3}", node.Id, node.Type, node.GetType().Name, null != nodeFunc ? nodeFunc.Signature : "global");
                    }
                }
            }
            else {
                node.Type = GetTypeVec(node.Type);

                var vnode = node as ComputeGraphVarNode;
                if (null != vnode) {
                    var funcInfo = vnode.OwnFunc;
                    VecVar(funcInfo, vnode.VarName, vnode.Type, vnode.Id);
                }
                else {
                    if (s_PrintVectorizedVars) {
                        var cnode = node as ComputeGraphCalcNode;
                        var cvnode = node as ComputeGraphConstNode;
                        if (null != cnode) {
                            Console.WriteLine("vectorize graph calc node:{0} type:{1} op:{2} func:{3}", node.Id, node.Type, cnode.Operator, null != nodeFunc ? nodeFunc.Signature : "global");
                        }
                        else if (null != cvnode) {
                            Console.WriteLine("vectorize graph const node:{0} type:{1} val:{2} func:{3}", node.Id, node.Type, cvnode.Value, null != nodeFunc ? nodeFunc.Signature : "global");
                        }
                        else {
                            Console.WriteLine("vectorize graph node:{0} type:{1} node type:{2} func:{3}", node.Id, node.Type, node.GetType().Name, null != nodeFunc ? nodeFunc.Signature : "global");
                        }
                    }
                }
            }
            return true;
        }
        private static void VecVar(FuncInfo? funcInfo, string vname, string vtype, uint nodeId)
        {
            if (null != funcInfo) {
                if (funcInfo.UniqueLocalVarInfos.TryGetValue(vname, out var vinfo)) {
                    vinfo.Type = GetTypeVec(vinfo.Type);

                    if (s_PrintVectorizedVars)
                        Console.WriteLine("vectorize func var:{0} type:{1} func:{2} node:{3}", vname, vinfo.Type, funcInfo.Signature, nodeId);
                }
                else if (ProgramTransform.s_GlobalVarInfos.TryGetValue(vname, out vinfo)) {
                    vinfo.Type = GetTypeVec(vinfo.Type);
                }
                else {
                    bool find = false;
                    foreach (var p in funcInfo.Params) {
                        if (vname == p.Name) {
                            p.Type = GetTypeVec(p.Type);
                            find = true;
                            break;
                        }
                    }
                    if (!find) {
                        Console.WriteLine("[Error]: func var for vectorize not found:{0} type:{1} func:{2} node:{3}", vname, vtype, funcInfo.Signature, nodeId);
                    }
                }
            }
            else {
                if (ProgramTransform.s_GlobalVarInfos.TryGetValue(vname, out var vinfo)) {
                    vinfo.Type = GetTypeVec(vinfo.Type);
                }
                else {
                    Console.WriteLine("[Error]: global var for vectorize not found:{0} type:{1} node:{3}", vname, vtype, nodeId);
                }
            }
        }
        private static bool VecFuncCallback(ComputeGraphNode node)
        {
            var cnode = node as ComputeGraphCalcNode;
            if (null != cnode) {
                string sig = cnode.Operator;
                if (s_FuncInfos.TryGetValue(sig, out var funcInfo)) {
                    var argTypes = new List<string>();
                    for (int ix = 1; ix < cnode.PrevNodes.Count; ++ix) {
                        var p = cnode.PrevNodes[ix];
                        argTypes.Add(p.Type);
                    }

                    if (s_PrintVectorizedVars) {
                        var nodeFunc = node.OwnFunc;
                        Console.Write("==> vectorize func:{0} args:", sig);
                        string prestr = string.Empty;
                        foreach(var argtype in argTypes) {
                            Console.Write(prestr);
                            Console.Write(argtype);
                            prestr = ",";
                        }
                        Console.WriteLine(" node:{0} caller:{1}", node.Id, null != nodeFunc ? nodeFunc.Signature : "global");
                    }
                    VectorizeFunc(funcInfo, argTypes, s_DeducingVecFuncQueue);
                }
            }
            return true;
        }

        private static Queue<VectorialFuncInfo> s_DeducingVecFuncQueue = new Queue<VectorialFuncInfo>();
        private static Queue<VectorialFuncInfo> s_CalledVecFuncQueue = new Queue<VectorialFuncInfo>();
        private static Stack<VecFuncCodeInfo> s_VecFuncCodeStack = new Stack<VecFuncCodeInfo>();
        private static HashSet<string> s_CalledScalarFuncs = new HashSet<string>();
        private static HashSet<string> s_VecGlobals = new HashSet<string>();
    }
}