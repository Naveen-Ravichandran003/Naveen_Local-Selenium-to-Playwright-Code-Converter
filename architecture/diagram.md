# System Architecture

```mermaid
graph TD
    User["User / QA Engineer"] -->|Pastes Java Code| UI["Premium HTML/JS UI (Direct Fetch)"]
    UI -->|REST API POST| LLM["Ollama Local Engine (lama3.2:1b)"]
    LLM -->|Generates TS| UI
    UI -->|Displays Result| User
    
    UI -.->|Local Execution| PS["PowerShell Backend (main_converter.ps1)"]
    PS -->|File System| Res["Converted Directory"]

    subgraph "Local Machine (Secure Zone)"
    UI
    PS
    LLM
    end
```

## Logic Flow
1. **Source of Truth:** User input via the glassmorphism UI.
2. **Analysis:** Browser-side JS sanitizes the input and sends it to the local Ollama instance (`localhost:11434`).
3. **Reasoning:** Ollama processes the Selenium-to-Playwright prompt.
4. **Local Persistence:** For full project conversion, the PowerShell script creates the actual file structure.
5. **Payload:** Reusable Playwright TypeScript tests.
