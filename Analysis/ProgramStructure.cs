using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using static Hlsl2Numpy.Program;

namespace Hlsl2Numpy
{
    internal enum VarUsage
    {
        Find = 0,
        Decl,
        Read,
        Write,
        ObjSet,
    }
    internal sealed class DeclVarInfo
    {
        internal string Name = string.Empty;
        internal string Type = string.Empty;
    }
    internal sealed class BlockVarInfo
    {
        internal string Name = string.Empty;
        internal string Type = string.Empty;
        internal VarUsage Usage = VarUsage.Find;

        internal BlockInfo? OwnerBlock = null;
        internal int OwnerBasicBlockIndex = -1;
        internal int OwnerStatementIndex = -1;

        internal string? CompileTimeConst = null;
        internal string GetCompileTimeConstDesc()
        {
            if (null == CompileTimeConst) {
                return "[ ]";
            }
            else if (string.IsNullOrEmpty(CompileTimeConst)) {
                return "[x]";
            }
            else {
                return CompileTimeConst;
            }
        }

        internal bool IsInvalid
        {
            get {
                return this == s_InvalidInfo;
            }
        }
        internal static BlockVarInfo s_InvalidInfo = new BlockVarInfo();
    }
    internal sealed class UsingVarInfo
    {
        internal List<BlockVarInfo> Vars = new List<BlockVarInfo>();
        internal int UsingCount = 0;

        internal BlockVarInfo CurSetVarInfo
        {
            get {
                if (UsingCount > 0 && UsingCount <= Vars.Count) {
                    for (int ix = UsingCount - 1; ix >= 0; --ix) {
                        var vinfo = Vars[ix];
                        if (vinfo.Usage == VarUsage.Decl || vinfo.Usage == VarUsage.Write) {
                            return vinfo;
                        }
                    }
                }
                return BlockVarInfo.s_InvalidInfo;
            }
        }
        internal BlockVarInfo CurGetVarInfo
        {
            get {
                if (UsingCount > 0 && UsingCount <= Vars.Count) {
                    for (int ix = UsingCount - 1; ix >= 0; --ix) {
                        var vinfo = Vars[ix];
                        if (vinfo.Usage == VarUsage.Read) {
                            return vinfo;
                        }
                    }
                }
                return BlockVarInfo.s_InvalidInfo;
            }
        }
        internal BlockVarInfo CurObjSetVarInfo
        {
            get {
                if (UsingCount > 0 && UsingCount <= Vars.Count) {
                    for (int ix = UsingCount - 1; ix >= 0; --ix) {
                        var vinfo = Vars[ix];
                        if (vinfo.Usage == VarUsage.ObjSet) {
                            return vinfo;
                        }
                    }
                }
                return BlockVarInfo.s_InvalidInfo;
            }
        }

        internal BlockVarInfo SetVarInfo(int endUsingVarIndex)
        {
            if (endUsingVarIndex < 0)
                endUsingVarIndex = Vars.Count - 1;
            if (endUsingVarIndex >= 0 && endUsingVarIndex < Vars.Count) {
                for (int ix = endUsingVarIndex; ix >= 0; --ix) {
                    var vinfo = Vars[ix];
                    if (vinfo.Usage == VarUsage.Decl || vinfo.Usage == VarUsage.Write) {
                        return vinfo;
                    }
                }
            }
            return BlockVarInfo.s_InvalidInfo;
        }
        internal BlockVarInfo GetVarInfo(int endUsingVarIndex)
        {
            if (endUsingVarIndex < 0)
                endUsingVarIndex = Vars.Count - 1;
            if (endUsingVarIndex >= 0 && endUsingVarIndex < Vars.Count) {
                for (int ix = endUsingVarIndex; ix >= 0; --ix) {
                    var vinfo = Vars[ix];
                    if (vinfo.Usage == VarUsage.Read) {
                        return vinfo;
                    }
                }
            }
            return BlockVarInfo.s_InvalidInfo;
        }
        internal BlockVarInfo ObjSetVarInfo(int endUsingVarIndex)
        {
            if (endUsingVarIndex < 0)
                endUsingVarIndex = Vars.Count - 1;
            if (endUsingVarIndex >= 0 && endUsingVarIndex < Vars.Count) {
                for (int ix = endUsingVarIndex; ix >= 0; --ix) {
                    var vinfo = Vars[ix];
                    if (vinfo.Usage == VarUsage.ObjSet) {
                        return vinfo;
                    }
                }
            }
            return BlockVarInfo.s_InvalidInfo;
        }
    }
    internal sealed class BasicBlockStatementInfo
    {
        internal Dsl.ISyntaxComponent? Statement = null;
        internal Dsl.ISyntaxComponent? Attribute = null;

        internal Dictionary<string, DeclVarInfo> DeclVars = new Dictionary<string, DeclVarInfo>();
        internal Dictionary<string, UsingVarInfo> UsingVars = new Dictionary<string, UsingVarInfo>();

        internal void ResetUsingCount()
        {
            foreach (var pair in UsingVars) {
                pair.Value.UsingCount = 0;
            }
        }
        internal int GetUsingVarIndex(string name)
        {
            int usingVarIndex = -1;
            if (UsingVars.TryGetValue(name, out var uvinfo)) {
                usingVarIndex = uvinfo.UsingCount - 1;
            }
            return usingVarIndex;
        }
        internal bool SetVarConst(string name, string val)
        {
            bool ret = false;
            if (UsingVars.TryGetValue(name, out var uvinfo)) {
                var svinfo = uvinfo.CurSetVarInfo;
                if (!svinfo.IsInvalid) {
                    svinfo.CompileTimeConst = val;
                    ret = true;
                }
            }
            return ret;
        }
        internal bool CacheVarConst(int usingVarIndex, string name, string val)
        {
            bool ret = false;
            if (UsingVars.TryGetValue(name, out var uvinfo)) {
                var gvinfo = uvinfo.GetVarInfo(usingVarIndex);
                if (!gvinfo.IsInvalid) {
                    gvinfo.CompileTimeConst = val;
                    ret = true;
                }
            }
            return ret;
        }
        internal bool TryGetVarSetConst(int endUsingVarIndex, string name, out string val)
        {
            bool ret = false;
            val = string.Empty;
            if (UsingVars.TryGetValue(name, out var uvinfo)) {
                var svinfo = uvinfo.SetVarInfo(endUsingVarIndex);
                if (!svinfo.IsInvalid && null != svinfo.CompileTimeConst) {
                    val = svinfo.CompileTimeConst;
                    ret = true;
                }
            }
            return ret;
        }
        internal bool TryGetVarCacheConst(int endUsingVarIndex, string name, out string val)
        {
            bool ret = false;
            val = string.Empty;
            if (UsingVars.TryGetValue(name, out var uvinfo)) {
                var gvinfo = uvinfo.GetVarInfo(endUsingVarIndex);
                if (!gvinfo.IsInvalid && null != gvinfo.CompileTimeConst) {
                    val = gvinfo.CompileTimeConst;
                    ret = true;
                }
            }
            return ret;
        }
        internal bool TryGetVarSetOrCacheConst(int endUsingVarIndex, string name, out string val)
        {
            bool ret = false;
            val = string.Empty;
            if (UsingVars.TryGetValue(name, out var uvinfo)) {
                if (endUsingVarIndex < 0)
                    endUsingVarIndex = uvinfo.Vars.Count - 1;
                if (endUsingVarIndex >= 0 && endUsingVarIndex < uvinfo.Vars.Count) {
                    for (int ix = endUsingVarIndex; ix >= 0; --ix) {
                        var vinfo = uvinfo.Vars[ix];
                        if ((vinfo.Usage == VarUsage.Decl || vinfo.Usage == VarUsage.Write) && null != vinfo.CompileTimeConst) {
                            val = vinfo.CompileTimeConst;
                            ret = true;
                            break;
                        }
                        else if (vinfo.Usage == VarUsage.Read && null != vinfo.CompileTimeConst) {
                            val = vinfo.CompileTimeConst;
                            ret = true;
                            break;
                        }
                    }
                }
            }
            return ret;
        }
    }
    internal sealed class BasicBlockInfo
    {
        internal int CurStatementIndex = -1;
        internal List<BasicBlockStatementInfo> Statements = new List<BasicBlockStatementInfo>();

