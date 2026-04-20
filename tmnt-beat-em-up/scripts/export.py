import subprocess, sys, os, http.server, threading, webbrowser
from pathlib import Path
import typer
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn

app = typer.Typer()
console = Console()

ROOT = Path(__file__).parent.parent
GODOT = Path(os.environ.get("GODOT4_PATH", "/usr/bin/godot4"))

@app.command()
def export(
    platform: str = "web",
    port: int = 8080,
    open_browser: bool = True,
):
    out_dir = ROOT / "builds" / platform
    out_dir.mkdir(parents=True, exist_ok=True)

    preset_map = {
        "web": "Web",
        "linux": "Linux/X11",
        "windows": "Windows Desktop"
    }

    preset = preset_map.get(platform, "Web")

    console.print(f"[cyan]Exporting {preset}...[/cyan]")

    cmd = [
        str(GODOT),
        "--headless",
        "--export-release",
        preset,
        str(out_dir / ("index.html" if platform == "web" else f"tmnt.{platform}"))
    ]

    result = subprocess.run(cmd, cwd=ROOT)

    if result.returncode != 0:
        console.print("[red]Export failed[/red]")
        sys.exit(1)

    console.print("[green]Export success[/green]")

    if platform == "web":
        _serve_web(out_dir, port, open_browser)

def _serve_web(build_dir: Path, port: int, open_browser: bool):
    os.chdir(build_dir)

    class Handler(http.server.SimpleHTTPRequestHandler):
        def end_headers(self):
            self.send_header("Cross-Origin-Opener-Policy", "same-origin")
            self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
            super().end_headers()

        def log_message(self, fmt, *args):
            pass

    server = http.server.HTTPServer(("", port), Handler)

    console.print(f"[green]Serving at http://localhost:{port}[/green]")

    if open_browser:
        threading.Timer(1.0, lambda: webbrowser.open(f"http://localhost:{port}")).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        console.print("[yellow]Server stopped[/yellow]")

if __name__ == "__main__":
    app()