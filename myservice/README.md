# README

## 1. 执行权限

```
chmod +x ./battery_check.applescript
chmod +x ./top_recorder.sh
chmod +x ./nvim_clean.sh
```

## 2. 修改 plist 中的命令行工具路径


```xml
<!-- 只能使用绝对路径 -->
<array>
	<string>/absolut/path/to/nvim_clean.sh</string>
</array>
```

## 3. 注册服务

将 plist 文件放入 `~/Library/LaunchAgents/`

