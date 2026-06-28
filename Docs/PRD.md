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
