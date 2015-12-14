#region usings

using System;
#endregion usings
namespace VVVV.Nodes
	public class SkeletonGetJointListNode : IPlugin, IDisposable
		private IStringOut FParentNameOutput;
		private Skeleton FSkeleton;
		#region constructor/destructor
		protected virtual void Dispose(bool disposing)
		~SkeletonGetJointListNode()
		}
		#region node name and infos
			}
		}
		public bool AutoEvaluate
			get { return false; }
		}

        #region pin creation
			// create inputs
			FHost.CreateStringOutput("Parent Name", TSliceMode.Dynamic, TPinVisibility.True, out FParentNameOutput);
		}
        #region mainloop
		}
		//called when data for any output pin is requested
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
			}