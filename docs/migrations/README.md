# Yize migrations (sunnyxorange/qihang-oms)

## 2026-09-28 — platform / tao missing tables

- `2026-09-28-yize-oms-tao-missing.sql` — all `oms_tao_*` required by Java entities
- `2026-09-28-yize-platform-missing.sql` — tao + jd/pdd/dou/wei goods tables also missing from seed

**Source**: adapted from upstream-family `zeasin/qihang-cb-erp` `docs/qihang-cb-erp.sql`
(commit `92899b4f087207042aebc6a0579b8ec6e1753b44`), plus entity columns
`audit_status` / `audit_time` and indexes for `shop_id` / `tid`.

**Apply (trial MySQL)**:

```bash
docker exec -i qihang-mysql mysql -uroot -pAndy_123 qihang-oms   < docs/migrations/2026-09-28-yize-platform-missing.sql
```

No AppKeys / shop tokens / live marketplace data in these files.
Remaining entity gaps (no official DDL found here): `erp_bill_*`, `o_order_ship_list*`.

## 2026-09-28 — erp bill + ship-list remaining gaps

- `2026-09-28-yize-erp-ship-missing.sql` — `erp_bill_shipment`, `erp_bill_shop_accounts`, `erp_bill_shop_order`, `o_order_ship_list`, `o_order_ship_list_item`

**Source**: entity-faithful (Java `@TableName` entities + mapper XML). No CREATE found in `qihang-cb-erp` SQL for these five.

```bash
docker exec -i qihang-mysql mysql -uroot -pAndy_123 qihang-oms \
  < docs/migrations/2026-09-28-yize-erp-ship-missing.sql
```

