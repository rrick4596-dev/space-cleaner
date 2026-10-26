# 🧹 Space Cleaner — Interactive Disk Analysis Tool

**A TreeSize-like PowerShell tool for Windows that helps you find and safely delete large folders to free up disk space.**

---

> Is your C: drive nearly full? **Space Cleaner** scans your system, visualizes directory sizes in a color-coded tree view, flags folders that are safe to delete, and suggests safe cleanup commands — all without risking critical system files.

---

## 🚀 Quick Start

```powershell
# 1. Open PowerShell as Administrator
# 2. Navigate to the folder
cd path\to\space-cleaner

# 3. Allow script execution (one-time setup)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 4. Run the tool
./space_cleaner.ps1
```

---

## 🎮 How to Use

| Key | Action |
|-----|--------|
| `1`–`12` | Drill into folder number N |
| `b` | Go back to parent folder |
| `c` | Show safe cleanup commands |
| `h` | Show help/instructions |
| `q` | Quit |

---

## 🎨 Color Codes

| Color | Meaning |
|-------|---------|
| 🟢 **Green** `[SAFE]` | Safe to delete (cache, temp, VM bundles) |
| 🟡 **Yellow** | Caution — system or app data (review before deleting) |
| 🔴 **Red** | Critical system files (NEVER delete directly) |

---

## 🛡️ Safety Rules

| ✅ Generally Safe | ⚠️ Review First | ❌ NEVER Delete |
|------------------|-----------------|-----------------|
| Application caches (`cache*`) | `AppData\Local\*` subfolders | `Windows\*` (core system) |
| Package manager caches (`uv`, `npm`) | `WinSxS` (use DISM) | `Program Files\*` (installed apps) |
| Virtual machine bundles (`vm*`) | Large unknown folders | `Documents`, `Pictures`, `Videos` |
| Temporary files (`Temp`) | | `Downloads` (personal files) |

---

## 🛠️ Safe Cleanup Commands

Run these **as Administrator** when appropriate:

```powershell
# Clean Python package cache
uv cache clean

# Clean Node.js package cache
npm cache clean --force

# Clean Windows Component Store (several GB)
dism /online /cleanup-image /startcomponentcleanup

# Delete specific large folders (verify contents first!)
Remove-Item -Recurse -Force "C:\Users\<YourName>\AppData\Local\Innovative Solutions\DriverMax"
```

---

## 📊 Example Output

```
CURRENT PATH: C: > Users > Huawei

Drive C: 72.32 GB used | 50.89 GB free

DIRECTORIES:
  AppData [14.8 GB] ####---------------- [SAFE]
    Local [14.5 GB] ###---------------- [SAFE]
      Adobe [18.19 GB] ####------------- [SAFE]
      Claude-3p [10.2 GB] ###---------- [SAFE]
  Documents [0.0 GB] ------------------
  Downloads [0.46 GB] -----------------

OPTIONS:
  [number] = Drill into that folder
  b        = Go back to parent folder
  c        = Show cleanup commands
  h        = Show help/instructions
  q        = Quit
```

---

## 🏆 Real Results

After running this tool on a real system and following its suggestions:

| Cleanup Action | Space Freed |
|----------------|-------------|
| `uv cache clean` | 0.61 GB |
| `npm cache clean` | 0.35 GB |
| Delete `claudevm.bundle` | 9.1 GB |
| Delete `hermes` folder | 2.73 GB |
| Delete `Lightroom CC` folder | 17.87 GB |
| DISM WinSxS cleanup | ~9 GB |
| **Total** | **~39.7 GB** |

**Drive went from 11 GB free → 51 GB free (+40 GB gained!)**

---

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

This tool is provided **"as-is"** without warranty. It is **read-only** — it scans and reports but never deletes automatically. Always verify folder contents before deleting anything. The author is not responsible for data loss resulting from improper use.

---

## 💾 Clone and Run

```bash
git clone https://github.com/rrick4596-dev/space-cleaner.git
cd space-cleaner
./space_cleaner.ps1
```