        internal BasicBlockStatementInfo CurStatementInfo()
        {
            Debug.Assert(CurStatementIndex >= 0 && CurStatementIndex < Statements.Count);
            return Statements[CurStatementIndex];
        }
        internal BasicBlockStatementInfo GetOrAddStatement(int index)
        {
            Debug.Assert(index >= 0 && index <= Statements.Count);
            BasicBlockStatementInfo stmInfo;
            if (index == Statements.Count) {
                stmInfo = new BasicBlockStatementInfo();
                Statements.Add(stmInfo);
            }
            else {
                stmInfo = Statements[index];
            }
            return stmInfo;
        }

        internal void Reset()
        {
            CurStatementIndex = -1;
            foreach (var stm in Statements) {
                stm.ResetUsingCount();
            }
        }
        internal bool SetVarConst(string name, string val)
        {
            bool ret = CurStatementInfo().SetVarConst(name, val);
            return ret;
        }
        internal bool CacheVarConst(int statementIndex, int statementUsingVarIndex, string name, string val)
        {
            if (statementIndex == -1)
                statementIndex = Statements.Count - 1;
            bool ret = Statements[statementIndex].CacheVarConst(statementUsingVarIndex, name, val);
            return ret;
        }
        internal bool TryGetVarSetConst(int endStatementIndex, int endStatementUsingVarIndex, string name, out string val)
        {
            if (endStatementIndex == -1)
                endStatementIndex = Statements.Count - 1;
            bool ret = false;
            val = string.Empty;
            for (int ix = endStatementIndex; ix >= 0; --ix) {
                var stmInfo = Statements[ix];
                if (stmInfo.TryGetVarSetConst(ix < endStatementIndex ? -1 : endStatementUsingVarIndex, name, out var v)) {
                    val = v;
                    ret = true;
                    break;
                }
            }
            return ret;
        }
        internal bool TryGetVarSetOrCacheConst(int endStatementIndex, int endStatementUsingVarIndex, string name, out string val)
        {
            if (endStatementIndex == -1)
                endStatementIndex = Statements.Count - 1;
            bool ret = false;
            val = string.Empty;
            for (int ix = endStatementIndex; ix >= 0; --ix) {
                var stmInfo = Statements[ix];
                if (stmInfo.TryGetVarSetOrCacheConst(ix < endStatementIndex ? -1 : endStatementUsingVarIndex, name, out var v)) {
                    val = v;
                    ret = true;
                    break;
                }
            }
            return ret;
        }

        internal bool FindDeclVarInfo(string name, out BasicBlockStatementInfo? basicBlockStmInfo, out DeclVarInfo? vinfo)
        {
            bool ret = false;
            basicBlockStmInfo = null;
            vinfo = null;
            foreach (var bbsi in Statements) {
                if (bbsi.DeclVars.TryGetValue(name, out vinfo)) {
                    basicBlockStmInfo = bbsi;
                    ret = true;
                    break;
                }
            }
            return ret;
        }
        internal bool FindVarInfo(int endBasicBlockStatementIndex, int endBasicBlockStatementUsingVarIndex, string name, out BasicBlockStatementInfo? basicBlockStmInfo, out BlockVarInfo? vinfo)
        {
            bool ret = false;
            basicBlockStmInfo = null;
            vinfo = null;
            if (endBasicBlockStatementIndex < 0)
                endBasicBlockStatementIndex = Statements.Count - 1;
            for (int ix = 0; ix <= endBasicBlockStatementIndex && ix < Statements.Count; ++ix) {
                var bbsi = Statements[ix];
                if (bbsi.UsingVars.TryGetValue(name, out var uvinfo) && uvinfo.Vars.Count > 0) {
                    int usingVarIndex = (ix < endBasicBlockStatementIndex ? -1 : endBasicBlockStatementUsingVarIndex);
                    if (usingVarIndex < 0)
                        usingVarIndex = uvinfo.Vars.Count - 1;
                    if (usingVarIndex >= 0 && usingVarIndex < uvinfo.Vars.Count) {
                        vinfo = uvinfo.Vars[usingVarIndex];
                        basicBlockStmInfo = bbsi;
                        ret = true;
                        break;
                    }
                }
            }
            return ret;
        }

        internal void Print(int indent, int index)
        {
            Console.WriteLine("{0}===basic block[index:{1}]===", Literal.GetSpaceString(indent), index);
            Console.WriteLine("{0}decl vars:", Literal.GetSpaceString(indent));
            for (int ix = 0; ix < Statements.Count; ++ix) {
                var stmInfo = Statements[ix];
                foreach (var pair in stmInfo.DeclVars) {
                    var vinfo = pair.Value;
                    Console.WriteLine("{0}{1}:{2}[at {3}]", Literal.GetSpaceString(indent + 1), vinfo.Name, vinfo.Type, ix);
                }
            }
            Console.WriteLine("{0}using vars:", Literal.GetSpaceString(indent));
            for (int ix = 0; ix < Statements.Count; ++ix) {
                var stmInfo = Statements[ix];
                foreach (var pair in stmInfo.UsingVars) {
                    var usingVarInfo = pair.Value;
                    var vinfos = usingVarInfo.Vars;
                    for (int vix = 0; vix < vinfos.Count; ++vix) {
                        var vinfo = vinfos[vix];
                        Console.WriteLine("{0}{1}:{2}[at {3}, {4}]({5}) = {6} <- {7}[{8}][{9}]", Literal.GetSpaceString(indent + 1), vinfo.Name, vinfo.Type, ix, vix, vinfo.Usage, vinfo.GetCompileTimeConstDesc(), null != vinfo.OwnerBlock ? vinfo.OwnerBlock.BlockId : "MaybeGlobal", vinfo.OwnerBasicBlockIndex, vinfo.OwnerStatementIndex);
                    }
                }
            }
        }
    }
    internal sealed class BlockInfo
    {
        internal int BlockId = 0;
        internal int CurBasicBlockIndex = 0;

