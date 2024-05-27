# pyproject.toml

[pyright](https://github.com/microsoft/pyright/blob/main/docs/configuration.md#sample-pyprojecttoml-file)

[ruff](https://docs.astral.sh/ruff/tutorial/#configuration)

pyright 单独的设置文件为 `pyrightconfig.json`.

ruff 单独的设置文件为 `ruff.toml` 和 `pyproject.toml` 设置内容完全一样.

使用 pyproject 可以同时添加 pyright 和 ruff 两个 lsp 的设置.

```toml
[tool.pyright]
include = ["src"]
exclude = [
  "**/node_modules",
  "**/__pycache__",
  "src/experimental",
  "src/typestubs"
]

executionEnvironments = [
  { root = "src/web", pythonVersion = "3.5", pythonPlatform = "Windows", extraPaths = [ "src/service_libs" ] },
  { root = "src/sdk", pythonVersion = "3.0", extraPaths = [ "src/backend" ] },
  { root = "src/tests", extraPaths = ["src/tests/e2e", "src/sdk" ]},
  { root = "src" }
]
verboseOutput = true # This is useful when diagnosing certain problems like import resolution issues.
venvPath = "."  # virtual env path
venv = ".venv"  # virtual env folder name

[tool.ruff]
# Set the maximum line length to 79.
line-length = 79

[tool.ruff.lint]
# Add the `line-too-long` rule to the enforced rule set. By default, Ruff omits rules that
# overlap with the use of a formatter, like Black, but we can override this behavior by
# explicitly adding the rule.
extend-select = ["E501"]
```

<br />

# pyrightconfig.json

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
