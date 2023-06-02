using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using static Hlsl2Numpy.Program;

namespace Hlsl2Numpy
{
    internal sealed class FuncInfo
    {
        internal string Name = string.Empty;
        internal string Signature = string.Empty;
        internal bool HasInOutOrOutParams = false;
        internal bool HasLoop = false;

        internal bool ParseAndPruned = false;
        internal bool Transformed = false;
        internal bool VarRenamed = false;
        internal bool BlockInfoConstructed = false;
        internal bool CodeGenerateEnabled = false;

        internal List<VarInfo> Params = new List<VarInfo>();
        internal VarInfo RetInfo = new VarInfo();
        internal List<VarInfo> InOutOrOutParams = new List<VarInfo>();
        internal BlockInfo ToplevelBlock = new BlockInfo();
        internal ComputeGraph FuncComputeGraph = new ComputeGraph();
        internal List<VectorialFuncInfo> Vectorizations = new List<VectorialFuncInfo>();
        internal int VectorizeNo = 0;
        internal List<string> UsingGlobals = new List<string>();
        internal HashSet<string> ModifiedParams = new HashSet<string>();

        internal Dictionary<string, string> LocalTypeDefs = new Dictionary<string, string>();
        internal Dictionary<string, Dictionary<int, VarInfo>> LocalVarInfos = new Dictionary<string, Dictionary<int, VarInfo>>();
        internal Dictionary<string, VarInfo> UniqueLocalVarInfos = new Dictionary<string, VarInfo>();
        internal HashSet<string> UsingFuncOrApis = new HashSet<string>();

        internal Dsl.ISyntaxComponent? LastAttribute = null;

        internal void ClearBlockInfo()
        {
            VarRenamed = false;
            BlockInfoConstructed = false;
            ToplevelBlock.ClearChildren();
            FuncComputeGraph.Reset(this);
            UniqueLocalVarInfos.Clear();
        }
        internal void ClearForReTransform()
        {
            Transformed = false;
            LocalTypeDefs.Clear();
            LocalVarInfos.Clear();
            UsingFuncOrApis.Clear();
            LastAttribute = null;
        }
        internal void ResetScalarFuncInfo()
        {
            foreach (var p in Params) {
                p.Type = p.OriType;
            }
            RetInfo.Type = RetInfo.OriType;
        }

        internal bool IsVoid()
        {
            return RetInfo.Type == "void";
        }
        internal string GetVecNoTag()
        {
            if (VectorizeNo == 0)
                return string.Empty;
            else
                return VectorizeNo.ToString();
        }
        internal VectorialFuncInfo GetVectorialFuncInfo()
        {
            return Vectorizations[VectorizeNo];
        }
    }
    internal class VectorialFuncInfo
    {
        internal string FuncSignature = string.Empty;
        internal List<string> VecArgTypes = new List<string>();
        internal string VecRetType = string.Empty;
        internal FuncInfo? VecFuncInfo = null;
        internal int VectorizeNo = 0;

        internal void ModifyFuncInfo()
        {
            if (null != VecFuncInfo) {
                for (int ix = 0; ix < VecFuncInfo.Params.Count; ++ix) {
                    var p = VecFuncInfo.Params[ix];
                    if (ix < VecArgTypes.Count) {
                        p.Type = VecArgTypes[ix];
                    }
                }
                if (!VecFuncInfo.IsVoid()) {
                    VecFuncInfo.RetInfo.Type = VecRetType;
                }
                VecFuncInfo.VectorizeNo = VectorizeNo;
            }
        }
    }
    internal class VecFuncCodeInfo
    {
        internal FuncInfo VecFuncInfo;
        internal StringBuilder VecFuncStringBuilder;

        internal VecFuncCodeInfo(FuncInfo funcInfo, StringBuilder sb)
        {
            VecFuncInfo = funcInfo;
            VecFuncStringBuilder = sb;
        }
    }
    internal enum SyntaxUsage
    {
        Anything = 0,
        Operator,
        MemberName,
        FuncName,
        TypeName,
        MaxNum
    }
    internal readonly ref struct ParseContextInfo
    {
        internal SyntaxUsage Usage { get; init; } = SyntaxUsage.Anything;
        internal bool IsInAssignLHS { get; init; } = false;
        internal bool IsObjInAssignLHS { get; init; } = false;
        internal bool IsInCondExp { get; init; } = false;
        internal bool IsTopLevelStatement { get; init; } = false;

        internal string LhsType { get; init; } = string.Empty;

        public ParseContextInfo()
        { }
        public ParseContextInfo(ParseContextInfo inherit)
        {
            Usage = inherit.Usage;
            IsInAssignLHS = inherit.IsInAssignLHS;
            IsObjInAssignLHS = inherit.IsObjInAssignLHS;
            IsInCondExp = inherit.IsInCondExp;

            LhsType = inherit.LhsType;
        }
    }
    internal sealed class CaseInfo
    {
        internal Dsl.ISyntaxComponent? CaseBlock = null;
        internal List<StringBuilder> Exps = new List<StringBuilder>();
        internal List<Dsl.ISyntaxComponent> Statements = new List<Dsl.ISyntaxComponent>();
    }
}
