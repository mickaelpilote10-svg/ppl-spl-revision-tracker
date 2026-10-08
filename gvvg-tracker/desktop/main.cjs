const { app, BrowserWindow, shell } = require("electron");

const APP_URL = "https://ppl-spl-revision-tracker-gvvg-track.vercel.app/";
const APP_ORIGIN = new URL(APP_URL).origin;
let mainWindow;

function openSafeExternal(rawUrl) {
  try {
    const url = new URL(rawUrl);
    if (url.protocol === "https:" || url.protocol === "mailto:") {
      shell.openExternal(url.href);
    }
  } catch (_) {
    // Ignore malformed or unsafe URLs.
  }
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1240,
    height: 850,
    minWidth: 760,
    minHeight: 600,
    show: false,
    backgroundColor: "#0f1b29",
    autoHideMenuBar: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
      webSecurity: true
    }
  });

  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    openSafeExternal(url);
    return { action: "deny" };
  });

  mainWindow.webContents.on("will-navigate", (event, rawUrl) => {
    try {
      if (new URL(rawUrl).origin !== APP_ORIGIN) {
        event.preventDefault();
        openSafeExternal(rawUrl);
      }
    } catch (_) {
      event.preventDefault();
    }
  });

  mainWindow.once("ready-to-show", () => mainWindow.show());
  mainWindow.loadURL(APP_URL).catch(() => {
    if (!mainWindow || mainWindow.isDestroyed()) return;
    mainWindow.loadURL("data:text/html;charset=utf-8," + encodeURIComponent(
      "<!doctype html><html lang='fr'><meta charset='utf-8'><title>Connexion nécessaire</title>" +
      "<body style='font:16px Segoe UI,Arial;background:#0f1b29;color:#eef3f7;padding:48px'>" +
      "<h1>Connexion Internet nécessaire</h1>" +
      "<p>Cette application ouvre ton espace de révision en ligne. Vérifie ta connexion, puis réessaie.</p>" +
      "<p><a style='color:#8cc4f3' href='" + APP_URL + "'>Réessayer</a></p></body></html>"
    ));
    mainWindow.show();
  });

  mainWindow.on("closed", () => { mainWindow = null; });
}

app.whenReady().then(() => {
  createWindow();
  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
