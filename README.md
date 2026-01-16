# Hytale Launcher

A lightweight Windows launcher for Hytale that launches the game client in offline mode.

## Purpose

This launcher is designed for **unofficial/pirate versions** of Hytale. It provides a simple executable that launches the game with the correct arguments without needing batch scripts.

## Features

- **Offline Mode**: Uses `--auth-mode offline` to bypass authentication
- **Auto Username**: Uses your Windows username automatically
- **Static UUID**: Uses UUID `13371337-1337-1337-1337-133713371337` by default
- **Auto Directory Setup**: Creates UserData folder if missing
- **Configuration File**: Supports `config.json` for custom player name and UUID
- **Command Line Parameters**: Override settings via command line arguments
- **Simple**: No configuration needed - just run the executable

## Usage

### Basic Usage

1. Place `HytaleLauncher.exe` in the root of your Hytale installation directory
2. Run `HytaleLauncher.exe`
3. The launcher will:
   - Create a `config.json` file with default settings if it doesn't exist
   - Create a `UserData` folder if it doesn't exist
   - Launch `HytaleClient.exe` with the correct arguments
   - Use your Windows username as the player name

### Configuration

Edit `config.json` to customize your settings:

```json
{
  "playerName": "YourPlayerName",
  "uuid": "13371337-1337-1337-1337-133713371337"
}
```

### Command Line Parameters

You can override the config.json settings using command line arguments:

```powershell
# Set custom player name
HytaleLauncher.exe --name "MyPlayerName"

# Set custom UUID
HytaleLauncher.exe --uuid "00000000-0000-0000-0000-000000000000"

# Use both
HytaleLauncher.exe --name "MyPlayerName" --uuid "00000000-0000-0000-0000-000000000000"
```

**Priority**: Command line parameters > config.json > defaults

## Directory Structure

The launcher expects this directory structure:
```
HytaleRoot/
├── HytaleLauncher.exe
├── package/
│   ├── game/
│   │   └── latest/
│   │       └── Client/
│   │           └── HytaleClient.exe
│   └── jre/
│       └── latest/
│           └── bin/
│               └── java.exe
└── UserData/ (created automatically)
```

## Building from Source

### Prerequisites

- Windows operating system
- PowerShell
- .NET Framework 4.0 or later (for C# compiler)

### Compilation

Run the PowerShell script:

```powershell
.\compile_to_exe.ps1
```

This will:
1. Generate `launcher.cs` from the PowerShell script
2. Compile it using the C# compiler
3. Create `HytaleLauncher.exe` in the current directory

## Error Handling

The launcher handles common errors with popup notifications:

- **Missing HytaleClient.exe**: Shows an error message with the expected path

## License

This project is provided as-is for educational purposes.

## Disclaimer

This is a fan-made launcher and is not affiliated with Hypixel Studios or the official Hytale project.
