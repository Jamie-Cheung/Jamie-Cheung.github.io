Personal homepage: https://jamie-cheung.github.io/

## 一键显示 / 隐藏主页（无需改仓库 Public / Private）

把仓库设为 **Private** 会下线 GitHub Pages，改回 **Public** 后还要重新部署，比较麻烦。

推荐做法：

1. **仓库保持 Public**（代码在 GitHub 上可见；若必须连代码也隐藏，只能继续用 Private + 付费方案，或接受无法对外建站）。
2. 在仓库 **Settings → Pages → Build and deployment** 里，**Source 选 GitHub Actions**（只需设置一次）。
3. 用 Actions 控制对外展示的内容：

| 操作 | 方法 |
|------|------|
| **隐藏主页** | Actions → **Hide homepage** → Run workflow |
| **显示主页** | Actions → **Publish homepage** → Run workflow |

也可编辑根目录 `site-config.json`：把 `"published": false` 后 push 到 `main`，会自动部署离线页；改回 `true` 则恢复完整主页。

隐藏时访客只会看到「主页暂未公开」，不会出现 404，也**不必**再切换仓库可见性。
