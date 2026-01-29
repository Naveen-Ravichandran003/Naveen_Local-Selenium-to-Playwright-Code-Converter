# Task Plan - Selenium to Playwright Converter

## Project Phases

### 🟢 Phase 0: Initialization (Current)
- [ ] Initialize project memory files (`task_plan.md`, `findings.md`, `progress.md`, `gemini.md`)
- [ ] Discovery Questions for the User
- [ ] Define Data Schema in `gemini.md`

### 🏗️ Phase 1: B - Blueprint (Vision & Logic)
- [x] Research existing Selenium to Playwright conversion tools/patterns
- [x] Define conversion mapping (Selenium Java -> Playwright TS/JS)
- [ ] Define System Architecture:
    - **Frontend:** HTML/JS dashboard (due to local environment constraints)
    - **Backend:** PowerShell-based conversion scripts interacting with Ollama.
    - **Logic:** Prompt-engineered conversion using `llama3.2:1b` (pending) or `tinyllama`.
- [x] Finalize Blueprint

### ⚡ Phase 2: L - Link (Connectivity)
- [x] Setup local environment (Ollama on port 11434)
- [x] Verify Ollama accessibility and model availability
- [wip] Pull optimized model (`llama3.2:1b`)

### ⚙️ Phase 3: A - Architect (The 3-Layer Build)
- [ ] Layer 1: Architecture (`architecture/`) - Write SOPs for conversion logic
- [ ] Layer 2: Navigation - Logic to route code chunks to conversion tools
- [ ] Layer 3: Tools (`tools/`) - Implement Python/Node scripts for actual conversion

### ✨ Phase 4: S - Stylize (Refinement & UI)
- [ ] Refine output formatting (Prettier, ESLint rules)
- [ ] If applicable, a simple UI for uploading/pasting code

### 🛰️ Phase 5: T - Trigger (Deployment)
- [ ] Final documentation
- [ ] Maintenance log in `gemini.md`

## Checklists
- [ ] Core conversion logic for Basic Selectors
- [ ] Core conversion logic for Actions (Click, Type)
- [ ] Core conversion logic for Assertions
- [ ] Wait mechanism conversion (Explicit/Implicit -> Playwright auto-waiting)
- [ ] Page Object Model (POM) structure conversion
