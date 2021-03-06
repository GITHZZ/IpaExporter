using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;

//注意:${xxx} xxx代表是objc方法
namespace IpaExporter
{
	public class _Builder
	{
		static void BuildApp()
		{
//理论上不允许修改------------
            string[] LEVELS = new string[]
            {
                ${objcfunc_BuilderCSFileEdit_getPackScenePath} //form objc
            };
            
            string exportPath = ${objcfunc_BuilderCSFileEdit_getExportPath};
            string exportXcodePath = ${objcfunc_BuilderCSFileEdit_getXcodeExportPath};
            
			//获取shell脚本参数
			string args = "";
            string productName = "";
			string[] strs = System.Environment.GetCommandLineArgs(); 
			foreach(var s in strs)
			{
				if(s.Contains("-args"))
				{
                    //参数必须是json格式
					args = s.Split('_')[1];
				}
    
                if(s.Contains("-productName"))
                {
                    productName = s.Split('_')[1];
                }
			}
            
            string path = string.Format("{0}/{1}", exportPath, "xcodeproj_create_Result.txt");
            if (File.Exists(path))
                File.Delete(path);//删除文件

            //必须参数
			PlayerSettings.iOS.sdkVersion = iOSSdkVersion.DeviceSDK;
            _CustomBuilder customBuilder = new _CustomBuilder();
            
            //获取配置信息
            JsonData allPlatformInfo = JsonMapper.ToObject(args);
            JsonData platformItem = new JsonData();
            if(allPlatformInfo.Keys.Contains(productName)){
                platformItem = allPlatformInfo[productName];
            }else{
                Debug.LogError("不存在" + productName + "配置信息");
            }
            
            customBuilder.BuildApp(platformItem, LEVELS, exportXcodePath);
            
            //如果成功写入结果到文件
            //创建结果标记文件
            FileStream fs = new FileStream(path, FileMode.OpenOrCreate, FileAccess.ReadWrite);
            StreamWriter writer = new StreamWriter(fs);
            writer.WriteLine("*****SUCCESS*****");
            writer.Close();
//理论上不允许修改------------
		}
	}
}
