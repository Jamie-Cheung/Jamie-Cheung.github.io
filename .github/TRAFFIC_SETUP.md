# Traffic stats setup

The homepage reads `data/traffic.json`, which is updated from the GitHub Traffic API.

## One-time secret (required)

The default `GITHUB_TOKEN` cannot call the Traffic API. Add a classic Personal Access Token once:

1. GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. **Generate new token (classic)** with the **`repo`** scope
3. In this repository, open **Settings** → **Secrets and variables** → **Actions**
4. Create a repository secret named **`TRAFFIC_SYNC_TOKEN`** and paste the token

After that:

- **Deploy homepage** will refresh traffic data on every deploy
- **Sync traffic stats** runs daily at 00:30 UTC and redeploys when the numbers change

## Manual refresh

Actions → **Sync traffic stats** → **Run workflow**
