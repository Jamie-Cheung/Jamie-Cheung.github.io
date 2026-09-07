# 一次性设置：Pages 改用 GitHub Actions

Cloud Agent **无法代替你点击** GitHub 网页上的 Settings（需要你的账号管理员权限）。请在本机浏览器完成下面 **3 步**（约 30 秒）。

## 步骤

1. 打开：**https://github.com/Jamie-Cheung/Jamie-Cheung.github.io/settings/pages**

2. 找到 **Build and deployment** → **Source**

3. 在下拉框中选择 **GitHub Actions**（不要选 *Deploy from a branch*）

4. 保存后，到 **Actions** 页签，运行一次 **Publish homepage** workflow，等待约 1 分钟变绿

## 完成后

- **隐藏主页**：Actions → **Hide homepage** → Run workflow  
- **显示主页**：Actions → **Publish homepage** → Run workflow  

隐藏后外人只能看到「主页暂未公开」；你自己可用 `site-config.json` 里的 `previewKey` 打开完整预览（类似谷歌学术隐藏主页后自己仍能看）。

以后不必再改仓库 Public / Private。

## 若下拉框里没有 GitHub Actions

先确认仓库为 **Public**，且 `.github/workflows/` 里已有 `deploy-pages.yml`（本仓库已包含）。刷新 Settings → Pages 页面后再试。
