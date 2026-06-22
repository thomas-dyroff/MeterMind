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
