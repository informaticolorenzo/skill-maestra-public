const vscode = require("vscode");
const childProcess = require("child_process");
const fs = require("fs");
const http = require("http");
const net = require("net");
const path = require("path");

const port = 8000;
const pageRelativeParts = ["_archivos_por_categoria", "web", "html", "index.html"];
const pageRelativeUrl = "/_archivos_por_categoria/web/html/index.html";
const fallbackUrl = `http://127.0.0.1:${port}${pageRelativeUrl}`;

function findRepoRoot() {
  const folders = vscode.workspace.workspaceFolders || [];
  return folders
    .map((folder) => folder.uri.fsPath)
    .find((folderPath) => fs.existsSync(path.join(folderPath, ...pageRelativeParts)));
}

function runPowerShell(repoRoot, args) {
  return new Promise((resolve, reject) => {
    const child = childProcess.spawn(
      "powershell.exe",
      ["-NoProfile", "-ExecutionPolicy", "Bypass", ...args],
      {
        cwd: repoRoot,
        windowsHide: true
      }
    );

    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (chunk) => {
      stdout += chunk.toString();
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk.toString();
    });
    child.on("error", reject);
    child.on("close", (code) => {
      if (code === 0) {
        resolve(stdout);
        return;
      }
      reject(new Error((stderr || stdout || `PowerShell termino con codigo ${code}`).trim()));
    });
  });
}

async function updateIndex(repoRoot) {
  const updater = path.join(
    repoRoot,
    "_archivos_por_categoria",
    "scripts",
    "ps1",
    "Update-SkillMaestraWebIndex.ps1"
  );
  if (!fs.existsSync(updater)) return;

  await runPowerShell(repoRoot, ["-File", updater, "-RepoRoot", repoRoot]);
}

function isServerReady() {
  return new Promise((resolve) => {
    const socket = net.createConnection({ host: "127.0.0.1", port, timeout: 500 });
    socket.once("connect", () => {
      socket.destroy();
      resolve(true);
    });
    socket.once("timeout", () => {
      socket.destroy();
      resolve(false);
    });
    socket.once("error", () => resolve(false));
  });
}

function isPageReady() {
  return new Promise((resolve) => {
    const request = http.get(fallbackUrl, (response) => {
      response.resume();
      resolve(response.statusCode === 200);
    });
    request.setTimeout(1000, () => {
      request.destroy();
      resolve(false);
    });
    request.on("error", () => resolve(false));
  });
}

async function ensureFallbackServer(repoRoot) {
  if ((await isServerReady()) && (await isPageReady())) return true;

  const launcher = path.join(repoRoot, "open-skill-maestra-web.ps1");
  if (!fs.existsSync(launcher)) return false;

  await runPowerShell(repoRoot, ["-File", launcher, "-ServerOnly"]);

  for (let i = 0; i < 30; i += 1) {
    if (await isPageReady()) return true;
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  return false;
}

async function openLivePreview(repoRoot) {
  const livePreview = vscode.extensions.getExtension("ms-vscode.live-server");
  if (!livePreview) return false;

  const pagePath = path.join(repoRoot, ...pageRelativeParts);
  await livePreview.activate();
  await vscode.commands.executeCommand(
    "livePreview.start.preview.atFileString",
    pagePath
  );
  return true;
}

async function openSimpleBrowser() {
  await vscode.commands.executeCommand("simpleBrowser.show", fallbackUrl);
}

function openFallbackWebview(detail) {
  const panel = vscode.window.createWebviewPanel(
    "skillMaestraViewer",
    "Skill Maestra",
    vscode.ViewColumn.Active,
    {
      enableScripts: false,
      retainContextWhenHidden: true
    }
  );

  panel.webview.html = `<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body {
      margin: 0;
      padding: 24px;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: #f4f7fb;
      color: #10233f;
    }
    code { background: #e8eef8; padding: 2px 5px; border-radius: 4px; }
  </style>
</head>
<body>
  <h1>Skill Maestra no se pudo abrir</h1>
  <p>Live Preview no respondio y el servidor local de respaldo tampoco quedo disponible.</p>
  <p>URL de respaldo: <code>${fallbackUrl}</code></p>
  <p>${detail || ""}</p>
</body>
</html>`;
}

async function openViewer() {
  const repoRoot = findRepoRoot();
  if (!repoRoot) {
    vscode.window.showWarningMessage("Skill Maestra: no encuentro el workspace del proyecto.");
    return;
  }

  try {
    await updateIndex(repoRoot);
  } catch (error) {
    vscode.window.showWarningMessage(`Skill Maestra: no pude regenerar el indice. ${error.message}`);
  }

  try {
    if (await openLivePreview(repoRoot)) return;
  } catch (error) {
    console.warn("Skill Maestra Live Preview fallback:", error);
  }

  try {
    if (await ensureFallbackServer(repoRoot)) {
      await openSimpleBrowser();
      return;
    }
  } catch (error) {
    openFallbackWebview(error.message);
    return;
  }

  openFallbackWebview();
}

function activate(context) {
  const disposable = vscode.commands.registerCommand("skillMaestraViewer.open", openViewer);
  context.subscriptions.push(disposable);

  // La extension esta instalada para todo VS Code: solo se abre sola en Skill Maestra
  if (findRepoRoot()) setTimeout(openViewer, 1000);
}

function deactivate() {}

module.exports = {
  activate,
  deactivate
};
