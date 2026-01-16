using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

public class Launcher {
    private static string CONFIG_FILE = "config.json";
    private static string DEFAULT_UUID = "13371337-1337-1337-1337-133713371337";

    public static void Main(string[] args) {
        string hytaleDir = AppDomain.CurrentDomain.BaseDirectory;
        string playerName = Environment.UserName;
        string uuid = DEFAULT_UUID;

        // Load from config.json if exists
        LoadConfig(ref playerName, ref uuid);

        // Override with command line arguments
        for (int i = 0; i < args.Length; i++) {
            if (args[i] == "--name" && i + 1 < args.Length) {
                playerName = args[i + 1];
                i++;
            } else if (args[i] == "--uuid" && i + 1 < args.Length) {
                uuid = args[i + 1];
                i++;
            }
        }

        string userDataDir = Path.Combine(hytaleDir, "UserData");
        if (!Directory.Exists(userDataDir)) {
            Directory.CreateDirectory(userDataDir);
        }

        string clientPath = Path.Combine(hytaleDir, "package", "game", "latest", "Client", "HytaleClient.exe");
        string appDir = Path.Combine(hytaleDir, "package", "game", "latest");
        string javaExec = Path.Combine(hytaleDir, "package", "jre", "latest", "bin", "java.exe");

        try {
            var process = new Process();
            process.StartInfo.FileName = clientPath;
            process.StartInfo.Arguments = string.Format(
                "--app-dir \"{0}\" --user-dir \"{1}\" --java-exec \"{2}\" --auth-mode offline --uuid {3} --name \"{4}\"",
                appDir, userDataDir, javaExec, uuid, playerName
            );
            process.StartInfo.UseShellExecute = true;
            process.Start();
        } catch (Exception ex) {
            MessageBox.Show(
                "Error launching HytaleClient:\n" + ex.Message + "\n\n" +
                "Make sure HytaleClient.exe exists at:\n" + clientPath,
                "Launch Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error
            );
        }
    }

    private static void LoadConfig(ref string playerName, ref string uuid) {
        if (!File.Exists(CONFIG_FILE)) {
            CreateDefaultConfig();
            return;
        }

        try {
            string json = File.ReadAllText(CONFIG_FILE);
            json = json.Replace("\r", "").Replace("\n", "").Replace(" ", "");

            int nameStart = json.IndexOf("\"playerName\":\"") + 14;
            int nameEnd = json.IndexOf("\"", nameStart);
            if (nameStart > 13 && nameEnd > nameStart) {
                playerName = json.Substring(nameStart, nameEnd - nameStart);
            }

            int uuidStart = json.IndexOf("\"uuid\":\"") + 8;
            int uuidEnd = json.IndexOf("\"", uuidStart);
            if (uuidStart > 7 && uuidEnd > uuidStart) {
                uuid = json.Substring(uuidStart, uuidEnd - uuidStart);
            }
        } catch {
            // Use defaults if config is invalid
        }
    }

    private static void CreateDefaultConfig() {
        try {
            string json = "{\r\n  \"playerName\": \"" + Environment.UserName + "\",\r\n  \"uuid\": \"" + DEFAULT_UUID + "\"\r\n}";
            File.WriteAllText(CONFIG_FILE, json);

            MessageBox.Show(
                "Configuration file created: " + CONFIG_FILE + "\n\n" +
                "Please edit the config.json file to configure your settings:\n" +
                "- playerName: Your in-game player name\n" +
                "- uuid: Your unique UUID\n\n" +
                "Then run the launcher again.",
                "Configuration Required",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information
            );

            Environment.Exit(0);
        } catch { }
    }
}
