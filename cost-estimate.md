# Cost estimate: Matdata 2.0

**Version:** 1.0
**Last updated:** 2026-06-29
**Status:** Pre-study ready for review

This document describes the expected costs for Matdata 2.0 during the MVP phase and the first 12 months after launch. The figures are estimated from public price lists valid as of Q2 2026 and assume the region `europe-west1` (Belgium) or a comparable nearby EU region for data residency.

> **Disclaimer:** Actual prices may differ. This document is a basis for budgeting and is updated at least once per quarter. All figures are in SEK and exclude VAT unless otherwise stated.

## Contents
- [1. Assumptions about traffic and volume](#assumptions)
- [2. Cost estimate per service](#per-service)
- [3. Total estimate for the MVP](#total-mvp)
- [4. Scaling to 5,000 users](#scaling)
- [5. One-off costs](#one-off)
- [6. Cost control and alerts](#control)
- [7. Open source and other](#oss)

## 1. Assumptions about traffic and volume <a name="assumptions"></a>

| Scenario | Active users/month | Receipts/user/month | Total receipts/month | PDF size (avg) |
| --- | --- | --- | --- | --- |
| MVP (internal testing) | 5 | 20 | 100 | 150 KB |
| Early users | 50 | 15 | 750 | 150 KB |
| Launch | 500 | 10 | 5,000 | 150 KB |
| Growth (12 months) | 5,000 | 8 | 40,000 | 150 KB |

Each receipt is assumed to produce:
* One PDF file in Cloud Storage.
* One Pub/Sub message.
* One Parser Service execution (~3 s CPU and 512 MB RAM).
* Approximately 25 rows in `RECEIPT_ITEMS`.
* Approximately 25 rows in `GLOBAL_PRICE_POINTS` (if consent is given).

## 2. Cost estimate per service <a name="per-service"></a>

### 2.1 Google Cloud Run
Cloud Run is priced per vCPU-second and per GiB-RAM-second. Generous free tier (180,000 vCPU-s + 360,000 GiB-s per month).

| Scenario | Cloud Run (core) | Cloud Run (parser) | Total Cloud Run |
| --- | --- | --- | --- |
| MVP | Free tier covers | Free tier covers | 0 kr |
| Early users | Free tier covers | Free tier covers | 0 kr |
| Launch | ~50 kr | ~30 kr | ~80 kr |
| Growth | ~400 kr | ~250 kr | ~650 kr |

### 2.2 Cloud Storage (PDF storage)
Standard bucket in the region `europe-west1`. ~0.02 USD per GB per month. Lifecycle policy deletes PDFs after 30 days (see [non-functional-requirements.md](non-functional-requirements.md) NFR-D1).

| Scenario | Stored PDF volume | Monthly cost |
| --- | --- | --- |
| MVP | 15 MB | < 1 kr |
| Early users | 110 MB | < 1 kr |
| Launch | 750 MB | ~2 kr |
| Growth | 6 GB | ~15 kr |

### 2.3 Google Cloud Pub/Sub
Pub/Sub: 10 GB included per month, then ~40 öre per GB. Message size is assumed to be < 1 KB.

| Scenario | Number of messages | Data volume | Monthly cost |
| --- | --- | --- | --- |
| MVP | 100 | < 1 MB | 0 kr |
| Early users | 750 | < 1 MB | 0 kr |
| Launch | 5,000 | ~5 MB | 0 kr |
| Growth | 40,000 | ~40 MB | 0 kr |

### 2.4 Neon (serverless PostgreSQL)

Neon offers a free tier (0.5 GB storage, 191.9 compute hours/month) and paid plans from ~19 USD/month (Launch) that provide 10 GB and autoscaling.

| Scenario | Plan | Storage | Compute hours | Monthly cost |
| --- | --- | --- | --- | --- |
| MVP | Free | < 100 MB | Low, < free tier | 0 kr |
| Early users | Free | < 500 MB | < free tier | 0 kr |
| Launch | Launch | ~1 GB | Moderate | ~210 kr (≈ 19 USD) |
| Growth | Scale | ~5 GB | High | ~750 kr (≈ 69 USD) |

PR environments create database branches. The free tier is sufficient as long as only one or two PRs are open at the same time. If the CI/CD cost becomes noticeable: configure a shorter branch lifetime or share a test database.

### 2.5 Cloud Logging, Cloud Trace, Cloud Monitoring
GCP's observability stack has a generous free tier (50 GB Cloud Logging per project/month).

| Scenario | Log volume | Monthly cost |
| --- | --- | --- |
| MVP | < 1 GB | 0 kr |
| Early users | < 5 GB | 0 kr |
| Launch | ~10 GB | 0 kr |
| Growth | ~40 GB | 0 kr (below the 50 GB free tier) |

### 2.6 Domain, certificate and e-mail

| Item | Cost |
| --- | --- |
| Domain (.se) | ~120 kr/year |
| SSL/TLS | 0 kr (Google-managed) |
| Transactional e-mail (e.g. Brevo, Resend) | 0 kr for MVP, ~50 kr/month at launch |

### 2.7 GitHub Actions
The free tier covers everything in a public repo. For private repos there is a free quota (2,000 min/month for Pro).

## 3. Total estimate for the MVP <a name="total-mvp"></a>

| Scenario | Monthly cost (estimate) | Annual cost |
| --- | --- | --- |
| MVP (internal testing) | < 25 kr | ~300 kr |
| Early users (50 users) | ~50 kr | ~600 kr |
| Launch (500 users) | ~350 kr | ~4,200 kr |

The MVP phase is extremely cost-effective thanks to all the free tiers. The real cost at launch is almost entirely determined by the Neon paid plan, which becomes necessary as soon as the database passes 0.5 GB or traffic reaches a level where the free tier's compute hours run out.

## 4. Scaling to 5,000 users <a name="scaling"></a>

At 5,000 active users the monthly cost is judged to land at around 1,500–2,000 kr excl. VAT.

| Item | Monthly cost |
| --- | --- |
| Cloud Run | ~650 kr |
| Cloud Storage | ~15 kr |
| Pub/Sub | ~10 kr |
| Neon (Scale) | ~750 kr |
| Logs and observability | ~50 kr |
| E-mail | ~150 kr |
| Other (DNS, domain) | ~10 kr |
| **Total** | **~1,635 kr/month** |

This level assumes that the OCR/Vision API (requirement K17) is not activated. If K17 is activated, ~1.50 USD per 1,000 documents is added for Google Cloud Vision OCR, which at 40,000 receipts/month becomes ~60 USD = ~650 kr/month.

## 5. One-off costs <a name="one-off"></a>

| Item | Estimate |
| --- | --- |
| External design hours (if applicable) | 0–10,000 kr |
| Penetration test before public launch | 15,000–40,000 kr |
| Legal review of privacy policy and terms | 5,000–10,000 kr |
| Logo and brand | 0–5,000 kr |

For a hobby version or fully self-built version all one-off costs are 0 kr. For a public launch a penetration test and a legal review should be planned in.

## 6. Cost control and alerts <a name="control"></a>

* **GCP budget alerts:** Set to 90 % and 100 % of the monthly budget. Alert channel: e-mail.
* **Neon notifications:** Enabled for storage and compute thresholds.
* **Cloud Run max instances:** Configured (`--max-instances`) to prevent runaway scale.
* **Pub/Sub flow control:** Limit the number of concurrent messages to avoid loops.
* **Lifecycle on Cloud Storage:** Automatic deletion of PDFs after 30 days.

See [risk-register.md](risk-register.md) entry **E1** for the risk description.

## 7. Open source and other <a name="oss"></a>

No paid licences are used in the MVP. All frameworks (Spring Boot, Apache PDFBox, Tailwind CSS, HTMX, Thymeleaf) are open source under permissive licences (Apache 2.0, MIT or equivalent).

If we introduce paid components in the future (e.g. a slot for "Latest food price news" via a data service), the costs are to be updated in this document.
