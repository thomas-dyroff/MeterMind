# MeterMind – Product Requirements Document

## 1. Produktübersicht

MeterMind ist eine iOS-App zur Erfassung und Analyse von Energie- und Ressourcenverbrauch in Privathaushalten. Nutzer erfassen regelmäßig Zählerstände und erhalten daraus Verbrauchs- und Kostenanalysen.

## 2. Zielgruppe

* Privathaushalte (primär)
* Mieter und Eigentümer
* Fokus: Einzelpersonen ohne technische Smart-Home-Systeme

## 3. Kernproblem

Nutzer haben keinen klaren Überblick über:

* tatsächlichen Energieverbrauch
* Kostenentwicklung
* historische Verbrauchstrends

## 4. Lösung

Eine einfache, lokale iOS-App zur:

* strukturierten Erfassung von Zählerständen
* automatischen Berechnung von Verbrauch
* Visualisierung von Trends und Kosten

## 5. Feature-Scope

### 5.1 Free Version

* Unbegrenzte Zähler
* Unterstützte Zählertypen:

  * Strombezug
  * PV-Einspeisung
  * Gas
  * Wasser
  * Fernwärme
  * Heizöl
  * Benutzerdefiniert
* Zählerstandserfassung (Datum, Wert, Notiz)
* Verbrauchsberechnung
* Diagramme (Verbrauch + Kostenvisualisierung, falls Tarif vorhanden)
* CSV Export
* Deutsch + Englisch Lokalisierung

### 5.2 Premium Version

* Kostenberechnung (Tarife pro Zähler)
* CloudKit Synchronisation
* Erinnerungen (Standardintervalle)
* OCR-Erkennung (Zahlenerkennung aus Foto)
* PDF Export
* Mehrere Immobilien

## 6. Nicht-Ziele

* Web-App
* Android
* Smart Home Integration
* Home Assistant
* Smart Meter APIs
* Apple Watch App
* CSV Import
* Enterprise Multi-User Systeme

## 7. Monetarisierung

* 1,99 € monatlich
* 14,99 € jährlich

## 8. Datenschutzprinzipien

* Keine Registrierung
* Kein Tracking
* Keine Werbung
* Lokale Speicherung standardmäßig
* Optional iCloud Sync (Premium)

## 9. UX Prinzipien

* Minimalistische Eingabeprozesse
* Reduktion auf 3 Hauptaktionen:

  * Zähler anlegen
  * Wert erfassen
  * Analyse ansehen

## 10. Erfolgskriterien

* Zeit zur Erfassung eines Zählerstands < 10 Sekunden
* Wiederkehrende Nutzung (monatliche Erfassung)
* Premium Conversion über Sync und Kostenfeatures


# Aktualisierung für Docs/PRD.md

## Dashboard / Startseite

Die Startseite zeigt eine vertikale Liste aller angelegten Zähler.

Für jeden Zähler wird eine eigene Dashboard-Karte angezeigt.

### Pro Zählerkarte

* Icon passend zum Zählertyp
* Name des Zählers
* Letzter erfasster Zählerstand
* Einheit
* Datum der letzten Erfassung
* Liniendiagramm der Verbräuche der letzten 12 Monate

### Nicht Bestandteil der ersten Dashboard-Version

* Kosten
* Prognose
* Einsparpotenzial
* KI-Insight
* Trend-Badge gegen Vormonat

Diese Elemente können später ergänzt werden.

### Empty State

Wenn keine Zähler vorhanden sind:

* Hinweis anzeigen
* Primäre Aktion: „Zähler anlegen“



# 11. Onboarding & User Education

## Zielsetzung

Das Onboarding führt neue Nutzer in weniger als zwei Minuten durch die wichtigsten Funktionen der App und vermittelt das grundlegende Nutzungskonzept.

Es soll Hemmschwellen abbauen, den ersten Erfolg ("First Success") schnell ermöglichen und den langfristigen Mehrwert der regelmäßigen Zählerstanderfassung verdeutlichen.

Grundprinzipien:

* kurz und verständlich
* visuell ansprechend
* jederzeit erneut aufrufbar
* kein Zwang zur Registrierung
* keine Marketingseiten
* Fokus auf den praktischen Nutzen

---

## Erstes Starten der App

