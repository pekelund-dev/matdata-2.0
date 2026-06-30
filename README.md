# Matdata 2.0 — Pre-study

**Smart shopping, price history and global statistics powered by digital receipts.**

This repository contains the pre-study for Matdata 2.0. The pre-study describes what is to be built, why, how and under which conditions. It serves as the governing reference for the subsequent implementation phase.

## Document status

| Status | Date | Version |
| --- | --- | --- |
| Pre-study ready for review | 2026-06-29 | 1.0 |

All documents are written in English. Swedish-language terms (e.g. "Moms-kollen") are kept where they are part of the product vocabulary, and a glossary is provided.

## Document index

The documents are organised into three layers: what we are building, how we are building it, and what we have decided along the way.

### Layer 1 — Vision and scope (what)
| Document | Purpose |
| --- | --- |
| [prestudy.md](prestudy.md) | Overall pre-study: background, purpose, target audience, MVP concept and competitive analysis. |
| [project-plan_requirements.md](project-plan_requirements.md) | Requirements matrix (MoSCoW), development phases and test strategy. |
| [user-stories.md](user-stories.md) | Epics and user stories with Given/When/Then acceptance criteria derived from the requirements. |
| [ux-ui_vision.md](ux-ui_vision.md) | Design philosophy, core views, component catalogue, personas and design prompts. |

### Layer 2 — Architecture and quality (how)
| Document | Purpose |
| --- | --- |
| [architecture.md](architecture.md) | Technical architecture, C4 diagrams, data flows, data model, IaC and CI/CD. |
| [non-functional-requirements.md](non-functional-requirements.md) | Non-functional requirements: performance, availability, security, accessibility, i18n. |
| [gdpr.md](gdpr.md) | GDPR strategy, cookie handling and user rights. |
| [dpia.md](dpia.md) | Data Protection Impact Assessment per GDPR Article 35. |

### Layer 3 — Governance and decision support (why)
| Document | Purpose |
| --- | --- |
| [risk-register.md](risk-register.md) | Risk register with likelihood, impact, mitigation and owner. |
| [cost-estimate.md](cost-estimate.md) | Cost estimate for GCP, Neon and supporting services. |
| [open-decisions.md](open-decisions.md) | Log of open and closed architecture decisions (ADR-light). |
| [glossary.md](glossary.md) | Glossary of terms, acronyms and product-specific concepts. |

## How to read the pre-study

* **New to the project?** Start with [prestudy.md](prestudy.md) and [glossary.md](glossary.md). Then move on to [ux-ui_vision.md](ux-ui_vision.md) to get a feel for the final product.
* **Going to build?** Read [architecture.md](architecture.md), [non-functional-requirements.md](non-functional-requirements.md) and [project-plan_requirements.md](project-plan_requirements.md) in that order. The development backlog lives in [user-stories.md](user-stories.md) and as GitHub issues (can be created via [scripts/create-github-issues.sh](scripts/create-github-issues.sh), see [scripts/README.md](scripts/README.md)).
* **Reviewing security or legal?** Read [gdpr.md](gdpr.md) and [dpia.md](dpia.md) together. The risk register in [risk-register.md](risk-register.md) completes the picture.
* **Reviewing funding or governance?** [cost-estimate.md](cost-estimate.md), [risk-register.md](risk-register.md) and [open-decisions.md](open-decisions.md) provide the basis for go/no-go decisions.

## Scope of the pre-study

The pre-study describes the MVP scope and the adjacent backlog. Specifically, it does **not** cover:

* Detailed implementation, class diagrams or code examples beyond what is needed to illustrate the architecture.
* Marketing plan or launch campaign.
* Detailed analysis of store formats other than ICA. Other stores are handled through the plug-in architecture (requirement K20).

## Definition of Done — the pre-study is complete when

* [x] Vision, target audience and MVP scope are documented and consistent across all documents.
* [x] Functional requirements are described in a MoSCoW matrix with clear K numbers.
* [x] Non-functional requirements are described with measurable goals.
* [x] The architecture is illustrated with the C4 model at least to container level.
* [x] Asynchronous data flows are illustrated with sequence diagrams.
* [x] The data model is described at entity level and covers MVP requirements as well as selected Should/Could requirements.
* [x] CI/CD and PR environments have a documented flow description.
* [x] GDPR strategy and DPIA are documented.
* [x] A risk register with mitigations is in place.
* [x] A cost estimate for the MVP is available.
* [x] Open decisions are listed so that they are not lost during the implementation phase.

## Contributing to the pre-study

The pre-study lives in a Git repository and is version-controlled like any code base.

* Changes are made via Pull Request against `main`.
* Larger changes (new chapters, modified architecture, new requirements) must be referenced in [open-decisions.md](open-decisions.md).
* Smaller changes (spelling, formatting, clearer wording) can be approved directly.
