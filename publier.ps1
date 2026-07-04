# Script de publication de Suivi Sante
# Double-cliquer sur publier.bat pour le lancer.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$apkDest = Join-Path (Split-Path $PSScriptRoot) "suivi sante apk and stuff\SuiviSante.apk"

# --- 1. Demander la nouvelle version ---
$cur = (Get-Content version.json -Raw | ConvertFrom-Json).version
Write-Host ""
Write-Host "=== Publication de Suivi Sante ===" -ForegroundColor Cyan
Write-Host "Version actuelle : $cur"
$ver = Read-Host "Nouvelle version (exemple: 1.6)"
if (-not $ver) { Write-Host "Annule."; exit 1 }
$notes = Read-Host "Quoi de neuf ? (une phrase)"
if (-not $notes) { $notes = "Mise a jour" }

# --- 2. Mettre a jour les numeros de version ---
Write-Host ""
Write-Host "[1/5] Mise a jour des numeros de version..." -ForegroundColor Yellow
$idx = "www\index.html"
$h = Get-Content $idx -Raw -Encoding UTF8
$h = $h -replace 'var APP_VERSION = "[^"]*";', "var APP_VERSION = `"$ver`";"
[IO.File]::WriteAllText((Join-Path $PSScriptRoot $idx), $h, (New-Object Text.UTF8Encoding $false))

$gradlePath = "android\app\build.gradle"
$g = Get-Content $gradlePath -Raw
$code = [int][regex]::Match($g, 'versionCode (\d+)').Groups[1].Value + 1
$g = $g -replace 'versionCode \d+', "versionCode $code"
$g = $g -replace 'versionName "[^"]*"', "versionName `"$ver`""
[IO.File]::WriteAllText((Join-Path $PSScriptRoot $gradlePath), $g, (New-Object Text.UTF8Encoding $false))

$vj = [ordered]@{
  version = $ver
  apkUrl  = "https://github.com/ChewyQc/suivi-sante-app/releases/latest/download/SuiviSante.apk"
  notes   = $notes
} | ConvertTo-Json
[IO.File]::WriteAllText((Join-Path $PSScriptRoot "version.json"), $vj, (New-Object Text.UTF8Encoding $false))

# --- 3. Compiler l'APK ---
Write-Host "[2/5] Synchronisation Capacitor..." -ForegroundColor Yellow
npx cap sync android
if ($LASTEXITCODE -ne 0) { throw "La synchronisation a echoue." }

Write-Host "[3/5] Compilation de l'APK..." -ForegroundColor Yellow
Push-Location android
.\gradlew.bat assembleDebug --console=plain
$buildOk = ($LASTEXITCODE -eq 0)
Pop-Location
if (-not $buildOk) { throw "La compilation a echoue." }
Copy-Item "android\app\build\outputs\apk\debug\app-debug.apk" $apkDest -Force
Write-Host "APK copie vers : $apkDest"

# --- 4. Envoyer sur GitHub ---
Write-Host "[4/5] Envoi du code sur GitHub..." -ForegroundColor Yellow
git add -A
git commit -m "Version $ver - $notes"
git push
if ($LASTEXITCODE -ne 0) { throw "Le git push a echoue." }

# --- 5. Publier la release avec l'APK ---
Write-Host "[5/5] Publication de la release v$ver..." -ForegroundColor Yellow
$tmp = [IO.Path]::GetTempFileName()
"protocol=https`nhost=github.com`n" | Out-File $tmp -Encoding ascii
$cred = cmd /c "git credential fill < `"$tmp`""
Remove-Item $tmp
$token = ($cred | Where-Object { $_ -like "password=*" }) -replace "^password=", ""
if (-not $token) { throw "Identifiants GitHub introuvables. Fais un git push manuel d'abord." }
$env:GH_TOKEN = $token
& ".tools\bin\gh.exe" release create "v$ver" $apkDest --title "Version $ver" --notes $notes
if ($LASTEXITCODE -ne 0) { throw "La creation de la release a echoue." }

Write-Host ""
Write-Host "=== TERMINE ! Version $ver publiee. ===" -ForegroundColor Green
Write-Host "Le telephone la proposera d'ici environ 5 minutes (cache GitHub)."
