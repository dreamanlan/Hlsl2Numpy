using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Hlsl2Numpy.Analysis
{
    internal struct SemanticInfo
    {
        internal bool NeedComputeGraph = true;

        internal string ResultType = string.Empty;
        internal bool IsVarValRef = false;
        internal string NameOrConst = string.Empty;

        internal ComputeGraphNode? GraphNode = null;

        internal SemanticInfo(bool needComputeGraph)
        {
            Reset(needComputeGraph);
        }
        internal void Reset(bool needComputeGraph)
        {
            NeedComputeGraph = needComputeGraph;

            ResultType = string.Empty;
            IsVarValRef = false;
            NameOrConst = string.Empty;
            GraphNode = null;
        }
        internal void CopyResultFrom(SemanticInfo other)
        {
            ResultType = other.ResultType;
            IsVarValRef = other.IsVarValRef;
            NameOrConst = other.NameOrConst;

            GraphNode = other.GraphNode;
        }
    }
}
