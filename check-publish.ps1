# 发布前检查：占位符、清单、图标、locale、模块导出
# 用法：powershell -ExecutionPolicy Bypass -File .\check-publish.ps1

$ErrorActionPreference = 'Stop'
$fail = 0
function Ok($m)   { Write-Host "  [OK]   $m" -ForegroundColor Green }
function Bad($m)  { Write-Host "  [FAIL] $m" -ForegroundColor Red; $script:fail++ }

Write-Host "`n== package.json ==" -ForegroundColor Cyan
$raw = Get-Content .\package.json -Raw
$pkg = $raw | ConvertFrom-Json

if ($raw -match 'REPLACE-ME') { Bad "还有 REPLACE-ME 占位符（author / repository / homepage / bugs）" }
else { Ok "占位符已替换" }

Ok "$($pkg.name)@$($pkg.version)"

if (-not $pkg.publishConfig.access) { Bad "缺少 publishConfig.access = public" }
else { Ok "publishConfig.access = $($pkg.publishConfig.access)" }

if (-not $pkg.dsh.bundle.patch) { Bad "缺少 dsh.bundle.patch" }
elseif (-not (Test-Path $pkg.dsh.bundle.patch)) { Bad "patch 文件不存在：$($pkg.dsh.bundle.patch)" }
else { Ok "dsh.bundle.patch -> $($pkg.dsh.bundle.patch)" }

Write-Host "`n== files 清单 ==" -ForegroundColor Cyan
foreach ($f in $pkg.files) {
  if ($f -like '*`**') {
    $dir = Split-Path $f -Parent
    $pat = Split-Path $f -Leaf
    $hit = @(Get-ChildItem -Path (Join-Path '.' $dir) -Filter $pat -ErrorAction SilentlyContinue)
    if ($hit.Count -eq 0) { Bad "通配符无匹配：$f" } else { Ok "$f -> $($hit.Count) 个文件" }
  } else {
    if (Test-Path $f) { Ok $f } else { Bad "清单里有、磁盘上没有：$f" }
  }
}

Write-Host "`n== icon ==" -ForegroundColor Cyan
if (Test-Path .\icon.svg) {
  $size = (Get-Item .\icon.svg).Length
  if ($size -gt 262144) { Bad "icon 超过 256 KiB（当前 $size 字节）" }
  else { Ok "icon.svg $size 字节" }
} else { Bad "缺少 icon.svg" }

Write-Host "`n== locale ==" -ForegroundColor Cyan
foreach ($f in Get-ChildItem .\locale\*.json) {
  try {
    $j = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $j.meta.title) { Bad "$($f.Name) 缺 meta.title" }
    elseif (-not $j.meta.description) { Bad "$($f.Name) 缺 meta.description" }
    else { Ok "$($f.Name) $($j.meta.title)" }
  } catch { Bad "$($f.Name) 不是合法 JSON：$($_.Exception.Message)" }
}

Write-Host "`n== 模块导出 ==" -ForegroundColor Cyan
$probe = Join-Path $env:TEMP ("dsh-probe-" + [guid]::NewGuid().ToString('N') + ".mjs")
@"
import { pathToFileURL } from 'node:url'
try {
  const m = await import(pathToFileURL(process.argv[2]).href)
  const missing = ['apply'].filter(k => typeof m[k] !== 'function')
  if (missing.length) { console.error('缺导出: ' + missing.join(',')); process.exit(1) }
  console.log('exports: ' + Object.keys(m).join(', '))
} catch (e) { console.error(e.message); process.exit(1) }
"@ | Set-Content -Path $probe -Encoding UTF8

$out = & node $probe (Resolve-Path .\index.js).Path 2>&1
Remove-Item $probe -Force -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) { Bad "index.js 无法加载：$out" } else { Ok $out }

Write-Host ""
if ($fail -gt 0) {
  Write-Host "$fail 项未通过，先修好再发布。" -ForegroundColor Red
  exit 1
}
Write-Host "全部通过。接下来：" -ForegroundColor Green
Write-Host "  1) git init && git add . && git commit -m `"v$($pkg.version)`""
Write-Host "  2) 在 github.com 新建空仓库，git remote add origin <url> && git push -u origin main"
Write-Host "  3) npm login"
Write-Host "  4) npm publish --access public"
Write-Host "  5) 给仓库打 dsh-plugin topic"
