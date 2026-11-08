# 发布前检查

在仓库根目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\check-publish.ps1
```

它会依次检查：

1. `package.json` 里还有没有 `REPLACE-ME` 占位符（漏改会发布死链）
2. `dsh.bundle.patch` 是否指向存在的文件
3. `files` 里列的文件是否都在
4. `icon.svg` 是否超过 256 KiB
5. `locale/*.json` 能否解析、是否带了 `meta.title` 和 `meta.description`
6. `index.js` 能否被 Node 作为 ESM 导入，是否导出 `apply`

全绿之后输出发布步骤；有红项就退出，不会让你带着问题发出去。
