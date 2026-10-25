# Claude Code Space Cleaner
# Interactive tool to identify large directories that can be safely deleted
# Created by Claude Code - Anthropic

# Check disk usage and identify large directories
Write-Host "🔍 Starting disk space analysis..." -ForegroundColor Cyan
$cDrive = Get-PSDrive C
$diskUsage = [math]::Round(($cDrive.Used / $cDrive.TotalSize) * 100, 1)
Write-Host "C: drive is $($cDrive.Used) GB used ($($cDrive.Used / $cDrive.TotalSize * 100)%)" -ForegroundColor Yellow
Write-Host "Available space: $($cDrive.Free) GB" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Find large directories (top 15)
Write-Host "🔍 Scanning for large directories..." -ForegroundColor Cyan
$largeDirs = Get-ChildItem C:\ -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    [PSCustomObject]@{
        Name = $_.Name
        SizeGB = [math]::Round($size/1GB, 2)
        Path = $_.FullName
    }
} | Sort-Object SizeGB -Descending | Select-Object -First 15

# Display results
if ($largeDirs) {
    Write-Host "`n📊 Top 15 Largest Directories on C:" -ForegroundColor Cyan
    $largeDirs | Format-Table -Property Name, SizeGB, Path -AutoSize | Out-String | Write-Host

    Write-Host "`n💡 Safe to delete (with caution):" -ForegroundColor Green
    $largeDirs | ForEach-Object {
        $safeToDelete = $false
        $reason = ""

        # Check if it's a known safe target
        if ($_.Name -like "AppData\Local\*" -or $_.Name -like "Downloads" -or $_.Name -like "Temp" -or $_.Name -like "Temp*") {
            $safeToDelete = $true
            $reason = "Common temporary/user data"
        } elseif ($_.Name -like "WinSxS") {
            $safeToDelete = $true
            $reason = "Windows Component Store (can be cleaned with DISM)"
        } elseif ($_.Name -like "vm_bundles" -or $_.Name -like "vm*") {
            $safeToDelete = $true
            $reason = "Virtual machine bundles (Claude/VM tools)"
        } elseif ($_.Name -like "cache" -or $_.Name -like "cache*") {
            $safeToDelete = $true
            $reason = "Application cache data"
        } elseif ($_.Name -like "temp" -or $_.Name -like "temp*") {
            $safeToDelete = $true
            $reason = "Temporary files"
        } elseif ($_.Name -like "cache") {
            $safeToDelete = $true
            $reason = "Application cache"
        }

        if ($safeToDelete) {
            Write-Host "  ✓ $($_.Name) ($($_.SizeGB) GB) - $reason" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($_.Name) ($($_.SizeGB) GB) - $reason" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "No large directories found!" -ForegroundColor Red
}

Write-Host "`n💡 Safe cleanup commands:" -ForegroundColor Green
Write-Host "  • Run 'uv cache clean' to clean Python package cache" -ForegroundColor Yellow
Write-Host "  • Run 'npm cache clean --force' to clean Node.js cache" -ForegroundColor Yellow
Write-Host "  • Run 'dism /online /cleanup-image /startcomponentcleanup' as Administrator to clean Windows component store" -ForegroundColor Yellow
Write-Host "  • Delete large folders using: Remove-Item -Recurse -Force <path>" -ForegroundColor Yellow
Write-Host "`n⚠️ WARNING: Always verify folder contents before deletion!" -ForegroundColor Red
Write-Host "  Never delete: Windows, Program Files, Documents, Pictures, Videos" -ForegroundColor Red