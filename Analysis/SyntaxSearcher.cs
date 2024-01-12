using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using static Hlsl2Numpy.Program;

namespace Hlsl2Numpy
{
    internal struct SyntaxStackInfo
    {
        internal Dsl.ISyntaxComponent Syntax;
        internal int Index;

        internal SyntaxStackInfo(Dsl.ISyntaxComponent syntax, int index)
        {
            Syntax = syntax;
            Index = index;
        }
    }
    internal static class SyntaxSearcher
    {
        internal delegate bool SyntaxPredDelegation(Dsl.ISyntaxComponent info, int index, IEnumerable<SyntaxStackInfo> syntaxStack);

        internal static bool Search(Dsl.ISyntaxComponent info, SyntaxPredDelegation pred)
        {
            var syntaxStack = new Stack<SyntaxStackInfo>();
            return IterateSyntax(info, 0, syntaxStack, pred);
        }

        private static bool IterateSyntax(Dsl.ISyntaxComponent info, int index, Stack<SyntaxStackInfo> syntaxStack, SyntaxPredDelegation pred)
        {
            bool ret = false;
            ret = pred(info, index, syntaxStack);
            if (!ret) {
                var valData = info as Dsl.ValueData;
                var funcData = info as Dsl.FunctionData;
                var stmData = info as Dsl.StatementData;
                if (null != valData) {
                    ret = IterateValue(valData, index, syntaxStack, pred);
                }
                else if (null != funcData) {
                    ret = IterateFunction(funcData, index, syntaxStack, pred);
                }
                else if (null != stmData) {
                    ret = IterateStatement(stmData, index, syntaxStack, pred);
                }
            }
            return ret;
        }
        private static bool IterateValue(Dsl.ValueData valData, int index, Stack<SyntaxStackInfo> syntaxStack, SyntaxPredDelegation pred)
        {
            return false;
        }
        private static bool IterateFunction(Dsl.FunctionData funcData, int index, Stack<SyntaxStackInfo> syntaxStack, SyntaxPredDelegation pred)
        {
            bool ret = false;
            syntaxStack.Push(new SyntaxStackInfo(funcData, index));
            if (funcData.IsHighOrder) {
                ret = IterateSyntax(funcData.LowerOrderFunction, -1, syntaxStack, pred);
            }
            else {
                ret = IterateSyntax(funcData.Name, -1, syntaxStack, pred);
            }
            if (!ret) {
                int cindex = 0;
                foreach (var p in funcData.Params) {
                    ret = IterateSyntax(p, cindex, syntaxStack, pred);
                    if (ret)
                        break;
                    ++cindex;
                }
            }
            syntaxStack.Pop();
            return ret;
        }
        private static bool IterateStatement(Dsl.StatementData stmData, int index, Stack<SyntaxStackInfo> syntaxStack, SyntaxPredDelegation pred)
        {
            bool ret = false;
            int cindex = 0;
            syntaxStack.Push(new SyntaxStackInfo(stmData, index));
            foreach (var func in stmData.Functions) {
                ret = IterateSyntax(func, cindex, syntaxStack, pred);
                if (ret)
                    break;
                ++cindex;
            }
            syntaxStack.Pop();
            return ret;
        }
    }
}