# Stock In / Stock Out Structure (Shared Catalog + 3 Working Modes)

## Purpose
This document explains:
1. How Stock In and Stock Out are currently made in the app.
2. The structure to use when backend tracking is introduced/extended.
3. What to store vs what **not** to store, while supporting all modes:
   - `PHARMACY_RETAIL`
   - `PHARMACY_WHOLESALE`
   - `CLINIC_INVENTORY`

---

## Assumption: Catalog is Shared (Single Source of Truth)
- Product catalog (`products`) and insurance catalog (`insurances`, `productInsurances`) are synced from backend into device.
- Stock operations must reference catalog IDs (`productId`, `insuranceId`) and avoid storing duplicated catalog names for persistence.
- Names can be resolved at read-time from catalog snapshots or joins.

---

## 1) Current App Flow (Observed)

## Stock In (current)
- UI builds `StockInCreateDTO` with:
  - `productId`, `quantity`, `pricePerUnit`, `batchNumber`, `location`, `expiryDate`, `reorderLevel`, `deviceType`.
- `StockInService.createStockIn(...)` validates and inserts into local `stock_ins`.
- Persisted local table (`stock_ins`) includes:
  - `id`, `productId`, `quantity`, `location`, `pricePerUnit`, `batchNumber`, `expiryDate`, `reorderLevel`, `userId`, timestamps.

## Stock Out (current)
- UI builds `StockOutCreateDTO` with mode-specific metadata and `items`.
- `StockOutService.createStockOut(...)`:
  - validates stock availability,
  - creates `stock_outs` item rows,
  - auto-reduces `stock_ins.quantity`,
  - creates `stock_out_sales` rows under one `transactionId`.
- Persisted local data is split:
  - `stock_outs` = item-level movement and pricing breakdown.
  - `stock_out_sales` = transaction/header-level context (patient/destination/service, total, prescriber fields, user, timestamps).

## Important current gap (for backend design)
- Wholesale fields `destinationPharmacyPhone` and `tinNumber` are present in DTO/UI but are **not persisted** in local DB and not included in sync payload.

---

## 2) Target Backend Tracking Model (Recommended)

Use event-style movement tracking with clear header/item separation.

## A. `stock_in_records` (inbound batches)
Store one row per stock-in batch.

Required
- `id` (UUID, client-generated accepted)
- `moduleId`
- `deviceId`
- `mode` (`PHARMACY_RETAIL` | `PHARMACY_WHOLESALE` | `CLINIC_INVENTORY`)
- `productId` (shared catalog ID)
- `quantity`
- `pricePerUnit` (nullable for clinic if policy allows)
- `createdByUserId`
- `createdAt`

Optional
- `location`
- `batchNumber`
- `expiryDate`
- `reorderLevel`
- `sourceRef` (invoice/supplier/reference)
- `syncMeta` (`clientCreatedAt`, `clientLastSyncedAt`)

## B. `stock_out_transactions` (header)
One row per transaction/session (`transactionId` in current app terms).

Required
- `id` (transaction UUID)
- `moduleId`
- `deviceId`
- `mode`
- `counterpartyName` (patient / destination pharmacy / clinic fallback)
- `createdByUserId`
- `createdAt`

Optional by mode
- Retail:
  - `insuranceCardNumber`
  - `issuingCompany`
  - `prescriberName`
  - `prescriberLicenseId`
  - `prescribingOrganization`
- Wholesale:
  - `destinationPharmacyPhone` (add in backend + local future)
  - `tinNumber` (add in backend + local future)
- Clinic:
  - `destinationClinicService`

System fields
- `status` (`POSTED`, `VOIDED`)
- `voidReason`
- `syncMeta`

## C. `stock_out_items` (line items / movements)
One row per dispatched/sold stock line.

Canonical relationship:
- One `stock_out_transactions.id` -> many `stock_out_items`.
- This means a single stock-out transaction can contain multiple item rows.
- Each item row must minimally carry:
  - `stockInId`
  - `quantitySold`
  - `pricePerUnit`

