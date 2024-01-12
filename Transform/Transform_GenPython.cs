using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.IO;
using System.Text;
using System.Security.AccessControl;
using System.Security.Cryptography.X509Certificates;
using System.Reflection;
using System.Reflection.Metadata;
using System.Xml.Linq;
using Hlsl2Numpy.Analysis;

namespace Hlsl2Numpy
{
    internal partial class ProgramTransform
    {
        private static void GenFuncHead(StringBuilder funcSb, int indent, string signature, FuncInfo funcInfo)
        {
            if (funcInfo.CodeGenerateEnabled) {
                string fullFuncName = string.Format("{0}{1}", signature, s_IsVectorizing ? c_VectorialNameSuffix + funcInfo.GetVecNoTag() : string.Empty);
                AddUsingFuncOrApi(fullFuncName);

                funcSb.Append("{0}def {1}(", Literal.GetIndentString(indent), fullFuncName);
                for (int ix = 0; ix < funcInfo.Params.Count; ++ix) {
                    if (ix > 0)
                        funcSb.Append(", ");
                    funcSb.Append("{0}", funcInfo.Params[ix].Name);
                }
                funcSb.Append("):");
                funcSb.AppendLine();
            }
        }
        private static void GenFuncPass(StringBuilder funcSb, int indent, FuncInfo funcInfo)
        {
            if (funcInfo.CodeGenerateEnabled) {
                funcSb.Append("{0}pass", Literal.GetIndentString(indent));
                funcSb.AppendLine();
            }
        }
        private static void GenFuncUsingGlobals(StringBuilder funcSb, int indent, FuncInfo funcInfo)
        {
            var globals = funcInfo.UsingGlobals;
            if (funcInfo.CodeGenerateEnabled && globals.Count > 0) {
                funcSb.Append("{0}global ", Literal.GetIndentString(indent));
                for (int ix = 0; ix < globals.Count; ++ix) {
                    if (ix > 0)
                        funcSb.Append(", ");
                    funcSb.Append(globals[ix]);
                }
                funcSb.AppendLine();
            }
        }
        private static void GenVoidFuncReturn(StringBuilder funcSb, int indent, Dsl.ISyntaxComponent? lastStm, FuncInfo funcInfo, Dsl.ISyntaxComponent syntax)
        {
            if (funcInfo.CodeGenerateEnabled && funcInfo.IsVoid() && funcInfo.HasInOutOrOutParams) {
                if (null == lastStm) {
                    funcSb.Append("{0}return ", Literal.GetIndentString(indent));
                    for (int ix = 0; ix < funcInfo.InOutOrOutParams.Count; ++ix) {
                        var p = funcInfo.InOutOrOutParams[ix];
                        if (ix > 0)
                            funcSb.Append(", ");
                        GenBroadcast(funcSb, p.Type, p.Name, "True", syntax);
                    }
                    funcSb.AppendLine();
                }
                else {
                    var retFunc = lastStm as Dsl.FunctionData;
                    if (null == retFunc || retFunc.GetId() != "return" && retFunc.GetId() != "<-") {
                        funcSb.Append("{0}return ", Literal.GetIndentString(indent));
                        for (int ix = 0; ix < funcInfo.InOutOrOutParams.Count; ++ix) {
                            var p = funcInfo.InOutOrOutParams[ix];
                            if (ix > 0)
                                funcSb.Append(", ");
                            GenBroadcast(funcSb, p.Type, p.Name, "True", syntax);
                        }
                        funcSb.AppendLine();
                    }
                }
            }
        }

