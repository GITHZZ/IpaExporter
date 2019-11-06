using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;

namespace IpaExporter
{
	public class _Builder
	{
		static void BuildApp()
		{
//理论上不允许修改------------
            string[] LEVELS = new string[]
            {
                ${packScene}
            };
            
            string exportPath = ${exportPath};
            string exportXcodePath = ${exportXcodePath};
            
			//获取shell脚本参数
			string args = "";
			string[] strs = System.Environment.GetCommandLineArgs(); 
			foreach(var s in strs)
			{
				if(s.Contains("-args"))
				{
                    //参数必须是json格式
					args = s.Split('_')[1];
				}
			}
            
            string path = string.Format("{0}/{1}", exportPath, "xcodeproj_create_Result.txt");
            if (File.Exists(path))
                File.Delete(path);//删除文件

            //创建结果标记文件
            FileStream fs = new FileStream(path, FileMode.OpenOrCreate, FileAccess.ReadWrite);

            //必须参数
			PlayerSettings.iOS.sdkVersion = iOSSdkVersion.DeviceSDK;
            _CustomBuilder customBuilder = new _CustomBuilder();
            JsonData jsonObj = JsonMapper.ToObject(args);

            customBuilder.BuildApp(jsonObj, LEVELS, exportXcodePath);
            
            //如果成功写入结果到文件
            StreamWriter writer = new StreamWriter(fs);
            writer.WriteLine("*****SUCCESS*****");
            writer.Close();
//理论上不允许修改------------
		}
	}
}