Beim ersten Start der App wird automatisch der Onboarding-Wizard angezeigt.

Der Nutzer kann:

* den Wizard vollständig durchlaufen
* einzelne Seiten überspringen
* den Wizard jederzeit abbrechen

Nach Abschluss oder Überspringen wird der Wizard nicht erneut automatisch angezeigt.

Persistenz:

```text
hasCompletedOnboarding = true
```

---

## Erneuter Aufruf

Der Wizard kann jederzeit erneut gestartet werden.

Navigation:

Einstellungen

→ Hilfe

→ Einführung ansehen

Dies ermöglicht es Nutzern, Funktionen später erneut nachzulesen.

---

## Versionsbasiertes Onboarding

Für größere Releases wird zusätzlich ein versionsbasiertes Onboarding unterstützt.

Beispiel:

Version 1.2 führt OCR ein.

Beim ersten Start nach dem Update wird keine komplette Einführung angezeigt, sondern ein kurzer Hinweisdialog mit den neuen Funktionen.

Persistenz:

```text
lastSeenOnboardingVersion
```

Dadurch wird jeder Versionshinweis nur einmal angezeigt.

---

# Aufbau des Wizards

Der Wizard besteht aus vier Seiten.

Jede Seite enthält:

* Illustration
* kurze Überschrift
* erklärenden Text
* Fortschrittsanzeige
* Weiter-Button
* Überspringen

Keine Seite enthält mehr als zwei kurze Absätze.

---

## Seite 1

### Willkommen bei MeterMind

Titel:

Willkommen bei MeterMind

Text:

Erfasse Strom-, Gas-, Wasser- und weitere Zählerstände einfach und übersichtlich.

Behalte deinen Verbrauch langfristig im Blick und erkenne Entwicklungen frühzeitig.

Illustration:

Dashboard mit mehreren Zählerkarten.

CTA:

Weiter

---

## Seite 2

### Zähler anlegen

Titel:

Lege deine Zähler an

Text:

Erstelle beliebig viele Zähler – zum Beispiel für Strom, Gas, Wasser oder deine Photovoltaik-Einspeisung.

Jeder Zähler erhält seine eigene Historie und Auswertung.

Illustration:

Dialog "Neuer Zähler".

CTA:

Weiter

---

## Seite 3

### Regelmäßig erfassen

Titel:

Erfasse deine Zählerstände

Text:

Trage deine Zählerstände regelmäßig ein.

Bereits wenige Einträge reichen aus, um erste Verbrauchstrends sichtbar zu machen.

Illustration:

Eingabemaske für einen neuen Zählerstand.

CTA:

Weiter

---

## Seite 4

### Verbrauch verstehen

Titel:

Analysiere deinen Verbrauch

Text:

Das Dashboard zeigt dir die Entwicklung jedes Zählers.

In der Detailansicht findest du Diagramme für Woche, Monat, Quartal und Jahr.

Deine Daten bleiben auf deinem Gerät. Keine Registrierung. Kein Tracking.

Illustration:

Dashboard und Detailansicht mit Diagrammen.

CTA:

Jetzt starten

---

# Benutzerführung nach dem Onboarding

Nach Abschluss wird der Nutzer direkt zur Dashboard-Ansicht geführt.

Falls noch kein Zähler existiert:

Empty State:

"Lege deinen ersten Zähler an."

Primäre Aktion:

Zähler anlegen

Sekundäre Aktion:

Einführung erneut ansehen

---

# UX-Richtlinien

Der Wizard soll sich wie ein natürlicher Bestandteil der App anfühlen.

Daher gelten folgende Regeln:

* maximal vier Seiten
* keine Werbetexte
* keine Aufforderung zum Premium-Kauf
* keine Berechtigungsabfragen innerhalb des Wizards
* konsistentes Design gemäß DESIGN.md
* Animationen dezent und kurz (< 250 ms)

---

# Technische Anforderungen

Implementierung mit SwiftUI.

Persistenz über `@AppStorage`.

Benötigte Schlüssel:

* hasCompletedOnboarding
* lastSeenOnboardingVersion

Komponenten:

* OnboardingView
* OnboardingPage
* OnboardingPageViewModel
* OnboardingCoordinator

