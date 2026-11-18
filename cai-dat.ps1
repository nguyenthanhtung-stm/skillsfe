# Cài các skill FE trong repo này vào Claude (Desktop / Code) trên máy hiện tại.
# Chạy: powershell -ExecutionPolicy Bypass -File <repo>\cai-dat.ps1
# Cập nhật về sau: git pull trong repo (skill được liên kết junction, không cần cài lại).
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8

function Bao($s, $mau = "Gray") { Write-Host $s -ForegroundColor $mau }
$repo = $PSScriptRoot
$dich = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force $dich | Out-Null

foreach ($sk in Get-ChildItem (Join-Path $repo "skills") -Directory) {
    $dst = Join-Path $dich $sk.Name
    $item = Get-Item $dst -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq "Junction" -and $item.Target -contains $sk.FullName) {
        Bao "  $($sk.Name): đã liên kết sẵn" Green; continue
    }
    if ($item) {
        if ($item.LinkType) { $item.Delete() }
        else {
            $bak = "$dst.bak-$(Get-Date -Format yyyyMMddHHmmss)"
            Move-Item $dst $bak; Bao "  $($sk.Name): bản cũ chuyển sang $bak" Yellow
        }
    }
    New-Item -ItemType Junction -Path $dst -Target $sk.FullName | Out-Null
    Bao "  $($sk.Name): đã liên kết → $($sk.FullName)" Green
}

foreach ($c in "node", "git") {
    if (Get-Command $c -ErrorAction SilentlyContinue) { Bao "  $($c): có" Green } else { Bao "  $($c): THIẾU — cần cho dự án Next.js" Yellow }
}
Bao "Xong. Mở phiên Claude mới để nạp skill."
