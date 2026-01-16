# Hytale Launcher

A lightweight Windows launcher for Hytale that generates authentication tokens and launches the game client.

## Purpose

This launcher is designed for **unofficial/pirate versions** of Hytale. It solves two key problems:

1. **Unique UUID Generation**: Generates a unique UUID based on your username, so you don't share UUIDs with other users when joining servers. Each username gets a consistent but unique UUID.

2. **Token Simulation**: Fakes the authentication tokens that the game requests to verify a real user, allowing unofficial clients to bypass authentication checks.

## Features

- **Automatic Token Generation**: Generates UUID, session tokens, and identity tokens automatically
- **Username-based UUID**: Your UUID is derived from your player name using MD5 hashing, ensuring consistency
- **Fake Authentication**: Simulates JWT tokens and session tokens that the game expects
- **Configuration-based**: Uses a JSON configuration file for player name and client path
- **Error Handling**: Shows user-friendly popup messages for configuration errors and launch failures
- **Logging**: Maintains detailed logs for debugging purposes

## Usage

### First Run

1. Run `HytaleLauncher.exe`
2. The launcher will create a `config.json` file if it doesn't exist
3. A popup will appear asking you to configure the file
4. Edit `config.json` with your settings:
   ```json
   {
     "playerName": "YourPlayerName",
     "clientPath": "C:\\Path\\To\\HytaleClient.exe"
   }
   ```
5. Run the launcher again to start the game

### Configuration

Edit `config.json` to configure:

- **playerName**: Your in-game player name
- **clientPath**: Full path to the `HytaleClient.exe` executable

### Logs

Logs are stored in the `logs` directory:
- `latest.log`: Most recent log
- `hytale_YYYYMMDD_HHMMSS.log`: Timestamped logs

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

### Compilation Options

You can customize the default values by editing the placeholders in `compile_to_exe.ps1`:

- `@DEFAULT_PLAYER_NAME@`: Default player name
- `@DEFAULT_CLIENT_PATH@`: Default client path

## Error Handling

The launcher handles common errors with popup notifications:

- **Missing config.json**: Creates the file and prompts you to edit it
- **Invalid client path**: Shows an error message with instructions to fix the path
- **Launch failures**: Displays detailed error information

## License

This project is provided as-is for educational purposes.

## Disclaimer

This is a fan-made launcher and is not affiliated with Hypixel Studios or the official Hytale project.
