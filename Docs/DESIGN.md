# MeterMind Design System

Version 1.0 · Verbrauchs-Tracking für Strom, Gas & Wasser

## 1. Prinzipien

1. **Zahlen zuerst.** Der Zählerstand ist der Held jeder Karte — größte Schriftgröße, höchster Kontrast. Alles andere ordnet sich unter.
2. **Ruhige Dichte.** Drei Versorgungsarten, drei Karten, ein Rhythmus. Keine Karte sticht durch Form ab — nur durch Farbe und Daten.
3. **Trend auf einen Blick.** Farbe kommuniziert Richtung, bevor man liest: Grün = besser, Orange/Gelb = neutral/Achtung. Nie Rot für reine Information — Rot bleibt für echte Warnungen reserviert.
4. **Weiche Geometrie, harte Daten.** Großzügige Rundungen und Luft im Layout, aber Zahlen, Einheiten und Linien bleiben präzise und nüchtern gesetzt.

---

## 2. Farben

### Primärpalette

| Token | Hex | Verwendung |
|---|---|---|
| `--color-primary-900` | `#0D3B36` | Header-Akzente, primäre Buttons (dunkel), Footer-CTA-Hintergrund |
| `--color-primary-700` | `#0F5C52` | Icon-Kreise Strom, aktive Tab-Icons, Markerpunkte |
| `--color-primary-500` | `#178F7D` | Sparkline-Linien, sekundäre Akzente |
| `--color-teal-600` | `#1A7A94` | Icon-Kreis Gas |
| `--color-cyan-500` | `#2BA8C4` | Icon-Kreis Wasser |

### Neutrale Palette

