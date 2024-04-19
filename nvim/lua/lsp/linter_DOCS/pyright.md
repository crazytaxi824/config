# pyright

[doc](https://github.com/microsoft/pyright/blob/main/docs/configuration.md)

手动添加 `pyrightconfig.json` 文件在根目录中.

```json
// pyrightconfig.json
{
  "executionEnvironments": [
    {
      "extraPaths": ["src"] // Additional search paths that will be used when searching for modules imported by files.
    }
  ],
  "verboseOutput": true, // This is useful when diagnosing certain problems like import resolution issues.

  // 以下两个设置都必须要
  "venvPath": ".", // virtual env path
  "venv": ".venv" // virtual env folder name
}
```