        internal Dictionary<string, string> VarTypesOnPrologue = new Dictionary<string, string>();
        internal Dictionary<string, string> VarCopyTemporaries = new Dictionary<string, string>();
        internal Dictionary<string, string> VarTemporaries = new Dictionary<string, string>();
        internal Dictionary<string, string> AllVarTemporaries = new Dictionary<string, string>();

        internal BlockInfo? Parent = null;
        internal List<BlockInfo> ChildBlocks = new List<BlockInfo>();
        internal List<BasicBlockInfo> BasicBlocks = new List<BasicBlockInfo>();

        internal FuncInfo? OwnerFunc = null;
        internal Dsl.ISyntaxComponent? Syntax = null;
        internal int FuncSyntaxIndex = 0;
        internal Dsl.ISyntaxComponent? Attribute = null;

        internal List<BlockInfo> SubsequentBlocks = new List<BlockInfo>();

        internal Dictionary<string, DeclVarInfo> CurBasicBlockStatementDeclVars
        {
            get {
                return CurBasicBlockStatement().DeclVars;
            }
        }
        internal Dictionary<string, UsingVarInfo> CurBasicBlockStatementUsingVars
        {
            get {
                return CurBasicBlockStatement().UsingVars;
            }
        }

        internal BlockInfo()
        {
            BasicBlocks.Add(new BasicBlockInfo());
            ResetCurBasicBlock(0);
        }
        internal int FindChildIndex(BlockInfo blockInfo, out int sindex)
        {
            sindex = -1;
            int index = -1;
            for (int ix = 0; ix < ChildBlocks.Count; ++ix) {
                var bi = ChildBlocks[ix];
                if (bi == blockInfo) {
                    index = ix;
                    sindex = -1;
                    break;
                }
                else if (bi.Syntax == blockInfo.Syntax) {
                    int six = bi.SubsequentBlocks.IndexOf(blockInfo);
                    if (six >= 0) {
                        index = ix;
                        sindex = six;
                        break;
                    }
                }
            }
            return index;
        }
        internal BlockInfo? FindChild(Dsl.ISyntaxComponent syntax, int ix)
        {
            BlockInfo? blockInfo = null;
            foreach (var bi in ChildBlocks) {
                if (bi.Syntax == syntax) {
                    if (bi.FuncSyntaxIndex == ix) {
                        blockInfo = bi;
                        Debug.Assert(blockInfo.FuncSyntaxIndex == 0);
                    }
                    else {
                        int index = 1;
                        foreach (var sbi in bi.SubsequentBlocks) {
                            if (sbi.FuncSyntaxIndex == ix) {
                                blockInfo = sbi;
                                Debug.Assert(blockInfo.FuncSyntaxIndex == index);
                                break;
                            }
                            ++index;
                        }
                    }
                    break;
                }
            }
            return blockInfo;
        }
        internal void AddChild(BlockInfo child)
        {
            Debug.Assert(null != child.Syntax);
            bool isNewChild = true;
            if (ChildBlocks.Count > 0) {
                var lastChild = ChildBlocks[ChildBlocks.Count - 1];
                if (lastChild.Syntax == child.Syntax && child.FuncSyntaxIndex > 0) {
                    lastChild.SubsequentBlocks.Add(child);
                    isNewChild = false;
                }
            }
            if (isNewChild) {
                ChildBlocks.Add(child);
                BasicBlocks.Add(new BasicBlockInfo());
            }
        }
        internal void ClearChildren()
        {
            ChildBlocks.Clear();
            BasicBlocks.Clear();
            BasicBlocks.Add(new BasicBlockInfo());
            ResetCurBasicBlock(0);
        }
        internal void SetOrAddCurStatement(Dsl.ISyntaxComponent stm)
        {
            SetOrAddCurStatement(stm, null);
        }
        internal void SetOrAddCurStatement(Dsl.ISyntaxComponent stm, Dsl.ISyntaxComponent? attr)
        {
            var bbi = CurBasicBlock();
            int index = bbi.CurStatementIndex + 1;
            var stmInfo = bbi.GetOrAddStatement(index);
            stmInfo.Statement = stm;
            if (null != attr)
                stmInfo.Attribute = attr;
            bbi.CurStatementIndex = index;
        }

        internal BasicBlockInfo CurBasicBlock()
        {
            Debug.Assert(BasicBlocks.Count > 0 && BasicBlocks.Count == ChildBlocks.Count + 1);
            Debug.Assert(CurBasicBlockIndex >= 0 && CurBasicBlockIndex < BasicBlocks.Count);
            return BasicBlocks[CurBasicBlockIndex];
        }
        internal BasicBlockStatementInfo CurBasicBlockStatement()
        {
            var basicBlockInfo = CurBasicBlock();
            return basicBlockInfo.CurStatementInfo();
        }

