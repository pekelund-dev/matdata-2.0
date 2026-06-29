# Matdata 2.0 — Förstudie

**Smarta inköp, prishistorik och global statistik via digitala kvitton.**

Detta repository innehåller förstudien för Matdata 2.0. Förstudien beskriver vad som ska byggas, varför, hur och under vilka förutsättningar. Den fungerar som styrande underlag för den efterföljande implementationsfasen.

## Dokumentstatus

| Status | Datum | Version |
| --- | --- | --- |
| Förstudie klar för granskning | 2026-06-29 | 1.0 |

Alla dokument är skrivna på svenska. Tekniska termer, kodexempel och AI-prompter behåller engelska där det är etablerad praxis.

## Dokumentindex

Dokumenten är organiserade i tre lager: vad vi bygger, hur vi bygger det och vad vi har bestämt under resans gång.

### Lager 1 — Vision och scope (vad)
| Dokument | Syfte |
| --- | --- |
| [prestudy.md](prestudy.md) | Övergripande förstudie: bakgrund, syfte, målgrupp, MVP-koncept och konkurrensanalys. |
| [project-plan_requirements.md](project-plan_requirements.md) | Kravmatris (MoSCoW), utvecklingsfaser och teststrategi. |
| [ux-ui_vision.md](ux-ui_vision.md) | Designfilosofi, kärnvyer, komponentkatalog, personas och designprompter. |

### Lager 2 — Arkitektur och kvalitet (hur)
| Dokument | Syfte |
| --- | --- |
| [architecture.md](architecture.md) | Teknisk arkitektur, C4-diagram, dataflöden, datamodell, IaC och CI/CD. |
| [non-functional-requirements.md](non-functional-requirements.md) | Icke-funktionella krav: prestanda, tillgänglighet, säkerhet, accessibility, i18n. |
| [gdpr.md](gdpr.md) | GDPR-strategi, cookie-hantering och användarrättigheter. |
| [dpia.md](dpia.md) | Data Protection Impact Assessment enligt GDPR Artikel 35. |

### Lager 3 — Styrning och beslutsstöd (varför)
| Dokument | Syfte |
| --- | --- |
| [risk-register.md](risk-register.md) | Riskregister med sannolikhet, konsekvens, mitigering och ägare. |
| [cost-estimate.md](cost-estimate.md) | Kostnadsuppskattning för GCP, Neon och kringtjänster. |
| [open-decisions.md](open-decisions.md) | Logg över öppna och stängda arkitekturbeslut (ADR-light). |
| [glossary.md](glossary.md) | Ordlista över termer, akronymer och produktspecifika begrepp. |

## Hur du läser förstudien

* **Är du ny i projektet?** Börja med [prestudy.md](prestudy.md) och [glossary.md](glossary.md). Gå sedan vidare till [ux-ui_vision.md](ux-ui_vision.md) för en känsla av slutprodukten.
* **Ska du bygga?** Läs [architecture.md](architecture.md), [non-functional-requirements.md](non-functional-requirements.md) och [project-plan_requirements.md](project-plan_requirements.md) i den ordningen.
* **Granskar du säkerhet eller juridik?** Läs [gdpr.md](gdpr.md) och [dpia.md](dpia.md) tillsammans. Riskregistret i [risk-register.md](risk-register.md) kompletterar bilden.
* **Granskar du finansiering eller styrning?** [cost-estimate.md](cost-estimate.md), [risk-register.md](risk-register.md) och [open-decisions.md](open-decisions.md) ger underlag för go/no-go-beslut.

## Avgränsningar för förstudien

Förstudien beskriver MVP-scope och näraliggande backlog. Specifikt ingår inte:

* Detaljerad implementation, klassdiagram eller kodexempel utöver det som krävs för att illustrera arkitektur.
* Marknadsplan eller lanseringskampanj.
* Detaljerad analys av butiksformat utöver ICA. Övriga butikers format hanteras via plugin-arkitekturen (krav K20).

## Definition of Done — förstudien är klar när

* [x] Vision, målgrupp och MVP-scope är dokumenterade och konsistenta över alla dokument.
* [x] Funktionella krav är beskrivna i en MoSCoW-matris med tydliga K-nummer.
* [x] Icke-funktionella krav är beskrivna med mätbara mål.
* [x] Arkitekturen är illustrerad med C4-modellen åtminstone till container-nivå.
* [x] Asynkrona dataflöden är illustrerade med sekvensdiagram.
* [x] Datamodellen är beskriven på entitetsnivå och täcker MVP-krav samt valda Should/Could-krav.
* [x] CI/CD och PR-miljöer har en beskriven flödesbeskrivning.
* [x] GDPR-strategi och DPIA finns dokumenterade.
* [x] Riskregister med mitigeringar är upprättat.
* [x] Kostnadsuppskattning för MVP finns på plats.
* [x] Öppna beslut är listade så att de inte tappas bort i implementationsfasen.

## Bidra till förstudien

Förstudien lever i ett Git-repository och versionshanteras som vilken kodbas som helst.

* Ändringar görs via Pull Request mot `main`.
* Större ändringar (nya kapitel, ändrad arkitektur, nya krav) ska refereras i [open-decisions.md](open-decisions.md).
* Mindre ändringar (stavning, formatering, tydligare formuleringar) kan godkännas direkt.
