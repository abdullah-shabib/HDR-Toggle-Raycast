<#
.SYNOPSIS
    Turn raw Raycast window screenshots into Raycast Store metadata screenshots.

.DESCRIPTION
    Raycast for Windows does not yet have the built-in Window Capture tool, so this
    reproduces its output: it centers each raw screenshot on a 2000x1250 (16:10) canvas
    over a consistent background and writes the results to the metadata/ folder where the
    store expects them. A Snipping Tool "window" capture already includes the window's
    rounded corners and drop shadow on transparency, so those are preserved as-is.

    Workflow:
      1. Run `npm run dev` so the extension loads, arrange each frame in Raycast.
      2. Capture the Raycast window with the Snipping Tool (Win+Shift+S) and save the
         PNGs into a folder (default: .\shots-raw), named so they sort in the order you
         want (e.g. 1.png, 2.png, ...).
      3. Run this script. Output: metadata\hdr-toggle-1.png, -2.png, ...

    Two looks:
      * Rectangle snip (window + wallpaper baked in)  -> run with -Fill (cover, full-bleed).
      * Window snip (just the window, transparent)     -> run without -Fill (window floats
        centered on the script's background / your -Background image).
      Add -Zoom 1.15 to push the content larger in frame.

.PARAMETER InputDir
    Folder containing the raw screenshot PNGs. Default: .\shots-raw

.PARAMETER OutputDir
    Where to write the finished screenshots. Default: .\metadata

.PARAMETER Background
    Optional path to a wallpaper image used as the background (scaled to cover the
    canvas). If omitted, a dark gradient matching the extension icon is used.

.PARAMETER Prefix
    Output file name prefix. Default: hdr-toggle
#>
[CmdletBinding()]
param(
    [string]$InputDir = ".\shots-raw",
    [string]$OutputDir = ".\metadata",
    [string]$Background,
    [string]$Prefix = "hdr-toggle",
    # -Fill: the raw capture already includes the desktop/wallpaper (a Snipping Tool
    # "rectangle" snip), so scale it to cover the whole canvas edge-to-edge instead of
    # centering it on a separate background. Use this for rectangle captures.
    [switch]$Fill,
    # Extra zoom applied on top, center-cropping more of the capture to make the window
    # larger in frame. 1.0 = no extra zoom.
    [double]$Zoom = 1.0
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$CanvasW = 2000
$CanvasH = 1250
$MarginX = 180   # min horizontal padding around the window
$MarginY = 120   # min vertical padding around the window

function New-Background {
    $bmp = New-Object System.Drawing.Bitmap($CanvasW, $CanvasH)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    if ($Background -and (Test-Path $Background)) {
        $src = [System.Drawing.Image]::FromFile((Resolve-Path $Background))
        # Scale to cover, then center-crop.
        $scale = [Math]::Max($CanvasW / $src.Width, $CanvasH / $src.Height)
        $dw = [int]($src.Width * $scale); $dh = [int]($src.Height * $scale)
        $dx = [int](($CanvasW - $dw) / 2); $dy = [int](($CanvasH - $dh) / 2)
        $g.DrawImage($src, $dx, $dy, $dw, $dh)
        $src.Dispose()
    }
    else {
        $rect = New-Object System.Drawing.Rectangle(0, 0, $CanvasW, $CanvasH)
        $c1 = [System.Drawing.Color]::FromArgb(255, 24, 26, 32)
        $c2 = [System.Drawing.Color]::FromArgb(255, 44, 48, 64)
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $c1, $c2, 90)
        $g.FillRectangle($brush, $rect)
        $brush.Dispose()
    }
    return @{ Bitmap = $bmp; Graphics = $g }
}

if (-not (Test-Path $InputDir)) {
    throw "Input folder '$InputDir' not found. Create it and put your raw screenshot PNGs inside (e.g. 1.png, 2.png)."
}
$shots = @(Get-ChildItem -Path $InputDir -Filter *.png | Sort-Object Name)
if ($shots.Count -eq 0) {
    throw "No .png files found in '$InputDir'."
}
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$index = 0
foreach ($shot in $shots) {
    $index++
    $src = [System.Drawing.Image]::FromFile($shot.FullName)

    $bg = New-Background
    $bmp = $bg.Bitmap
    $g = $bg.Graphics

    if ($Fill) {
        # Cover the whole canvas (the capture already has its own background); crop overflow.
        $scale = [Math]::Max($CanvasW / $src.Width, $CanvasH / $src.Height) * $Zoom
    }
    else {
        # Center on the script's background, fitting within the margins. A transparent
        # "window" capture keeps its own rounded corners + shadow over the background.
        $maxW = $CanvasW - ($MarginX * 2)
        $maxH = $CanvasH - ($MarginY * 2)
        $scale = [Math]::Min($maxW / $src.Width, $maxH / $src.Height) * $Zoom
    }
    $w = [int]($src.Width * $scale)
    $h = [int]($src.Height * $scale)
    $x = [int](($CanvasW - $w) / 2)
    $y = [int](($CanvasH - $h) / 2)

    $g.DrawImage($src, $x, $y, $w, $h)

    $outPath = Join-Path $OutputDir "$Prefix-$index.png"
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "Wrote $outPath  ($CanvasW x $CanvasH)"

    $g.Dispose(); $bmp.Dispose(); $src.Dispose()
}

Write-Host "`nDone - $index screenshot(s) in $OutputDir"