        internal void ResetCurBasicBlock(int ix)
        {
            CurBasicBlockIndex = ix;
            CurBasicBlock().Reset();
        }
        internal bool SetVarConst(string name, string constVal)
        {
            return CurBasicBlock().SetVarConst(name, constVal);
        }
        internal bool TryGetVarConstInBlockScope(int endBasicBlockIndex, int endBasicBlockStatementIndex, int endBasicBlockStatementUsingVarIndex, string name, BlockInfo queryBlock, out string val)
        {
            if (!IsFuncBlockInfoConstructed()) {
                //数据流分析的数据结构未构建完成前不能决定变量是否具有常量值
                val = string.Empty;
                return false;
            }
            if (this != queryBlock && ExistsDeclVarInCurBlock(name)) {
                val = string.Empty;
                return false;
            }
            if (endBasicBlockIndex == -1)
                endBasicBlockIndex = BasicBlocks.Count - 1;
            Debug.Assert(endBasicBlockIndex >= 0 && endBasicBlockIndex < BasicBlocks.Count);

            bool ret = false;
            if (IsLoopOrInLoop()) {
                val = string.Empty;
                if (ExistsSetVarInBlockScope(0, 0, 0, name, false, queryBlock)) {
                    ret = true;
                }
            }
            else {
                var lastBasicBlock = BasicBlocks[endBasicBlockIndex];
                if (lastBasicBlock.TryGetVarSetConst(endBasicBlockStatementIndex, endBasicBlockStatementUsingVarIndex, name, out val)) {
                    ret = true;
                }
                else {
                    //查找子语句块与基本块（交替进行）
                    for (int ix = endBasicBlockIndex - 1; ix >= 0; --ix) {
                        var blockInfo = ChildBlocks[ix];
                        Debug.Assert(null != blockInfo);
                        bool isLoop = blockInfo.IsLoop();
                        bool isIfBranches = blockInfo.IsIfBranches();
                        bool isSwitchBranches = blockInfo.IsSwitchBranches();
                        if (isLoop) {
                            val = string.Empty;
                            if (blockInfo.ExistsSetVarInBlockScope(0, 0, 0, name, false, queryBlock)) {
                                ret = true;
                                break;
                            }
                        }
                        else if (isIfBranches) {
                            if (blockInfo.IsFullIfBranches()) {
                                bool first = blockInfo.TryGetVarConstInBlockScope(-1, -1, -1, name, queryBlock, out var val0);
                                bool isSame = true;
                                foreach (var sbi in blockInfo.SubsequentBlocks) {
                                    if (sbi.TryGetVarConstInBlockScope(-1, -1, -1, name, queryBlock, out var tval)) {
                                        if (first) {
                                            if (val0 != tval) {
                                                isSame = false;
                                                break;
                                            }
                                        }
                                        else {
                                            isSame = false;
                                            break;
                                        }
                                    }
                                }
                                if (isSame) {
                                    if (first) {
                                        val = val0;
                                        ret = true;
                                        break;
                                    }
                                }
                                else {
                                    val = string.Empty;
                                    ret = true;
                                    break;
                                }
                            }
                            else {
                                val = string.Empty;
                                if (blockInfo.ExistsSetVarInBlockScope(0, 0, 0, name, false, queryBlock)) {
                                    ret = true;
                                    break;
                                }
                                foreach (var sbi in blockInfo.SubsequentBlocks) {
                                    if (sbi.ExistsSetVarInBlockScope(0, 0, 0, name, false, queryBlock)) {
                                        ret = true;
                                        break;
                                    }
                                }
                                if (ret)
                                    break;
                            }
                        }
                        else if (isSwitchBranches) {
                            if (blockInfo.IsFullSwitchBranches()) {
                                bool init = false;
                                bool first = true;
                                string val0 = string.Empty;
                                bool isSame = true;
                                foreach (var cbi in blockInfo.ChildBlocks) {
                                    bool r = cbi.TryGetVarConstInBlockScope(-1, -1, -1, name, queryBlock, out var tval);
                                    if (!init) {
                                        init = true;
                                        first = r;
                                        val0 = tval;
                                    }
                                    else if (r) {
                                        if (first) {
                                            if (val0 != tval) {
                                                isSame = false;
                                                break;
                                            }
                                        }
                                        else {
                                            isSame = false;
                                            break;
                                        }
                                    }
                                }
                                if (isSame) {
                                    if (first) {
                                        val = val0;
                                        ret = true;
                                        break;
                                    }
                                }
                                else {
                                    val = string.Empty;
                                    ret = true;
                                    break;
                                }
                            }
                            else {
                                val = string.Empty;
                                if (blockInfo.ExistsSetVarInBlockScope(0, 0, 0, name, false, queryBlock)) {
                                    ret = true;
                                    break;
                                }
                            }
                        }
                        else {
                            bool find = blockInfo.TryGetVarConstInBlockScope(-1, -1, -1, name, queryBlock, out var val0);
                            if (find) {
                                val = val0;
                                ret = true;
                                break;
                            }
                        }
                        var basicBlock = BasicBlocks[ix];
                        if (basicBlock.TryGetVarSetConst(-1, -1, name, out val)) {
                            ret = true;
                            break;
                        }
                    }
                }
            }
            return ret;
        }
        internal bool TryGetVarConstInParent(string name, BlockInfo queryBlock, out string val)
        {
            if (!IsFuncBlockInfoConstructed()) {
                //数据流分析的数据结构未构建完成前不能决定变量是否具有常量值
                val = string.Empty;
                return false;
            }
            bool ret = false;
            val = string.Empty;
            var parent = Parent;
            if (null != parent) {
                int ix = parent.FindChildIndex(this, out var six);
                //这里不需要判断是否子块的一个分支，多个分支的其它分支里的赋值不会影响当前分支，所以只需要处理当前子块的前导结点即可
                if (parent.TryGetVarConstInBlockScope(ix, -1, -1, name, queryBlock, out val)) {
                    ret = true;
                }
                else {
                    bool findDecl = parent.ExistsDeclVarInCurBlock(name);
                    if (!findDecl) {
                        ret = parent.TryGetVarConstInParent(name, queryBlock, out val);
                    }
                }
            }
            return ret;
        }
        internal bool TryGetVarConstInBasicBlock(int basicBlockIndex, int basicBlockStatementIndex, int basicBlockStatementUsingVarIndex, string name, out string val)
        {
            if (!IsFuncBlockInfoConstructed()) {
                //数据流分析的数据结构未构建完成前不能决定变量是否具有常量值
                val = string.Empty;
                return false;
            }
            Debug.Assert(basicBlockIndex >= 0 && basicBlockIndex < BasicBlocks.Count);
            var basicBlock = BasicBlocks[basicBlockIndex];

            bool ret = false;
            if (IsLoopOrInLoop()) {
                val = string.Empty;
                if (ExistsSetVarInBlockScope(0, 0, 0, name, false, this)) {
                    ret = true;
                }
            }
            else if (basicBlock.TryGetVarSetOrCacheConst(basicBlockStatementIndex, basicBlockStatementUsingVarIndex, name, out val)) {
                ret = true;
            }
            else if (TryGetVarConstInBlockScope(basicBlockIndex, basicBlockStatementIndex, basicBlockStatementUsingVarIndex, name, this, out val)) {
                ret = true;
            }
            else {
                bool findDecl = ExistsDeclVarInCurBlock(name);
                if (findDecl) {
                    ret = false;
                }
                else {
                    ret = TryGetVarConstInParent(name, this, out val);
                }
            }
            if (ret) {
                basicBlock.CacheVarConst(basicBlockStatementIndex, basicBlockStatementUsingVarIndex, name, val);
            }
            return ret;
        }
        internal bool TryGetCurVarConst(string name, out string val)
        {
            return TryGetVarConstInBasicBlock(CurBasicBlockIndex, CurBasicBlock().CurStatementIndex, CurBasicBlockStatement().GetUsingVarIndex(name), name, out val);
        }

