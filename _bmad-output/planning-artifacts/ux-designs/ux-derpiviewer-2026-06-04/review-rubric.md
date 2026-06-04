# Spine Pair Review — derpiviewer

## Overall verdict

This spine pair is an honest and thorough brownfield reverse-engineering of an existing Flutter codebase, but it fails as a downstream-consumable contract. DESIGN.md uses a non-standard frontmatter dialect (arrays of name/value/role objects, Dart symbolic color references instead of hex strings) that cannot be mechanically extracted the way the spec requires. EXPERIENCE.md reinforces this by referencing sections rather than individual tokens. The most impactful gap is that zero key flows include a failure path — a downstream developer or AI consuming this pair would not know how error states should behave. The spine pair documents faithfully what exists today, but does not specify the design system in a form that a downstream consumer can independently build from.

## 1. Flow Coverage — broken

Checked: All 5 key flows in EXPERIENCE.md against the requirement for named protagonist, numbered steps, climax beat, and applicable failure path. Also checked whether every screen listed in frontmatter (`screens`) is covered by at least one key flow.

### Findings
- **[critical]** Zero of 5 flows have a failure path. Flows 1-5 describe happy-path only. A downstream developer gets no guidance on error states for browsing, searching, favoriting, settings, or detail inspection. (EXPERIENCE.md: Key Flows). *Fix suggestion:* Add a `Failure:` paragraph to each flow, following the pattern in the Quill and Drift examples.
- **[high]** The frontmatter `screens` entry `"Dialogs (×7)"` bundles 7 dialogs as a single opaque item. Flow 4 (Settings Configuration) covers booru switching and toggles but does not give individual flows for ChangeParamDialog, ChangeDownloadPrefDialog, ChangeKeyDialog, ClearCacheDialog, CustomAboutDialog, or ChangeSlideIntervalDialog. (EXPERIENCE.md frontmatter). *Fix suggestion:* Either list dialogs individually in `screens`, or add a dedicated dialog-interaction flow covering the most common dialog use case.
- **[medium]** Flow 2 (Targeted Search) describes the user opening the drawer on HomePage to adjust Search Settings, but by step 3 the user has already pushed to SearchPage. The IA shows Search Settings as a HomePage drawer item, meaning the user must go back or was expected to configure before searching. The flow steps contradict the IA. (EXPERIENCE.md: Flow 2 step 4 vs. IA). *Fix suggestion:* Reorder flow steps to match the actual navigation path, or add a step clarifying that settings are configured from HomePage before/after searching.

## 2. Token Completeness — broken

Checked: YAML frontmatter token definitions in DESIGN.md, plus all `{path.to.token}` prose references in EXPERIENCE.md. Verified format against `design-md-spec.md` (flat objects, hex strings, `{path.to.token}` cross-reference syntax).

### Findings
- **[critical]** Main light/dark theme colors use symbolic Dart constants (`Colors.blue`, `Colors.black54`, `Colors.grey[850]`) instead of hex strings. A downstream consumer outside the Flutter context cannot resolve these to renderable values. (DESIGN.md frontmatter `colors.light-primary`, `colors.dark-primary`). *Fix suggestion:* Replace all symbolic values with their hex equivalents (e.g., `Colors.grey[850]` -> `'#303030'`).
- **[critical]** The frontmatter `colors` section uses arrays of `{name, value, role}` objects instead of the spec-required flat object format. Mechanical extraction via the `{path.to.token}` resolver convention is impossible. (DESIGN.md frontmatter `colors`). *Fix suggestion:* Restructure as a flat kebab-case object: `primary: '#2196F3'`, `foreground: '#0000008A'`, etc.
- **[critical]** The `components` frontmatter uses prose descriptions and code-referenced property names (`barForegroundColor`, `primarySwatch`) instead of token-mapped objects with `{path.to.token}` references. A consumer cannot derive component-specific token values mechanically. (DESIGN.md frontmatter `components`). *Fix suggestion:* Replace prose with structured token maps, e.g., `floating-action-button: { background: '{colors.primary}', foreground: '{colors.barForeground}' }`.
- **[critical]** Zero `{path.to.token}` cross-references exist anywhere in DESIGN.md. The prose refers to tokens by ad-hoc names (e.g., "`primarySwatch` color", "`titleColor`", "`foregroundColor`") that don't resolve through the frontmatter path system. (DESIGN.md: Components section). *Fix suggestion:* Convert all ad-hoc token references to `{path.to.token}` syntax.
- **[medium]** Typography tokens specify `fontSize` only. No `lineHeight`, `letterSpacing`, or `fontWeight` values are defined for the size scale. (DESIGN.md frontmatter `typography.scale`). *Fix suggestion:* Add `lineHeight` and `fontWeight` for each type role, or add a note stating that platform defaults are used.
- **[medium]** No dark-mode typography adjustments are specified. If the app switches from light `Colors.black54` to dark `Colors.white`, the type scale remains the same — but this should be explicitly stated. (DESIGN.md). *Fix suggestion:* Add a note confirming the type scale is invariant across themes.
- **[low]** The `rounded` frontmatter uses prose descriptions ("default Material shape (4.0)", "default Material chip radius") instead of dimension values. A consumer outside Flutter cannot resolve these. (DESIGN.md frontmatter `rounded`). *Fix suggestion:* Add explicit dimension values alongside the semantic notes, e.g., `global: 4.0`, `chips: 8.0`, or add a `note` field.
- **[low]** The `spacing` frontmatter uses Flutter-specific property names (`mainAxisSpacing`, `crossAxisSpacing`, `childAspectRatio`) that are GridView delegate parameters, not design spacing tokens. (DESIGN.md frontmatter `spacing`). *Fix suggestion:* Separate layout-grid parameters from spacing-scale tokens. Use a standard scale (`'1': 4px`, `'2': 8px`, ...) for spacing and move layout properties to the relevant component description.

