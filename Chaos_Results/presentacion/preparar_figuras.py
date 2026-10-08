#!/usr/bin/env python3
"""Copia las figuras originales y define recortes de paneles para LaTeX.

No modifica los datos ni rasteriza los PDF. Los recortes conservan el
rótulo, los ejes y la escala de cada panel seleccionado.
"""
from pathlib import Path
import re
import shutil

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT.parent / "Imgs"
DEST = ROOT / "Imgs"
ORDER = ("gpg", "oo", "uoou", "o", "b", "ubu", "u", "upu", "p")


def page_size(filename):
    data = (SOURCE / filename).read_bytes()
    match = re.search(rb"/MediaBox\s*\[([^]]+)\]", data)
    if not match:
        raise ValueError(f"No se encontró MediaBox en {filename}")
    x0, y0, x1, y1 = map(float, match.group(1).split())
    return x1 - x0, y1 - y0


def crop_command(name, filename, col, row, cols, rows):
    width, height = page_size(filename)
    # row se cuenta desde arriba. trim usa izquierda, abajo, derecha, arriba.
    trim = (width * col / cols, height * (rows - row - 1) / rows,
            width * (cols - col - 1) / cols, height * row / rows)
    values = " ".join(f"{v:.3f}bp" for v in trim)
    return (rf"\expandafter\def\csname {name}\endcsname#1{{%" + "\n"
            + rf"  \includegraphics[trim={{{values}}},clip,width=\linewidth,"
            + rf"height=#1,keepaspectratio]{{{filename}}}" + "}\n")


def main():
    DEST.mkdir(exist_ok=True)
    files = set()
    missing = []
    for observable in ("DoS", "Ps", "Pr", "SFF"):
        for coin in ORDER:
            for geometry in ("Rect", "Sinai"):
                stem = (f"DoS_{geometry}_{coin}" if observable == "DoS"
                        else f"{observable}_{coin}_{geometry}")
                stems = (stem, f"{observable}_{geometry}_{coin}")
                filename = next((candidate + suffix for candidate in stems
                                 for suffix in (".pdf", ".png")
                                 if (SOURCE / (candidate + suffix)).exists()), None)
                if filename:
                    files.add(filename)
                else:
                    missing.append(stem)
    if missing:
        raise RuntimeError(f"Faltan figuras espectrales: {missing}")
    for observable in ("Ps", "Pr", "SFF"):
        for geometry in ("Rect", "Sinai"):
            filename = f"{observable}_Grover_{geometry}.pdf"
            if not (SOURCE / filename).exists():
                raise RuntimeError(f"Falta figura de Grover: {filename}")
            files.add(filename)
    for geometry in ("Rect", "Sinai"):
        files.add(f"Ps_pModif_{geometry}.pdf")

    for geometry in ("Rect", "Sinai"):
        files.add(f"Stadium_{geometry}.pdf")
        for suffix in ("", "_Deslocalizado"):
            files.add(f"IPR_Comparacion_{geometry}{suffix}.pdf")
            files.add(f"EntanglementEntropy_{geometry}{suffix}.pdf")

    time_rect = {
        "p": ("TimeAverage_Rect_p-uoou.pdf", 0, 0, 3, 2),
        "oo": ("TimeAverage_Rect_p-uoou.pdf", 1, 0, 3, 2),
        "b": ("TimeAverage_Rect_p-uoou.pdf", 2, 0, 3, 2),
        "gpg": ("TimeAverage_Rect_p-uoou.pdf", 0, 1, 3, 2),
        "o": ("TimeAverage_Rect_p-uoou.pdf", 1, 1, 3, 2),
        "uoou": ("TimeAverage_Rect_p-uoou.pdf", 2, 1, 3, 2),
        "ubu": ("TimeAverage_Rect_ubu-upu.pdf", 0, 0, 3, 1),
        "u": ("TimeAverage_Rect_ubu-upu.pdf", 1, 0, 3, 1),
        "upu": ("TimeAverage_Rect_ubu-upu.pdf", 2, 0, 3, 1),
    }
    time_sinai = {}
    for filename, names in (
        ("TimeAverage_Sinai_p-b.pdf", ("p", "oo", "b")),
        ("TimeAverage_Sinai_gpg-uoou.pdf", ("gpg", "o", "uoou")),
        ("TimeAverage_Sinai_ubu-upu.pdf", ("ubu", "u", "upu")),
    ):
        for col, coin in enumerate(names):
            time_sinai[coin] = (filename, col, 0, 3, 1)

    commands = ["% Generado por preparar_figuras.py. Recortes sin alterar los PDF.\n"]
    for geometry, panels in (("Rect", time_rect), ("Sinai", time_sinai)):
        for coin in ORDER:
            spec = panels[coin]
            files.add(spec[0])
            commands.append(crop_command(f"Time{geometry}{coin}", *spec))

    density = {
        "DensityRectFour": ("IPRDensity_Rect_Intervals04-09.pdf", 0, 0, 3, 2),
        "DensityRectSeven": ("IPRDensity_Rect_Intervals04-09.pdf", 0, 1, 3, 2),
        "DensitySinaiOne": ("IPRDensity_Sinai_Intervals01-08.pdf", 0, 0, 4, 2),
        "DensitySinaiFour": ("IPRDensity_Sinai_Intervals01-08.pdf", 3, 0, 4, 2),
    }
    for name, spec in density.items():
        files.add(spec[0])
        commands.append(crop_command(name, *spec))
    files.add("IPRDensity_Rect_Intervals10-15.pdf")
    for filename in sorted(files):
        shutil.copy2(SOURCE / filename, DEST / filename)
    (ROOT / "recortes.tex").write_text("".join(commands), encoding="utf-8")
    (ROOT / "figuras.txt").write_text("\n".join(sorted(files)) + "\n", encoding="utf-8")
    print(f"Proyecto preparado: {len(files)} figuras originales.")


if __name__ == "__main__":
    main()
