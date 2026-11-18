# Agent Instructions

Personal Windows utility-script repo. Two PowerShell scripts under `win/` plus Beads (`bd`)
issue tracking. No application code, no build system, no test suite.

## Running `bd` on this machine (read this first)

PowerShell execution policy is `Undefined` at every scope, so the `bd.ps1` shim **cannot be
loaded**. Invoking `bd` directly in PowerShell fails with `PSSecurityException` / "la ejecución
de scripts está deshabilitada en este sistema".

Always invoke it through the CMD shim:

```powershell
cmd /c "bd ready"          # works
cmd /c "bd list --status=open"
cmd /c "bd show <id>"
```

Do not "fix" this by changing the machine execution policy, and do not add `bd` calls to
PowerShell-based tooling that would inherit the same restriction. The Cursor hook
(`.cursor/hooks.json` -> `bd cursor-hook ...`) runs in its own shell and is unaffected.

## Task tracking

`bd` is the single source of truth for work items. Do not create markdown TODO lists, and do
not use `bd remember` to write `MEMORY.md` files.

```bash
bd ready              # issues with no blockers
bd show <id>          # full detail incl. design notes
bd update <id> --claim  # claim atomically
bd close <id>         # mark done
bd create "title" -d "details" -t task -p 2
```

Run `bd prime` for the authoritative command reference and workflow context; it is regenerated
by `bd setup` and supersedes any hand-written command list here.

### Session start / session end

Start: run `cmd /c "bd ready"` and read any open issue with `bd show <id>` before writing code —
the issue description is where the previous agent left context.

End: close finished issues, create a follow-up issue with concrete technical detail if work
remains, then report changed files and validation.

**Git authority is conservative by default.** Do not run `git commit`, `git push`, or
`bd dolt push` unless the user or orchestrator explicitly asks. The managed Beads block in this
file describes the profile rules: Conservative and Minimal profiles report status and proposed
commands instead of acting; only a Team-maintainer opt-in authorizes commits and pushes.

## Two separate remotes — do not conflate them

| What | Command | Where it goes |
|---|---|---|
| Source code | `git push` | `origin` = `git+https://github.com/alicedev94/comandos_utiles.git` |
| Issue data | `bd dolt push` | Same URL, but stored under `refs/dolt/data` on the remote |

They are separate ref namespaces on the same git remote. Pushing code does **not** push issue
data and vice versa. `.beads/issues.jsonl` is a passive export, not the wire protocol — do not
treat it as the source of truth and do not run `bd import` during normal operation.

The Dolt engine here is **embedded / in-process** (no server), data lives in
`.beads/embeddeddolt/`. See
[sync-concepts](https://github.com/gastownhall/beads/blob/main/docs/core-concepts/sync-concepts.md).

## The `win/` scripts

Both target a `drove-runtime` folder that is *not* in the repo:

- `win/detener_uso_carpeta.ps1` — finds processes whose command line or executable path
  contains `drove-runtime` and force-kills them (`Stop-Process -Force`).
- `win/elimar_carpeta_contemido.ps1` — `Remove-Item -Path ".\drove-runtime" -Recurse -Force`.
- `win/ejecutar_programa.ps1` — runs an `.exe` and waits for it to finish, propagating its
  exit code. Takes an optional `-Ruta` (default `.\drove-runtime\programa.exe`); passes no
  extra arguments to the executable.

Gotchas:

- `ejecutar_programa.ps1` needs `-ExecutionPolicy Bypass` to run on this machine
  (`powershell -ExecutionPolicy Bypass -File .\win\ejecutar_programa.ps1`), for the same
  policy reason described above. Its `-Ruta` default is relative to the current directory,
  not to the script location.

- **`elimar_carpeta_contemido.ps1` uses a relative path** (`.\drove-runtime`), so it only
  deletes a folder in the current working directory. Run it from the directory that actually
  contains `drove-runtime`, and confirm the target before running — `-Recurse -Force` is
  unrecoverable.
- The scripts are Windows-only (PowerShell + `Win32_Process` CIM class). They are a
  convenience for the author's machine, not portable tooling.
- `drove-runtime` is not tracked and not gitignored. If it is ever created in the repo root,
  add it to `.gitignore` before committing.

## Repository facts

- `package.json` is a stub: `npm test` intentionally fails with "no test specified". There is
  no build, lint, typecheck, or test command — do not invent one or claim validation that did
  not happen.
- No CI workflows, no pre-commit tooling of its own. The only git hooks are the Beads-managed
  ones under `.beads/hooks/` (pre-commit, pre-push, post-checkout, post-merge,
  prepare-commit-msg), installed by `bd init`. They are inert if `bd` is not on the hook
  shell's `PATH`.
- Default branch is `main`. Beads issues are currently empty (`bd ready` reports no open
  issues), so there is no pre-seeded roadmap to align with.

## Non-interactive shell commands

`cp`, `mv`, and `rm` may be aliased with `-i` on some systems and will hang waiting for
y/n input. Use `cp -f`, `mv -f`, `rm -f`, `rm -rf`, `cp -rf`. For remote commands use
`scp -o BatchMode=yes` and `ssh -o BatchMode=yes`; add `-y` to `apt-get` and
`HOMEBREW_NO_AUTO_UPDATE=1` to `brew`.

## Instruction files in this repo

| File | Role |
|---|---|
| `AGENTS.md` (this file) | Primary instructions |
| `CLAUDE.md` | Claude Code variant; its Build/Test and Architecture sections are unfilled placeholders |
| `.cursor/rules/beads.mdc` | `alwaysApply: true` — auto-loaded by Cursor |
| `.agents/skills/beads/SKILL.md` | Beads skill, loaded on demand |

The `<!-- BEGIN/END BEADS ... -->` and `<!-- BEGIN/END BEADS CODEX SETUP -->` blocks in this
file are generated by `bd setup`. Edit inside them only via `bd setup`; keep custom guidance
outside the markers so it survives regeneration.