## 3. Component Coverage — broken

Checked: Every component name in DESIGN.md Components section against EXPERIENCE.md Component Patterns section. Also checked every EXPERIENCE.md pattern against DESIGN.md.

### Findings
- **[critical]** DESIGN.md components `AppBar`, `FloatingActionButton (FAB)`, `Drawer`, `Switch`, and `Dropdown` have no corresponding behavioral specification in EXPERIENCE.md Component Patterns. A developer implementing interactions for these components gets no guidance. (DESIGN.md: Components; EXPERIENCE.md: Component Patterns). *Fix suggestion:* Add behavioral entries for these in EXPERIENCE.md Component Patterns.
- **[critical]** EXPERIENCE.md patterns `Infinite Scroll`, `Navigation Pattern`, `Image Loading`, `Bottom Sheet Patterns`, and `Tag Display` have no corresponding visual specification in DESIGN.md Components (they are implementation patterns, not components, but they cover behaviors tied to specific DESIGN.md components). Conversely, DESIGN.md's `Gallery Toolbar` has no EXPERIENCE.md behavioral pattern. (EXPERIENCE.md: Component Patterns). *Fix suggestion:* Either rename confusing patterns, or add visual specs for them in DESIGN.md. Ensure the toolbar has a behavioral entry in EXPERIENCE.md.
- **[medium]** EXPERIENCE.md Component Patterns uses narrative subsections instead of the table format (`Component | Use | Behavioral rules`) shown in both examples (Quill and Drift). This makes cross-referencing with DESIGN.md components slower and more error-prone. (EXPERIENCE.md: Component Patterns). *Fix suggestion:* Convert each narrative subsection into a table row with `Component`, `Use`, and `Behavioral rules` columns.

## 4. State Coverage — thin

Checked: Every IA surface listed in EXPERIENCE.md against the state table. Evaluated coverage of: empty, cold-load, focus, loading, error, offline, and permission-denied states.

### Findings
- **[critical]** No surface has an empty-state UI. ImageGrid shows "Grid with 0 items (no empty-state widget)", Search shows "Empty container", Favorites shows "Grid with 0 items (no empty-state widget)". Users see blank surfaces with no message or action. (EXPERIENCE.md: State Patterns table, Known gaps). *Fix suggestion:* Add a dedicated empty state per surface — at minimum a message explaining why the surface is empty (e.g., "No favorites yet. Tap the heart icon on any image.").
- **[critical]** Offline state is not handled for any component. Every row in the State Patterns table marks Offline as `[NOT HANDLED]`. (EXPERIENCE.md: State Patterns table). *Fix suggestion:* Define offline behavior per component — at minimum a passive indicator (no disruptive banner) with local-write-continue semantics for favorites.
- **[high]** No focus states are defined for any component. Tap targets (chips, switches, dropdowns) have no visual focus treatment specified. (EXPERIENCE.md: State Patterns). *Fix suggestion:* Add focus-state entries for each interactive component in the State Patterns table.
- **[high]** No cold-load state is defined for any surface. The State Patterns table jumps directly to "Loading" or "Loaded" without specifying what the user sees on first app open. (EXPERIENCE.md: State Patterns). *Fix suggestion:* Add a `Cold load` column or row entries describing initial render state (skeleton, cached content, or splash).
- **[medium]** Loading state for ImageGrid and Favorites is "Not shown (images load individually)" — no skeleton, placeholder, or shimmer. The user sees empty space while images resolve. (EXPERIENCE.md: State Patterns table). *Fix suggestion:* Add a skeleton/grid-placeholder matching the expected layout in each grid mode.
- **[medium]** The "Known gaps" section (in State Patterns) acknowledges these gaps as known, which is honest, but does not prescribe solutions or prioritization. (EXPERIENCE.md: State Patterns). *Fix suggestion:* Elevate each known gap to a spec entry with guidance on the preferred treatment, even if it remains unimplemented.

