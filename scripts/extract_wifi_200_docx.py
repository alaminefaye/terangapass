#!/usr/bin/env python3
"""
Extract venue rows from the '200 Types Wi‑Fi' Word doc (structured list with +221 phones).
Outputs database/data/wifi_venues_from_docx.json for DirectoryWifiProspectsDocxSeeder.

Usage:
  python3 scripts/extract_wifi_200_docx.py [path/to/file.docx]
If omitted, searches ~/Desktop for *200*Types*.docx
"""

from __future__ import annotations

import glob
import json
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

W_NS = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"

# Boundary: end of wifi/marketing segment, start of next venue name (concatenated in docx)
NEXT_VENUE = re.compile(
    r"(?<=[a-zàéèùîôêâç0-9])(?="
    r"Hôtel |Hotel |Résidence |La Résidence |Restaurant |Residence |"
    r"Le |La |Les |Chez |Campement |Lodge du |Mövenpick |Royam |Neptune |Royal |Auberge |"
    r"Dakar Résidence|Les Cordons|Les Manguiers|Lodge du "
    r")",
    re.IGNORECASE,
)

PHONE_SPLIT = re.compile(r"( — \+221\s*\d{2}\s*\d{3}\s*\d{2}\s*\d{2})")


def docx_plain(path: str) -> str:
    with zipfile.ZipFile(path) as z:
        root = ET.fromstring(z.read("word/document.xml"))
    parts: list[str] = []
    for t in root.iter(W_NS + "t"):
        if t.text:
            parts.append(t.text)
        if t.tail:
            parts.append(t.tail)
    return "".join(parts)


def normalize_phone(raw: str) -> str:
    s = raw.replace("\u00a0", " ").strip()
    digits = re.sub(r"\D", "", s)
    if digits.startswith("221") and len(digits) >= 12:
        return "+" + digits
    return "+" + digits if digits else ""


def parse_list(tail: str) -> list[dict]:
    parts = PHONE_SPLIT.split(tail)
    entries: list[dict] = []
    if not parts:
        return entries

    name_addr = parts[0].strip()
    i = 1
    while i < len(parts):
        delim = parts[i]
        m = re.search(r"\+221\s*(\d{2}\s*\d{3}\s*\d{2}\s*\d{2})", delim)
        phone = normalize_phone(m.group(0)) if m else ""
        i += 1
        if i >= len(parts):
            if name_addr and phone:
                na = split_name_addr(name_addr)
                if na:
                    entries.append(
                        {
                            "name": na[0],
                            "address": na[1],
                            "phone": phone,
                            "subtype": "",
                            "wifi_note": "",
                        }
                    )
            break

        mid = re.sub(r"^\s*—\s*", "", parts[i].strip(), count=1)

        subtype, wifi, next_name_addr = "", "", None
        if " — " in mid:
            subtype, rest = mid.split(" — ", 1)
            subtype = subtype.strip()
            mv = NEXT_VENUE.search(rest)
            if mv:
                wifi = rest[: mv.start()].strip()
                next_name_addr = rest[mv.start() :].strip()
            else:
                wifi = rest.strip()

        na = split_name_addr(name_addr)
        if na and phone:
            entries.append(
                {
                    "name": na[0],
                    "address": na[1],
                    "phone": phone,
                    "subtype": subtype,
                    "wifi_note": wifi,
                }
            )

        name_addr = next_name_addr if next_name_addr else ""
        i += 1

    return entries


def clip_glued_next_venue(wifi: str) -> str:
    """Doc sometimes omits a separator before the next « Name — »; trim glued tail."""
    m = re.search(r"(?<=[a-zàéèùâêîôûç0-9])(?=[A-ZÀÉÈÙ][a-zéèàùâêîôûç]+\s)", wifi)
    return wifi[: m.start()].strip() if m else wifi.strip()


def is_clean_row(r: dict) -> bool:
    w = r.get("wifi_note") or ""
    n = (r.get("name") or "").strip()
    if "religieux" in w.lower() or "communautaire" in w.lower():
        return False
    if " — " in w:
        return False
    if len(w) > 72:
        return False
    if len(n) < 4:
        return False
    # Truncated names when the doc format breaks (e.g. "le du Souvenir Africain") — article + lowercase word.
    m = re.match(r"^(le|la|les)\s+(\S)", n, re.IGNORECASE)
    if m and m.group(2).islower() and len(n) < 22:
        return False
    return True


