# Personal development

- Work directly on `main` for this personal project unless the user requests another branch.
- `origin` is `https://github.com/ZimaAI/test-WeKnora.git`; `upstream` is the original Tencent repository.
- Keep every GitHub Actions workflow manual-only (`workflow_dispatch`); do not add push, PR, schedule, or other automatic triggers.
- Never commit `.env`, credentials, database files, or deployment backups.

## Docker Desktop

- Reuse Compose project `weknora` and its existing data volumes. Do not run `down -v` or delete volumes during updates.
- Run `./scripts/update-local.ps1` in PowerShell to build the current checkout and update the local deployment.
- The script uses `docker-compose.yml` plus `docker-compose.local.yml` and tags local images with the Git commit.
- Local credentials and port bindings come from the ignored `.env`. Preserve the existing encryption keys when updating.
- Use the same two Compose files and `-p weknora` for subsequent container management.

<!-- CODEGRAPH_START -->
## CodeGraph

When `.codegraph/` exists at the repository root, use CodeGraph before text search or reading source files to locate or understand code. Prefer `codegraph_explore` / `codegraph_node` when available, or `codegraph explore` / `codegraph node` from the shell. If `.codegraph/` is absent, skip CodeGraph; indexing is the user's decision.
<!-- CODEGRAPH_END -->