Die Seiten werden datengetrieben aus einem Modell aufgebaut, sodass zukünftige Seiten oder versionsabhängige Hinweise ohne Änderungen an der View ergänzt werden können.

---

# Nicht Bestandteil der ersten Version

Folgende Inhalte gehören bewusst nicht in den Wizard:

* Premium-Funktionen
* CloudKit
* OCR
* PDF-Export
* Erinnerungen
* App-Bewertung
* Push-Berechtigungen
* Datenschutzdialoge

Diese werden erst dann erklärt oder angefragt, wenn der Nutzer die jeweilige Funktion erstmals verwendet ("Just-in-Time Education").

---

# Erfolgskriterien

Das Onboarding gilt als erfolgreich, wenn:

* mindestens 90 % der Nutzer den Wizard abschließen oder bewusst überspringen,
* der erste Zähler innerhalb weniger Minuten angelegt werden kann,
* der erste Zählerstand ohne zusätzliche Hilfe erfasst werden kann,
* der Nutzer den Zusammenhang zwischen Dashboard und Detailansicht versteht,
* keine Premium-Funktion erklärt wird, bevor sie tatsächlich relevant ist.



# 12. Produkt-Roadmap

## Zielsetzung

Die Entwicklung von MeterMind erfolgt iterativ in mehreren Versionen. Jede Version erweitert die App um klar abgegrenzte Funktionen, ohne die Einfachheit der Bedienung zu beeinträchtigen.

Die Roadmap orientiert sich an folgenden Grundsätzen:

* **Einfachheit vor Funktionsvielfalt**
* **Hoher Nutzermehrwert**
* **Tiefe Integration in iOS**
* **Datenschutz und lokale Verarbeitung**
* **Premium-Funktionen bieten Komfort statt Einschränkungen**

Neue Funktionen dürfen die Kernidee der App – die schnelle und unkomplizierte Erfassung und Analyse von Zählerständen – nicht beeinträchtigen.

---

# Version 1.1 – Komfort & Produktivität

## OCR-Zählererkennung (Premium)

Nutzer können den Zähler fotografieren. Mithilfe des Apple Vision Frameworks wird der Zählerstand vollständig lokal auf dem Gerät erkannt.

Der erkannte Wert wird hervorgehoben und kann vor dem Speichern überprüft oder korrigiert werden.

Unterstützt werden:

* Stromzähler
* Gaszähler
* Wasserzähler

Optional kann die Erkennung von Nachkommastellen aktiviert werden.

**Nutzen**

* deutlich schnellere Erfassung
* modernes Nutzungserlebnis
* keine Cloud-Verarbeitung

---

## Schnellerfassung (Free)

Direkt nach dem Start der App oder über den Schnellzugriff kann eine reduzierte Eingabemaske geöffnet werden.

Ablauf:

1. Zähler auswählen
2. Wert eingeben oder per OCR übernehmen
3. Speichern

Keine weiteren Dialoge.

**Nutzen**

* Erfassung innerhalb weniger Sekunden

---

## Interaktive Dashboard-Karten (Free)

Die Dashboard-Karten werden erweitert.

Zusätzlich zu den bestehenden Informationen zeigen sie:

* aktuellen Zählerstand
* letzte Erfassung
* Verbrauch seit letzter Ablesung
* Trendindikator

Ein Tap öffnet weiterhin die Detailansicht des jeweiligen Zählers.

**Nutzen**

* schneller Überblick
* weniger Navigation
* höhere Informationsdichte

---

# Version 1.2 – Analyse

## Apple-Health-ähnliche Diagramme (Free)

Die Diagramme werden modernisiert.

Neue Funktionen:

* sanfte Animationen
* Pinch-to-Zoom
* Auswahl einzelner Datenpunkte
* Tooltip mit Messwert
* optionaler Wechsel zwischen Balken- und Linienansicht

**Nutzen**

* deutlich bessere Interpretation der Verbrauchsdaten

---

## Intelligente Verbrauchsinsights (Premium)

MeterMind analysiert Verbrauchsdaten automatisch.

Beispiele:

* „12 % weniger Wasser als im Vormonat“
* „Höchster Stromverbrauch seit Januar“
* „Gasverbrauch unter dem Jahresdurchschnitt“

Es wird keine generative KI verwendet.

Alle Berechnungen erfolgen lokal.

