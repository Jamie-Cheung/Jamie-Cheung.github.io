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

### 隐藏后只有自己能看（类似谷歌学术）

隐藏不是把网站关掉，而是：

- **别人**打开 https://jamie-cheung.github.io/ 只能看到「主页暂未公开」
- **你自己**点页面上很浅的「我是站长」，输入预览口令，就能看到完整主页
- 口令正确后，这台电脑的浏览器会记住；下次直接打开网站也会进入你的预览
- 预览页顶部有黄条提示「当前仅你可见」。点「退出预览」后，这台电脑也会变回外人看到的样子

预览口令在 `site-config.json` 的 `previewKey`（当前默认是 `zhanjie-preview`，请改成只有你知道的口令）。更稳妥的做法：在仓库 **Settings → Secrets and variables → Actions** 里添加 `HOMEPAGE_PREVIEW_KEY`，它会覆盖 JSON 里的口令。

也可以把口令收藏成：

`https://jamie-cheung.github.io/?preview=你的口令`

GitHub Pages 没有谷歌学术那种「登录后才是我」的权限系统，所以这是口令预览，不是账号登录。外人打开网站看不到完整主页；但如果仓库仍是 Public，别人去 GitHub 翻源码还是能看到 `index.html`。
