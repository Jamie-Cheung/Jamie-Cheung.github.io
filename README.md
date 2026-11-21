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

也可编辑根目录 `site-config.json`：把 `"published": false` 后 push 到 `main`，会自动部署隐藏模式；改回 `true` 则恢复完整主页。

### 隐藏后需要密码才能看

隐藏不是把网站关掉，而是：

- 打开 https://jamie-cheung.github.io/ 会看到「主页暂未公开」和密码输入框
- 任何人输入正确密码后都能看到完整主页（不区分游客 / 站长）
- 密码正确后，这台电脑的浏览器会记住；下次可直接进入
- 顶部有黄条提示；点「退出」后需重新输入密码

密码在 `site-config.json` 的 `previewKey`。更稳妥的做法：在仓库 **Settings → Secrets and variables → Actions** 里添加 `HOMEPAGE_PREVIEW_KEY`，它会覆盖 JSON 里的口令。

也可以把口令收藏成：

`https://jamie-cheung.github.io/?preview=你的口令`

GitHub Pages 没有真正的账号登录系统，所以这是口令门禁，不是账号权限。没有密码的人看不到完整主页；但如果仓库仍是 Public，别人去 GitHub 翻源码还是能看到 `index.html`。
