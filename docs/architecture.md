# Architecture & Workflow Maps

Three Mermaid diagrams documenting the end-to-end agentic SDLC.

## 1. End-to-End Agentic SDLC Pipeline

From idea to production, every stage has an agent-driven skill or command.

```mermaid
flowchart TD
    subgraph INPUT["Input"]
        IDEA["Idea / Feature Request"]
        BUG["Bug Report"]
    end

    subgraph TRIAGE["Triage & Planning"]
        TR["/triage\nClassify, research, route\nto GitHub Issues"]
        PRD["/prd-taskmaster\nGenerate PRD,\npublish as GH Issue"]
        SPEC["/agent-os:shape-spec\nGather context,\nstructure implementation plan"]
    end

    subgraph IMPLEMENTATION["Implementation"]
        FEAT["/feature-dev\nGuided feature development\nwith codebase understanding"]
        B2P["/bug-to-pr\n8-stage pipeline:\ntriage -> RCA -> counsel\n-> implement -> simplify"]
        P2P["/prd-to-pr\nFull PRD-to-merged-PR\norchestration"]
        AGENTS["Specialized Agents\nios-architect | ios-developer\ngcp-platform-engineer\ndead-code-agent"]
    end

    subgraph QUALITY["Quality Gates"]
        SIMP["/simplify\nCode clarity,\nconsistency, reuse"]
        PRHO["/pr-handoff-to-codex\n4 adversarial Codex agents:\nArchitecture | Security\nCode Quality | Orchestrator"]
        REVIEW["/code-review\nPR review with\nspecialized agents"]
    end

    subgraph CICD["CI/CD Pipeline"]
        CI["ci-gates.yml\nPath-filtered checks"]
        TESTS["backend-tests | ios-tests\nios-ui-tests | perf-tests"]
        DEPLOY["gcp-deploy.yml\nBuild + Deploy to Dev"]
        STAGE["gcp-promote-staging.yml\ncrane copy + approval gate"]
        PROD["gcp-promote-prod.yml\ntag v* + approval gate"]
    end

    subgraph SELFHEAL["Self-Healing Deploy"]
        SH["/self-healing-deploy\n7-phase pipeline"]
        SH1["Phase 0: Recon"]
        SH2["Phase 1: Merge"]
        SH3["Phase 2: Self-Heal CI\nRead logs, classify, fix"]
        SH4["Phase 3: DB Migrations"]
        SH5["Phase 4: Terraform Apply"]
        SH6["Phase 5: Dev Verification"]
        SH7["Phase 6-7: Promote\nStaging -> Production"]
    end

    IDEA --> TR
    BUG --> TR
    TR --> PRD
    PRD --> SPEC
    SPEC --> FEAT
    SPEC --> B2P
    SPEC --> P2P
    FEAT --> AGENTS
    B2P --> AGENTS
    P2P --> AGENTS
    AGENTS --> SIMP
    SIMP --> PRHO
    PRHO --> REVIEW
    REVIEW --> CI
    CI --> TESTS
    TESTS --> SH
    SH --> SH1 --> SH2 --> SH3 --> SH4 --> SH5 --> SH6 --> SH7
    SH7 --> PROD
    SH3 -.->|fix & retry| CI
    DEPLOY -.-> STAGE -.-> PROD

    style INPUT fill:#e1f5fe
    style TRIAGE fill:#f3e5f5
    style IMPLEMENTATION fill:#e8f5e9
    style QUALITY fill:#fff3e0
    style CICD fill:#fce4ec
    style SELFHEAL fill:#f1f8e9
```

## 2. Claude Code Tool Ecosystem

How skills, agents, commands, hooks, plugins, and MCP servers connect.

