#!/usr/bin/env python3
"""Injeta o ícone (arquivos PNG "legado", sem asset catalog) num .app
já buildado pelo `xtool dev build`, já que o xtool no Linux não
consegue compilar Assets.xcassets (precisa do actool, só existe no macOS).

Uso: python3 patch_app_icon.py [caminho/para/MinhasFinancas.app]
"""
import plistlib
import shutil
import sys
from pathlib import Path

script_dir = Path(__file__).resolve().parent
project_dir = script_dir.parent
design_dir = project_dir / "design"

app_path = Path(sys.argv[1]) if len(sys.argv) > 1 else project_dir / "xtool" / "MinhasFinancas.app"

if not app_path.is_dir():
    sys.exit(f"ERRO: não encontrei o app em {app_path}. Rode 'xtool dev build' primeiro.")

info_plist_path = app_path / "Info.plist"
if not info_plist_path.is_file():
    sys.exit(f"ERRO: não encontrei Info.plist em {info_plist_path}.")

icon_2x = design_dir / "AppIcon60x60@2x.png"
icon_3x = design_dir / "AppIcon60x60@3x.png"
for f in (icon_2x, icon_3x):
    if not f.is_file():
        sys.exit(f"ERRO: ícone não encontrado: {f}")

# 1) copia os PNGs pra raiz do bundle
shutil.copy2(icon_2x, app_path / "AppIcon60x60@2x.png")
shutil.copy2(icon_3x, app_path / "AppIcon60x60@3x.png")
print(f"Copiado: {icon_2x.name} e {icon_3x.name} -> {app_path}")

# 2) detecta o formato original do plist (binário ou XML) pra manter igual
raw = info_plist_path.read_bytes()
fmt = plistlib.FMT_BINARY if raw.startswith(b"bplist00") else plistlib.FMT_XML

with open(info_plist_path, "rb") as f:
    plist = plistlib.load(f)

plist["CFBundleIcons"] = {
    "CFBundlePrimaryIcon": {
        "CFBundleIconFiles": ["AppIcon60x60"],
        "CFBundleIconName": "AppIcon",
    }
}
plist["CFBundleIconName"] = "AppIcon"

with open(info_plist_path, "wb") as f:
    plistlib.dump(plist, f, fmt=fmt)

print(f"Info.plist atualizado ({app_path.name}) com CFBundleIcons.")
print("Pronto. Agora instale com: xtool install <caminho para o .app>")
