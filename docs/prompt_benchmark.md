# Meal estimation accuracy: benchmarking prompt strategies against ground truth

The Gemini prompt that estimates calories/macros from a meal photo was benchmarked
against 100 real photos (Nutrition5k + SNAPMe, both public CC BY 4.0 datasets) across
several prompt variants — a chain-of-thought ablation, a Brazilian nutrition
reference-table grounding step ([TACO](https://github.com/brolesi/taco)), a scale-in-frame
detection instruction, and a structured-reasoning field — before shipping any change to
production, using a paired per-sample t-test rather than aggregate MAPE alone (aggregate
metrics can look improved from a few outliers even when no individual prediction actually
got better).

| Arm | Model | N | MAPE kcal | MAE kcal | Bias (mean±sd) | Matched reference food rate | Avg latency |
|---|---|---|---|---|---|---|---|
| baseline | gemini-3.1-flash-lite | 100 | 79.5% | 106.9 kcal | -1.4±159.1 | 0% | 4.1s |
| combined | gemini-3.1-flash-lite | 93 | 76.9% | 108.9 kcal | -0.4±162.0 | 69% | 4.4s |
| grounded | gemini-3.1-flash-lite | 100 | 74.9% | 104.0 kcal | 10.0±146.8 | 68% | 4.2s |
| no_cot | gemini-3.1-flash-lite | 100 | 55.9% | 96.9 kcal | -15.1±145.0 | 0% | 3.6s |
| no_cot_with_scale | gemini-3.1-flash-lite | 100 | 95.7% | 105.8 kcal | -13.1±153.8 | 0% | 5.8s |
| no_cot_with_scale_reasoning | gemini-3.1-flash-lite | 100 | 57.4% | 99.5 kcal | -15.6±152.4 | 0% | 5.6s |
| with_scale | gemini-3.1-flash-lite | 100 | 56.8% | 105.3 kcal | -12.4±152.9 | 0% | 3.2s |

Paired comparison of each challenger arm against baseline on the exact same 100 samples
(|t| ≳ 1.98 is roughly the p<0.05 threshold for n≈100 paired samples):

| Challenger arm | N pairs | Challenger wins | Baseline wins | Ties | Mean paired Δ (kcal) | t-stat |
|---|---|---|---|---|---|---|
| combined | 93 | 48 (52%) | 43 (46%) | 2 | 1.9 | 0.26 |
| grounded | 100 | 49 (49%) | 48 (48%) | 3 | 2.9 | 0.40 |
| no_cot | 100 | 47 (47%) | 31 (31%) | 22 | 10.0 | 2.08 |
| no_cot_with_scale | 100 | 40 (40%) | 42 (42%) | 18 | 1.1 | 0.23 |
| no_cot_with_scale_reasoning | 100 | 44 (44%) | 37 (37%) | 19 | 7.4 | 1.43 |
| with_scale | 100 | 46 (46%) | 38 (38%) | 16 | 1.6 | 0.30 |

## What shipped

`no_cot_with_scale_reasoning` — `no_cot_with_scale` plus a `raciocinio_volumetrico`
(Portuguese for "volumetric reasoning") free-text field declared *first* in the response
schema, so the model generates its scale-check/component/mass-estimation reasoning as real
tokens before committing to any numeric field, instead of being asked to "reason silently"
under structured JSON output (which it has no mechanism to actually do) — plus a tightened
uncertainty band for the scale-confirmed case.

This recovered most of the accuracy lost when scale detection was first added to `no_cot`:
paired t rose from `no_cot_with_scale`'s 0.23 to 1.43 (still short of the ~1.98 significance
threshold, but the second-best result of all 7 arms tested, well ahead of every other
scale/grounding variant) and MAPE fell from 95.7% back down to 57.4%, close to plain
`no_cot`'s 55.9%, without a latency regression (5.6s vs. 5.8s).

The `no_cot_with_scale` arm was the first candidate to ship, on weaker evidence (it added
scale detection but lost most of `no_cot`'s accuracy gain, MAPE 95.7% vs. 55.9%). A
follow-up prompt-engineering review flagged that regression and proposed the
`raciocinio_volumetrico` field as the fix, which is the version that actually shipped.

None of the 100 benchmark photos contain a visible kitchen scale, so the scale-reading
capability's real value still can't be fully measured against this ground truth — that part
of the ship decision remains a product bet, not a proven result.

Migrating off `gemini-2.5-flash-lite` was justified independent of any of this: it already
returns HTTP 404 for newly-created API keys today, well before its announced 2026-10-16
shutdown.

## Why not TACO grounding

The reference-table grounding step (`grounded`) showed no significant per-sample effect on
its own (t=0.40), and adding it on top of the chain-of-thought removal (`combined`) erased
that arm's gain entirely (t=0.26 vs. `no_cot`'s 2.08) — despite raising the matched
reference food rate to ~69%. The leading (unproven) hypothesis is that the large reference
block dilutes the model's attention on the core estimation task, compounded by the fact
that none of the benchmark photos are Brazilian dishes, so most TACO matches are
approximate at best. This runs counter to Yan et al. (2025)'s finding that RAG-style
nutrition-database grounding cut error substantially on a different multimodal setup —
worth revisiting if a Brazilian-dish benchmark set becomes available.

## On chain-of-thought

Removing the model's step-by-step reasoning instructions was the single largest, most
consistent improvement found (MAPE 79.5% → 55.9%, MAE 106.9 → 96.9 kcal) — the opposite
direction from Vedovelli et al. (2026), who found no significant prompt-engineering effect
(including chain-of-thought) across 40 vision-language models on Nutrition5k. The reason
for the reversal here is not established; it may be specific to this model or this task
framing.

## On structured reasoning vs. suppressed reasoning

The `no_cot` result above looks like it contradicts giving the model any reasoning step at
all — but `no_cot_with_scale_reasoning` shows the contradiction is about *how* reasoning is
elicited, not whether it happens. The original chain-of-thought prompts (`baseline`,
`grounded`, `with_scale`) asked the model to "reason internally" across numbered steps
while still emitting pure JSON immediately — impossible for a model whose only mechanism
for "thinking" is generating tokens, since suppressing the reasoning output suppresses the
reasoning itself. Giving the model an actual schema field (`raciocinio_volumetrico`,
declared first so it's generated before any numeric field) to externalize that same
reasoning as real tokens recovered most of `no_cot`'s advantage that scale detection had
erased (t: 0.23 → 1.43; MAPE: 95.7% → 57.4%), with no latency regression. This is a
genuinely different mechanism from the rejected CoT prompts, not a re-test of them.

## Literature

- L. Vedovelli et al., "Model architecture dominates nutritional estimation accuracy in
  vision-language systems," *Scientific Reports*, 2026.
  [doi.org/10.1038/s41598-026-58755-w](https://doi.org/10.1038/s41598-026-58755-w)
- R. Yan et al., "DietAI24 as a framework for comprehensive nutrition estimation using
  multimodal large language models," *Communications Medicine*, 2025.
  [doi.org/10.1038/s43856-025-01159-0](https://doi.org/10.1038/s43856-025-01159-0)
- Benchmark ground truth: [Nutrition5k](https://github.com/google-research-datasets/Nutrition5k)
  (Google Research, CC BY 4.0) and SNAPMe (USDA Ag Data Commons, CC BY 4.0).
- Additional literature underpinning the existing uncertainty-interval calibration is
  cited in [`spec_diet_tracker_v2.md`](spec_diet_tracker_v2.md) §4.
