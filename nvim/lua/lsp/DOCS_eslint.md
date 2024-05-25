# eslint

[eslint doc](https://eslint.org/docs/latest/use/getting-started)

## 安装 eslint

```bash
# 注意: 这里不能使用 --save-dev 否则下面 npm init @eslint/config 报错.
# 执行了 npm init @eslint/config 之后, eslint 会被移到 devDependencies 中.
npm install eslint

# 初始化 eslint config, 选择 commonjs
npm init @eslint/config
```

配置 eslint

```javascript
// eslint.config.mjs
export default [
  // ...
  {
    rules: {
      // "off" or 0 - turn the rule off
      // "warn" or 1 - turn the rule on as a warning (doesn’t affect exit code)
      // "error" or 2 - turn the rule on as an error (exit code will be 1)
      'no-unused-vars': 1,
    },
  },
];
```

<br />

## 安装 jest 用于测试

[jest doc](https://jestjs.io/docs/getting-started)

```bash
npm install --save-dev jest
```

```json
// package.json
// 设置后可以使用命令 npm test <file> 来测试
{
  "scripts": {
    "test": "jest"
  }
}
```

<br />

## eslint + jest rules (optional)

不安装 eslint-plugin-jest, eslint 会对 jest 中的函数报错, eg: test(), 不影响文件执行, 只是 linter 报错.

```bash
npm install --save-dev eslint-plugin-jest
```

`eslint.config.mjs` 中添加以下设置.

```javascript
// eslint.config.mjs
import jest from 'eslint-plugin-jest';

export default [
  // ...
  {
    files: ['*.test.js'],
    ...jest.configs['flat/recommended'],
  },
];
```