**Nutzen**

* zusätzlicher Mehrwert ohne Mehraufwand für den Nutzer

---

## Verbrauchsziele (Premium)

Für jeden Zähler können Jahresziele definiert werden.

Beispiele:

* 2.500 kWh Strom
* 110 m³ Wasser

Das Dashboard zeigt:

* aktuellen Fortschritt
* verbleibendes Budget
* Prognose zum Jahresende

**Nutzen**

* Motivation zum Energiesparen
* bessere Kontrolle der Verbrauchsentwicklung

---

# Version 1.3 – iOS Integration

## Widgets (Premium)

Home-Screen-Widgets in drei Größen.

Anzeige:

* aktueller Verbrauch
* letzte Erfassung
* nächste Erinnerung

Ein Tap öffnet direkt den entsprechenden Zähler.

---

## Live Activities & Dynamic Island (Premium)

Während einer aktiven Erfassung oder bei fälligen Erinnerungen können Informationen auf Sperrbildschirm und Dynamic Island dargestellt werden.

---

## Flexible Erinnerungen (Free)

Erinnerungen können flexibel konfiguriert werden.

Unterstützt werden:

* monatlich
* quartalsweise
* jährlich
* nach Zeitraum seit letzter Erfassung
* Monatsende

Optional:

* intelligente Erinnerung bei unregelmäßiger Nutzung

---

# Version 1.4 – Berichte & Automatisierung

## Jahreszusammenfassung (Premium)

Automatisch erzeugter Jahresbericht.

Inhalte:

* Verbrauch
* Kosten
* Trends
* Einsparungen
* Vergleich zum Vorjahr

Export als PDF.

---

## Apple Intelligence / Kurzbefehle (Premium)

Integration in die Kurzbefehle-App.

Beispiele:

* neuen Stromzählerstand erfassen
* aktuellen Wasserverbrauch anzeigen
* Monatsbericht exportieren

Ziel ist die nahtlose Einbindung in iOS-Automationen.

---

## Lock-Screen Widgets (Premium)

Kompakte Widgets für den Sperrbildschirm.

Anzeige:

* aktueller Verbrauch
* nächste Erinnerung

---

# Version 1.5 – Intelligente Analysen

## Verbrauchsprognose 2.0 (Premium)

Erweiterte Prognose unter Berücksichtigung:

* historischer Daten
* saisonaler Schwankungen
* bisherigem Jahresverlauf

Die Prognose zeigt zusätzlich einen Unsicherheitsbereich.

---

## Anomalie-Erkennung (Premium)

Automatische Erkennung ungewöhnlicher Verbrauchsänderungen.

Beispiele:

* Wasserleck
* ungewöhnlich hoher Stromverbrauch
* ungewöhnlich niedriger Gasverbrauch

Schwellwerte können individuell angepasst werden.

---

## Erweiterter Export (Premium)

Unterstützte Formate:

* CSV
* Excel
* PDF

Der Nutzer kann auswählen:

* einzelne Zähler
* mehrere Zähler
* beliebige Zeiträume

Diagramme werden in den Export integriert.

---

# Priorisierungsstrategie

Die Umsetzung neuer Funktionen erfolgt nach folgenden Kriterien:

1. Nutzen für möglichst viele Anwender
2. Einhaltung der einfachen Bedienbarkeit
3. Integration in bestehende Workflows
4. Tiefe Integration in das Apple-Ökosystem
5. Lokale Verarbeitung und Datenschutz

Funktionen, die den Bedienaufwand erhöhen oder die App unnötig komplex machen, werden grundsätzlich zurückgestellt oder verworfen.

---

# Langfristige Produktvision

MeterMind soll sich zu einer modernen, datenschutzfreundlichen iOS-Anwendung entwickeln, die Privathaushalten hilft, ihren Energie- und Ressourcenverbrauch nachhaltig zu verstehen und zu optimieren.

Dabei bleibt der Fokus bewusst auf einer nativen Apple-Erfahrung mit klarer Benutzerführung, hoher Performance und lokaler Datenverarbeitung. Die App soll kein Smart-Home-System ersetzen, sondern die einfachste und hochwertigste Lösung für die manuelle Erfassung und Analyse von Zählerständen im Apple-Ökosystem sein.