## 5. Visual Reference Coverage — broken

Checked: `mockups/`, `wireframes/`, and `imports/` directories under the spine pair directory. Also searched for any `→` or inline references to visual files in both spine documents.

### Findings
- **[critical]** No `mockups/`, `wireframes/`, or `imports/` directories exist. Neither spine contains any inline reference to a visual file (`(→ mockups/...)`). A downstream consumer has zero visual reference — no wireframe, mockup, screenshot, or diagram to anchor the specifications. (Entire directory). *Fix suggestion:* At minimum add a wireframe diagram showing the key screen layout and navigation flow. Include screenshots of the existing app as visual reference with annotations linking to DESIGN.md components.

## 6. Bloat and Overspecification — adequate

Checked: Prose volume vs. signal; pixel-level specs where semantic would suffice; source restatement; sections a downstream consumer would not read.

### Findings
- **[medium]** The DESIGN.md Components section (prose) and Do's and Don'ts section contain implementation-level guidance specific to the Flutter codebase (e.g., "Use `AppTheme.defaultTheme` / `AppTheme.darkTheme` for theme consistency", "Use `SearchInterface` abstract class for any new image-list page"). This reads as a developer contribution guide rather than a design specification. (DESIGN.md: Components, Do's and Don'ts). *Fix suggestion:* Separate design constraints (visual rules) from implementation guidance (code patterns). Move code-pattern guidance to a companion developer guide or inline comments in `component-inventory.md`.
- **[low]** The Do's and Don'ts section mixes code-pattern items (Provider + Consumer pattern, SearchInterface abstract class) with genuine design rules (reference theme tokens, don't hardcode colors). The design rules get diluted. (DESIGN.md: Do's and Don'ts). *Fix suggestion:* Keep only design-visible rules in DESIGN.md Do's and Don'ts; move code-architecture items to a separate implementation conventions document.

## 7. Inheritance Discipline — broken

Checked: EXPERIENCE.md `design_ref` and `source` frontmatter; name consistency of UJ/requirements, glossary entries, and component names between the two spines; resolvability of EXPERIENCE.md token references against DESIGN.md tokens.

### Findings
- **[critical]** EXPERIENCE.md uses `{DESIGN.md.colors}`, `{DESIGN.md.typography}`, `{DESIGN.md.components}`, `{DESIGN.md.colors.tag-categories}`, and `{DESIGN.md.Brand & Style}` as token references. These resolve to DESIGN.md sections, not individual frontmatter tokens. A downstream consumer or automated tool cannot resolve a specific value (e.g., `{colors.primary}`) from these references. (EXPERIENCE.md: Foundation, Accessibility Floor). *Fix suggestion:* Replace section-level references with individual token paths: `{colors.light-primary.primarySwatch.value}` or restructure DESIGN.md tokens to enable `{colors.primary}`.
- **[critical]** Component names are inconsistent between the two spines. DESIGN.md uses "Image Grid (Thumbnails)", "Gallery Viewer", "Gallery Toolbar", "Fav Icon", "Toast (Snackbar alternative)" while EXPERIENCE.md uses "Image Loading", "Gallery Interaction", "Favorite Toggle", "Toast Feedback". A consumer cannot mechanically cross-reference. (Both spines). *Fix suggestion:* Align all component names across both spines. Use DESIGN.md component names as the canonical list and map them one-to-one in EXPERIENCE.md Component Patterns.
- **[high]** DESIGN.md frontmatter is missing the required `name` key (uses `project` instead) and `description` key. EXPERIENCE.md frontmatter is missing the `sources` array (has a flat `source` string). Both deviate from the spec's required metadata structure. (Both spines frontmatter). *Fix suggestion:* Add `name: derpiviewer` and a `description` field to DESIGN.md; add a `sources` array with entries per source file to EXPERIENCE.md.
- **[medium]** The `design_ref: ./DESIGN.md` path is correct, but EXPERIENCE.md calls its section "Component Patterns" while DESIGN.md calls its analogous section "Components" — a minor but avoidable naming mismatch. (EXPERIENCE.md: Component Patterns section heading vs DESIGN.md: Components section heading). *Fix suggestion:* Use the same section heading in both spines ("Components" or "Component Patterns", consistently).

## 8. Shape Fit — adequate

Checked: DESIGN.md section order against spec (Brand & Style -> Colors -> Typography -> Layout & Spacing -> Elevation & Depth -> Shapes -> Components -> Do's and Don'ts). EXPERIENCE.md mandatory-default and required-when-applicable sections.

### Findings
- **[high]** EXPERIENCE.md is missing the "Inspiration & Anti-patterns" section. The `.decision-log.md` records design decisions (e.g., "No brand identity", "No deep linking") that could be framed as Inspired/Rejected entries, but no such section exists. The Quill and Drift examples both include this section, and the decision log's content would benefit from this framing. (EXPERIENCE.md). *Fix suggestion:* Add an Inspiration & Anti-patterns section distilling the `.decision-log.md` decisions into "Lifted from [source]" and "Rejected — [pattern]" entries.
- **[high]** DESIGN.md frontmatter is missing the required `name` field (uses `project: derpiviewer` instead of `name: derpiviewer`). Also missing the required `description` field. Per `design-md-spec.md`, `name` and `description` are required. (DESIGN.md frontmatter). *Fix suggestion:* Add `name: derpiviewer` and a `description` string to the frontmatter.
- **[medium]** EXPERIENCE.md has no Glossary section. The spec does not require a glossary for experience spines, but both examples include glossary-like entries in their component/state tables. The current spine uses terms like "booru", "hero transition", "SliverGrid", and "ChangeNotifier" without defining them for a non-Flutter audience. (EXPERIENCE.md). *Fix suggestion:* Add a brief Glossary defining domain terms (booru, Philomena, hero transition) and Flutter-specific patterns for non-Flutter consumers.

## Mechanical Notes

- **Frontmatter format drift:** Both spines use `schema: design-md` / `schema: experience-md`, `version: "1.0"`, `project: derpiviewer`, `created`, `updated`, `source` — none of which appear in the reference examples or spec. While not wrong per se, this makes the spines harder to validate against the canonical format.
- **No Mermaid or other structured diagrams:** The IA diagram in EXPERIENCE.md is ASCII-art with emoji markers. It is functional but cannot be mechanically validated. Consider Mermaid for cross-referencing with DESIGN.md components.
- **EXPERIENCE.md `source` vs `sources`:** The spec examples use a `sources` array of `{planning_artifacts}` macros. This spine uses `source: Brownfield reverse-engineering from lib/ Flutter source` — a flat string, not an array. The `.decision-log.md` lists 17 specific source files but the EXPERIENCE.md frontmatter does not reference them.
- **`name` vs `project`:** Both spines use `project` in frontmatter where the spec expects `name`. This is consistent across the two files but inconsistent with the spec.
- **DESIGN.md `rounded` values:** `thumbnails: sharp (0, via Material with transparent color)` has a space after the colon and a parenthetical — valid YAML but unconventional for a dimension field.
- **DESIGN.md typography `weight` section:** Uses `FontWeight.bold` (Dart constant) instead of numeric values or CSS keywords. Not parseable outside Flutter.
- **No `heroTag` cross-reference:** The DESIGN.md prose mentions `heroTag: "fav-fab"` and `heroTag: "sch-fab"`, and the EXPERIENCE.md mentions hero transitions, but neither file references the specific hero tags used — a consumer would not know what tag values to use when implementing the hero animation.
- **EXPERIENCE.md screen list:** `"Dialogs (×7)"` and `"BottomSheets (Share, Detail)"` are non-standard screen names with special characters. If consumed mechanically, the parentheses and multiplication sign would need escaping.

---

## Finding Summary

| Severity | Count |
|----------|-------|
| Critical | 9 |
| High | 6 |
| Medium | 6 |
| Low | 3 |
| **Total** | **24** |

## Verdicts by Category

| # | Category | Verdict |
|---|----------|---------|
| 1 | Flow Coverage | broken |
| 2 | Token Completeness | broken |
| 3 | Component Coverage | broken |
| 4 | State Coverage | thin |
| 5 | Visual Reference Coverage | broken |
| 6 | Bloat and Overspecification | adequate |
| 7 | Inheritance Discipline | broken |
| 8 | Shape Fit | adequate |