        internal bool FindVarInfoInBlockScope(int endBasicBlockIndex, int endBasicBlockStatementIndex, int endBasicBlockStatementUsingVarIndex, string name, BlockInfo queryBlock, out BlockInfo? blockInfo, out BasicBlockInfo? basicBlockInfo, out BasicBlockStatementInfo? basicBlockStmInfo, out BlockVarInfo? vinfo)
        {
            blockInfo = null;
            basicBlockInfo = null;
            basicBlockStmInfo = null;
            vinfo = null;
            if (this != queryBlock && ExistsDeclVarInCurBlock(name)) {
                return false;
            }
            if (endBasicBlockIndex == -1)
                endBasicBlockIndex = BasicBlocks.Count - 1;
            Debug.Assert(endBasicBlockIndex >= 0 && endBasicBlockIndex < BasicBlocks.Count);

            bool ret = false;
            var lastBasicBlock = BasicBlocks[endBasicBlockIndex];
            if (lastBasicBlock.FindVarInfo(endBasicBlockStatementIndex, endBasicBlockStatementUsingVarIndex, name, out basicBlockStmInfo, out vinfo)) {
                blockInfo = this;
                basicBlockInfo = lastBasicBlock;
                ret = true;
            }
            else {
                //查找子语句块与基本块（交替进行）
                for (int ix = endBasicBlockIndex - 1; ix >= 0; --ix) {
                    var cblockInfo = ChildBlocks[ix];
                    Debug.Assert(null != cblockInfo);
                    if (cblockInfo.FindVarInfoInBlockScope(-1, -1, -1, name, queryBlock, out blockInfo, out basicBlockInfo, out basicBlockStmInfo, out vinfo)) {
                        ret = true;
                        break;
                    }
                    foreach (var sbi in cblockInfo.SubsequentBlocks) {
                        if (sbi.FindVarInfoInBlockScope(-1, -1, -1, name, queryBlock, out blockInfo, out basicBlockInfo, out basicBlockStmInfo, out vinfo)) {
                            ret = true;
                            break;
                        }
                    }
                    var basicBlock = BasicBlocks[ix];
                    if (basicBlock.FindVarInfo(-1, -1, name, out basicBlockStmInfo, out vinfo)) {
                        blockInfo = this;
                        basicBlockInfo = basicBlock;
                        ret = true;
                        break;
                    }
                }
            }
            return ret;
        }
        internal bool FindVarInfoInParent(string name, BlockInfo queryBlock, out BlockInfo? blockInfo, out BasicBlockInfo? basicBlockInfo, out BasicBlockStatementInfo? basicBlockStmInfo, out BlockVarInfo? vinfo)
        {
            bool ret = false;
            var parent = Parent;
            if (null != parent) {
                int ix = parent.FindChildIndex(this, out var six);
                //这里不需要判断是否子块的一个分支，多个分支的其它分支里的变量不会影响当前分支，所以只需要处理当前子块的前导结点即可
                if (parent.FindVarInfoInBlockScope(ix, -1, -1, name, queryBlock, out blockInfo, out basicBlockInfo, out basicBlockStmInfo, out vinfo)) {
                    ret = true;
                }
                else {
                    bool findDecl = parent.ExistsDeclVarInCurBlock(name);
                    if (!findDecl) {
                        ret = parent.FindVarInfoInParent(name, queryBlock, out blockInfo, out basicBlockInfo, out basicBlockStmInfo, out vinfo);
                    }
                }
            }
            else {
                blockInfo = null;
                basicBlockInfo = null;
                basicBlockStmInfo = null;
                vinfo = null;
            }
            return ret;
        }
        internal bool FindVarInfoInBasicBlock(int basicBlockIndex, int basicBlockStatementIndex, int basicBlockStatementUsingVarIndex, string name, out BlockInfo? blockInfo, out BasicBlockInfo? basicBlockInfo, out BasicBlockStatementInfo? basicBlockStmInfo, out BlockVarInfo? vinfo)
        {
            bool ret;
            if (FindVarInfoInBlockScope(basicBlockIndex, basicBlockStatementIndex, basicBlockStatementUsingVarIndex, name, this, out blockInfo, out basicBlockInfo, out basicBlockStmInfo, out vinfo)) {
                ret = true;
            }
            else {
                bool findDecl = ExistsDeclVarInCurBlock(name);
                if (findDecl) {
                    ret = false;
                }
                else {
                    ret = FindVarInfoInParent(name, this, out blockInfo, out basicBlockInfo, out basicBlockStmInfo, out vinfo);
                }
            }
            return ret;
        }
        internal bool FindVarInfo(string name, out BlockInfo? blockInfo, out BasicBlockInfo? basicBlockInfo, out BasicBlockStatementInfo? basicBlockStmInfo, out BlockVarInfo? vinfo)
        {
            return FindVarInfoInBasicBlock(CurBasicBlockIndex, CurBasicBlock().CurStatementIndex, CurBasicBlockStatement().GetUsingVarIndex(name), name, out blockInfo, out basicBlockInfo, out basicBlockStmInfo, out vinfo);
        }

