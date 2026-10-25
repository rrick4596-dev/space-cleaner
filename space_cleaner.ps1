# =============================================================================
# Claude Code Space Cleaner - Interactive TreeSize-like Disk Analysis Tool
# =============================================================================
# Scans your C: drive, shows directories in a color-coded tree view,
# identifies safe-to-delete folders, and suggests cleanup commands.
# Created by Claude Code - Anthropic
# =============================================================================

# --- Configuration ---
$MAX_DEPTH = 3
$MAX_ITEMS_PER_LEVEL = 12
$SAFE_EXCLUSIONS = @("$Recycle.Bin", "System Volume Information")
$SHOW_HELP_AT_START = $true

# --- Colors ---
$COLOR_HEADER = "Cyan"
$COLOR_SAFE = "Green"
$COLOR_CAUTION = "Yellow"
$COLOR_CRITICAL = "Red"
$COLOR_INFO = "White"
$COLOR_WARNING = "Magenta"

# --- Functions ---

function Show-Instructions {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor $COLOR_HEADER
    Write-Host "       CLAUDE CODE SPACE CLEANER v1.0" -ForegroundColor $COLOR_HEADER
    Write-Host "================================================" -ForegroundColor $COLOR_HEADER
    Write-Host ""
    Write-Host "WHAT THIS TOOL DOES:" -ForegroundColor $COLOR_INFO
    Write-Host "  Scans your C: drive and shows directories in a tree view" -ForegroundColor $COLOR_INFO
    Write-Host "  Color-codes folders by size and safety" -ForegroundColor $COLOR_INFO
    Write-Host "  Lets you drill into folders to explore subfolders" -ForegroundColor $COLOR_INFO
    Write-Host "  Suggests safe cleanup commands to free disk space" -ForegroundColor $COLOR_INFO
    Write-Host ""
    Write-Host "COLOR CODES:" -ForegroundColor $COLOR_INFO
    Write-Host "  [GREEN]  = Safe to delete (cache, temp, VM bundles)" -ForegroundColor $COLOR_SAFE
    Write-Host "  [YELLOW] = Caution - system or app data (review before deleting)" -ForegroundColor $COLOR_CAUTION
    Write-Host "  [RED]    = Critical system files (NEVER delete directly)" -ForegroundColor $COLOR_CRITICAL
    Write-Host ""
    Write-Host "HOW TO USE:" -ForegroundColor $COLOR_INFO
    Write-Host "  1. Review the directory tree below" -ForegroundColor $COLOR_INFO
    Write-Host "  2. Type a folder number to drill into that folder" -ForegroundColor $COLOR_INFO
    Write-Host "  3. Type 'b' to go back to parent folder" -ForegroundColor $COLOR_INFO
    Write-Host "  4. Type 'c' to see cleanup commands" -ForegroundColor $COLOR_INFO
    Write-Host "  5. Type 'q' or 'quit' to exit" -ForegroundColor $COLOR_INFO
    Write-Host ""
    Write-Host "SAFETY WARNING:" -ForegroundColor $COLOR_WARNING
    Write-Host "  NEVER delete: Windows, Program Files, Documents, Pictures, Videos" -ForegroundColor $COLOR_WARNING
    Write-Host "  Always verify folder contents before deleting anything!" -ForegroundColor $COLOR_WARNING
    Write-Host ""
    Write-Host "Press any key to start scanning..." -ForegroundColor $COLOR_INFO
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Get-DirectorySize {
    param([string]$Path)
    try {
        $size = (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        return [math]::Round($size / 1GB, 2)
    } catch {
        return 0
    }
}

function Show-SizeBar {
    param([double]$SizeGB, [double]$MaxGB = 100)
    $barLength = 40
    $filled = [math]::Min([int](($SizeGB / $MaxGB) * $barLength), $barLength)
    $filled = [math]::Max($filled, 0)
    $bar = "#" * $filled + "-" * ($barLength - $filled)
    return $bar
}

function Get-FolderColorAndSafety {
    param([string]$FolderName, [double]$SizeGB)

    $isSafe = $false
    $reason = ""

    $safePatterns = @("cache*", "Temp", "Temp*", "vm*", "vm_bundles*", "Download*")
    foreach ($pattern in $safePatterns) {
        if ($FolderName -like $pattern) {
            $isSafe = $true
            $reason = "Common temporary/user data"
            break
        }
    }

    if ($FolderName -eq "WinSxS") {
        $isSafe = $true
        $reason = "Windows Component Store (use DISM command)"
    }

    if ($isSafe) {
        return @{ Color = $COLOR_SAFE; IsSafe = $true; Reason = $reason }
    }
    elseif ($SizeGB -gt 10) {
        return @{ Color = $COLOR_CRITICAL; IsSafe = $false; Reason = "Large system/app directory" }
    }
    elseif ($SizeGB -gt 1) {
        return @{ Color = $COLOR_CAUTION; IsSafe = $false; Reason = "Review contents before deleting" }
    }
    else {
        return @{ Color = $COLOR_CAUTION; IsSafe = $false; Reason = "Small directory" }
    }
}

function Show-TreeNode {
    param(
        [string]$Path,
        [string]$Prefix = "",
        [int]$Depth = 0,
        [int]$MaxDepth = $MAX_DEPTH,
        [int]$MaxItems = $MAX_ITEMS_PER_LEVEL,
        [bool]$IsRoot = $true
    )

    if ($Depth -gt $MaxDepth) { return }

    try {
        $folders = Get-ChildItem $Path -Directory -ErrorAction SilentlyContinue |
                   Where-Object { $SAFE_EXCLUSIONS -notcontains $_.Name } |
                   ForEach-Object {
                       $size = Get-DirectorySize $_.FullName
                       [PSCustomObject]@{
                           Name = $_.Name
                           FullName = $_.FullName
                           SizeGB = $size
                       }
                   } |
                   Sort-Object SizeGB -Descending |
                   Select-Object -First $MaxItems
    } catch {
        return
    }

    $total = $folders.Count
    for ($i = 0; $i -lt $total; $i++) {
        $item = $folders[$i]
        $isLastItem = ($i -eq $total - 1)

        if ($IsRoot) {
            $connector = ""
        } elseif ($isLastItem) {
            $connector = "+-- "
        } else {
            $connector = "|-- "
        }

        if ($IsRoot) {
            $newPrefix = ""
        } elseif ($isLastItem) {
            $newPrefix = $Prefix + "    "
        } else {
            $newPrefix = $Prefix + "|   "
        }

        $safety = Get-FolderColorAndSafety $item.Name $item.SizeGB
        $bar = Show-SizeBar $item.SizeGB
        $safeSuffix = if ($safety.IsSafe) { " [SAFE]" } else { "" }

        Write-Host ("{0}{1} {2} [{3} GB] {4}{5}" -f $Prefix, $connector, $item.Name, $item.SizeGB, $bar, $safeSuffix) -ForegroundColor $safety.Color

        if (-not $IsRoot -and $Depth -lt $MaxDepth) {
            Show-TreeNode -Path $item.FullName -Prefix $newPrefix -Depth ($Depth + 1) -MaxDepth $MaxDepth -MaxItems $MaxItems -IsRoot $false
        }
    }
}

function Show-CleanupCommands {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor $COLOR_HEADER
    Write-Host "       SAFE CLEANUP COMMANDS" -ForegroundColor $COLOR_HEADER
    Write-Host "================================================" -ForegroundColor $COLOR_HEADER
    Write-Host ""
    Write-Host "Run these commands as Administrator when appropriate:" -ForegroundColor $COLOR_INFO
    Write-Host ""
    Write-Host "  1. uv cache clean" -ForegroundColor $COLOR_YELLOW
    Write-Host "     Cleans Python package manager cache (~0.6 GB typical)" -ForegroundColor $COLOR_INFO
    Write-Host ""
    Write-Host "  2. npm cache clean --force" -ForegroundColor $COLOR_YELLOW
    Write-Host "     Cleans Node.js package cache (~0.3 GB typical)" -ForegroundColor $COLOR_INFO
    Write-Host ""
    Write-Host "  3. dism /online /cleanup-image /startcomponentcleanup" -ForegroundColor $COLOR_YELLOW
    Write-Host "     Cleans Windows Component Store (several GB typical)" -ForegroundColor $COLOR_INFO
    Write-Host "     Must be run in Elevated PowerShell as Administrator" -ForegroundColor $COLOR_INFO
    Write-Host ""
    Write-Host "  4. Remove-Item -Recurse -Force <path>" -ForegroundColor $COLOR_YELLOW
    Write-Host "     Deletes specific large folders (verify contents first!)" -ForegroundColor $COLOR_INFO
    Write-Host ""
    Write-Host "NEVER delete directly:" -ForegroundColor $COLOR_CRITICAL
    Write-Host "  Windows, Program Files, Documents, Pictures, Videos" -ForegroundColor $COLOR_CRITICAL
    Write-Host ""
    Write-Host "Press any key to return..." -ForegroundColor $COLOR_INFO
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Get-UserInput {
    param([string]$Prompt)
    Write-Host ($Prompt + " ") -ForegroundColor $COLOR_HEADER -NoNewline
    return Read-Host
}

# --- Main Program ---

$currentPathStack = @("C:\")
$showInstructions = $SHOW_HELP_AT_START

while ($true) {
    Clear-Host

    if ($showInstructions) {
        Show-Instructions
        $showInstructions = $false
    }

    Write-Host ("CURRENT PATH: " + ($currentPathStack -join " > ")) -ForegroundColor $COLOR_HEADER
    Write-Host ""

    $cDrive = Get-PSDrive C
    $usedGB = [math]::Round($cDrive.Used / 1GB, 2)
    $freeGB = [math]::Round($cDrive.Free / 1GB, 2)
    Write-Host ("Drive C: $usedGB GB used | $freeGB GB free") -ForegroundColor $COLOR_INFO
    Write-Host ""

    Write-Host "DIRECTORIES:" -ForegroundColor $COLOR_HEADER
    Show-TreeNode -Path $currentPathStack[-1] -Prefix "" -Depth 0 -MaxDepth $MAX_DEPTH -MaxItems $MAX_ITEMS_PER_LEVEL -IsRoot $true
    Write-Host ""

    Write-Host "OPTIONS:" -ForegroundColor $COLOR_HEADER
    Write-Host "  [number] = Drill into that folder (e.g., type '1' for first item)"
    Write-Host "  b        = Go back to parent folder"
    Write-Host "  c        = Show cleanup commands"
    Write-Host "  h        = Show help/instructions"
    Write-Host "  q        = Quit"
    Write-Host ""

    $input = Get-UserInput -Prompt "Enter choice:"

    if ($input -eq "q" -or $input -eq "quit") {
        Write-Host "Goodbye!" -ForegroundColor $COLOR_HEADER
        break
    }
    elseif ($input -eq "b") {
        if ($currentPathStack.Count -gt 1) {
            $currentPathStack = $currentPathStack[0..($currentPathStack.Count - 2)]
        } else {
            Write-Host "Already at root. Press any key..." -ForegroundColor $COLOR_WARNING
            $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
    elseif ($input -eq "c") {
        Show-CleanupCommands
    }
    elseif ($input -eq "h") {
        $showInstructions = $true
    }
    elseif ([int]::TryParse($input, [ref]$null)) {
        $choice = [int]$input
        try {
            $folders = Get-ChildItem $currentPathStack[-1] -Directory -ErrorAction SilentlyContinue |
                       Where-Object { $SAFE_EXCLUSIONS -notcontains $_.Name } |
                       ForEach-Object {
                           $size = Get-DirectorySize $_.FullName
                           [PSCustomObject]@{
                               Name = $_.Name
                               FullName = $_.FullName
                               SizeGB = $size
                           }
                       } |
                       Sort-Object SizeGB -Descending |
                       Select-Object -First $MAX_ITEMS_PER_LEVEL

            if ($choice -ge 1 -and $choice -le $folders.Count) {
                $selected = $folders[$choice - 1]
                $currentPathStack += $selected.FullName
            } else {
                Write-Host "Invalid choice. Press any key..." -ForegroundColor $COLOR_WARNING
                $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        } catch {
            Write-Host "Error accessing folder. Press any key..." -ForegroundColor $COLOR_WARNING
            $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
    else {
        Write-Host "Invalid input. Press any key..." -ForegroundColor $COLOR_WARNING
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# =============================================================================
# END OF SCRIPT
# =============================================================================