| Token | Hex | Verwendung |
|---|---|---|
| `--color-ink-900` | `#10201D` | Überschriften, Zählerstand-Zahlen |
| `--color-ink-600` | `#5B6B68` | Sekundärtext, Labels |
| `--color-ink-400` | `#94A19E` | Tertiärtext, Metadaten (z. B. „Letzte Eingabe") |
| `--color-surface` | `#FFFFFF` | Kartenhintergrund |
| `--color-bg` | `#F6F8F7` | Seitenhintergrund |
| `--color-border` | `#E7ECEA` | Trennlinien, Kartenrahmen |

### Statusfarben (Trend-Badges)

| Token | Hex (BG / Text) | Bedeutung |
|---|---|---|
| `--color-positive-bg` / `--color-positive-text` | `#DCF3E7` / `#1E7A4C` | Verbrauch gesunken (gut) |
| `--color-neutral-bg` / `--color-neutral-text` | `#FCEFD8` / `#A8721C` | Verbrauch unverändert |
| `--color-negative-bg` / `--color-negative-text` | `#FBE2E1` / `#C23B33` | Verbrauch gestiegen (nur bei Bedarf) |

### Datenfarben (pro Versorgungsart — konsistent in Icons, Charts, Zahlen)

| Versorgung | Token | Hex |
|---|---|---|
| Strom | `--color-strom` | `#0F5C52` |
| Gas | `--color-gas` | `#1A7A94` |
| Wasser | `--color-wasser` | `#2BA8C4` |

**Kontrastregel:** Text auf farbigen Flächen erreicht mindestens WCAG AA (4.5:1). Icon-Kreise nutzen immer weißes Icon auf Vollton-Hintergrund.

---

## 3. Typografie

**Display/Headline:** `"Plus Jakarta Sans"`, Weight 800 (ExtraBold) — für App-Titel und Zählerstand-Zahlen. Kräftig, geometrisch, leicht abgerundete Formen passend zum Icon-Stil.

**Body/UI:** `"Inter"`, Weight 400–700 — für alle Fließtexte, Labels, Buttons. Neutral, hohe Lesbarkeit bei kleinen Größen.

**Daten/Mono-Akzent:** `"Inter"`, Tabular Numbers (`font-variant-numeric: tabular-nums`) für alle Beträge und Zählerstände, damit Ziffern nicht „springen".

### Skala

| Rolle | Größe | Weight | Line-height | Beispiel |
|---|---|---|---|---|
| App-Titel | 32px | 800 | 1.1 | „MeterMind" |
| Zählerstand (groß) | 36px | 800 | 1.0 | „4.758" |
| Einheit (klein, neben Zahl) | 16px | 600 | 1.0 | „kWh" |
| Karten-Titel | 19px | 700 | 1.2 | „Strom" |
| Sektionslabel | 13px | 500 | 1.3 | „Zählerstand" |
| Body | 15px | 400 | 1.5 | Fließtext |
| Meta/Caption | 12.5px | 500 | 1.3 | „Letzte Eingabe: …" |
| Badge-Text | 13px | 700 | 1.0 | „-8%" |

---

## 4. Spacing & Radius

Basis-Einheit: **4px**. Abstände als Vielfache: 4, 8, 12, 16, 20, 24, 32, 40.

| Token | Wert | Verwendung |
|---|---|---|
| `--radius-card` | 24px | Hauptkarten |
| `--radius-badge` | 999px | Trend-Pills, Buttons |
| `--radius-icon` | 999px | Icon-Kreise |
| `--radius-cta` | 20px | CTA-Leiste unten |
| `--space-card-padding` | 20px | Innenabstand Karten |
| `--space-section-gap` | 16px | Abstand zwischen Karten |

---

## 5. Komponenten

### Metric Card (Strom/Gas/Wasser)
- Icon-Kreis (44px, Vollton-Hintergrund, weißes Icon) + Titel + Subtitel links
- Trend-Badge oben rechts (Pfeil-Icon + Prozent + „vs. Vormonat")
- Großer Zählerstand mit Einheit, darunter Meta-Zeile „Letzte Eingabe: …"
- Inline-Sparkline rechtsbündig neben der Zahl, Endpunkt als gefüllter Punkt markiert
- Horizontale Trennlinie, darunter zweispaltiges Footer-Grid: „Kosten (Monat)" / „Prognose (Monat)" mit Wert in Akzentfarbe

### Insight-Karte
- Hellteal-Hintergrund (`#E4F2F0`), kein harter Rahmen
- Icon-Kreis dunkel links, Eyebrow „INSIGHT" in Caps + Akzentfarbe
- Fett-Titel + erklärender Body-Text, Chevron rechts zur Navigation
- Optionale Sparzeile mit Lampen-Icon, separat abgesetzt

### CTA-Leiste
- Volltonfläche `--color-primary-900`, weißer Text, `--radius-cta`
- Icon links in heller Kreisfläche, zweizeiliger Text (Titel fett / Subtitel gedämpft), Chevron rechts

### Bottom Navigation
- 4 Items, aktiver Zustand: gefülltes Icon in Primärfarbe + Unterstrich, inaktiv: Outline-Icon in `--color-ink-400`

### Trend-Badge
- Pill-Form, Pfeil-Icon (↓/↑/—) + Prozentwert, Hintergrund/Text je nach Statusfarbe

---

## 6. Icons

Outline-Stil mit 1.75–2px Strichstärke, abgerundete Linienenden. Versorgungsarten-Icons (Blitz, Flamme, Tropfen) immer als weißes Icon auf Vollton-Kreis, nie als reines Outline-Icon in der Kartenübersicht.

---

## 7. Motion

Zurückhaltend: Tab-Wechsel und Karten-Taps mit 150–200ms ease-out. Sparklines können beim ersten Laden von links nach rechts „zeichnen" (Stroke-Dasharray-Animation, 600ms), aber nur einmal pro Sitzung — kein Loop, kein wiederholtes Pulsieren.

---

## 8. Barrierefreiheit

- Trendfarben werden nie als einziger Indikator genutzt — Pfeil-Icon + Vorzeichen (+/-) immer zusätzlich zur Farbe.
- Fokuszustände: 2px Outline in `--color-primary-700`, 2px Offset.
- Mindestkontrast Text/Hintergrund: 4.5:1 für Fließtext, 3:1 für große Zahlen (≥24px/Bold).