        internal Dictionary<string, BlockVarInfo> GetGetOuterVarsInBlockScope(bool excludeDeclInCurBlock)
        {
            var allDeclVars = new HashSet<string>();
            var dict = new Dictionary<string, BlockVarInfo>();
            QueryGetOuterVarsInBlockScope(excludeDeclInCurBlock, this, allDeclVars, dict);
            return dict;
        }
        internal Dictionary<string, BlockVarInfo> GetSetOuterVarsInBlockScope(bool excludeDeclInCurBlock)
        {
            var allDeclVars = new HashSet<string>();
            var dict = new Dictionary<string, BlockVarInfo>();
            QuerySetOuterVarsInBlockScope(excludeDeclInCurBlock, this, allDeclVars, dict);
            return dict;
        }
        internal Dictionary<string, BlockVarInfo> GetSetOuterObjsInBlockScope(bool excludeDeclInCurBlock)
        {
            var allDeclVars = new HashSet<string>();
            var dict = new Dictionary<string, BlockVarInfo>();
            QuerySetOuterObjsInBlockScope(excludeDeclInCurBlock, this, allDeclVars, dict);
            return dict;
        }
        internal void QueryGetOuterVarsInBlockScope(bool excludeDeclInQueryBlock, BlockInfo queryBlock, HashSet<string> excludeVars, Dictionary<string, BlockVarInfo> allGetVars)
        {
            var newExcludeVars = excludeVars;
            if (excludeDeclInQueryBlock || this != queryBlock) {
                newExcludeVars = new HashSet<string>(excludeVars);
                foreach (var bbi in BasicBlocks) {
                    foreach (var bbsi in bbi.Statements) {
                        foreach (var pair in bbsi.DeclVars) {
                            if (!newExcludeVars.Contains(pair.Key))
                                newExcludeVars.Add(pair.Key);
                        }
                    }
                }
            }
            foreach (var bbi in BasicBlocks) {
                foreach (var bbsi in bbi.Statements) {
                    foreach (var pair in bbsi.UsingVars) {
                        if (!newExcludeVars.Contains(pair.Key)) {
                            foreach (var vinfo in pair.Value.Vars) {
                                if (vinfo.Usage == VarUsage.Read) {
                                    allGetVars[pair.Key] = vinfo;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            if (this != queryBlock) {
                foreach (var sbi in SubsequentBlocks) {
                    sbi.QueryGetOuterVarsInBlockScope(excludeDeclInQueryBlock, queryBlock, newExcludeVars, allGetVars);
                }
            }
            foreach (var cbi in ChildBlocks) {
                cbi.QueryGetOuterVarsInBlockScope(excludeDeclInQueryBlock, queryBlock, newExcludeVars, allGetVars);
            }
        }
        internal void QuerySetOuterVarsInBlockScope(bool excludeDeclInQueryBlock, BlockInfo queryBlock, HashSet<string> excludeVars, Dictionary<string, BlockVarInfo> allSetVars)
        {
            var newExcludeVars = excludeVars;
            if (excludeDeclInQueryBlock || this != queryBlock) {
                newExcludeVars = new HashSet<string>(excludeVars);
                foreach (var bbi in BasicBlocks) {
                    foreach (var bbsi in bbi.Statements) {
                        foreach (var pair in bbsi.DeclVars) {
                            if (!newExcludeVars.Contains(pair.Key))
                                newExcludeVars.Add(pair.Key);
                        }
                    }
                }
            }
            foreach (var bbi in BasicBlocks) {
                foreach (var bbsi in bbi.Statements) {
                    foreach (var pair in bbsi.UsingVars) {
                        if (!newExcludeVars.Contains(pair.Key)) {
                            foreach (var vinfo in pair.Value.Vars) {
                                if (vinfo.Usage == VarUsage.Decl || vinfo.Usage == VarUsage.Write) {
                                    allSetVars[pair.Key] = vinfo;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            if (this != queryBlock) {
                foreach (var sbi in SubsequentBlocks) {
                    sbi.QuerySetOuterVarsInBlockScope(excludeDeclInQueryBlock, queryBlock, newExcludeVars, allSetVars);
                }
            }
            foreach (var cbi in ChildBlocks) {
                cbi.QuerySetOuterVarsInBlockScope(excludeDeclInQueryBlock, queryBlock, newExcludeVars, allSetVars);
            }
        }
        internal void QuerySetOuterObjsInBlockScope(bool excludeDeclInQueryBlock, BlockInfo queryBlock, HashSet<string> excludeObjs, Dictionary<string, BlockVarInfo> allSetObjs)
        {
            var newExcludeVars = excludeObjs;
            if (excludeDeclInQueryBlock || this != queryBlock) {
                newExcludeVars = new HashSet<string>(excludeObjs);
                foreach (var bbi in BasicBlocks) {
                    foreach (var bbsi in bbi.Statements) {
                        foreach (var pair in bbsi.DeclVars) {
                            if (!newExcludeVars.Contains(pair.Key))
                                newExcludeVars.Add(pair.Key);
                        }
                    }
                }
            }
            foreach (var bbi in BasicBlocks) {
                foreach (var bbsi in bbi.Statements) {
                    foreach (var pair in bbsi.UsingVars) {
                        if (!newExcludeVars.Contains(pair.Key)) {
                            foreach (var vinfo in pair.Value.Vars) {
                                if (vinfo.Usage == VarUsage.ObjSet) {
                                    allSetObjs[pair.Key] = vinfo;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            if (this != queryBlock) {
                foreach (var sbi in SubsequentBlocks) {
                    sbi.QuerySetOuterObjsInBlockScope(excludeDeclInQueryBlock, queryBlock, newExcludeVars, allSetObjs);
                }
            }
            foreach (var cbi in ChildBlocks) {
                cbi.QuerySetOuterObjsInBlockScope(excludeDeclInQueryBlock, queryBlock, newExcludeVars, allSetObjs);
            }
        }

        internal bool ExistsGetVarInBlockScope(int startBasicBlockIndex, int startBasicBlockStatementIndex, int startBasicBlockStatementUsingVarIndex, string name, bool excludeDeclInQueryBlock, BlockInfo queryBlock)
        {
            bool ret = false;
            bool stop = false;
            if (excludeDeclInQueryBlock || this != queryBlock) {
                stop = ExistsDeclVarInCurBlock(name);
            }
            if (!stop) {
                Debug.Assert(startBasicBlockIndex >= 0 && startBasicBlockIndex < BasicBlocks.Count);

                if (IsLoop()) {
                    startBasicBlockIndex = 0;
                    startBasicBlockStatementIndex = 0;
                }
                for (int bbIx = startBasicBlockIndex; bbIx < BasicBlocks.Count; ++bbIx) {
                    var bbi = BasicBlocks[bbIx];
                    for (int bbsIx = startBasicBlockStatementIndex; bbsIx < bbi.Statements.Count; ++bbsIx) {
                        var bbsi = bbi.Statements[bbsIx];
                        if (bbsi.UsingVars.TryGetValue(name, out var uvinfo)) {
                            if (startBasicBlockStatementUsingVarIndex < 0)
                                startBasicBlockStatementUsingVarIndex = uvinfo.Vars.Count - 1;
                            bool find = false;
                            if (startBasicBlockStatementUsingVarIndex >= 0 && startBasicBlockStatementUsingVarIndex < uvinfo.Vars.Count) {
                                for (int uvix = startBasicBlockStatementUsingVarIndex; uvix < uvinfo.Vars.Count; ++uvix) {
                                    var vinfo = uvinfo.Vars[uvix];
                                    if (vinfo.Usage == VarUsage.Read) {
                                        find = true;
                                        break;
                                    }
                                }
                            }
                            if (find) {
                                ret = true;
                                break;
                            }
                        }
                    }
                    if (ret)
                        break;
                }
                if (!ret) {
                    if (this != queryBlock) {
                        foreach (var sbi in SubsequentBlocks) {
                            if (sbi.ExistsGetVarInBlockScope(0, 0, 0, name, excludeDeclInQueryBlock, queryBlock)) {
                                ret = true;
                                break;
                            }
                        }
                    }
                    foreach (var cbi in ChildBlocks) {
                        if (cbi.ExistsGetVarInBlockScope(0, 0, 0, name, excludeDeclInQueryBlock, queryBlock)) {
                            ret = true;
                            break;
                        }
                    }
                }
            }
            return ret;
        }
        internal bool ExistsSetVarInBlockScope(int startBasicBlockIndex, int startBasicBlockStatementIndex, int startBasicBlockStatementUsingVarIndex, string name, bool excludeDeclInQueryBlock, BlockInfo queryBlock)
        {
            bool ret = false;
            bool stop = false;
            if (excludeDeclInQueryBlock || this != queryBlock) {
                stop = ExistsDeclVarInCurBlock(name);
            }
            if (!stop) {
                Debug.Assert(startBasicBlockIndex >= 0 && startBasicBlockIndex < BasicBlocks.Count);

                if (IsLoop()) {
                    startBasicBlockIndex = 0;
                    startBasicBlockStatementIndex = 0;
                }
                for (int bbIx = startBasicBlockIndex; bbIx < BasicBlocks.Count; ++bbIx) {
                    var bbi = BasicBlocks[bbIx];
                    for (int bbsIx = startBasicBlockStatementIndex; bbsIx < bbi.Statements.Count; ++bbsIx) {
                        var bbsi = bbi.Statements[bbsIx];
                        if (bbsi.UsingVars.TryGetValue(name, out var uvinfo)) {
                            if (startBasicBlockStatementUsingVarIndex < 0)
                                startBasicBlockStatementUsingVarIndex = uvinfo.Vars.Count - 1;
                            bool find = false;
                            if (startBasicBlockStatementUsingVarIndex >= 0 && startBasicBlockStatementUsingVarIndex < uvinfo.Vars.Count) {
                                for (int uvix = startBasicBlockStatementUsingVarIndex; uvix < uvinfo.Vars.Count; ++uvix) {
                                    var vinfo = uvinfo.Vars[uvix];
                                    if (vinfo.Usage == VarUsage.Decl || vinfo.Usage == VarUsage.Write) {
                                        find = true;
                                        break;
                                    }
                                }
                            }
                            if (find) {
                                ret = true;
                                break;
                            }
                        }
                    }
                    if (ret)
                        break;
                }
                if (!ret) {
                    if (this != queryBlock) {
                        foreach (var sbi in SubsequentBlocks) {
                            if (sbi.ExistsSetVarInBlockScope(0, 0, 0, name, excludeDeclInQueryBlock, queryBlock)) {
                                ret = true;
                                break;
                            }
                        }
                    }
                    foreach (var cbi in ChildBlocks) {
                        if (cbi.ExistsSetVarInBlockScope(0, 0, 0, name, excludeDeclInQueryBlock, queryBlock)) {
                            ret = true;
                            break;
                        }
                    }
                }
            }
            return ret;
        }
        internal bool ExistsSetObjInBlockScope(int startBasicBlockIndex, int startBasicBlockStatementIndex, int startBasicBlockStatementUsingVarIndex, string name, bool excludeDeclInQueryBlock, BlockInfo queryBlock)
        {
            bool ret = false;
            bool stop = false;
            if (excludeDeclInQueryBlock || this != queryBlock) {
                stop = ExistsDeclVarInCurBlock(name);
            }
            if (!stop) {
                Debug.Assert(startBasicBlockIndex >= 0 && startBasicBlockIndex < BasicBlocks.Count);

                if (IsLoop()) {
                    startBasicBlockIndex = 0;
                    startBasicBlockStatementIndex = 0;
                }
                for (int bbIx = startBasicBlockIndex; bbIx < BasicBlocks.Count; ++bbIx) {
                    var bbi = BasicBlocks[bbIx];
                    for (int bbsIx = startBasicBlockStatementIndex; bbsIx < bbi.Statements.Count; ++bbsIx) {
                        var bbsi = bbi.Statements[bbsIx];
                        if (bbsi.UsingVars.TryGetValue(name, out var uvinfo)) {
                            if (startBasicBlockStatementUsingVarIndex < 0)
                                startBasicBlockStatementUsingVarIndex = uvinfo.Vars.Count - 1;
                            bool find = false;
                            if (startBasicBlockStatementUsingVarIndex >= 0 && startBasicBlockStatementUsingVarIndex < uvinfo.Vars.Count) {
                                for (int uvix = startBasicBlockStatementUsingVarIndex; uvix < uvinfo.Vars.Count; ++uvix) {
                                    var vinfo = uvinfo.Vars[uvix];
                                    if (vinfo.Usage == VarUsage.ObjSet) {
                                        find = true;
                                        break;
                                    }
                                }
                            }
                            if (find) {
                                ret = true;
                                break;
                            }
                        }
                    }
                    if (ret)
                        break;
                }
                if (!ret) {
                    if (this != queryBlock) {
                        foreach (var sbi in SubsequentBlocks) {
                            if (sbi.ExistsSetObjInBlockScope(0, 0, 0, name, excludeDeclInQueryBlock, queryBlock)) {
                                ret = true;
                                break;
                            }
                        }
                    }
                    foreach (var cbi in ChildBlocks) {
                        if (cbi.ExistsSetObjInBlockScope(0, 0, 0, name, excludeDeclInQueryBlock, queryBlock)) {
                            ret = true;
                            break;
                        }
                    }
                }
            }
            return ret;
        }

        internal bool ExistsGetVarInParent(string name, BlockInfo queryBlock)
        {
            bool ret = false;
            var parent = Parent;
            if (null != parent) {
                int ix = parent.FindChildIndex(this, out var six);
                //不需要考虑子块的其它分支（只有循环时需要考虑，在下面调用里已经处理）
                if (parent.ExistsGetVarInBlockScope(ix + 1, 0, 0, name, false, queryBlock)) {
                    ret = true;
                }
                else {
                    bool findDecl = parent.ExistsDeclVarInCurBlock(name);
                    if (!findDecl) {
                        ret = parent.ExistsGetVarInParent(name, queryBlock);
                    }
                }
            }
            return ret;
        }
        internal bool ExistsSetVarInParent(string name, BlockInfo queryBlock)
        {
            bool ret = false;
            var parent = Parent;
            if (null != parent) {
                int ix = parent.FindChildIndex(this, out var six);
                //不需要考虑子块的其它分支（只有循环时需要考虑，在下面调用里已经处理）
                if (parent.ExistsSetVarInBlockScope(ix + 1, 0, 0, name, false, queryBlock)) {
                    ret = true;
                }
                else {
                    bool findDecl = parent.ExistsDeclVarInCurBlock(name);
                    if (!findDecl) {
                        ret = parent.ExistsSetVarInParent(name, queryBlock);
                    }
                }
            }
            return ret;
        }
        internal bool ExistsSetObjInParent(string name, BlockInfo queryBlock)
        {
            bool ret = false;
            var parent = Parent;
            if (null != parent) {
                int ix = parent.FindChildIndex(this, out var six);
                //不需要考虑子块的其它分支（只有循环时需要考虑，在下面调用里已经处理）
                if (parent.ExistsSetObjInBlockScope(ix + 1, 0, 0, name, false, queryBlock)) {
                    ret = true;
                }
                else {
                    bool findDecl = parent.ExistsDeclVarInCurBlock(name);
                    if (!findDecl) {
                        ret = parent.ExistsSetObjInParent(name, queryBlock);
                    }
                }
            }
            return ret;
        }

        internal bool ExistsGetVarStartBasicBlock(int basicBlockIndex, int basicBlockStatementIndex, int basicBlockStatementUsingVarIndex, string name, bool excludeDeclInCurBlock)
        {
            bool ret;
            if (ExistsGetVarInBlockScope(basicBlockIndex, basicBlockStatementIndex, basicBlockStatementUsingVarIndex, name, excludeDeclInCurBlock, this)) {
                ret = true;
            }
            else {
                bool findDecl = ExistsDeclVarInCurBlock(name);
                if (findDecl) {
                    ret = false;
                }
                else {
                    ret = ExistsGetVarInParent(name, this);
                }
            }
            return ret;
        }
        internal bool ExistsSetVarStartBasicBlock(int basicBlockIndex, int basicBlockStatementIndex, int basicBlockStatementUsingVarIndex, string name, bool excludeDeclInCurBlock)
        {
            bool ret;
            if (ExistsSetVarInBlockScope(basicBlockIndex, basicBlockStatementIndex, basicBlockStatementUsingVarIndex, name, excludeDeclInCurBlock, this)) {
                ret = true;
            }
            else {
                bool findDecl = ExistsDeclVarInCurBlock(name);
                if (findDecl) {
                    ret = false;
                }
                else {
                    ret = ExistsSetVarInParent(name, this);
                }
            }
            return ret;
        }
        internal bool ExistsSetObjStartBasicBlock(int basicBlockIndex, int basicBlockStatementIndex, int basicBlockStatementUsingVarIndex, string name, bool excludeDeclInCurBlock)
        {
            bool ret;
            if (ExistsSetObjInBlockScope(basicBlockIndex, basicBlockStatementIndex, basicBlockStatementUsingVarIndex, name, excludeDeclInCurBlock, this)) {
                ret = true;
            }
            else {
                bool findDecl = ExistsDeclVarInCurBlock(name);
                if (findDecl) {
                    ret = false;
                }
                else {
                    ret = ExistsSetObjInParent(name, this);
                }
            }
            return ret;
        }

        internal bool ExistsUsingVarInCurBlockScope(string name)
        {
            return ExistsGetVarStartBasicBlock(CurBasicBlockIndex, CurBasicBlock().CurStatementIndex, CurBasicBlockStatement().GetUsingVarIndex(name), name, false);
        }
        internal bool ExistsSetVarInCurBlockScope(string name)
        {
            return ExistsSetVarStartBasicBlock(CurBasicBlockIndex, CurBasicBlock().CurStatementIndex, CurBasicBlockStatement().GetUsingVarIndex(name), name, false);
        }
        internal bool ExistsSetObjInCurBlockScope(string name)
        {
            return ExistsSetObjStartBasicBlock(CurBasicBlockIndex, CurBasicBlock().CurStatementIndex, CurBasicBlockStatement().GetUsingVarIndex(name), name, false);
        }

        internal bool ExistsDeclVarInCurBlock(string name)
        {
            return FindDeclVarInCurBlock(name, out var bbi, out var bbsi, out var vi);
        }
        internal bool FindDeclVarInCurBlock(string name, out BasicBlockInfo? basicBlockInfo, out BasicBlockStatementInfo? basicBlockStmInfo, out DeclVarInfo? vinfo)
        {
            bool ret = false;
            basicBlockInfo = null;
            basicBlockStmInfo = null;
            vinfo = null;
            foreach (var bbi in BasicBlocks) {
                if (bbi.FindDeclVarInfo(name, out basicBlockStmInfo, out vinfo))
                    break;
            }
            return ret;
        }

        internal bool IsFuncBlockInfoConstructed()
        {
            Debug.Assert(null != OwnerFunc);
            return OwnerFunc.BlockInfoConstructed;
        }
        internal bool IsLoop()
        {
            Debug.Assert(null != Syntax);
            bool ret = false;
            string syntaxId = Syntax.GetId();
            if (syntaxId == "for" || syntaxId == "while" || syntaxId == "do") {
                ret = true;
            }
            return ret;
        }
        internal bool IsLoopOrInLoop()
        {
            bool ret = IsLoop();
            if (!ret && null != Parent) {
                ret = Parent.IsLoopOrInLoop();
            }
            return ret;
        }
        internal bool IsIfBranches()
        {
            Debug.Assert(null != Syntax);
            bool ret = false;
            string syntaxId = Syntax.GetId();
            if (syntaxId == "if") {
                ret = true;
            }
            return ret;
        }
        internal bool IsSwitchBranches()
        {
            Debug.Assert(null != Syntax);
            bool ret = false;
            string syntaxId = Syntax.GetId();
            if (syntaxId == "switch") {
                ret = true;
            }
            return ret;
        }
        internal bool IsFullIfBranches()
        {
            Debug.Assert(null != Syntax);
            bool ret = false;
            string syntaxId = Syntax.GetId();
            if (syntaxId == "if") {
                if (SubsequentBlocks.Count > 0) {
                    var stm = Syntax as Dsl.StatementData;
                    if (null != stm) {
                        foreach (var sbi in SubsequentBlocks) {
                            var func = stm.GetFunction(sbi.FuncSyntaxIndex);
                            if (null != func && func.GetId() == "else") {
                                ret = true;
                                break;
                            }
                        }
                    }
                }
            }
            return ret;
        }
        internal bool IsFullSwitchBranches()
        {
            Debug.Assert(null != Syntax);
            bool ret = false;
            string syntaxId = Syntax.GetId();
            if (syntaxId == "switch") {
                foreach (var cbi in ChildBlocks) {
                    if (null != cbi && null != cbi.Syntax && cbi.Syntax.GetId() == "default") {
                        ret = true;
                        break;
                    }
                }
            }
            return ret;
        }

        internal void ClearTemporaryInfo()
        {
            VarTypesOnPrologue.Clear();
            VarCopyTemporaries.Clear();
            VarTemporaries.Clear();
            AllVarTemporaries.Clear();
        }
        internal void AddCopyTemporary(string varName, string tempName)
        {
            if (!AllVarTemporaries.ContainsKey(varName)) {
                var vinfo = ProgramTransform.GetVarInfo(varName, VarUsage.Find);
                if (null != vinfo) {
                    VarTypesOnPrologue[varName] = vinfo.Type;
                }
                VarCopyTemporaries.Add(varName, tempName);
                AllVarTemporaries.Add(varName, tempName);
            }
        }
        internal void AddTemporary(string varName, string tempName)
        {
            if (!AllVarTemporaries.ContainsKey(varName)) {
                var vinfo = ProgramTransform.GetVarInfo(varName, VarUsage.Find);
                if (null != vinfo) {
                    VarTypesOnPrologue[varName] = vinfo.Type;
                }
                VarTemporaries.Add(varName, tempName);
                AllVarTemporaries.Add(varName, tempName);
            }
        }
        internal Dictionary<string, string> GetUnionTemporary()
        {
            var dict = new Dictionary<string, string>(VarCopyTemporaries);
            foreach (var pair in VarTemporaries) {
                dict.Add(pair.Key, pair.Value);
            }
            return dict;
        }
        internal bool TryGetTemporary(string varName, out string? tempName)
        {
            bool ret = false;
            if (VarCopyTemporaries.TryGetValue(varName, out tempName)) {
                ret = true;
            }
            else if (VarTemporaries.TryGetValue(varName, out tempName)) {
                ret = true;
            }
            else {
                ret = TryGetTemporaryInParent(varName, out tempName);
            }
            return ret;
        }
        internal bool TryGetTemporaryInParent(string varName, out string? tempName)
        {
            bool ret = false;
            bool findDecl = ExistsDeclVarInCurBlock(varName);
            if (!findDecl && null != Parent) {
                ret = Parent.TryGetTemporary(varName, out tempName);
            }
            else {
                tempName = string.Empty;
            }
            return ret;
        }
        internal void Print(int indent)
        {
            Print(indent, 0);
        }
        internal void Print(int indent, int index)
        {
            Console.WriteLine("{0}===block[id:{1} index:{2}]===", Literal.GetSpaceString(indent), BlockId, index);
            if (null != Syntax) {
                Console.WriteLine("{0}syntax:{1} func index:{2}", Literal.GetSpaceString(indent), Syntax.GetId(), FuncSyntaxIndex);
            }
            if (null != OwnerFunc) {
                Console.WriteLine("{0}owner func:{1}", Literal.GetSpaceString(indent), OwnerFunc.Name);
            }
            Debug.Assert(BasicBlocks.Count == ChildBlocks.Count + 1);
            if (ChildBlocks.Count > 0) {
                Console.WriteLine("{0}==BasicBlock[count:{1}+1] & ChildBlock[count:{1}]==", Literal.GetSpaceString(indent), ChildBlocks.Count);
                for (int ix = 0; ix < BasicBlocks.Count && ix < ChildBlocks.Count; ++ix) {
                    var bbi = BasicBlocks[ix];
                    bbi.Print(indent + 1, ix);
                    var cbi = ChildBlocks[ix];
                    cbi.Print(indent + 1, ix);
                }
            }
            var lastBasicBlock = BasicBlocks[BasicBlocks.Count - 1];
            lastBasicBlock.Print(indent + 1, BasicBlocks.Count - 1);
            if (SubsequentBlocks.Count > 0) {
                Console.WriteLine("{0}==SubsequentBlock[count:{1}]==", Literal.GetSpaceString(indent), SubsequentBlocks.Count);
                for (int ix = 0; ix < SubsequentBlocks.Count; ++ix) {
                    var sbi = SubsequentBlocks[ix];
                    sbi.Print(indent, ix);
                }
            }
        }
    }
}
