$Source = @"
using System;
using System.Diagnostics;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;

public class Launcher {
    private static string DEFAULT_PLAYER_NAME = @"@DEFAULT_PLAYER_NAME@";
    private static string DEFAULT_CLIENT_PATH = @"@DEFAULT_CLIENT_PATH@";
    private static string LOG_DIR = "logs";
    private static string CONFIG_FILE = "config.json";

    private static string PLAYER_NAME;
    private static string CLIENT_PATH;

    public static void Main() {
        LoadConfig();

        if (!Directory.Exists(LOG_DIR)) {
            Directory.CreateDirectory(LOG_DIR);
        }

        string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss").Replace(" ", "0");
        string logFile = Path.Combine(LOG_DIR, "hytale_" + timestamp + ".log");
        string latestLog = Path.Combine(LOG_DIR, "latest.log");

        Log(latestLog, "[" + DateTime.Now + "] Starting Hytale Launcher", false);
        Log(logFile, "[" + DateTime.Now + "] Starting Hytale Launcher", false);

        string uuid = GenerateUUID(PLAYER_NAME);
        Log(latestLog, "[" + DateTime.Now + "] Generated UUID: " + uuid);
        Log(logFile, "[" + DateTime.Now + "] Generated UUID: " + uuid);

        string sessionToken = GenerateRandomToken(32);
        Log(latestLog, "[" + DateTime.Now + "] Generated Session Token: " + sessionToken);
        Log(logFile, "[" + DateTime.Now + "] Generated Session Token: " + sessionToken);

        string identityToken = GenerateJWT(PLAYER_NAME);
        Log(latestLog, "[" + DateTime.Now + "] Generated Identity Token: " + identityToken);
        Log(logFile, "[" + DateTime.Now + "] Generated Identity Token: " + identityToken);

        Log(latestLog, "[" + DateTime.Now + "] Launching HytaleClient with UUID: " + uuid + ", Name: " + PLAYER_NAME);
        Log(logFile, "[" + DateTime.Now + "] Launching HytaleClient with UUID: " + uuid + ", Name: " + PLAYER_NAME);

        LaunchClient(uuid, sessionToken, identityToken);

        Log(latestLog, "[" + DateTime.Now + "] HytaleClient launched");
        Log(logFile, "[" + DateTime.Now + "] HytaleClient launched");
        Log(latestLog, "[" + DateTime.Now + "] Log saved to: " + logFile);
        Log(logFile, "[" + DateTime.Now + "] Log saved to: " + logFile);
    }

    private static void LoadConfig() {
        PLAYER_NAME = DEFAULT_PLAYER_NAME;
        CLIENT_PATH = DEFAULT_CLIENT_PATH;

        if (File.Exists(CONFIG_FILE)) {
            try {
                string json = File.ReadAllText(CONFIG_FILE);
                json = json.Replace("\r", "").Replace("\n", "").Replace(" ", "");
                
                int playerNameStart = json.IndexOf("\"playerName\":\"") + 14;
                int playerNameEnd = json.IndexOf("\"", playerNameStart);
                if (playerNameStart > 13 && playerNameEnd > playerNameStart) {
                    PLAYER_NAME = json.Substring(playerNameStart, playerNameEnd - playerNameStart);
                }

                int clientPathStart = json.IndexOf("\"clientPath\":\"") + 14;
                int clientPathEnd = json.IndexOf("\"", clientPathStart);
                if (clientPathStart > 13 && clientPathEnd > clientPathStart) {
                    CLIENT_PATH = json.Substring(clientPathStart, clientPathEnd - clientPathStart);
                }
            } catch {
                PLAYER_NAME = DEFAULT_PLAYER_NAME;
                CLIENT_PATH = DEFAULT_CLIENT_PATH;
            }
        } else {
            CreateDefaultConfig();
            MessageBox.Show(
                "Configuration file created: " + CONFIG_FILE + "\n\n" +
                "Please edit the config.json file to configure:\n" +
                "- playerName: Your player name\n" +
                "- clientPath: Path to HytaleClient.exe executable\n\n" +
                "Then run the launcher again.",
                "Configuration required",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information
            );
            Environment.Exit(0);
        }
    }

