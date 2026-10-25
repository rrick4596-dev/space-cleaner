# 🧹 Claude Code Space Cleaner

An interactive PowerShell tool to help Windows users identify large directories that can be safely deleted to free up disk space without affecting critical system processes.

## 📋 Features

- **Scan C: drive** for the 15 largest directories
- **Safety indicators** showing which folders are safe to delete
- **Safe cleanup commands** for common caches (uv, npm, DISM)
- **Warning system** for critical folders that should NOT be deleted
- **Interactive and easy to read** output

## 🚀 Quick Start

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1+ (built-in)

### Run the Tool

1. **Open PowerShell as Administrator** (right-click PowerShell → Run as Administrator)

2. **Navigate to the directory** where you downloaded the script:
   ```powershell
   cd path\to\space_cleaner.ps1
   ```

3. **Run the script**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ./space_cleaner.ps1
   ```

## 🔍 What It Does

| Step | Action |
|------|--------|
| 1 | Scans C: drive root directories |
| 2 | Identifies the 15 largest folders |
| 3 | Displays folder names, sizes, and paths |
| 4 | Flags folders that are typically safe to delete |
| 5 | Suggests safe cleanup commands |

## 🛡️ Safety Rules

✅ **Generally Safe to Delete:**
- Application caches (`cache`, `Temp`)
- Package manager caches (`uv`, `npm`)
- Virtual machine bundles (`vm_bundles`)
- Downloaded temporary files

⚠️ **Exercise Caution:**
- `AppData\Local\*` subfolders (user-specific data)
- `WinSxS` (Windows Component Store — use DISM command instead)

❌ **NEVER Delete:**
- `Windows\*` (core system files)
- `Program Files\*` and `Program Files (x86)\*` (installed applications)
- `Users\<YourName>\Documents`, `Pictures`, `Videos`, `Downloads` (personal files)

## 🛠️ Manual Safe Cleanup Commands

Run these **as Administrator** when appropriate:

```powershell
# Clean Python package cache (uv)
uv cache clean

# Clean Node.js cache
npm cache clean --force

# Clean Windows Component Store
dism /online /cleanup-image /startcomponentcleanup

# Clean Adobe Lightroom (if uninstalled)
Remove-Item -Recurse -Force "C:\Users\<YourName>\AppData\Local\Adobe\Lightroom CC"

# Clean Brave/Edge browser caches via browser settings (Settings → Privacy → Clear browsing data)
```

## 📊 Example Output

```
🔍 Starting disk space analysis...
C: drive is 71.2 GB used (92%)          
Available space: 11 GB                   
----------------------------------------
🔍 Scanning for large directories...

📊 Top 15 Largest Directories on C:

Name                 SizeGB Path
----                 ------ ----
Users                46.73 C:\Users
Windows              33.01 C:\Windows
Program Files        13.17 C:\Program Files
...

💡 Safe to delete (with caution):
  ✓ vm_bundles (9.1 GB) - Virtual machine bundles (Claude/VM tools)
  ✓ cache (0.6 GB) - Common temporary/user data
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -m 'Add some improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## 📄 License

MIT License — feel free to use, modify, and distribute.

## ⚠️ Disclaimer

This tool is provided "as-is" without warranty. Always verify folder contents before deleting anything. The author is not responsible for data loss resulting from improper use of this tool.

---

## 🏆 Example Results

After running this tool and following its suggestions on a real system:

| Cleanup Action | Space Freed |
|----------------|-------------|
| uv cache clean | 0.61 GB |
| npm cache clean | 0.35 GB |
| claudevm.bundle | 9.1 GB |
| hermes folder | 2.73 GB |
| Lightroom CC folder | 17.87 GB |
| DISM WinSxS cleanup | ~9 GB |
| **Total** | **~39.7 GB** |

**Drive went from 11 GB free → 51 GB free (+40 GB gained!)**

---

## 💾 Download / Clone

```bash
git clone https://github.com/your-username/space-cleaner.git
cd space-cleaner
./space_cleaner.ps1
```

Replace `your-username` with your actual GitHub username after pushing to GitHub.