def split_name_addr(block: str) -> tuple[str, str] | None:
    block = block.strip()
    if " — " not in block:
        return None
    name, addr = block.split(" — ", 1)
    return name.strip(), addr.strip()


def category_for(name: str, subtype: str) -> str:
    blob = (name + " " + subtype).lower()
    if any(
        x in blob
        for x in (
            "restaurant",
            "café",
            "cafe",
            "fast-food",
            "snack",
            "pizzeria",
            "boulangerie",
            "rooftop",
            "lounge",
        )
    ):
        return "restaurant"
    if blob.startswith(("chez ", "le ", "la ")) and "hôtel" not in blob and "hotel" not in blob:
        return "restaurant"
    return "hotel"


def approx_coords(address: str, index: int) -> tuple[float, float]:
    """Rough centroids for map pins (demo); replace with geocoding for production."""
    a = address.lower()
    zones: list[tuple[str, float, float]] = [
        ("plateau", 14.6939, -17.4441),
        ("almadies", 14.7420, -17.5120),
        ("mamelles", 14.7245, -17.4680),
        ("ngor", 14.7510, -17.5160),
        ("yoff", 14.7580, -17.4780),
        ("ouakam", 14.7245, -17.4920),
        ("fann", 14.6900, -17.4550),
        ("sacré", 14.7040, -17.4560),
        ("liberté", 14.7120, -17.4580),
        ("saly", 14.4460, -17.0150),
        ("portudal", 14.35, -16.97),
        ("mbour", 14.4167, -16.9667),
        ("somone", 14.50, -17.08),
        ("ngaparou", 14.48, -17.02),
        ("toubab dialaw", 14.5167, -17.0167),
        ("popenguine", 14.5167, -17.0167),
        ("toubacouta", 13.833, -16.233),
        ("ndangane", 14.133, -16.333),
        ("nianing", 14.333, -16.983),
        ("guéréo", 14.55, -17.05),
        ("saloum", 14.15, -16.35),
        ("sine saloum", 14.15, -16.35),
        ("diamniadio", 14.7200, -17.1830),
        ("warang", 14.4167, -16.9667),
        ("fann résidence", 14.6920, -17.4620),
    ]
    lat, lng = 14.7167, -17.4677
    for key, la, lo in zones:
        if key in a:
            lat, lng = la, lo
            break
    jitter = (index % 17) * 0.00035
    return round(lat + jitter, 6), round(lng + jitter, 6)


def main() -> None:
    if len(sys.argv) > 1:
        doc = sys.argv[1]
    else:
        hits = glob.glob(str(Path.home() / "Desktop" / "*200*Types*.docx"))
        if not hits:
            print("No docx found; pass path as argv", file=sys.stderr)
            sys.exit(1)
        doc = hits[0]

    text = docx_plain(doc)
    marker = "Hôtel Faidherbe"
    idx = text.find(marker)
    if idx == -1:
        print("Marker not found in document", file=sys.stderr)
        sys.exit(2)
    tail = text[idx:]
    # Listings after « (781–840) » use another layout (mosquées, etc.); a TOC line also contains « Religieux » — do not cut on that.
    cut = tail.find("(781–840)")
    if cut != -1:
        tail = tail[:cut]
    # Section titles are glued to the next venue without a lowercase boundary; remove them.
    tail = re.sub(
        r"Restaurants,\s*Cafés,\s*Rooftops et Fast.Food\s*\(\d+[-‑–]\d+\)",
        "",
        tail,
        flags=re.IGNORECASE,
    )
    rows = parse_list(tail)
    for r in rows:
        r["wifi_note"] = clip_glued_next_venue(r.get("wifi_note") or "")
    rows = [r for r in rows if is_clean_row(r)]
    for i, r in enumerate(rows):
        r["category"] = category_for(r["name"], r["subtype"])
        la, lo = approx_coords(r["address"], i)
        r["latitude"] = la
        r["longitude"] = lo

    out = {
        "source_doc": str(Path(doc).name),
        "extracted_count": len(rows),
        "rows": rows,
    }
    outp = Path(__file__).resolve().parents[1] / "database" / "data" / "wifi_venues_from_docx.json"
    outp.parent.mkdir(parents=True, exist_ok=True)
    outp.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote {len(rows)} rows to {outp}")


if __name__ == "__main__":
    main()
