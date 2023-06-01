using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

namespace Hlsl2Numpy
{
    internal sealed class VarInfo
    {
        internal string Name = string.Empty;
        internal string Type = string.Empty;
        internal string OriName = string.Empty;
        internal string OriType = string.Empty;
        internal bool IsConst = false;
        internal bool IsInOut = false;
        internal bool IsOut = false;
        internal List<string> Modifiers = new List<string>();
        internal string Semantic = string.Empty;
        internal string Register = string.Empty;
        internal Dsl.ISyntaxComponent? DefaultValueSyntax = null;
        internal string InitOrDefValueConst = string.Empty;

        internal BlockInfo? OwnerBlock = null;
        internal int OwnerBasicBlockIndex = -1;
        internal int OwnerStatementIndex = -1;

        internal void CopyParseInfoFrom(VarInfo other, out string varType)
        {
            Name = other.Name;
            if (string.IsNullOrEmpty(Type))
                Type = other.Type;
            OriType = other.OriType;
            IsConst = other.IsConst;
            IsInOut = other.IsInOut;
            IsOut = other.IsOut;
            Modifiers.Clear();
            Modifiers.AddRange(other.Modifiers);
            Semantic = other.Semantic;
            Register = other.Register;
            DefaultValueSyntax = other.DefaultValueSyntax;
            InitOrDefValueConst = other.InitOrDefValueConst;

            varType = Type;
        }
    }
    internal sealed class StructInfo
    {
        internal string Name = string.Empty;
        internal List<VarInfo> Fields = new List<VarInfo>();
        internal Dictionary<string, int> FieldName2Indexes = new Dictionary<string, int>();
    }
    internal sealed class CBufferInfo
    {
        internal string Name = string.Empty;
        internal string Register = string.Empty;
        internal List<VarInfo> Variables = new List<VarInfo>();
    }
}
