# MeterMind – Codex Context & Architecture

## 1. Entwicklungsprinzipien

* SwiftUI-first
* SwiftData als Single Source of Truth
* Strict MVVM Architektur
* Offline-first (lokal als Standard)
* CloudKit nur als Sync-Layer

## 2. Architekturübersicht

View → ViewModel → Repository → SwiftData

## 3. Projektstruktur

MeterMind/

* App/
* Core/

  * Models/
  * Repositories/
  * Services/
  * Extensions/
* Features/

  * Dashboard/
  * Meters/
  * Readings/
  * Analytics/
  * Export/
  * Settings/
  * Premium/
* Shared/

  * Components/
  * Theme/
  * Utilities/
* Resources/

## 4. Datenmodell

### Property

* id
* name
* createdAt
* meters[]

### Meter

* id
* propertyId
* name
* type
* unit
* serialNumber
* createdAt
* readings[]

### Reading

* id
* meterId
* date
* value
* note

### Tariff (Premium)

* id
* meterId
* pricePerUnit
* currency
* validFrom

## 5. Core Services

* ConsumptionService
* TariffCalculationService
* ExportService (CSV/PDF)
* OCRService (Vision Framework)
* SyncService (CloudKit)
* ReminderService

## 6. Business Logic

* Verbrauch = aktueller Wert - vorheriger Wert
* Kosten = Verbrauch × Tarif
* Aggregation:

  * Monatlich
  * Jährlich

## 7. Coding Standards

* Swift 6
* Async/Await bevorzugt
* Keine Force-Unwraps
* View max. 250 Zeilen
* Business Logic niemals in Views

## 8. Navigation

Tab-based:

* Dashboard
* Zähler
* Erfassen
* Analyse
* Einstellungen


# Aktualisierung für Docs/ARCHITECTURE.md / Docs/CODEX_CONTEXT.md

## Dashboard Architektur

Das Dashboard ist zählerzentriert.

### Komponenten

* DashboardView
* DashboardViewModel
* MeterDashboardCard
* MeterSparklineChart

### DashboardViewModel liefert

Pro Zähler:

* meterId
* meterName
* meterType
* iconName
* unit
* latestReadingValue
* latestReadingDate
* monthlyConsumptionLast12Months

### Berechnungslogik

Die letzten 12 Monatsverbräuche werden aus Reading-Differenzen berechnet.

Views enthalten keine Berechnungslogik.

Datenfluss:

ReadingRepository
→ ConsumptionService
→ DashboardViewModel
→ DashboardView
→ MeterDashboardCard