```mermaid
flowchart TB
    CC["Claude Code CLI"]

    subgraph SKILLS["Skills (trigger-matched)"]
        direction TB
        S1["self-healing-deploy"]
        S2["prd-taskmaster / prd-to-pr"]
        S3["bug-to-pr"]
        S4["pr-handoff-to-codex"]
        S5["triage"]
        S6["senior-architect"]
        S7["security-threat-model"]
        S8["gh-fix-ci"]
        S9["code-simplifier"]
        S10["ios-design / dead-code-cleanup"]
    end

    subgraph AGENTS["Agents (dispatched)"]
        A1["ios-architect"]
        A2["ios-developer"]
        A3["gcp-platform-engineer"]
        A4["dead-code-agent"]
    end

    subgraph COMMANDS["Commands (user-invoked)"]
        direction TB
        C1["agent-os/\ndiscover | index | inject\nplan-product | shape-spec"]
        C2["ops/\ncost-optimize | cost-report\nperf-check | perf-optimize\nsecurity-scan | pr-flow"]
        C3["ios/\nios-build | ios-design"]
        C4["design-os/\nproduct-vision | roadmap\ndata-model | design-tokens\ndesign-shell | design-screen\nshape-section | export"]
    end

    subgraph HOOKS["Hooks"]
        H1["Optional SessionStart\nsession-init.sh"]
    end

    subgraph PLUGINS["Plugins (marketplace)"]
        P1["superpowers v5.0.7"]
        P2["frontend-design"]
        P3["pr-review-toolkit"]
        P4["commit-commands"]
        P5["code-review"]
        P6["buildatscale"]
    end

    subgraph MCP["MCP Servers"]
        M1["xcodebuild\niOS builds, simulator"]
        M2["Docker (recommended)\ncontainer ops"]
    end

    CC --> SKILLS
    CC --> AGENTS
    CC --> COMMANDS
    CC --> HOOKS
    CC --> PLUGINS
    CC <--> MCP

    style CC fill:#1a237e,color:#fff
    style SKILLS fill:#e8eaf6
    style AGENTS fill:#e0f2f1
    style COMMANDS fill:#fff8e1
    style HOOKS fill:#fce4ec
    style PLUGINS fill:#f3e5f5
    style MCP fill:#e8f5e9
```

## 3. CI/CD Workflow Dependencies

How the 16 GitHub Actions workflows connect and depend on each other.

```mermaid
flowchart TD
    subgraph PR["Pull Request"]
        CIG["ci-gates.yml\ndorny/paths-filter"]
    end

    subgraph CHECKS["PR Checks (conditional)"]
        BT["backend-tests.yml\n.NET build + test"]
        IT["ios-tests.yml\nFastlane unit tests"]
        TP["gcp-terraform.yml\nterraform plan"]
        CIP["ci-passed\nbranch protection gate"]
    end

    subgraph MERGE["On Merge to Main"]
        DEP["gcp-deploy.yml\nBuild + Test + Deploy Dev"]
        TFA["gcp-terraform.yml\nterraform apply"]
    end

    subgraph PROMOTE["Promotion"]
        STG["gcp-promote-staging.yml\ncrane copy + approval"]
        PRD["gcp-promote-prod.yml\ncrane copy + approval"]
    end

    subgraph SUPPORT["Support Workflows"]
        MIG["gcp-db-migrations.yml\nSQL runner per env"]
        RB["gcp-rollback.yml\ntraffic shift rollback"]
        AIHF["gcp-ai-config-admin-hotfix.yml"]
    end

    subgraph SCHEDULED["Scheduled"]
        OPS["weekly-ops-review.yml\nSunday 8PM CT"]
        RET["gcs-artifact-retention.yml\nMonday 3:30AM UTC"]
    end

    subgraph MANUAL["Manual / Event"]
        UIT["ios-ui-tests.yml\nUI smoke tests"]
        PERF["perf-tests.yml\nK6 load tests"]
        TF["sync-testflight-feedback.yml"]
        CL["claude.yml\n@claude bot"]
    end

    CIG -->|backend changed| BT
    CIG -->|iOS changed| IT
    CIG -->|terraform changed| TP
    BT --> CIP
    IT --> CIP
    TP --> CIP
    CIP -->|merge| DEP
    CIP -->|merge + tf| TFA
    DEP -->|dispatch| STG
    STG -->|tag v*| PRD
    MIG -.->|any env| DEP
    MIG -.->|any env| STG
    MIG -.->|any env| PRD
    RB -.->|emergency| DEP
    RB -.->|emergency| STG
    RB -.->|emergency| PRD

    style PR fill:#e3f2fd
    style CHECKS fill:#f1f8e9
    style MERGE fill:#fff3e0
    style PROMOTE fill:#fce4ec
    style SUPPORT fill:#f3e5f5
    style SCHEDULED fill:#e0f7fa
    style MANUAL fill:#fff8e1
```
