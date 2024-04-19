# pyright

[doc](https://github.com/microsoft/pyright/blob/main/docs/configuration.md)

手动添加 `pyrightconfig.json` 文件在根目录中.

```json
// pyrightconfig.json
// https://github.com/microsoft/pyright/blob/main/docs/configuration.md#sample-config-file
{
  "include": [
    "src"
  ],

  "exclude": [
    "**/node_modules",
    "**/__pycache__",
  ],

  // This is useful when diagnosing certain problems like import resolution issues.
  "verboseOutput": true,

  // 以下两个设置都必须要
  "venvPath": ".", // virtual env path
  "venv": ".venv" // virtual env folder name
}
```
