#$1 unity工程路径
#$2 导出路径
#$3 沙盒路径

#echo "打包信息"
#echo "导出路径(xcode工程和ipa):"$2

unity_project_path=$1
export_path=$2
bundle_res_path=$3

#--------------生成母包工程
#
pkill Unity
cd ${unity_project_path}
args_config=$(cat ${bundle_res_path}'/TempCode/Builder/Users/_CustomConfig.json'| sed s/[[:space:]]//g | tr -d '\n')

#生成xcode工程
/Applications/Unity/Unity.app/Contents/MacOS/Unity -buildTarget Ios -bacthmode -quit -projectPath ${unity_project_path} -executeMethod IpaExporter.Builder.BuildApp -logFile ${export_path}/xcodeproj_create_log.txt -args_${args_config}

echo "[配置信息]Unity日志路径:"${export_path}

grep "Completed 'Build.Player.iOSSupport'" ${export_path}/xcodeproj_create_log.txt
grep "error CS" ${export_path}/xcodeproj_create_log.txt