    private static void CreateDefaultConfig() {
        try {
            string escapedClientPath = DEFAULT_CLIENT_PATH.Replace("\\", "\\\\");
            string json = "{\r\n  \"playerName\": \"" + DEFAULT_PLAYER_NAME + "\",\r\n  \"clientPath\": \"" + escapedClientPath + "\"\r\n}";
            File.WriteAllText(CONFIG_FILE, json);
        } catch { }
    }

    private static void Log(string filePath, string message, bool append = true) {
        try {
            if (append) {
                File.AppendAllText(filePath, message + Environment.NewLine);
            } else {
                File.WriteAllText(filePath, message + Environment.NewLine);
            }
        } catch { }
    }

    private static string GenerateUUID(string name) {
        using (MD5 md5 = MD5.Create()) {
            byte[] hash = md5.ComputeHash(Encoding.UTF8.GetBytes(name));
            return new Guid(hash).ToString();
        }
    }

    private static string GenerateRandomToken(int length) {
        const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random random = new Random();
        char[] token = new char[length];
        for (int i = 0; i < length; i++) {
            token[i] = chars[random.Next(chars.Length)];
        }
        return new string(token);
    }

    private static string GenerateJWT(string playerName) {
        long iat = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        long exp = iat + 86400;

        string header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
        string payload = "{\"sub\":\"user123\",\"name\":\"" + playerName + "\",\"iat\":" + iat + ",\"exp\":" + exp + ",\"scope\":\"hytale:client\",\"userId\":\"69\"}";
        string secret = "your-secret-key";

        string headerEncoded = Base64UrlEncode(Encoding.UTF8.GetBytes(header));
        string payloadEncoded = Base64UrlEncode(Encoding.UTF8.GetBytes(payload));
        string stringToSign = headerEncoded + "." + payloadEncoded;

        using (HMACSHA256 hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secret))) {
            byte[] signature = hmac.ComputeHash(Encoding.UTF8.GetBytes(stringToSign));
            string signatureEncoded = Base64UrlEncode(signature);
            return headerEncoded + "." + payloadEncoded + "." + signatureEncoded;
        }
    }

    private static string Base64UrlEncode(byte[] input) {
        return Convert.ToBase64String(input)
            .Replace("+", "-")
            .Replace("/", "_")
            .Replace("=", "");
    }

    private static void LaunchClient(string uuid, string sessionToken, string identityToken) {
        try {
            var process = new Process();
            process.StartInfo.FileName = CLIENT_PATH;
            process.StartInfo.Arguments = "--uuid=" + uuid + " --name=" + PLAYER_NAME + " --identity-token=" + identityToken + " --session-token=" + sessionToken;
            process.StartInfo.UseShellExecute = true;
            process.Start();
        } catch (Exception ex) {
            Log(Path.Combine(LOG_DIR, "latest.log"), "[" + DateTime.Now + "] Error launching client: " + ex.Message);
            MessageBox.Show(
                "Error launching HytaleClient:\n" + ex.Message + "\n\n" +
                "Please check the clientPath in config.json and make sure the file exists.",
                "Launch Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error
            );
        }
    }
}
"@

$Source | Out-File -FilePath "launcher.cs" -Encoding UTF8

$cscPath = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $cscPath)) {
    $cscPath = "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}

$defaultPlayerName = "Player"
$defaultClientPath = "install\release\package\game\latest\Client\HytaleClient.exe"
$iconPath = "hytale.ico"

$content = Get-Content "launcher.cs" -Raw
$content = $content.Replace("@DEFAULT_CLIENT_PATH@", $defaultClientPath)
$content = $content.Replace("@DEFAULT_PLAYER_NAME@", $defaultPlayerName)
$content | Out-File "launcher.cs" -Encoding UTF8

& $cscPath /target:winexe /win32icon:$iconPath /out:HytaleLauncher.exe launcher.cs

Remove-Item launcher.cs

Write-Host "EXE creado: HytaleLauncher.exe"
