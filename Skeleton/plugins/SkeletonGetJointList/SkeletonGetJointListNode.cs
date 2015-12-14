#region usings

using System;using System.ComponentModel.Composition;using VVVV.PluginInterfaces.V1;using VVVV.Utils.VColor;using VVVV.Utils.VMath;using VVVV.SkeletonInterfaces;using VVVV.Core.Logging;
#endregion usings
namespace VVVV.Nodes{
	public class SkeletonGetJointListNode : IPlugin, IDisposable	{		#region field declaration		private IPluginHost FHost;		private INodeIn FSkeletonInput;        private IStringOut FJointNameOutput;
		private IStringOut FParentNameOutput;
		private Skeleton FSkeleton;		private bool FDisposed = false;		#endregion field declaration
		#region constructor/destructor		public void Dispose()		{			Dispose(true);			GC.SuppressFinalize(this);		}
		protected virtual void Dispose(bool disposing)        {        	// Check to see if Dispose has already been called.        	if(!FDisposed)        	{        		if(disposing)        		{        		}        		FHost.Log(TLogType.Debug, "PluginTemplate is being deleted");        	}        	FDisposed = true;        }
		~SkeletonGetJointListNode()		{			Dispose(false);
		}		#endregion constructor/destructor
		#region node name and infos		private static IPluginInfo FPluginInfo;		public static IPluginInfo PluginInfo		{			get			{				if (FPluginInfo == null)				{					FPluginInfo = new PluginInfo();					FPluginInfo.Name = "GetJointList";					FPluginInfo.Category = "Skeleton";					FPluginInfo.Version = "";					FPluginInfo.Author = "aoi";					FPluginInfo.Help = "GetJointList";					FPluginInfo.Bugs = "";					FPluginInfo.Warnings = "";				}				return FPluginInfo;
			}
		}
		public bool AutoEvaluate		{
			get { return false; }
		}		#endregion node name and infos

        #region pin creation        public void SetPluginHost(IPluginHost host)		{            if (host == null)            {                return;            }
			// create inputs			FHost = host;			var guids = new System.Guid[1];			guids[0] = SkeletonNodeIO.GUID;			FHost.CreateNodeInput("Skeleton", TSliceMode.Single, TPinVisibility.True, out FSkeletonInput);			FSkeletonInput.SetSubType2(typeof(ISkeleton), guids, "Skeleton");			// create outputs			FHost.CreateStringOutput("Joint Name", TSliceMode.Dynamic, TPinVisibility.True, out FJointNameOutput);
			FHost.CreateStringOutput("Parent Name", TSliceMode.Dynamic, TPinVisibility.True, out FParentNameOutput);
		}        #endregion pin creation
        #region mainloop        public void Configurate(IPluginConfig Input)		{			
		}
		//called when data for any output pin is requested		public void Evaluate(int SpreadMax)		{
			if (FSkeletonInput.PinIsChanged)
			{
				if (FSkeletonInput.IsConnected)
				{
					object currInterface;
					FSkeletonInput.GetUpstreamInterface(out currInterface);
					FSkeleton = (Skeleton)currInterface;
				}
				else
				{
					FSkeleton = null;
				}
			}
			
			if (FSkeletonInput.PinIsChanged)
			{
				if (FSkeleton != null)
				{
					int key_count = FSkeleton.JointTable.Keys.Count;
					string[] key_list = new string[key_count];
					FSkeleton.JointTable.Keys.CopyTo(key_list, 0);
					FJointNameOutput.SliceCount = key_count;
					FParentNameOutput.SliceCount = key_count;
					for (int i=0; i<key_count; i++)
					{
						FJointNameOutput.SetString(i, key_list[i]);
						IJoint joint = null;
						FSkeleton.JointTable.TryGetValue(key_list[i], out joint);
						string pname = "";
						if (joint != null && joint.Parent != null)
						{
							pname = joint.Parent.Name;
						}
						FParentNameOutput.SetString(i, pname);
					}
				}
			}		}		#endregion mainloop	}}