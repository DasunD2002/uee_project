Add-Type -AssemblyName System.Drawing

$sourcePath = Join-Path $PSScriptRoot "..\assets\images\rootly_logo.png"
if (-not (Test-Path $sourcePath)) {
    Write-Error "Source image not found: $sourcePath"
    exit 1
}

$sourceImg = [System.Drawing.Image]::FromFile($sourcePath)

$targets = [ordered]@{
    "mipmap-mdpi" = 48
    "mipmap-hdpi" = 72
    "mipmap-xhdpi" = 96
    "mipmap-xxhdpi" = 144
    "mipmap-xxxhdpi" = 192
}

$foregroundTargets = [ordered]@{
    "mipmap-mdpi" = 108
    "mipmap-hdpi" = 162
    "mipmap-xhdpi" = 216
    "mipmap-xxhdpi" = 324
    "mipmap-xxxhdpi" = 432
}

$resDir = Join-Path $PSScriptRoot "..\android\app\src\main\res"

# 1. Standard and Round Icons
foreach ($key in $targets.Keys) {
    $folder = Join-Path $resDir $key
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }

    $size = $targets[$key]
    $destBitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($destBitmap)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $destRect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
    $graphics.DrawImage($sourceImg, $destRect)

    # Save ic_launcher.png
    $outputPath = Join-Path $folder "ic_launcher.png"
    if (Test-Path $outputPath) { Remove-Item $outputPath -Force }
    $destBitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Save ic_launcher_round.png
    $roundPath = Join-Path $folder "ic_launcher_round.png"
    if (Test-Path $roundPath) { Remove-Item $roundPath -Force }
    $destBitmap.Save($roundPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $graphics.Dispose()
    $destBitmap.Dispose()
    Write-Host "Generated $key standard icon ($size x $size)"
}

# 2. Adaptive Foreground Icons (108dp canvas with ~72dp safe area centered)
foreach ($key in $foregroundTargets.Keys) {
    $folder = Join-Path $resDir $key
    $canvasSize = $foregroundTargets[$key]
    # Scale logo to ~70% of canvas so it's safely inside Android adaptive icon mask
    $iconSize = [int]($canvasSize * 0.70)
    $offset = [int](($canvasSize - $iconSize) / 2)

    $fgBitmap = New-Object System.Drawing.Bitmap($canvasSize, $canvasSize)
    $fgGraphics = [System.Drawing.Graphics]::FromImage($fgBitmap)
    $fgGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $fgGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $fgGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $fgGraphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $destRect = New-Object System.Drawing.Rectangle($offset, $offset, $iconSize, $iconSize)
    $fgGraphics.DrawImage($sourceImg, $destRect)

    $fgPath = Join-Path $folder "ic_launcher_foreground.png"
    if (Test-Path $fgPath) { Remove-Item $fgPath -Force }
    $fgBitmap.Save($fgPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $fgGraphics.Dispose()
    $fgBitmap.Dispose()
    Write-Host "Generated $key adaptive foreground ($canvasSize x $canvasSize)"
}

$sourceImg.Dispose()

# 3. Create values/ic_launcher_background.xml
$valuesDir = Join-Path $resDir "values"
if (-not (Test-Path $valuesDir)) { New-Item -ItemType Directory -Path $valuesDir -Force | Out-Null }
$bgColorXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#FFFFFF</color>
</resources>
"@
Set-Content -Path (Join-Path $valuesDir "ic_launcher_background.xml") -Value $bgColorXml -Encoding UTF8

# 4. Create mipmap-anydpi-v26/ic_launcher.xml
$anyDpiDir = Join-Path $resDir "mipmap-anydpi-v26"
if (-not (Test-Path $anyDpiDir)) { New-Item -ItemType Directory -Path $anyDpiDir -Force | Out-Null }
$adaptiveXml = @"
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"@
Set-Content -Path (Join-Path $anyDpiDir "ic_launcher.xml") -Value $adaptiveXml -Encoding UTF8
Set-Content -Path (Join-Path $anyDpiDir "ic_launcher_round.xml") -Value $adaptiveXml -Encoding UTF8

Write-Host "All Android launcher icons and adaptive XMLs generated successfully!"
