# Bursary & Scholarship Eligibility Logic for Find Teacher Training


**Owner:** Iain McNulty

**Purpose:** Document and clarify how bursary and scholarship eligibility is determined from course naming conventions within the Find Teacher Training service.

**Audience:** Software developers and technical stakeholders.

---

## 1. Overview

This document summarises guidance agreed with policy colleagues on how to interpret bursary and scholarship eligibility for ITT courses based on course titles. It outlines the rules, heuristics, and known exceptions that developers should use when implementing or maintaining eligibility logic in the Find Teacher Training service.

The service does **not** collect detailed course-content breakdowns from providers (e.g., a 50% subject split). Therefore, eligibility is inferred via naming conventions, aligned with sector expectations and DfE policy rules.

This document should be reevaluated each Recruitment Cycle to confirm that the heuristics still apply and are valid.

---

## 2. Official Sources for Bursary Rates

Developers must reference **only the following sources** for up‑to‑date bursary and scholarship values:

### 2.1 Get Into Teaching (GiT) Summary

Used as a quick reference for bursary rates and subject eligibility.

### 2.2 GOV.UK Funding Pages

These are the definitive sources and must be used when implementing or updating bursary logic.

Relevant pages:

- **2025 to 2026 Academic Year:** https://www.gov.uk/guidance/funding-initial-teacher-training-itt-academic-year-2025-to-2026
- **2026 to 2027 Academic Year:** https://www.gov.uk/guidance/funding-initial-teacher-training-itt-academic-year-2026-to-2027

---

## 3. Policy: The 50% Subject Split Rule

DfE policy states:

- A bursary applies only if **50% or more** of a course’s content is in a **bursary‑eligible subject**.
- If two subjects are exactly 50/50, the bursary defaults to the subject with the **higher bursary value**.
- Providers determine the split; DfE does not validate or collect this information.

Given the service cannot capture this data, heuristics based on course names are used (see Section 4).

---

## 4. Naming Conventions & Interpretation Rules

### 4.1 "X with Y" Format

- Indicates **X is the primary (majority) subject**, presumed ≥50%.
- The supporting subject (Y) is assumed to be a minority component.

**Therefore:**

- If **X** is bursary‑eligible → apply bursary.
- If **X** is not bursary‑eligible → do **not** apply bursary.

**Examples:**

- *PE with geography* → No bursary (PE is majority, not eligible).
- *Geography with history* → Geography bursary applies.

---

### 4.2 "X and Y" Format

- Typically implies both subjects are **50% each**.
- Sector practice is that providers should list the **bursary subject first**, although this is not always consistent.

**Developer rule:**

- Assume **the first named subject** is the bursary‑determining subject.
- Unless the subject is one of the recognised standalone double‑subjects (below).

---

### 4.3 Recognised Standalone Multi‑Subject Fields

These subjects exist as defined combinations and should **not** be treated as split‑subject courses:

- Art and design
- Design and technology
- Health and social care
- English and media studies

These are treated as single subjects, not combinations.

---

## 5. Science Combinations (Special Case)

"Science" courses are considered an exception due to typical content structure.

Science commonly comprises approximately:

- 1/3 Biology
- 1/3 Chemistry
- 1/3 Physics

### Policy-aligned interpretation:

- *Science with chemistry* → eligible for **£29k** (Chemistry bursary)
- *Science with physics* → eligible for **£29k** (Physics bursary)
- *Science with biology* → eligible for **£5k** (Biology bursary)

This reflects the assumption that chemistry and physics content together exceed 50% unless providers specify otherwise.

Providers may rename a course if they disagree with the bursary outcome.

---

## 6. Summary of Implementation Logic

### Primary rule:

> Use the first named subject to determine bursary/scholarship eligibility except in defined cases listed in this document.

### Algorithmic interpretation:

1. Extract the first named subject.
2. If the subject is part of Modern Languages, inspect specific named languages.
3. Check if the subject is bursary‑eligible.
4. Apply Science exceptions where applicable.
5. Ignore supporting subjects; the service cannot infer a 50/50 split.
6. Display bursary/scholarship accordingly.

Providers can (and usually do) rename courses to correct bursary signalling.

---

## 7. Known Limitations

- Course titles do not always follow sector naming conventions.
- The service does not receive or validate 50/50 split declarations.
- Rare edge cases may be flagged by providers, though this is historically uncommon.

---

## 8. Future Considerations

Possible enhancements (subject to policy input):

- Allow providers to specify subject split percentages.
- Add validation warnings when a bursary‑eligible subject appears second.
- Improve admin UI to better support combination subjects.

---

## 9. Contact

For questions about this document or bursary logic implementation, contact:

- **Iain McNulty** (Technical Lead)
- **Chris Cuff** (Policy)

---

This document should be reviewed annually alongside GOV.UK bursary updates to ensure continued accuracy.
