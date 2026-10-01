"""Dibuja en PDF los pares DoS/Unfold extraídos del notebook."""

import json
from pathlib import Path

from reportlab.lib.colors import HexColor
from reportlab.lib.units import cm
from reportlab.pdfgen import canvas


BASE = Path(__file__).resolve().parent
DATA = json.loads((BASE / "dos_barras.json").read_text())
OUT = BASE / "Imgs"
OUT.mkdir(exist_ok=True)

WIDTH, HEIGHT = 5.7 * cm, 3.75 * cm
LEFT, RIGHT, GAP = 20, 7, 12
BOTTOM, TOP = 25, 89
PANEL_WIDTH = (WIDTH - LEFT - RIGHT - GAP) / 2
BAR_COLOR = HexColor("#ffd52e")
EDGE_COLOR = HexColor("#7d6b15")


def number(value):
    if abs(value) >= 100:
        return f"{value:.0f}"
    return f"{value:g}"


def panel(pdf, x0, bins, title):
    xmin = min(row[0] for row in bins)
    xmax = max(row[1] for row in bins)
    ymax = max(row[2] for row in bins) * 1.08
    exponent = -4 if ymax < 0.01 else 0
    yscale = 10 ** (-exponent)

    pdf.setFont("Helvetica-Bold", 7)
    pdf.setFillColor(HexColor("#171717"))
    pdf.drawCentredString(x0 + PANEL_WIDTH / 2, HEIGHT - 13, title)

    pdf.setFillColor(BAR_COLOR)
    pdf.setStrokeColor(EDGE_COLOR)
    pdf.setLineWidth(0.27)
    for start, end, height in bins:
        xx = x0 + (start - xmin) / (xmax - xmin) * PANEL_WIDTH
        width = (end - start) / (xmax - xmin) * PANEL_WIDTH
        hh = height / ymax * (TOP - BOTTOM)
        pdf.rect(xx, BOTTOM, width, hh, fill=1, stroke=1)

    pdf.setStrokeColor(HexColor("#333333"))
    pdf.setLineWidth(0.45)
    pdf.line(x0, BOTTOM, x0 + PANEL_WIDTH, BOTTOM)
    pdf.line(x0, BOTTOM, x0, TOP)
    pdf.setFont("Helvetica", 5.5)
    pdf.setFillColor(HexColor("#333333"))
    for fraction in (0, 0.5, 1):
        xx = x0 + fraction * PANEL_WIDTH
        pdf.line(xx, BOTTOM, xx, BOTTOM - 2)
        label = number(xmin + fraction * (xmax - xmin))
        pdf.drawCentredString(xx, BOTTOM - 9, label)
    for fraction in (0, 0.5, 1):
        yy = BOTTOM + fraction * (TOP - BOTTOM)
        pdf.line(x0 - 2, yy, x0, yy)
        label = f"{fraction * ymax * yscale:.2g}"
        pdf.drawRightString(x0 - 3, yy - 2, label)
    if exponent:
        pdf.setFont("Helvetica", 5.4)
        pdf.drawRightString(x0 + PANEL_WIDTH, TOP + 2, "x10^-4")


for item in DATA:
    path = OUT / f"DoS_{item['stadium']}_{item['coin']}.pdf"
    pdf = canvas.Canvas(str(path), pagesize=(WIDTH, HEIGHT), pageCompression=1)
    panel(pdf, LEFT, item["dos"], "DoS")
    panel(pdf, LEFT + PANEL_WIDTH + GAP, item["unfold"], "Unfold")
    pdf.showPage()
    pdf.save()

print(f"Pares DoS/Unfold dibujados: {len(DATA)}")