        internal static void GenDeclVar(StringBuilder sb, int indent, VarInfo varInfo, bool forceNullInit, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                bool existsSetObj = ExistsSetObj(varInfo.Name);
                sb.Append(varInfo.Name);
                sb.Append(" = ");
                if (forceNullInit)
                    sb.AppendLine("None");
                else
                    sb.AppendLine(GetDefaultValueInPython(varInfo.Type, existsSetObj ? "True" : "False", syntax));
            }
        }
        private static void GenDeclVarName(StringBuilder sb, int indent, string varName)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append(varName);
            }
        }
        private static void GenConstAssignExp(StringBuilder sb, int indent, string vname, string val)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append("(");
                sb.Append(vname);
                sb.Append(" := ");
                sb.Append(val);
                sb.Append(")");
            }
        }
        private static void GenIncInExp(StringBuilder sb, int indent, StringBuilder lhsBuilder, StringBuilder argBuilder, string opdType)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append("(");
                sb.Append(lhsBuilder);
                sb.Append(" := ");
                string fn = "h_inc";
                string fullFuncName = fn + GetFuncArgsTag(fn, opdType);
                AddUsingFuncOrApi(fullFuncName);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(argBuilder);
                sb.Append(")");
                sb.Append(")");
            }
        }
        private static void GenDecInExp(StringBuilder sb, int indent, StringBuilder lhsBuilder, StringBuilder argBuilder, string opdType)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append("(");
                sb.Append(lhsBuilder);
                sb.Append(" := ");
                string fn = "h_dec";
                string fullFuncName = fn + GetFuncArgsTag(fn, opdType);
                AddUsingFuncOrApi(fullFuncName);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(argBuilder);
                sb.Append(")");
                sb.Append(")");
            }
        }
        private static void GenUnaryOp(StringBuilder sb, int indent, string op, StringBuilder argBuilder, string opdType)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                s_OperatorNames.TryGetValue(op, out var opn);
                Debug.Assert(null != opn);
                string fullFuncName = opn + GetFuncArgsTag(opn, opdType);
                AddUsingFuncOrApi(fullFuncName);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(argBuilder);
                sb.Append(")");
            }
        }
        private static void GenCompoundAssignInExp(StringBuilder sb, int indent, string op, StringBuilder lhsBuilder, StringBuilder arg1Builder, StringBuilder arg2Builder,
            string varType, string opd1Type, string opd2Type, string oprType, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                s_OperatorNames.TryGetValue(op, out var opn);
                Debug.Assert(null != opn);
                sb.Append("(");
                sb.Append(lhsBuilder);
                sb.Append(" := ");
                bool needCast = false;
                if (varType != oprType) {
                    needCast = true;
                    GenCastBegin(sb, varType, oprType, "False", syntax);
                }
                string fullFuncName = opn + GetFuncArgsTag(opn, opd1Type, opd2Type);
                AddUsingFuncOrApi(fullFuncName);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(arg1Builder);
                sb.Append(", ");
                sb.Append(arg2Builder);
                sb.Append(")");
                if (needCast) {
                    GenCastEnd(sb);
                }
                sb.Append(")");
            }
        }
        private static void GenAssignInExp(StringBuilder sb, int indent, StringBuilder lhsBuilder, StringBuilder argBuilder, string varType, string opdType, string vname, string rhsName, bool rhsIsVarValRef, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append("(");
                sb.Append(lhsBuilder);
                sb.Append(" := ");
                GenAssignRHS(sb, argBuilder, varType, opdType, vname, rhsName, rhsIsVarValRef, syntax);
                sb.Append(")");
            }
        }
        private static void GenBinaryOp(StringBuilder sb, int indent, string op, StringBuilder arg1Builder, StringBuilder arg2Builder, string opd1Type, string opd2Type)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                s_OperatorNames.TryGetValue(op, out var opn);
                Debug.Assert(null != opn);
                string fullFuncName = opn + GetFuncArgsTag(opn, opd1Type, opd2Type);
                AddUsingFuncOrApi(fullFuncName);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(arg1Builder);
                sb.Append(", ");
                sb.Append(arg2Builder);
                sb.Append(")");
            }
        }
        private static string GenMemberCompoundSet(StringBuilder sb, int indent, string op, StringBuilder objBuilder, StringBuilder memberBuilder, StringBuilder arg1Builder, StringBuilder arg2Builder,
            string objType, string mtype, string opd1Type, string opd2Type, string oprType, bool needBroadcast, bool genGetOutAndEndRet, string outVar, bool isStatement, Dsl.ISyntaxComponent syntax)
        {
            string retVar = string.Empty;
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                if (needBroadcast) {
                    if (isStatement) {
                        sb.Append("_, ");
                        sb.Append(TryRenameTemporary(outVar));
                        sb.Append(" = ");
                    }
                    else {
                        GenGetRetValBegin("_obj_cset_", sb, out retVar);
                    }
                }
                string struName = GetTypeNoVecPrefix(objType);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    string mname = memberBuilder.ToString();
                    if (struInfo.FieldName2Indexes.TryGetValue(mname, out var index)) {
                        string funcName;
                        if (needBroadcast) {
                            funcName = struName + "_" + mname + "_set_and_broadcast";
                            GenStructSetAndBroadcast(funcName, objType, index, syntax);
                        }
                        else {
                            funcName = struName + "_" + mname + "_set";
                            GenStructSet(funcName, objType, index, syntax);
                        }
                        sb.Append(funcName);
                        sb.Append("(");
                        sb.Append(objBuilder);
                        sb.Append(", ");
                        s_OperatorNames.TryGetValue(op, out var opn);
                        Debug.Assert(null != opn);
                        bool cast = false;
                        if (mtype != oprType) {
                            cast = true;
                            GenCastBegin(sb, mtype, oprType, "False", syntax);
                        }
                        string fullFuncName = opn + GetFuncArgsTag(opn, opd1Type, opd2Type);
                        AddUsingFuncOrApi(fullFuncName);
                        sb.Append(fullFuncName);
                        sb.Append("(");
                        sb.Append(arg1Builder);
                        sb.Append(", ");
                        sb.Append(arg2Builder);
                        sb.Append(")");
                        if (cast)
                            GenCastEnd(sb);
                        sb.Append(")");
                    }
                }
                else {
                    string typeWithoutSuffix = GetTypeRemoveSuffix(objType);
                    if (IsBaseType(typeWithoutSuffix)) {
                        var nameSb = NewStringBuilder();
                        nameSb.Append(memberBuilder);
                        string m = SwizzleConvert(nameSb.ToString());
                        nameSb.Length = 0;
                        nameSb.Append("swizzle_set");
                        if (needBroadcast)
                            nameSb.Append("_and_broadcast");
                        nameSb.Append(GetSuffixInfoFuncArgTag(objType));
                        nameSb.Append("_");
                        nameSb.Append(m);
                        string funcName = nameSb.ToString();
                        AddUsingFuncOrApi(funcName);
                        sb.Append(funcName);
                        sb.Append("(");
                        sb.Append(objBuilder);
                        sb.Append(", ");
                        s_OperatorNames.TryGetValue(op, out var opn);
                        Debug.Assert(null != opn);
                        bool cast = false;
                        if (mtype != oprType) {
                            cast = true;
                            GenCastBegin(sb, mtype, oprType, "False", syntax);
                        }
                        string fullFuncName = opn + GetFuncArgsTag(opn, opd1Type, opd2Type);
                        AddUsingFuncOrApi(fullFuncName);
                        sb.Append(fullFuncName);
                        sb.Append("(");
                        sb.Append(arg1Builder);
                        sb.Append(", ");
                        sb.Append(arg2Builder);
                        sb.Append(")");
                        if (cast)
                            GenCastEnd(sb);
                        sb.Append(")");
                        RecycleStringBuilder(nameSb);
                    }
                    else {
                        var nameSb = NewStringBuilder();
                        nameSb.Append(objType);
                        nameSb.Append("_");
                        nameSb.Append(memberBuilder);
                        nameSb.Append("_set");
                        if (needBroadcast)
                            nameSb.Append("_and_broadcast");
                        string funcName = nameSb.ToString();
                        AddUsingFuncOrApi(funcName);
                        sb.Append(funcName);
                        sb.Append("(");
                        sb.Append(objBuilder);
                        sb.Append(", ");
                        s_OperatorNames.TryGetValue(op, out var opn);
                        Debug.Assert(null != opn);
                        bool cast = false;
                        if (mtype != oprType) {
                            cast = true;
                            GenCastBegin(sb, mtype, oprType, "False", syntax);
                        }
                        string fullFuncName = opn + GetFuncArgsTag(opn, opd1Type, opd2Type);
                        AddUsingFuncOrApi(fullFuncName);
                        sb.Append(fullFuncName);
                        sb.Append("(");
                        sb.Append(arg1Builder);
                        sb.Append(", ");
                        sb.Append(arg2Builder);
                        sb.Append(")");
                        if (cast)
                            GenCastEnd(sb);
                        sb.Append(")");
                        RecycleStringBuilder(nameSb);
                    }
                }
                if (genGetOutAndEndRet) {
                    GenGetOutParamAndEndGetRetVal(outVar, 1, retVar, sb);
                }
            }
            return retVar;
        }
        private static string GenMemberSet(StringBuilder sb, int indent, StringBuilder objBuilder, StringBuilder memberBuilder, StringBuilder rhsBuilder,
            string objType, string mtype, string rhsType, bool rhsIsVarValRef, bool needBroadcast, bool genGetOutAndEndRet, string outVar, bool isStatement, Dsl.ISyntaxComponent syntax)
        {
            string retVar = string.Empty;
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                if (needBroadcast) {
                    if (isStatement) {
                        sb.Append("_, ");
                        sb.Append(TryRenameTemporary(outVar));
                        sb.Append(" = ");
                    }
                    else {
                        GenGetRetValBegin("_obj_set_", sb, out retVar);
                    }
                }
                string struName = GetTypeNoVecPrefix(objType);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    string mname = memberBuilder.ToString();
                    if (struInfo.FieldName2Indexes.TryGetValue(mname, out var index)) {
                        string funcName;
                        if (needBroadcast) {
                            funcName = struName + "_" + mname + "_set_and_broadcast";
                            GenStructSetAndBroadcast(funcName, objType, index, syntax);
                        }
                        else {
                            funcName = struName + "_" + mname + "_set";
                            GenStructSet(funcName, objType, index, syntax);
                        }
                        sb.Append(funcName);
                        sb.Append("(");
                        sb.Append(objBuilder);
                        sb.Append(", ");
                        bool cast = false;
                        bool needCopy = false;
                        if (!IsSameType(mtype, rhsType)) {
                            cast = true;
                            GenCastBegin(sb, mtype, rhsType, "False", syntax);
                        }
                        if (!cast && rhsIsVarValRef) {
                            needCopy = GenVecCopyBegin(sb, rhsType, syntax);
                        }
                        sb.Append(rhsBuilder);
                        if (cast)
                            GenCastEnd(sb);
                        else if (needCopy)
                            GenVecCopyEnd(sb);
                        sb.Append(")");
                    }
                }
                else {
                    string typeWithoutSuffix = GetTypeRemoveSuffix(objType);
                    if (IsBaseType(typeWithoutSuffix)) {
                        var nameSb = NewStringBuilder();
                        nameSb.Append(memberBuilder);
                        string m = SwizzleConvert(nameSb.ToString());
                        nameSb.Length = 0;
                        nameSb.Append("swizzle_set");
                        if (needBroadcast)
                            nameSb.Append("_and_broadcast");
                        nameSb.Append(GetSuffixInfoFuncArgTag(objType));
                        nameSb.Append("_");
                        nameSb.Append(m);
                        string fullFuncName = nameSb.ToString();
                        AddUsingFuncOrApi(fullFuncName);
                        sb.Append(fullFuncName);
                        sb.Append("(");
                        sb.Append(objBuilder);
                        sb.Append(", ");
                        bool cast = false;
                        bool needCopy = false;
                        if (!IsSameType(mtype, rhsType)) {
                            cast = true;
                            GenCastBegin(sb, mtype, rhsType, "False", syntax);
                        }
                        if (!cast && rhsIsVarValRef) {
                            needCopy = GenVecCopyBegin(sb, rhsType, syntax);
                        }
                        sb.Append(rhsBuilder);
                        if (cast)
                            GenCastEnd(sb);
                        else if (needCopy)
                            GenVecCopyEnd(sb);
                        sb.Append(")");
                        RecycleStringBuilder(nameSb);
                    }
                    else {
                        var nameSb = NewStringBuilder();
                        nameSb.Append(objType);
                        nameSb.Append("_");
                        nameSb.Append(memberBuilder);
                        nameSb.Append("_set");
                        if (needBroadcast)
                            nameSb.Append("_and_broadcast");
                        string funcName = nameSb.ToString();
                        AddUsingFuncOrApi(funcName);
                        sb.Append(funcName);
                        sb.Append("(");
                        sb.Append(objBuilder);
                        sb.Append(", ");
                        bool cast = false;
                        bool needCopy = false;
                        if (!IsSameType(mtype, rhsType)) {
                            cast = true;
                            GenCastBegin(sb, mtype, rhsType, "False", syntax);
                        }
                        if (!cast && rhsIsVarValRef) {
                            needCopy = GenVecCopyBegin(sb, rhsType, syntax);
                        }
                        sb.Append(rhsBuilder);
                        if (cast)
                            GenCastEnd(sb);
                        else if (needCopy)
                            GenVecCopyEnd(sb);
                        sb.Append(")");
                        RecycleStringBuilder(nameSb);
                    }
                }
                if (genGetOutAndEndRet) {
                    GenGetOutParamAndEndGetRetVal(outVar, 1, retVar, sb);
                }
            }
            return retVar;
        }
        private static void GenMemberGet(StringBuilder sb, int indent, StringBuilder objBuilder, StringBuilder memberBuilder, string objType, string mname, int fieldIndex, StructInfo? struInfo, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                if (fieldIndex >= 0 && null != struInfo) {
                    string struName = struInfo.Name;
                    string funcName = struName + "_" + mname;
                    GenStructGet(funcName, objType, fieldIndex, syntax);
                    sb.Append(funcName);
                    sb.Append("(");
                    sb.Append(objBuilder);
                    sb.Append(")");
                }
                else {
                    string typeWithoutSuffix = GetTypeRemoveSuffix(objType);
                    if (IsBaseType(typeWithoutSuffix)) {
                        var nameSb = NewStringBuilder();
                        nameSb.Append(memberBuilder);
                        string m = SwizzleConvert(nameSb.ToString());
                        nameSb.Length = 0;
                        nameSb.Append("swizzle");
                        nameSb.Append(GetSuffixInfoFuncArgTag(objType));
                        nameSb.Append("_");
                        nameSb.Append(m);
                        string fullFuncName = nameSb.ToString();
                        AddUsingFuncOrApi(fullFuncName);
                        sb.Append(fullFuncName);
                        sb.Append("(");
                        sb.Append(objBuilder);
                        sb.Append(")");
                        RecycleStringBuilder(nameSb);
                    }
                    else {
                        var nameSb = NewStringBuilder();
                        nameSb.Append(objType);
                        nameSb.Append("_");
                        nameSb.Append(memberBuilder);
                        string funcName = nameSb.ToString();
                        AddUsingFuncOrApi(funcName);
                        sb.Append(funcName);
                        sb.Append("(");
                        sb.Append(objBuilder);
                        sb.Append(")");
                        RecycleStringBuilder(nameSb);
                    }
                }
            }
        }
        private static string GenCompoundElementSet(StringBuilder sb, int indent, string op, StringBuilder objBuilder, StringBuilder argBuilder, StringBuilder arg1Builder, StringBuilder arg2Builder,
            string objType, string argType, string lhsType, string opd1Type, string opd2Type, string resType, bool needBroadcast, bool genGetOutAndEndRet, string outVar, bool isStatement, Dsl.ISyntaxComponent syntax)
        {
            string retVar = string.Empty;
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                if (needBroadcast) {
                    if (isStatement) {
                        sb.Append("_, ");
                        sb.Append(TryRenameTemporary(outVar));
                        sb.Append(" = ");
                    }
                    else {
                        GenGetRetValBegin("_arr_cset_", sb, out retVar);
                    }
                }

                s_OperatorNames.TryGetValue(op, out var opn);
                Debug.Assert(null != opn);

                var nameSb = NewStringBuilder();
                nameSb.Append("array_set");
                if (needBroadcast)
                    nameSb.Append("_and_broadcast");
                nameSb.Append(GetSuffixInfoFuncArgTag(objType));
                nameSb.Append(GetSuffixInfoFuncArgTag(argType));
                string funcName = nameSb.ToString();
                if (needBroadcast)
                    GenOrRecordArraySetAndBroadcast(funcName, objType, argType, syntax);
                else
                    GenOrRecordArraySet(funcName, objType, argType, syntax);
                sb.Append(funcName);
                sb.Append("(");
                sb.Append(objBuilder);
                sb.Append(", ");
                sb.Append(argBuilder);
                sb.Append(", ");
                bool needCast = false;
                if (lhsType != resType) {
                    needCast = true;
                    GenCastBegin(sb, lhsType, resType, "False", syntax);
                }
                string fullFuncName = opn + GetFuncArgsTag(opn, opd1Type, opd2Type);
                AddUsingFuncOrApi(fullFuncName);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(arg1Builder);
                sb.Append(", ");
                sb.Append(arg2Builder);
                sb.Append(")");
                if (needCast) {
                    GenCastEnd(sb);
                }
                sb.Append(")");
                if (genGetOutAndEndRet) {
                    GenGetOutParamAndEndGetRetVal(outVar, 1, retVar, sb);
                }
            }
            return retVar;
        }
        private static string GenElementSet(StringBuilder sb, int indent, StringBuilder objBuilder, StringBuilder argBuilder, StringBuilder varBuilder, StringBuilder rhsBuilder,
            string objType, string argType, string lhsType, string rhsType, bool rhsIsVarValRef, bool needBroadcast, bool genGetOutAndEndRet, string outVar, bool isStatement, Dsl.ISyntaxComponent syntax)
        {
            string retVar = string.Empty;
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                if (needBroadcast) {
                    if (isStatement) {
                        sb.Append("_, ");
                        sb.Append(TryRenameTemporary(outVar));
                        sb.Append(" = ");
                    }
                    else {
                        GenGetRetValBegin("_arr_set_", sb, out retVar);
                    }
                }

                var nameSb = NewStringBuilder();
                nameSb.Append("array_set");
                if (needBroadcast)
                    nameSb.Append("_and_broadcast");
                nameSb.Append(GetSuffixInfoFuncArgTag(objType));
                nameSb.Append(GetSuffixInfoFuncArgTag(argType));
                string funcName = nameSb.ToString();
                if (needBroadcast)
                    GenOrRecordArraySetAndBroadcast(funcName, objType, argType, syntax);
                else
                    GenOrRecordArraySet(funcName, objType, argType, syntax);
                sb.Append(funcName);
                sb.Append("(");
                sb.Append(objBuilder);
                sb.Append(", ");
                sb.Append(argBuilder);
                sb.Append(", ");

                bool needCast = false;
                bool needCopy = false;
                if (!IsSameType(lhsType, rhsType)) {
                    needCast = true;
                    GenCastBegin(sb, lhsType, rhsType, "False", syntax);
                }
                if (!needCast && rhsIsVarValRef) {
                    needCopy = GenVecCopyBegin(sb, rhsType, syntax);
                }
                sb.Append(rhsBuilder);
                if (needCast) {
                    GenCastEnd(sb);
                }
                else if (needCopy) {
                    GenVecCopyEnd(sb);
                }
                sb.Append(")");
                if (genGetOutAndEndRet) {
                    GenGetOutParamAndEndGetRetVal(outVar, 1, retVar, sb);
                }
                RecycleStringBuilder(nameSb);
            }
            return retVar;
        }
        private static void GenArrayName(StringBuilder sb, int indent, StringBuilder objBuilder, StringBuilder argBuilder)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append(objBuilder);
                sb.Append("_x");
                sb.Append(argBuilder);
            }
        }
        private static void GenElementGet(StringBuilder sb, int indent, StringBuilder objBuilder, StringBuilder argBuilder, string objType, string argType, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                var nameSb = NewStringBuilder();
                nameSb.Append("array_get");
                nameSb.Append(GetSuffixInfoFuncArgTag(objType));
                nameSb.Append(GetSuffixInfoFuncArgTag(argType));

                string funcName = nameSb.ToString();
                GenOrRecordArrayGet(funcName, objType, argType, syntax);
                sb.Append(funcName);
                sb.Append("(");
                sb.Append(objBuilder);
                sb.Append(", ");
                sb.Append(argBuilder);
                sb.Append(")");
                RecycleStringBuilder(nameSb);
            }
        }
        private static void GenInitListBegin(StringBuilder sb, int indent, string resultType, bool isStruct, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                if (!isStruct) {
                    GenArrayInitBegin(sb, resultType, syntax);
                }
                sb.Append("[");
            }
        }
        private static void GenInitListEnd(StringBuilder sb, bool isStruct)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("]");
                if (!isStruct)
                    GenArrayInitEnd(sb);
            }
        }
        private static void GenFuncCall(StringBuilder sb, int indent, StringBuilder objBuilder, IList<StringBuilder> argBuilders, string objType, string funcName, string resultType,
            IList<string> argTypes, IList<bool> argIsVarRefs, IList<string> argNameOrConsts, Dsl.FunctionData func, FuncInfo? funcInfo, bool isVec)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                string baseType = string.Empty;
                bool isBaseTypeCtor = false;
                bool isCommaExp = false;
                var curFunc = CurFuncInfo();
                if (null != funcInfo) {
                    var nameSb = NewStringBuilder();
                    nameSb.Append(funcInfo.Signature);
                    if (isVec) {
                        nameSb.Append(c_VectorialNameSuffix);
                        nameSb.Append(funcInfo.GetVecNoTag());
                    }
                    string fullFuncName = nameSb.ToString();
                    RecycleStringBuilder(nameSb);
                    sb.Append(fullFuncName);

                    AddUsingFuncOrApi(fullFuncName);
                }
                else {
                    if (func.IsHighOrder) {
                        string objFuncName = objType + "_" + funcName;
                        string fullFuncName = objFuncName + GetFuncArgsTag(objFuncName, argTypes);
                        sb.Append(fullFuncName);

                        AddUsingFuncOrApi(fullFuncName);
                    }
                    else if (func.HaveId()) {
                        baseType = GetTypeRemoveSuffix(funcName);
                        if (IsBaseType(baseType)) {
                            isBaseTypeCtor = argTypes.Count > 1;

                            string fullFuncName;
                            if (isBaseTypeCtor) {
                                fullFuncName = GetBaseTypeCtorSig(funcName, argTypes);
                            }
                            else {
                                fullFuncName = GetCastFuncSig(funcName, argTypes[0], out var isBroadcast);
                            }
                            sb.Append(fullFuncName);

                            AddUsingFuncOrApi(fullFuncName);
                        }
                        else {
                            string hlslFuncName;
                            if (funcName == "mul") {
                                hlslFuncName = "h_matmul";
                            }
                            else {
                                hlslFuncName = "h_" + funcName;
                            }
                            string fullFuncName = hlslFuncName + GetFuncArgsTag(hlslFuncName, argTypes);
                            sb.Append(fullFuncName);

                            AddUsingFuncOrApi(fullFuncName);
                        }
                    }
                    else {
                        isCommaExp = true;
                        sb.Append("tuple_get_lastval");
                        sb.Append("(");
                    }
                }
                sb.Append("(");
                if (func.IsHighOrder) {
                    GenAppend(sb, objBuilder);
                    if (argBuilders.Count > 0)
                        GenAppend(sb, ", ");
                }
                for (int ix = 0; ix < argBuilders.Count; ++ix) {
                    var argBuilder = argBuilders[ix];
                    if (ix > 0)
                        sb.Append(", ");
                    string argType = argTypes[ix];
                    bool argIsVarRef = argIsVarRefs[ix];
                    string argNameOrConst = argNameOrConsts[ix];
                    bool cast = false;
                    bool copy = false;
                    if (null != funcInfo) {
                        var param = funcInfo.Params[ix];
                        bool needCopy = argIsVarRef && funcInfo.ModifiedParams.Contains(param.Name);
                        if (param.Type != argType) {
                            cast = true;
                            string ptype = param.Type;
                            GenCastBegin(sb, ptype, argType, needCopy ? "True" : "False", func);
                        }
                        else if (needCopy) {
                            copy = GenVecCopyBegin(sb, argType, func);
                        }
                    }
                    else if (isBaseTypeCtor) {
                        var at = GetTypeRemoveSuffix(argType);
                        var atNoVectorize = GetTypeNoVec(at);
                        var atp = GetTypeSuffix(argType);
                        if (baseType != atNoVectorize) {
                            cast = true;
                            string tmptype = baseType + atp;
                            GenCastBegin(sb, tmptype, argType, "False", func);
                        }
                    }
                    sb.Append(argBuilder.ToString());
                    if (cast) {
                        GenCastEnd(sb);
                    }
                    else if (copy) {
                        GenVecCopyEnd(sb);
                    }
                }
                if (null != funcInfo) {
                    for (int ix = func.GetParamNum(); ix < funcInfo.Params.Count; ++ix) {
                        if (ix > 0)
                            sb.Append(", ");
                        var defVal = funcInfo.Params[ix].DefaultValueSyntax;
                        var constDefVal = funcInfo.Params[ix].InitOrDefValueConst;
                        if (null != defVal) {
                            if (!string.IsNullOrEmpty(constDefVal)) {
                                sb.Append(constDefVal);
                            }
                            else {
                                var tempSb = NewStringBuilder();
                                var tempSi = new SemanticInfo(true);
                                TransformSyntax(defVal, tempSb, 0, ref tempSi);
                                var cres = tempSi.NameOrConst;
                                if (string.IsNullOrEmpty(cres)) {
                                    sb.Append(tempSb);
                                }
                                else {
                                    funcInfo.Params[ix].InitOrDefValueConst = cres;
                                    sb.Append(cres);
                                }
                                RecycleStringBuilder(tempSb);
                            }
                        }
                        else {
                            Console.WriteLine("func '{0}'s arguments dismatch, signature: {1}, line: {2}, vectorizing: {3}", funcInfo.Name, funcInfo.Signature, func.GetLine(), s_IsVectorizing);
                        }
                    }
                }
                sb.Append(")");
                if (isCommaExp) {
                    sb.Append(")");
                }
            }
        }
        private static void GenCast(StringBuilder sb, int indent, StringBuilder argBuilder, string resultType, string argType, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                string fn = GetCastFuncSig(resultType, argType, out var isBroadcast);
                GenOrRecordCastFunc(fn, resultType, argType, isBroadcast, syntax);
                sb.Append(fn);
                sb.Append("(");
                sb.Append(argBuilder);
                sb.Append(")");
            }
        }
        private static void GenCondExp(StringBuilder sb, int indent, StringBuilder arg1Builder, StringBuilder arg2Builder, StringBuilder arg3Builder, string opd1Type, string opd2Type, string opd3Type, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                string funcName = "h_where";
                string fullFuncName = funcName + GetFuncArgsTag(funcName, opd1Type, opd2Type, opd3Type);
                GenOrRecordWhereFunc(fullFuncName, opd1Type, opd2Type, opd3Type, syntax);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(arg1Builder);
                sb.Append(", ");
                sb.Append(arg2Builder);
                sb.Append(", ");
                sb.Append(arg3Builder);
                sb.Append(")");
            }
        }
        private static void GenStringConst(StringBuilder sb, int indent, string val)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                sb.Append('"');
                sb.Append(val);
                sb.Append('"');
            }
        }
        private static void GenNumberConst(StringBuilder sb, int indent, string val)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                sb.Append(val);
            }
        }
        private static void GenBoolConstOrVarOrName(StringBuilder sb, int indent, string id, bool isBoolConstOrVar)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                if (IsHlslBool(id))
                    sb.Append(ConstToPython(id));
                else {
                    if (s_IsVectorizing && isBoolConstOrVar)
                        sb.Append(TryRenameTemporary(id));
                    else
                        sb.Append(id);
                }
            }
        }
        private static void GenAssignStatement(StringBuilder sb, int indent, StringBuilder lhsBuilder, StringBuilder rhsBuilder, string lhsType, string rhsType, string vname, string rhsName, bool rhsIsVarValRef, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                sb.Append(lhsBuilder);
                sb.Append(" = ");
                GenAssignRHS(sb, rhsBuilder, lhsType, rhsType, vname, rhsName, rhsIsVarValRef, syntax);
                sb.AppendLine();
            }
        }
        private static void GenCompoundAssignStatement(StringBuilder sb, int indent, string op, StringBuilder lhsBuilder, StringBuilder arg1Builder, StringBuilder arg2Builder, string lhsType, string opd1Type, string opd2Type, string oprType, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                s_OperatorNames.TryGetValue(op, out var opn);
                Debug.Assert(null != opn);
                sb.Append(lhsBuilder);
                sb.Append(" = ");
                bool needCast = false;
                if (lhsType != oprType) {
                    needCast = true;
                    GenCastBegin(sb, lhsType, oprType, "False", syntax);
                }
                string fullFuncName = opn + GetFuncArgsTag(opn, opd1Type, opd2Type);
                AddUsingFuncOrApi(fullFuncName);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(arg1Builder);
                sb.Append(", ");
                sb.Append(arg2Builder);
                sb.Append(")");
                if (needCast) {
                    GenCastEnd(sb);
                }
                sb.AppendLine();
            }
        }
        private static void GenConstAssign(StringBuilder sb, int indent, string vname, string val)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                sb.Append(vname);
                sb.Append(" = ");
                sb.AppendLine(val);
            }
        }
        private static void GenIncStatement(StringBuilder sb, int indent, StringBuilder varBuilder, StringBuilder argBuilder, string varType)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                sb.Append(varBuilder);
                sb.Append(" = ");
                string fn = "h_inc";
                string fullFuncName = fn + GetFuncArgsTag(fn, varType);
                AddUsingFuncOrApi(fullFuncName);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(argBuilder);
                sb.AppendLine(")");
            }
        }
        private static void GenDecStatement(StringBuilder sb, int indent, StringBuilder varBuilder, StringBuilder argBuilder, string varType)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

                sb.Append(varBuilder);
                sb.Append(" = ");
                string fn = "h_dec";
                string fullFuncName = fn + GetFuncArgsTag(fn, varType);
                AddUsingFuncOrApi(fullFuncName);
                sb.Append(fullFuncName);
                sb.Append("(");
                sb.Append(argBuilder);
                sb.AppendLine(")");
            }
        }
        private static void GenReturnStatement(StringBuilder sb, int indent, StringBuilder argBuilder, string argType, Dsl.ISyntaxComponent? retVal, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("{0}return", Literal.GetIndentString(indent));
                if (null != retVal) {
                    sb.Append(" ");
                    var funcInfo = CurFuncInfo();
                    if (null != funcInfo) {
                        bool needCast = false;
                        string rtype = funcInfo.RetInfo.Type;
                        if (!IsSameType(rtype, argType)) {
                            needCast = true;
                            if (s_IsVectorizing && IsTypeVec(rtype) && !IsTypeVec(argType)) {
                                bool find = false;
                                foreach (var p in funcInfo.Params) {
                                    if (!p.IsOut && IsTypeVec(p.Type)) {
                                        find = true;
                                        break;
                                    }
                                }
                                if (find)
                                    GenCastBegin(sb, rtype, argType, "True", syntax);
                                else
                                    GenCastBegin(sb, rtype, argType, "True", syntax);
                            }
                            else {
                                GenCastBegin(sb, rtype, argType, "True", syntax);
                            }
                        }
                        sb.Append(argBuilder);
                        if (needCast) {
                            GenCastEnd(sb);
                        }
                        if (funcInfo.HasInOutOrOutParams) {
                            bool hasRet = !funcInfo.IsVoid();
                            for (int ix = 0; ix < funcInfo.InOutOrOutParams.Count; ++ix) {
                                var p = funcInfo.InOutOrOutParams[ix];
                                if (hasRet || ix > 0)
                                    sb.Append(", ");
                                GenBroadcast(sb, p.Type, p.Name, "True", syntax);
                            }
                        }
                    }
                    else {
                        sb.Append(argBuilder);
                    }
                }
                sb.AppendLine();
            }
        }
        private static void GenVecIfWithElseHead(StringBuilder sb, int indent, string varPrefix, int ix, string type, StringBuilder argBuilder, out string ifExpVar)
        {
            if (CurFuncCodeGenerateEnabled()) {
                ifExpVar = varPrefix + "exp_" + ix;
                sb.Append("{0}{1} = ", Literal.GetIndentString(indent), ifExpVar);
                sb.Append(argBuilder);
                sb.AppendLine();
                string fn = "any_ifexp_true";
                sb.AppendLine("{0}if {1}{2}({3}):", Literal.GetIndentString(indent), fn, GetSimpleFuncArgTag(type), ifExpVar);
            }
            else {
                ifExpVar = string.Empty;
            }
        }
        private static void GenVecIfWithoutElseHead(StringBuilder sb, int indent, string varPrefix, string type, StringBuilder argBuilder, out string ifExpVar)
        {
            if (CurFuncCodeGenerateEnabled()) {
                ifExpVar = varPrefix + "exp";
                sb.Append("{0}{1} = ", Literal.GetIndentString(indent), ifExpVar);
                sb.Append(argBuilder);
                sb.AppendLine();
                string fn = "any_ifexp_true";
                sb.AppendLine("{0}if {1}{2}({3}):", Literal.GetIndentString(indent), fn, GetSimpleFuncArgTag(type), ifExpVar);
            }
            else {
                ifExpVar = string.Empty;
            }
        }
        private static void GenVecElseHead(StringBuilder sb, int indent, List<string> expVars, List<string> expTypes)
        {
            if (CurFuncCodeGenerateEnabled()) {
                var orBuilder = NewStringBuilder();
                string type = VecInferAndGenOr(expVars, expTypes, 0, orBuilder);
                string fn = "not_all_ifexp_true";
                sb.AppendLine("{0}if {1}{2}({3}):", Literal.GetIndentString(indent), fn, GetSimpleFuncArgTag(type), orBuilder.ToString());
                RecycleStringBuilder(orBuilder);
            }
        }
        private static void GenVecElseAllFalseHead(StringBuilder sb, int indent, List<string> expVars, List<string> expTypes)
        {
            if (CurFuncCodeGenerateEnabled()) {
                var orBuilder = NewStringBuilder();
                string type = VecInferAndGenOr(expVars, expTypes, 0, orBuilder);
                string fn = "not_any_ifexp_true";
                sb.AppendLine("{0}if {1}{2}({3}):", Literal.GetIndentString(indent), fn, GetSimpleFuncArgTag(type), orBuilder.ToString());
                RecycleStringBuilder(orBuilder);
            }
        }
        private static void GenSwitchBegin(StringBuilder sb, int indent, StringBuilder argBuilder, out string switchVar)
        {
            if (CurFuncCodeGenerateEnabled()) {
                int uid = GenUniqueNumber();
                switchVar = string.Format("_switch_{0}", uid);
                sb.Append("{0}{1} = ", Literal.GetIndentString(indent), switchVar);
                sb.Append(argBuilder);
                sb.AppendLine();
                sb.AppendLine("{0}while True:", Literal.GetIndentString(indent));
            }
            else {
                switchVar = string.Empty;
            }
        }
        private static void GenSwitchEnd(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.AppendLine("break");
            }
        }
        private static void GenCaseBegin(StringBuilder sb, int indent, string switchVar, CaseInfo caseInfo, List<StringBuilder> caseExps)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("{0}if ", Literal.GetIndentString(indent));
                if (caseInfo.Exps.Count > 0) {
                    caseExps.AddRange(caseInfo.Exps);
                    for (int ix = 0; ix < caseInfo.Exps.Count; ++ix) {
                        if (ix > 0)
                            sb.Append(" or ");
                        sb.Append(switchVar);
                        sb.Append(" == ");
                        sb.Append(caseInfo.Exps[ix].ToString());
                    }
                }
                else {
                    sb.Append("True");
                }
                sb.AppendLine(":");
            }
        }
        private static void GenCaseEnd(StringBuilder sb, int indent, string switchVar, IList<StringBuilder> caseExps)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("{0}if ", Literal.GetIndentString(indent));
                for (int ix = 0; ix < caseExps.Count; ++ix) {
                    if (ix > 0)
                        sb.Append(" or ");
                    sb.Append(switchVar);
                    sb.Append(" == ");
                    sb.Append(caseExps[ix].ToString());
                }
                sb.AppendLine(":");
                ++indent;
                sb.AppendLine("{0}break", Literal.GetIndentString(indent));
                --indent;
            }
        }
        private static void GenVecSwitchHead(StringBuilder sb, int indent, StringBuilder argBuilder, out string switchVar)
        {
            if (CurFuncCodeGenerateEnabled()) {
                int uid = GenUniqueNumber();
                switchVar = string.Format("_vecswitch_{0}", uid);
                sb.Append("{0}{1} = ", Literal.GetIndentString(indent), switchVar);
                sb.Append(argBuilder);
                sb.AppendLine();
            }
            else {
                switchVar = string.Empty;
            }
        }
        private static void GenVecCaseHead(StringBuilder sb, int indent, string switchVar, string switchVarType, List<StringBuilder> caseExps)
        {
            if (CurFuncCodeGenerateEnabled()) {
                var orBuilder = NewStringBuilder();
                string type = VecInferAndGenEqualIntOr(switchVar, switchVarType, caseExps, 0, orBuilder);
                string fn = "any_ifexp_true";
                sb.AppendLine("{0}if {1}{2}({3}):", Literal.GetIndentString(indent), fn, GetSimpleFuncArgTag(type), orBuilder.ToString());
                RecycleStringBuilder(orBuilder);
            }
        }
        private static void GenVecDefaultHead(StringBuilder sb, int indent, string switchVar, string switchVarType, List<StringBuilder> caseExps)
        {
            if (CurFuncCodeGenerateEnabled()) {
                var orBuilder = NewStringBuilder();
                string type = VecInferAndGenEqualIntOr(switchVar, switchVarType, caseExps, 0, orBuilder);
                string fn = "not_all_ifexp_true";
                sb.AppendLine("{0}if {1}{2}({3}):", Literal.GetIndentString(indent), fn, GetSimpleFuncArgTag(type), orBuilder.ToString());
                RecycleStringBuilder(orBuilder);
            }
        }
        private static void GenOtherStatement(StringBuilder sb, int indent, StringBuilder stmBuilder)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append(stmBuilder);
                sb.AppendLine();
            }
        }

        private static void GenXXX(StringBuilder sb, int indent, string op, StringBuilder arg1Builder, StringBuilder arg2Builder, string opd1Type, string opd2Type, string oprType)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));

            }
        }
        private static void GenBreak(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.AppendLine("{0}break", Literal.GetIndentString(indent));
            }
        }
        private static void GenContinue(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.AppendLine("{0}continue", Literal.GetIndentString(indent));
            }
        }
        private static void GenWhile(StringBuilder sb, int indent, StringBuilder argBuilder)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append("while ");
                sb.Append(argBuilder);
                sb.AppendLine(":");
            }
        }
        private static void GenWhileTrue(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.AppendLine("while True:");
            }
        }
        private static void GenIf(StringBuilder sb, int indent, StringBuilder argBuilder)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append("if ");
                sb.Append(argBuilder);
                sb.AppendLine(":");
            }
        }
        private static void GenElif(StringBuilder sb, int indent, StringBuilder argBuilder)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append("elif ");
                sb.Append(argBuilder);
                sb.AppendLine(":");
            }
        }
        private static void GenElse(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.AppendLine("{0}else:", Literal.GetIndentString(indent));
            }
        }
        private static void GenIfNot(StringBuilder sb, int indent, StringBuilder argBuilder)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
                sb.Append("if not ");
                sb.Append(argBuilder);
                sb.AppendLine(":");
            }
        }
        private static void GenIfTrue(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.AppendLine("{0}if True:", Literal.GetIndentString(indent));
            }
        }
        private static void GenPass(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.AppendLine("{0}pass", Literal.GetIndentString(indent));
            }
        }
        private static void GenTry(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.AppendLine("{0}try:", Literal.GetIndentString(indent));
            }
        }
        private static void GenFinally(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.AppendLine("{0}finally:", Literal.GetIndentString(indent));
            }
        }
        private static void GenIndent(StringBuilder sb, int indent)
        {
            if (CurFuncCodeGenerateEnabled()) {
                if (indent > 0)
                    sb.Append(Literal.GetIndentString(indent));
            }
        }
        private static void GenAppend(StringBuilder sb, string str)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append(str);
            }
        }
        private static void GenAppend(StringBuilder sb, StringBuilder arg)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append(arg);
            }
        }
        private static void GenAppendLine(StringBuilder sb, string str)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.AppendLine(str);
            }
        }
        private static void GenAppendLine(StringBuilder sb)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.AppendLine();
            }
        }

        private static void GenAssignRHS(StringBuilder sb, StringBuilder rhsBuilder, string lhsType, string rhsType, string vname, string rhsName, bool rhsIsVarValRef, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                bool needCast = false;
                bool needCopy = false;
                bool existsSetObj = ExistsSetObj(vname);
                if (!IsSameType(lhsType, rhsType)) {
                    needCast = true;
                    GenCastBegin(sb, lhsType, rhsType, existsSetObj ? "True" : "False", syntax);
                }
                if (!needCast && rhsIsVarValRef) {
                    needCopy = existsSetObj;
                    if (!string.IsNullOrEmpty(rhsName)) {
                        needCopy = ExistsSetObj(rhsName) || needCopy;
                    }
                    if (needCopy) {
                        needCopy = GenVecCopyBegin(sb, rhsType, syntax);
                    }
                }
                sb.Append(rhsBuilder);
                if (needCast) {
                    GenCastEnd(sb);
                }
                else if (needCopy) {
                    GenVecCopyEnd(sb);
                }
            }
        }
        private static void GenBroadcast(StringBuilder sb, string type, string name, string writableBoolVal, Dsl.ISyntaxComponent syntax)
        {
            GenBroadcast(sb, type, name, writableBoolVal, false, syntax);
        }
        private static void GenBroadcast(StringBuilder sb, string type, string name, string writableBoolVal, bool forVecOnSkip, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                bool needVec = false;
                if (s_IsVectorizing && !IsTypeVec(type)) {
                    needVec = true;
                }
                if (needVec) {
                    string dtype = GetTypeVec(type);
                    string fn = GetCastFuncSig(dtype, type, out var isBroadcast);
                    GenOrRecordCastFunc(fn, dtype, type, isBroadcast, syntax);
                    sb.Append(fn);
                    sb.Append("(");
                    sb.Append(writableBoolVal);
                    sb.Append(", ");
                    sb.Append(name);
                    sb.Append(")");
                }
                else if (!forVecOnSkip) {
                    sb.Append(name);
                }
            }
        }
        private static void GenCastBegin(StringBuilder sb, string lhsType, string rhsType, string writableBoolVal, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                string fn = GetCastFuncSig(lhsType, rhsType, out var isBroadcast);
                GenOrRecordCastFunc(fn, lhsType, rhsType, isBroadcast, syntax);
                sb.Append(fn);
                sb.Append("(");
                if (isBroadcast) {
                    sb.Append(writableBoolVal);
                    sb.Append(", ");
                }
            }
        }
        private static void GenCastEnd(StringBuilder sb)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append(")");
            }
        }
        private static bool GenVecCopyBegin(StringBuilder sb, string type, Dsl.ISyntaxComponent syntax)
        {
            bool ret = false;
            if (CurFuncCodeGenerateEnabled()) {
                string typeWithoutArrTag = GetTypeRemoveArrTag(type, out var isTuple, out var isStruct, out var isVec, out var arrNums);
                if (isVec || isTuple || isStruct || arrNums.Count > 0 || GetTypeSuffix(typeWithoutArrTag).Length > 0) {
                    string fn = "h_copy_" + GetTypeAbbr(type);
                    GenOrRecordCopyFunc(fn, typeWithoutArrTag, isTuple, isStruct, isVec, arrNums, syntax);
                    sb.Append(fn);
                    sb.Append("(");
                    ret = true;
                }
            }
            return ret;
        }
        private static void GenVecCopyEnd(StringBuilder sb)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append(")");
            }
        }
        private static void GenArrayInitBegin(StringBuilder sb, string arrType, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                //为了尽量使用numpy/pytorch的张量的功能（主要考虑到性能），普通数组与结构数组的表示不一样
                //普通数组使用numpy/pytorch的张量表示，结构数组使用python的list表示（结构也是使用list表示的）
                //数组的向量化是对数组元素的向量化（普通数组与结构数组都是）
                string funcName = "array_init";
                var nameBuilder = NewStringBuilder();
                nameBuilder.Append(funcName);
                nameBuilder.Append(GetSuffixInfoFuncArgTag(arrType));
                string fullFuncName = nameBuilder.ToString();
                RecycleStringBuilder(nameBuilder);
                GenOrRecordArrayInit(fullFuncName, arrType, syntax);
                sb.Append(fullFuncName);
                sb.Append("(");
            }
        }
        private static void GenArrayInitEnd(StringBuilder sb)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append(")");
            }
        }

        private static void GenOrRecordDefValFunc(string fn, string typeWithoutArrTag, bool isTuple, bool isStruct, bool isVec, IList<int> arrNums, Dsl.ISyntaxComponent syntax)
        {
            AddUsingFuncOrApi(fn);
            if (isTuple) {
                Debug.Assert(false);
            }
            else if (isStruct) {
                string struName = GetTypeNoVecPrefix(typeWithoutArrTag);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            sb.AppendLine("def {0}({1}):", fn, isVec ? "writable" : string.Empty);
                            sb.Append("\treturn ");
                            GenStructDefVal(sb, struInfo, isVec, "writable", syntax);
                            sb.AppendLine();
                            sb.AppendLine();
                        }
                    }
                }
            }
            else if (arrNums.Count > 0) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, syntax.GetId(), syntax.GetLine());
                }
                string struName = GetTypeNoVecPrefix(typeWithoutArrTag);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            sb.AppendLine("def {0}(num{1}):", fn, isVec ? ", writable" : string.Empty);
                            sb.Append("\treturn [ ");
                            GenStructDefVal(sb, struInfo, isVec, "writable", syntax);
                            string ixName = string.Format("ix_{0}", GenUniqueNumber());
                            sb.Append(" for ");
                            sb.Append(ixName);
                            sb.AppendLine(" in range(num) ]");
                            sb.AppendLine();
                        }
                    }
                }
            }
        }
        private static void GenOrRecordCastFunc(string fn, string lhsType, string rhsType, bool isBroadcast, Dsl.ISyntaxComponent syntax)
        {
            AddUsingFuncOrApi(fn);
            string typeWithoutArrTag = GetTypeRemoveArrTag(lhsType, out var isTuple, out var isStruct, out var isVec, out var arrNums);
            if (isTuple) {
                Debug.Assert(false);
            }
            else if (isStruct) {
                string struName = GetTypeNoVecPrefix(lhsType);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            sb.AppendLine("def {0}({1}rhs):", fn, isBroadcast ? "writable, " : string.Empty);
                            if (rhsType.StartsWith(c_TupleTypePrefix)) {
                                if (rhsType.Contains(c_VectorialTupleTypeTag)) {
                                    sb.Append("\treturn ");
                                    int charIndex = 0;
                                    GenBroadcastPartialVecTuple(sb, "rhs", rhsType, struInfo, isBroadcast ? "writable" : "True", syntax, ref charIndex);
                                    sb.AppendLine();
                                }
                                else if (isBroadcast) {
                                    sb.Append("\treturn ");
                                    GenBroadcastStruct(sb, "rhs", struInfo, "writable", syntax);
                                    sb.AppendLine();
                                }
                                else {
                                    sb.AppendLine("\treturn rhs");
                                }
                            }
                            else {
                                string rStruName = GetTypeNoVecPrefix(rhsType, out var isVec2);
                                if (rStruName == struName && !isVec2) {
                                    sb.Append("\treturn ");
                                    GenBroadcastStruct(sb, "rhs", struInfo, isBroadcast ? "writable" : "True", syntax);
                                    sb.AppendLine();
                                }
                                else {
                                    Debug.Assert(false);
                                }
                            }
                            sb.AppendLine();
                        }
                    }
                }
            }
            else if (arrNums.Count > 0) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, syntax.GetId(), syntax.GetLine());
                }
                var rTypeWithoutArrTag = GetTypeRemoveArrTag(rhsType, out var rIsTuple, out var rIsStuct, out var rIsVec, out var rArrNums);
                string struName = GetTypeNoVecPrefix(typeWithoutArrTag);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            sb.AppendLine("def {0}({1}rhs):", fn, isBroadcast ? "writable, " : string.Empty);
                            sb.Append("\treturn [ ");
                            string ixName = string.Format("ix_{0}", GenUniqueNumber());
                            GenCastBegin(sb, typeWithoutArrTag, rTypeWithoutArrTag, isBroadcast ? "writable" : "True", syntax);
                            sb.Append("rhs[");
                            sb.Append(ixName);
                            sb.Append("]");
                            GenCastEnd(sb);
                            sb.Append(" for ");
                            sb.Append(ixName);
                            sb.AppendLine(" in range(len(rhs)) ]");
                            sb.AppendLine();
                        }
                    }
                }
                else {
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            //普通数组的cast/broadcast借助lib里的基础api批量处理
                            sb.AppendLine("def {0}({1}rhs):", fn, isBroadcast ? "writable, " : string.Empty);
                            if (isBroadcast) {
                                sb.Append("\treturn ");
                                string cfn = "array_broadcast" + GetSuffixInfoFuncArgTag(rhsType);
                                AddUsingFuncOrApi(cfn);
                                sb.Append(cfn);
                                sb.AppendLine("(writable, rhs)");
                            }
                            else {
                                sb.Append("\treturn ");
                                string cfn = "array_cast" + GetSuffixInfoFuncArgTag(lhsType) + GetSuffixInfoFuncArgTag(rhsType);
                                AddUsingFuncOrApi(cfn);
                                sb.Append(cfn);
                                sb.AppendLine("(rhs)");
                            }
                        }
                    }
                }
            }
        }
        private static void GenOrRecordCopyFunc(string fn, string typeWithoutArrTag, bool isTuple, bool isStruct, bool isVec, IList<int> arrNums, Dsl.ISyntaxComponent syntax)
        {
            AddUsingFuncOrApi(fn);
            if (isTuple) {
                Debug.Assert(false);
            }
            else if (isStruct) {
                string struName = GetTypeNoVecPrefix(typeWithoutArrTag);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            sb.AppendLine("def {0}(v):", fn);
                            sb.Append("\treturn ");
                            GenCopyStruct(sb, "v", struInfo, syntax);
                            sb.AppendLine();
                            sb.AppendLine();
                        }
                    }
                }
            }
            else if (arrNums.Count > 0) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, syntax.GetId(), syntax.GetLine());
                }
                string struName = GetTypeNoVecPrefix(typeWithoutArrTag);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            sb.AppendLine("def {0}(v):", fn);
                            sb.Append("\treturn [ ");
                            string elemName = string.Format("elem_{0}", GenUniqueNumber());
                            GenCopyStruct(sb, elemName, struInfo, syntax);
                            sb.Append(" for ");
                            sb.Append(elemName);
                            sb.AppendLine(" in v ]");
                            sb.AppendLine();
                        }
                    }
                }
                else {
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            //普通数组使用numpy/torch的张量，可以使用底层api拷贝
                            sb.AppendLine("def {0}(v):", fn);
                            sb.Append("\treturn array_copy(v)");
                            sb.AppendLine();
                        }
                    }
                }
            }
        }
        private static void GenOrRecordWhereFunc(string fn, string boolType, string lhsType, string rhsType, Dsl.ISyntaxComponent syntax)
        {
            //只有结构或结构数组需要生成 where api
            AddUsingFuncOrApi(fn);
            string typeWithoutArrTag = GetTypeRemoveArrTag(lhsType, out var isTuple, out var isStruct, out var isVec, out var arrNums);
            if (isTuple) {
                Debug.Assert(false);
            }
            else if (isStruct) {
                string struName = GetTypeNoVecPrefix(lhsType, out var lIsVec);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            sb.AppendLine("def {0}(b, y, n):", fn);
                            string rStruName = GetTypeNoVecPrefix(rhsType, out var rIsVec);
                            if (rStruName == struName) {
                                sb.Append("\treturn ");
                                GenWhereStruct(sb, "b", "y", "n", boolType, lIsVec, rIsVec, struInfo, syntax);
                                sb.AppendLine();
                            }
                            else {
                                Debug.Assert(false);
                            }
                            sb.AppendLine();
                        }
                    }
                }
            }
            else if (arrNums.Count > 0) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, syntax.GetId(), syntax.GetLine());
                }
                string struName = GetTypeNoVecPrefix(typeWithoutArrTag, out var lIsVec);
                if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                    var rTypeWithoutArrTag = GetTypeRemoveArrTag(rhsType, out var rIsTuple, out var rIsStuct, out var rIsVec, out var rArrNums);
                    if (CurFuncCodeGenerateEnabled()) {
                        if (!s_AutoGenCodes.ContainsKey(fn)) {
                            var sb = new StringBuilder();
                            s_AutoGenCodes.Add(fn, sb);

                            sb.AppendLine("def {0}(b, y, n):", fn);
                            sb.Append("\treturn [ ");
                            GenWhereStruct(sb, "b", "y[ix]", "n[ix]", boolType, lIsVec, rIsVec, struInfo, syntax);
                            sb.AppendLine(" for ix in range(min(len(y), len(n))) ]");
                            sb.AppendLine();
                        }
                    }
                }
            }
        }
        private static void GenOrRecordArrayInit(string fn, string objType, Dsl.ISyntaxComponent syntax)
        {
            //只有tuple与结构数组需要生成 array_init
            AddUsingFuncOrApi(fn);
            string typeWithoutArrTag = GetTypeRemoveArrTag(objType, out var isTuple, out var isStruct, out var isVec, out var arrNums);
            isVec = IsTypeVec(typeWithoutArrTag, out isTuple, out isStruct);
            if (isTuple) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, syntax.GetId(), syntax.GetLine());
                }
                if (CurFuncCodeGenerateEnabled()) {
                    if (!s_AutoGenCodes.ContainsKey(fn)) {
                        var sb = new StringBuilder();
                        s_AutoGenCodes.Add(fn, sb);

                        sb.AppendLine("def {0}(arr):", fn);
                        sb.AppendLine("\treturn arr");
                        sb.AppendLine();
                    }
                }
            }
            else if (isStruct) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported !");
                }
                if (CurFuncCodeGenerateEnabled()) {
                    if (!s_AutoGenCodes.ContainsKey(fn)) {
                        var sb = new StringBuilder();
                        s_AutoGenCodes.Add(fn, sb);

                        sb.AppendLine("def {0}(arr):", fn);
                        sb.AppendLine("\treturn arr");
                        sb.AppendLine();
                    }
                }
            }
        }
        private static void GenOrRecordArraySet(string fn, string objType, string argType, Dsl.ISyntaxComponent syntax)
        {
            //只有结构数组需要生成 array_set
            AddUsingFuncOrApi(fn);
            string typeWithoutArrTag = GetTypeRemoveArrTag(objType, out var isTuple, out var isStruct, out var isVec, out var arrNums);
            string struName = GetTypeNoVecPrefix(typeWithoutArrTag);
            if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}", arrNums.Count);
                }
                var argIsVec = IsTypeVec(argType);
                if (argIsVec) {
                    Console.WriteLine("[error]: struct array can't access by vectorial index ! index type:{0}, id:{1}, line:{2}", argType, syntax.GetId(), syntax.GetLine());
                }
                if (CurFuncCodeGenerateEnabled()) {
                    if (!s_AutoGenCodes.ContainsKey(fn)) {
                        var sb = new StringBuilder();
                        s_AutoGenCodes.Add(fn, sb);

                        sb.AppendLine("def {0}(arr, ix, val):", fn);
                        sb.Append("\tarr[ix] = ");
                        GenCopyStruct(sb, "val", struInfo, syntax);
                        sb.AppendLine();
                        sb.AppendLine("\treturn val");
                        sb.AppendLine();
                    }
                }
            }
        }
        private static void GenOrRecordArrayGet(string fn, string objType, string argType, Dsl.ISyntaxComponent syntax)
        {
            //只有结构数组需要生成 array_get
            AddUsingFuncOrApi(fn);
            string typeWithoutArrTag = GetTypeRemoveArrTag(objType, out var isTuple, out var isStruct, out var isVec, out var arrNums);
            string struName = GetTypeNoVecPrefix(typeWithoutArrTag);
            if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, syntax.GetId(), syntax.GetLine());
                }
                var argIsVec = IsTypeVec(argType);
                if (argIsVec) {
                    Console.WriteLine("[error]: struct array can't access by vectorial index ! index type:{0}, id:{1}, line:{2}", argType, syntax.GetId(), syntax.GetLine());
                }
                if (CurFuncCodeGenerateEnabled()) {
                    if (!s_AutoGenCodes.ContainsKey(fn)) {
                        var sb = new StringBuilder();
                        s_AutoGenCodes.Add(fn, sb);

                        sb.AppendLine("def {0}(arr, ix):", fn);
                        sb.AppendLine("\treturn arr[ix]");
                        sb.AppendLine();
                    }
                }
            }
        }
        private static void GenOrRecordArraySetAndBroadcast(string fn, string objType, string argType, Dsl.ISyntaxComponent syntax)
        {
            //只有结构数组需要生成 array_set_and_broadcast
            AddUsingFuncOrApi(fn);
            string typeWithoutArrTag = GetTypeRemoveArrTag(objType, out var isTuple, out var isStruct, out var isVec, out var arrNums);
            string struName = GetTypeNoVecPrefix(typeWithoutArrTag);
            if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                if (arrNums.Count > 1) {
                    Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, syntax.GetId(), syntax.GetLine());
                }
                var argIsVec = IsTypeVec(argType);
                if (argIsVec) {
                    Console.WriteLine("[error]: struct array can't access by vectorial index ! index type:{0}, id:{1}, line:{2}", argType, syntax.GetId(), syntax.GetLine());
                }
                if (CurFuncCodeGenerateEnabled()) {
                    if (!s_AutoGenCodes.ContainsKey(fn)) {
                        var sb = new StringBuilder();
                        s_AutoGenCodes.Add(fn, sb);

                        sb.AppendLine("def {0}(arr, ix, val):", fn);
                        string ixName = string.Format("ix_{0}", GenUniqueNumber());
                        sb.Append("\tfor ");
                        sb.Append(ixName);
                        sb.AppendLine(" in range(len(arr)):");
                        sb.Append("\t\tif ");
                        sb.Append(ixName);
                        sb.AppendLine(" != ix:");
                        sb.Append("\t\t\tarr[");
                        sb.Append(ixName);
                        sb.Append("] = ");
                        GenBroadcastStruct(sb, "arr[" + ixName + "]", struInfo, "True", syntax);
                        sb.AppendLine();

                        sb.Append("\tarr[ix] = ");
                        GenCopyStruct(sb, "val", struInfo, syntax);
                        sb.AppendLine();
                        sb.AppendLine("\treturn val, arr");
                        sb.AppendLine();
                    }
                }
            }
        }
        private static void GenStructSet(string fn, string lhsType, int index, Dsl.ISyntaxComponent syntax)
        {
            AddUsingFuncOrApi(fn);
            string struName = GetTypeNoVecPrefix(lhsType);
            if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                if (CurFuncCodeGenerateEnabled()) {
                    if (!s_AutoGenCodes.ContainsKey(fn)) {
                        var sb = new StringBuilder();
                        s_AutoGenCodes.Add(fn, sb);

                        sb.AppendLine("def {0}(lhs, rhs):", fn);
                        var fi = struInfo.Fields[index];
                        var cTypeWithoutArrTag = GetTypeRemoveArrTag(fi.Type, out var isTuple, out var isStruct, out var isVec, out var arrNums);
                        if (isTuple) {
                            Debug.Assert(false);
                        }
                        else if (isStruct) {
                            string cstruName = GetTypeNoVecPrefix(fi.Type);
                            if (s_StructInfos.TryGetValue(cstruName, out var cstruInfo)) {
                                sb.AppendFormat("\tlhs[{0}] = ", index);
                                GenCopyStruct(sb, "rhs", cstruInfo, syntax);
                                sb.AppendLine();
                            }
                        }
                        else if (arrNums.Count > 0) {
                            if (arrNums.Count > 1) {
                                Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, syntax.GetId(), syntax.GetLine());
                            }
                            string cstruName = GetTypeNoVecPrefix(cTypeWithoutArrTag);
                            if (s_StructInfos.TryGetValue(cstruName, out var cstruInfo)) {
                                sb.AppendFormat("\tlhs[{0}] = ", index);
                                sb.Append("[");
                                string elemName = string.Format("elem_{0}", GenUniqueNumber());
                                GenCopyStruct(sb, elemName, cstruInfo, syntax);
                                sb.Append(" for ");
                                sb.Append(elemName);
                                sb.AppendLine(" in rhs ]");
                            }
                            else {
                                sb.AppendFormat("\tlhs[{0}] = ", index);
                                bool needCopy = GenVecCopyBegin(sb, cTypeWithoutArrTag, syntax);
                                sb.Append("rhs");
                                if (needCopy)
                                    GenVecCopyEnd(sb);
                                sb.AppendLine();
                            }
                        }
                        else {
                            sb.AppendFormat("\tlhs[{0}] = ", index);
                            bool needCopy = GenVecCopyBegin(sb, cTypeWithoutArrTag, syntax);
                            sb.Append("rhs");
                            if (needCopy)
                                GenVecCopyEnd(sb);
                            sb.AppendLine();
                        }
                        sb.AppendLine("\treturn rhs");
                        sb.AppendLine();
                    }
                }
            }
        }
        private static void GenStructGet(string fn, string lhsType, int index, Dsl.ISyntaxComponent syntax)
        {
            AddUsingFuncOrApi(fn);
            string struName = GetTypeNoVecPrefix(lhsType);
            if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                if (CurFuncCodeGenerateEnabled()) {
                    if (!s_AutoGenCodes.ContainsKey(fn)) {
                        var sb = new StringBuilder();
                        s_AutoGenCodes.Add(fn, sb);

                        sb.AppendLine("def {0}(lhs):", fn);
                        sb.AppendFormat("\treturn lhs[{0}]", index);
                        sb.AppendLine();
                        sb.AppendLine();
                    }
                }
            }
        }
        private static void GenStructSetAndBroadcast(string fn, string lhsType, int index, Dsl.ISyntaxComponent syntax)
        {
            AddUsingFuncOrApi(fn);
            string struName = GetTypeNoVecPrefix(lhsType);
            if (s_StructInfos.TryGetValue(struName, out var struInfo)) {
                if (CurFuncCodeGenerateEnabled()) {
                    if (!s_AutoGenCodes.ContainsKey(fn)) {
                        var sb = new StringBuilder();
                        s_AutoGenCodes.Add(fn, sb);

                        sb.AppendLine("def {0}(lhs, rhs):", fn);
                        var fi = struInfo.Fields[index];
                        var cTypeWithoutArrTag = GetTypeRemoveArrTag(fi.Type, out var isTuple, out var isStruct, out var isVec, out var arrNums);
                        if (isTuple) {
                            Debug.Assert(false);
                        }
                        else if (arrNums.Count > 0) {
                            if (arrNums.Count > 1) {
                                Console.WriteLine("[error]: only one-dimensional arrays of structs are supported ! dim:{0}, id:{1}, line:{2}", arrNums.Count, syntax.GetId(), syntax.GetLine());
                            }
                        }
                        GenInplaceBroadcastStruct(sb, 1, "lhs", struInfo, "True");
                        sb.AppendFormat("\tlhs[{0}] = rhs", index);
                        sb.AppendLine();
                        sb.AppendLine("\treturn rhs, lhs");
                        sb.AppendLine();
                    }
                }
            }
        }
        private static void GenStructDefVal(StringBuilder sb, StructInfo struInfo, bool isVec, string writableBoolVal, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("[");
                for (int ix = 0; ix < struInfo.Fields.Count; ++ix) {
                    var fi = struInfo.Fields[ix];
                    if (ix > 0)
                        sb.Append(", ");
                    if (s_StructInfos.TryGetValue(fi.Type, out var cstruInfo)) {
                        //这里还是直接生成，如果没有单独使用嵌入的结构，就不用生成这个结构的默认值函数了
                        GenStructDefVal(sb, cstruInfo, isVec, writableBoolVal, syntax);
                    }
                    else if (isVec) {
                        sb.Append(GetDefaultValueInPython(GetTypeVec(fi.Type), writableBoolVal, syntax));
                    }
                    else {
                        sb.Append(GetDefaultValueInPython(fi.Type, writableBoolVal, syntax));
                    }
                }
                sb.Append("]");
            }
        }
        private static bool GenBroadcastPartialVecTuple(StringBuilder sb, string rhs, string type, StructInfo struInfo, string writableBoolVal, Dsl.ISyntaxComponent syntax, ref int charIndex)
        {
            bool ret = false;
            if (CurFuncCodeGenerateEnabled()) {
                string tag = c_TupleTypePrefix + struInfo.Fields.Count.ToString();
                string struType = struInfo.Name;
                string vecStruType = c_VectorialTypePrefix + struInfo.Name;
                if (type.IndexOf(tag, charIndex) == charIndex) {
                    charIndex += tag.Length;
                    ret = true;
                    sb.Append("[");
                    for (int ix = 0; ix < struInfo.Fields.Count; ++ix) {
                        var fi = struInfo.Fields[ix];
                        if (ix > 0)
                            sb.Append(", ");
                        string ty = fi.Type;
                        if (charIndex + 1 < type.Length && type[charIndex] == '_' && type[charIndex + 1] == '_') {
                            charIndex += 2;
                            string typeWithoutArrTag = GetTypeRemoveArrTag(ty, out var isTuple, out var isStruct, out var isVec, out var arrNums);
                            if (isTuple) {
                                Debug.Assert(false);
                            }
                            else if (isStruct) {
                                if (s_StructInfos.TryGetValue(ty, out var cstruInfo)) {
                                    if (!GenBroadcastPartialVecTuple(sb, rhs + "[" + ix + "]", type, cstruInfo, writableBoolVal, syntax, ref charIndex)) {
                                        ret = false;
                                        break;
                                    }
                                }
                            }
                            else {
                                if (arrNums.Count > 0) {
                                    if (s_StructInfos.TryGetValue(typeWithoutArrTag, out var cstruInfo)) {
                                        sb.Append("[");
                                        string elemName = string.Format("elem_{0}", GenUniqueNumber());
                                        bool r = GenBroadcastPartialVecTuple(sb, elemName, type, cstruInfo, writableBoolVal, syntax, ref charIndex);
                                        sb.Append(" for ");
                                        sb.Append(elemName);
                                        sb.Append(" in ");
                                        sb.Append(rhs);
                                        sb.Append("[");
                                        sb.Append(ix);
                                        sb.Append("] ]");
                                        if (!r) {
                                            ret = false;
                                            break;
                                        }
                                    }
                                    else {
                                        string fn = "array_broadcast" + GetSuffixInfoFuncArgTag(ty);
                                        AddUsingFuncOrApi(fn);
                                        sb.Append(fn);
                                        sb.Append("(");
                                        sb.Append(writableBoolVal);
                                        sb.Append(", ");
                                        sb.Append(rhs);
                                        sb.Append("[");
                                        sb.Append(ix);
                                        sb.Append("])");
                                    }
                                }
                                else {
                                    int nix = type.IndexOf(ty, charIndex);
                                    if (nix == charIndex) {
                                        charIndex += ty.Length;
                                        string fn = "h_broadcast_" + GetTypeAbbr(ty);
                                        AddUsingFuncOrApi(fn);
                                        sb.Append(fn);
                                        sb.Append("(");
                                        sb.Append(writableBoolVal);
                                        sb.Append(", ");
                                        sb.Append(rhs);
                                        sb.Append("[");
                                        sb.Append(ix);
                                        sb.Append("])");
                                    }
                                    else {
                                        string vty = GetTypeVec(ty);
                                        nix = type.IndexOf(vty, charIndex);
                                        if (nix == charIndex) {
                                            charIndex += vty.Length;
                                            string fn = "h_copy_t_" + GetTypeAbbr(ty);
                                            AddUsingFuncOrApi(fn);
                                            sb.Append(fn);
                                            sb.Append("(");
                                            sb.Append(rhs);
                                            sb.Append("[");
                                            sb.Append(ix);
                                            sb.Append("])");
                                        }
                                        else {
                                            ret = false;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            ret = false;
                            break;
                        }
                    }
                    sb.Append("]");
                }
                else if (type.IndexOf(struType, charIndex) == charIndex) {
                    charIndex += struType.Length;
                    ret = true;
                    GenBroadcastStruct(sb, rhs, struInfo, writableBoolVal, syntax);
                }
                else if (type.IndexOf(vecStruType, charIndex) == charIndex) {
                    charIndex += vecStruType.Length;
                    ret = true;
                    GenCopyStruct(sb, rhs, struInfo, syntax);
                }
            }
            return ret;
        }
        private static void GenBroadcastStruct(StringBuilder sb, string rhs, StructInfo struInfo, string writableBoolVal, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("[");
                for (int ix = 0; ix < struInfo.Fields.Count; ++ix) {
                    var fi = struInfo.Fields[ix];
                    if (ix > 0)
                        sb.Append(", ");
                    string typeWithoutArrTag = GetTypeRemoveArrTag(fi.Type, out var isTuple, out var isStruct, out var isVec, out var arrNums);
                    if (isTuple) {
                        Debug.Assert(false);
                    }
                    else if (isStruct) {
                        if (s_StructInfos.TryGetValue(typeWithoutArrTag, out var cstruInfo)) {
                            GenBroadcastStruct(sb, rhs + "[" + ix + "]", cstruInfo, writableBoolVal, syntax);
                        }
                        else {
                            Debug.Assert(false);
                        }
                    }
                    else {
                        if (arrNums.Count > 0) {
                            if (s_StructInfos.TryGetValue(typeWithoutArrTag, out var cstruInfo)) {
                                sb.Append("[");
                                string elemName = string.Format("elem_{0}", GenUniqueNumber());
                                GenBroadcastStruct(sb, elemName, cstruInfo, writableBoolVal, syntax);
                                sb.Append(" for ");
                                sb.Append(elemName);
                                sb.Append(" in ");
                                sb.Append(rhs);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.Append("] ]");
                            }
                            else {
                                string fn = "array_broadcast" + GetSuffixInfoFuncArgTag(fi.Type);
                                AddUsingFuncOrApi(fn);
                                sb.Append(fn);
                                sb.Append("(");
                                sb.Append(writableBoolVal);
                                sb.Append(", ");
                                sb.Append(rhs);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.Append("])");
                            }
                        }
                        else {
                            string fn = "h_broadcast_" + GetTypeAbbr(fi.Type);
                            AddUsingFuncOrApi(fn);
                            sb.Append(fn);
                            sb.Append("(");
                            sb.Append(writableBoolVal);
                            sb.Append(", ");
                            sb.Append(rhs);
                            sb.Append("[");
                            sb.Append(ix);
                            sb.Append("])");
                        }
                    }
                }
                sb.Append("]");
            }
        }
        private static void GenCopyStruct(StringBuilder sb, string val, StructInfo struInfo, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("[");
                for (int ix = 0; ix < struInfo.Fields.Count; ++ix) {
                    var fi = struInfo.Fields[ix];
                    if (ix > 0)
                        sb.Append(", ");
                    string typeWithoutArrTag = GetTypeRemoveArrTag(fi.Type, out var isTuple, out var isStruct, out var isVec, out var arrNums);
                    if (isTuple) {
                        Debug.Assert(false);
                    }
                    else if (isStruct) {
                        if (s_StructInfos.TryGetValue(typeWithoutArrTag, out var cstruInfo)) {
                            GenCopyStruct(sb, val + "[" + ix + "]", cstruInfo, syntax);
                        }
                    }
                    else {
                        if (arrNums.Count > 0) {
                            if (s_StructInfos.TryGetValue(typeWithoutArrTag, out var cstruInfo)) {
                                sb.Append("[");
                                string elemName = string.Format("elem_{0}", GenUniqueNumber());
                                GenCopyStruct(sb, elemName, cstruInfo, syntax);
                                sb.Append(" for ");
                                sb.Append(elemName);
                                sb.Append(" in ");
                                sb.Append(val);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.Append("] ]");
                            }
                            else {
                                //普通数组的copy在GenVecCopyBegin里已处理
                                bool needCopy = GenVecCopyBegin(sb, fi.Type, syntax);
                                sb.Append(val);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.Append("]");
                                if (needCopy)
                                    GenVecCopyEnd(sb);
                            }
                        }
                        else {
                            bool needCopy = GenVecCopyBegin(sb, fi.Type, syntax);
                            sb.Append(val);
                            sb.Append("[");
                            sb.Append(ix);
                            sb.Append("]");
                            if (needCopy)
                                GenVecCopyEnd(sb);
                        }
                    }
                }
                sb.Append("]");
            }
        }
        private static void GenWhereStruct(StringBuilder sb, string b, string y, string n, string boolType, bool lIsVec, bool rIsVec, StructInfo struInfo, Dsl.ISyntaxComponent syntax)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("[");
                for (int ix = 0; ix < struInfo.Fields.Count; ++ix) {
                    var fi = struInfo.Fields[ix];
                    if (ix > 0)
                        sb.Append(", ");
                    string typeWithoutArrTag = GetTypeRemoveArrTag(fi.Type, out var isTuple, out var isStruct, out var isVec, out var arrNums);
                    if (isTuple) {
                        Debug.Assert(false);
                    }
                    else if (isStruct) {
                        if (s_StructInfos.TryGetValue(typeWithoutArrTag, out var cstruInfo)) {
                            GenWhereStruct(sb, b, y + "[" + ix + "]", n + "[" + ix + "]", boolType, lIsVec, rIsVec, cstruInfo, syntax);
                        }
                    }
                    else {
                        if (arrNums.Count > 0) {
                            if (s_StructInfos.TryGetValue(typeWithoutArrTag, out var cstruInfo)) {
                                sb.Append("[");
                                string ixName = string.Format("ix_{0}", GenUniqueNumber());
                                GenWhereStruct(sb, b, y + "[" + ixName + "]", n + "[" + ixName + "]", boolType, lIsVec, rIsVec, cstruInfo, syntax);
                                sb.Append(" for ");
                                sb.Append(ixName);
                                sb.Append(" in range(min(len(");
                                sb.Append(y);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.Append("]), len(");
                                sb.Append(n);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.Append("]))) ]");
                            }
                            else {
                                //普通数组的 where 操作与普通类型的 where 都在lib里提供
                                string whereFuncName = "h_where";
                                string lType = lIsVec ? GetTypeVec(fi.Type) : fi.Type;
                                string rType = rIsVec ? GetTypeVec(fi.Type) : fi.Type;
                                string resultType = GetWhereResultType(boolType, lType, rType);
                                string whereFullFuncName = whereFuncName + GetFuncArgsTag(whereFuncName, boolType, lType, rType);
                                AddUsingFuncOrApi(whereFullFuncName);
                                sb.Append(whereFullFuncName);
                                sb.Append("(");
                                sb.Append(b);
                                sb.Append(", ");
                                sb.Append(y);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.Append("], ");
                                sb.Append(n);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.Append("])");
                            }
                        }
                        else {
                            string whereFuncName = "h_where";
                            string lType = lIsVec ? GetTypeVec(fi.Type) : fi.Type;
                            string rType = rIsVec ? GetTypeVec(fi.Type) : fi.Type;
                            string resultType = GetWhereResultType(boolType, lType, rType);
                            string whereFullFuncName = whereFuncName + GetFuncArgsTag(whereFuncName, boolType, lType, rType);
                            AddUsingFuncOrApi(whereFullFuncName);
                            sb.Append(whereFullFuncName);
                            sb.Append("(");
                            sb.Append(b);
                            sb.Append(", ");
                            sb.Append(y);
                            sb.Append("[");
                            sb.Append(ix);
                            sb.Append("], ");
                            sb.Append(n);
                            sb.Append("[");
                            sb.Append(ix);
                            sb.Append("])");
                        }
                    }
                }
                sb.Append("]");
            }
        }
        private static void GenInplaceBroadcastStruct(StringBuilder sb, int indent, string varName, StructInfo struInfo, string writableBoolVal)
        {
            if (CurFuncCodeGenerateEnabled()) {
                for (int ix = 0; ix < struInfo.Fields.Count; ++ix) {
                    var fi = struInfo.Fields[ix];
                    string typeWithoutArrTag = GetTypeRemoveArrTag(fi.Type, out var isTuple, out var isStruct, out var isVec, out var arrNums);
                    if (isTuple) {
                        Debug.Assert(false);
                    }
                    else if (isStruct) {
                        if (s_StructInfos.TryGetValue(typeWithoutArrTag, out var cstruInfo)) {
                            GenInplaceBroadcastStruct(sb, indent, varName + "[" + ix + "]", cstruInfo, writableBoolVal);
                        }
                    }
                    else {
                        if (arrNums.Count > 0) {
                            if (s_StructInfos.TryGetValue(typeWithoutArrTag, out var cstruInfo)) {
                                sb.Append(Literal.GetIndentString(indent));
                                string elemName = string.Format("elem_{0}", GenUniqueNumber());
                                sb.Append("for ");
                                sb.Append(elemName);
                                sb.Append(" in ");
                                sb.Append(varName);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.AppendLine("]:");
                                GenInplaceBroadcastStruct(sb, indent, elemName, cstruInfo, writableBoolVal);
                            }
                            else {
                                sb.Append(Literal.GetIndentString(indent));
                                sb.Append(varName);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.Append("] = ");
                                string fn = "array_broadcast" + GetSuffixInfoFuncArgTag(fi.Type);
                                AddUsingFuncOrApi(fn);
                                sb.Append(fn);
                                sb.Append("(");
                                sb.Append(writableBoolVal);
                                sb.Append(", ");
                                sb.Append(varName);
                                sb.Append("[");
                                sb.Append(ix);
                                sb.AppendLine("])");
                            }
                        }
                        else {
                            sb.Append(Literal.GetIndentString(indent));
                            sb.Append(varName);
                            sb.Append("[");
                            sb.Append(ix);
                            sb.Append("] = ");
                            string fn = "h_broadcast_" + GetTypeAbbr(fi.Type);
                            AddUsingFuncOrApi(fn);
                            sb.Append(fn);
                            sb.Append("(");
                            sb.Append(writableBoolVal);
                            sb.Append(", ");
                            sb.Append(varName);
                            sb.Append("[");
                            sb.Append(ix);
                            sb.AppendLine("])");
                        }
                    }
                }
            }
        }

        private static void GenGetOutParamAndEndGetRetVal(string outVar, int outIx, string retVar, StringBuilder sb)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append(", ");
                sb.Append(TryRenameTemporary(outVar));
                sb.Append(" := ");
                GenGetOutParam(retVar, outIx, sb);
                GenGetRetValEnd(sb);
            }
        }
        private static void GenGetRetValBegin(string tag, StringBuilder sb, out string retVar)
        {
            if (CurFuncCodeGenerateEnabled()) {
                int uid = GenUniqueNumber();
                retVar = string.Format("{0}{1}", tag, uid);
                sb.Append("tuple_get_retval((");
                sb.Append(retVar);
                sb.Append(" := ");
            }
            else {
                retVar = string.Empty;
            }
        }
        private static void GenGetRetValEnd(StringBuilder sb)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("))");
            }
        }
        private static void GenGetOutParam(string retVar, int outIx, StringBuilder sb)
        {
            if (CurFuncCodeGenerateEnabled()) {
                sb.Append("tuple_get_outparam(");
                sb.Append(retVar);
                sb.Append(", ");
                sb.Append(outIx);
                sb.Append(")");
            }
        }

        private static string VecInferAndGenWhere(string trueVar, string trueVarType, string falseVar, string falseVarType, List<string> expVars, List<string> expTypes, int index, StringBuilder sb, Dsl.ISyntaxComponent syntax)
        {
            Debug.Assert(expVars.Count == expTypes.Count);
            string whereFuncName = "h_where";
            if (index == expVars.Count - 1) {
                string expVar = expVars[index];
                string expType = expTypes[index];

                string resultType = GetWhereResultType(expType, trueVarType, falseVarType);

                if (CurFuncCodeGenerateEnabled()) {
                    string whereFullFuncName = whereFuncName + GetFuncArgsTag(whereFuncName, expType, trueVarType, falseVarType);
                    GenOrRecordWhereFunc(whereFullFuncName, expType, trueVarType, falseVarType, syntax);
                    sb.Append(whereFullFuncName);
                    sb.Append("(");
                    sb.Append(expVar);
                    sb.Append(", ");
                    sb.Append(trueVar);
                    sb.Append(", ");
                    sb.Append(falseVar);
                    sb.Append(")");
                }
                return resultType;
            }
            else if (index < expVars.Count - 1) {
                string expVar = expVars[index];
                string expType = expTypes[index];

                var argBuilder = NewStringBuilder();
                string whereType = VecInferAndGenWhere(trueVar, trueVarType, falseVar, falseVarType, expVars, expTypes, index + 1, argBuilder, syntax);
                string resultType = GetWhereResultType(expType, trueVarType, whereType);

                if (CurFuncCodeGenerateEnabled()) {
                    string whereFullFuncName = whereFuncName + GetFuncArgsTag(whereFuncName, expType, trueVarType, whereType);
                    AddUsingFuncOrApi(whereFullFuncName);
                    sb.Append(whereFullFuncName);
                    sb.Append("(");
                    sb.Append(expVar);
                    sb.Append(",");
                    sb.Append(trueVar);
                    sb.Append(", ");
                    sb.Append(argBuilder);
                    sb.Append(")");
                }
                RecycleStringBuilder(argBuilder);
                return resultType;
            }
            else {
                return string.Empty;
            }
        }
        private static string VecInferAndGenWhereEqualInt(string trueVar, string trueVarType, string falseVar, string falseVarType, string varName, string varType, List<StringBuilder> expVals, int index, StringBuilder sb, Dsl.ISyntaxComponent syntax)
        {
            string whereFuncName = "h_where";
            if (index == expVals.Count - 1) {
                var expVal = expVals[index];

                var expBuilder = NewStringBuilder();
                string expType = VecInferAndGenEqualInt(varName, varType, expVal, expBuilder);
                string resultType = GetWhereResultType(expType, trueVarType, falseVarType);

                if (CurFuncCodeGenerateEnabled()) {
                    string whereFullFuncName = whereFuncName + GetFuncArgsTag(whereFuncName, expType, trueVarType, falseVarType);
                    GenOrRecordWhereFunc(whereFullFuncName, expType, trueVarType, falseVarType, syntax);
                    sb.Append(whereFullFuncName);
                    sb.Append("(");
                    sb.Append(expBuilder);
                    sb.Append(", ");
                    sb.Append(trueVar);
                    sb.Append(", ");
                    sb.Append(falseVar);
                    sb.Append(")");
                }
                RecycleStringBuilder(expBuilder);
                return resultType;
            }
            else if (index < expVals.Count - 1) {
                var expVal = expVals[index];

                var expBuilder = NewStringBuilder();
                string expType = VecInferAndGenEqualInt(varName, varType, expVal, expBuilder);
                var argBuilder = NewStringBuilder();
                string whereType = VecInferAndGenWhereEqualInt(trueVar, trueVarType, falseVar, falseVarType, varName, varType, expVals, index + 1, argBuilder, syntax);
                string resultType = GetWhereResultType(expType, trueVarType, whereType);

                if (CurFuncCodeGenerateEnabled()) {
                    string whereFullFuncName = whereFuncName + GetFuncArgsTag(whereFuncName, expType, trueVarType, whereType);
                    AddUsingFuncOrApi(whereFullFuncName);
                    sb.Append(whereFullFuncName);
                    sb.Append("(");
                    sb.Append(expBuilder);
                    sb.Append(",");
                    sb.Append(trueVar);
                    sb.Append(", ");
                    sb.Append(argBuilder);
                    sb.Append(")");
                }
                RecycleStringBuilder(expBuilder);
                RecycleStringBuilder(argBuilder);
                return resultType;
            }
            else {
                return string.Empty;
            }
        }
        private static string VecInferAndGenOr(List<string> expVars, List<string> expTypes, int index, StringBuilder sb)
        {
            Debug.Assert(expVars.Count == expTypes.Count);
            string orFuncName = "h_or";
            if (index == expVars.Count - 2) {
                string expVar1 = expVars[index];
                string expType1 = expTypes[index];
                string expVar2 = expVars[index + 1];
                string expType2 = expTypes[index + 1];

                string resultType = OperatorTypeInference("||", expType1, expType2);

                if (CurFuncCodeGenerateEnabled()) {
                    string orFullFuncName = orFuncName + GetFuncArgsTag(orFuncName, expType1, expType2);
                    AddUsingFuncOrApi(orFullFuncName);
                    sb.Append(orFullFuncName);
                    sb.Append("(");
                    sb.Append(expVar1);
                    sb.Append(", ");
                    sb.Append(expVar2);
                    sb.Append(")");
                }
                return resultType;
            }
            else if (index < expVars.Count - 2) {
                string expVar1 = expVars[index];
                string expType1 = expTypes[index];

                var argBuilder = NewStringBuilder();
                string expType2 = VecInferAndGenOr(expVars, expTypes, index + 1, argBuilder);
                string resultType = OperatorTypeInference("||", expType1, expType2);

                if (CurFuncCodeGenerateEnabled()) {
                    string orFullFuncName = orFuncName + GetFuncArgsTag(orFuncName, expType1, expType2);
                    AddUsingFuncOrApi(orFullFuncName);
                    sb.Append(orFullFuncName);
                    sb.Append("(");
                    sb.Append(expVar1);
                    sb.Append(", ");
                    sb.Append(argBuilder);
                    sb.Append(")");
                }
                RecycleStringBuilder(argBuilder);
                return resultType;
            }
            else if (expVars.Count == 1) {
                if (CurFuncCodeGenerateEnabled()) {
                    sb.Append(expVars[0]);
                }
                return expTypes[0];
            }
            else {
                return string.Empty;
            }
        }
        private static string VecInferAndGenEqualIntOr(string varName, string varType, List<StringBuilder> expVals, int index, StringBuilder sb)
        {
            string orFuncName = "h_or";
            if (index == expVals.Count - 2) {
                var expVal1 = expVals[index];
                var expVal2 = expVals[index + 1];

                var argBuilder1 = NewStringBuilder();
                var argBuilder2 = NewStringBuilder();
                string expType1 = VecInferAndGenEqualInt(varName, varType, expVal1, argBuilder1);
                string expType2 = VecInferAndGenEqualInt(varName, varType, expVal2, argBuilder2);
                string resultType = OperatorTypeInference("||", expType1, expType2);

                if (CurFuncCodeGenerateEnabled()) {
                    string orFullFuncName = orFuncName + GetFuncArgsTag(orFuncName, expType1, expType2);
                    AddUsingFuncOrApi(orFullFuncName);
                    sb.Append(orFullFuncName);
                    sb.Append("(");
                    sb.Append(argBuilder1);
                    sb.Append(", ");
                    sb.Append(argBuilder2);
                    sb.Append(")");
                }
                RecycleStringBuilder(argBuilder1);
                RecycleStringBuilder(argBuilder2);
                return resultType;
            }
            else if (index < expVals.Count - 2) {
                var expVal1 = expVals[index];

                var argBuilder1 = NewStringBuilder();
                var argBuilder2 = NewStringBuilder();
                string expType1 = VecInferAndGenEqualInt(varName, varType, expVal1, argBuilder1);
                string expType2 = VecInferAndGenEqualIntOr(varName, varType, expVals, index + 1, argBuilder2);
                string resultType = OperatorTypeInference("||", expType1, expType2);

                if (CurFuncCodeGenerateEnabled()) {
                    string orFullFuncName = orFuncName + GetFuncArgsTag(orFuncName, expType1, expType2);
                    AddUsingFuncOrApi(orFullFuncName);
                    sb.Append(orFullFuncName);
                    sb.Append("(");
                    sb.Append(argBuilder1);
                    sb.Append(", ");
                    sb.Append(argBuilder2);
                    sb.Append(")");
                }
                RecycleStringBuilder(argBuilder1);
                RecycleStringBuilder(argBuilder2);
                return resultType;
            }
            else if (expVals.Count == 1) {
                return VecInferAndGenEqualInt(varName, varType, expVals[0], sb);
            }
            else {
                return string.Empty;
            }
        }
        private static string VecInferAndGenEqualInt(string varName, string varType, StringBuilder expVal, StringBuilder sb)
        {
            string intType = "int";
            string eqFuncName = "h_equal";

            string resultType = OperatorTypeInference("==", varType, intType);

            if (CurFuncCodeGenerateEnabled()) {
                string eqFullFuncName = eqFuncName + GetFuncArgsTag(eqFuncName, varType, intType);
                AddUsingFuncOrApi(eqFullFuncName);
                sb.Append(eqFullFuncName);
                sb.Append("(");
                sb.Append(varName);
                sb.Append(", ");
                sb.Append(expVal);
                sb.Append(")");
            }
            return resultType;
        }
    }
}