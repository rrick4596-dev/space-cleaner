# Claude Code Space Cleaner
# Interactive tool to identify large directories that can be safely deleted
# Created by Claude Code - Anthropic

# Check disk usage and identify large directories
Write-Host "Starting disk space analysis..." -ForegroundColor Cyan
$cDrive = Get-PSDrive C
$usedGB = [math]::Round($cDrive.Used / 1GB, 2)
$freeGB = [math]::Round($cDrive.Free / 1GB, 2)
$totalGB = [math]::Round($cDrive.TotalSize / 1GB, 2)
$diskUsage = if ($totalGB -gt 0) { [math]::Round(($usedGB / $totalGB) * 100, 1) } else { 0 }
Write-Host ("C: drive is {0} GB used ({1}%)" -f $usedGB, $diskUsage) -ForegroundColor Yellow
Write-Host ("Available space: {0} GB" -f $freeGB) -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Find large directories (top 15)
Write-Host "Scanning for large directories..." -ForegroundColor Cyan
$largeDirs = Get-ChildItem C:\ -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    [PSCustomObject]@{
        Name = $_.Name
        SizeGB = [math]::Round($size / 1GB, 2)
        Path = $_.FullName
    }
} | Sort-Object SizeGB -Descending | Select-Object -First 15

# Display results
if ($largeDirs) {
    Write-Host "`nTop 15 Largest Directories on C:" -ForegroundColor Cyan
    $largeDirs | Format-Table -Property Name, SizeGB, Path -AutoSize | Out-String | Write-Host

    Write-Host "`nSafe to delete (with caution):" -ForegroundColor Green
    $largeDirs | ForEach-Object {
        $safeToDelete = $false
        $reason = ""

        # Check if it's a known safe target
        if ($_.Name -like "AppData\Local\*" -or $_.Name -like "Downloads" -or $_.Name -eq "Temp") {
            $safeToDelete = $true
            $reason = "Common temporary/user data"
        } elseif ($_.Name -eq "WinSxS") {
            $safeToDelete = $true
            $reason = "Windows Component Store (clean with DISM)"
        } elseif ($_.Name -like "vm_bundles" -or $_.Name -like "vm*") {
            $safeToDelete = $true
            $reason = "Virtual machine bundles (Claude/VM tools)"
        } elseif ($_.Name -like "cache*" -or $_.Name -eq "cache") {
            $safeToDelete = $true
            $reason = "Application cache data"
        } elseif ($_.Name -like "temp*" -or $_.Name -eq "Temp") {
            $safeToDelete = $true
            $reason = "Temporary files"
        }

        if ($safeToDelete) {
            Write-Host ("  [OK] {0} ({1} GB) - {2}" -f $_.Name, $_.SizeGB, $reason) -ForegroundColor Green
        } else {
            Write-Host ("  [!] {0} ({1} GB) - {2}" -f $_.Name, $_.SizeGB, $reason) -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "No large directories found!" -ForegroundColor Red
}

Write-Host "`nSafe cleanup commands:" -ForegroundColor Green
Write-Host "  * Run 'uv cache clean' to clean Python package cache" -ForegroundColor Yellow
Write-Host "  * Run 'npm cache clean --force' to clean Node.js cache" -ForegroundColor Yellow
Write-Host "  * Run 'dism /online /cleanup-image /startcomponentcleanup' as Administrator to clean Windows component store" -ForegroundColor Yellow
Write-Host "  * Delete large folders using: Remove-Item -Recurse -Force <path>" -ForegroundColor Yellow
Write-Host "`nWARNING: Always verify folder contents before deletion!" -ForegroundColor Red
Write-Host "  Never delete: Windows, Program Files, Documents, Pictures, Videos" -ForegroundColor Red