Required
- `id`
- `transactionId` (FK -> `stock_out_transactions.id`)
- `stockInId` (FK -> inbound batch)
- `productId` (denormalized for fast query, still catalog-linked)
- `quantitySold`
- `pricePerUnit`
- `itemTotal`
- `patientPays`
- `insurancePays`
- `createdAt`

Java-style item contract (for backend DTO/entity)
```java
private UUID stockInId;
private Integer quantitySold;
private BigDecimal pricePerUnit;
```

Optional
- `insuranceId` (retail only when insured)
- `pricingPolicyId` (if pricing rule engine exists)

---

## 3) What to Store vs Not Store

## Always store
- IDs and referential keys (`productId`, `stockInId`, `insuranceId`, `userId`, transaction IDs).
- Quantities and money values that produced ledger state (`quantitySold`, `pricePerUnit`, `itemTotal`, split pays).
- Mode (`deviceType`) and operational timestamps.
- Audit ownership (`moduleId`, `deviceId`, `createdByUserId`).

## Store only when relevant (mode-conditional)
- Retail clinical-prescription context only for retail insurance workflows.
- Wholesale business identity fields only for wholesale.
- Clinic destination service only for clinic inventory mode.

## Do NOT store (avoid persistence)
- UI-only/transient fields:
  - search text, selected tabs, local step index, filters, toggle states.
- Duplicated catalog labels as source of truth:
  - product/insurance names should be resolved from catalog by ID.
- Reconstructable aggregates:
  - transaction totals that can be derived from item rows (if stored, treat as cache/checksum only).
- Presentation strings:
  - formatted currency/date labels, tooltips, fallback display-only strings.

---

## 4) Three-Mode Data Matrix

## Stock In
- Retail: store all stock batch fields; `pricePerUnit` required.
- Wholesale: same as retail.
- Clinic: same structure, but `pricePerUnit` may be `0`/nullable per policy.

## Stock Out Header
- Retail: patient + insurance/prescriber context.
- Wholesale: destination pharmacy identity (+ phone/tin recommended to persist).
- Clinic: destination clinic service; no insurance/prescriber payload.

## Stock Out Item
- Retail: insurance split may be non-zero.
- Wholesale: usually private pricing, insurance null.
- Clinic: insurance null, patient/insurance split effectively all operational cost side.

---

## 5) Sync-Out Contract (Backend Main Tracking)

When posting to backend, send separated payloads (or equivalent endpoint contract):
- `stocksIn[]` from `stock_in_records`
- `stocksOut[]` from `stock_out_items`
- `stockOutTransactions[]` from `stock_out_transactions`

Minimum anti-duplication keys:
- `id` as idempotency key for each entity.
- `moduleId + deviceId` for source attribution.
- `createdAt` + `updatedAt` for reconciliation.

Reconciliation rules:
- Accept upserts by `id`.
- Reject orphan `stock_out_items` without existing `transactionId` and `stockInId`.
- Keep catalog validation strict (`productId` and `insuranceId` must exist in shared catalog).

---

## 6) Practical Next Changes (to align app with backend model)
1. Add local persistence for wholesale `destinationPharmacyPhone` and `tinNumber` in stock-out header table.
2. Include mode explicitly in stock-out header sync payload.
3. Ensure backend has 3 explicit structures:
   - inbound stock (`stock_in_records`)
   - stock-out header (`stock_out_transactions`)
   - stock-out items (`stock_out_items`)
4. Keep catalog entities out of stock movement payload except IDs.

---

## Summary
- Current app already separates stock-out header and items, which is good for backend tracking.
- Main backend extension needed is to formalize mode-aware transaction header + item contract and persist missing wholesale fields.
- With shared catalog, store only references and movement facts; avoid persisting UI/transient and duplicated catalog display data.
