# 从零开始：GitHub + Qoder 开发实战教程

> 本教程以一个完整案例带你体验：**注册 GitHub → 下载安装 Qoder → 用 Qoder 开发项目 → 提交到 GitHub** 的全流程。
>
> 即使你没有任何编程基础，跟着步骤操作也能完成。

---

## 案例项目简介

我们将开发一个 **"个人待办清单"（Todo List）** 网页应用，功能包括：
- 添加待办事项
- 标记完成 / 删除事项
- 数据本地保存（刷新不丢失）

最终效果是一个可以在浏览器中打开使用的单页应用，代码将托管在 GitHub 上。

---

## 第一步：注册 GitHub 账号

### 1.1 打开注册页面

打开浏览器，访问：**https://github.com/signup**

### 1.2 填写注册信息

| 字段 | 填写内容 | 说明 |
|------|---------|------|
| Email | 你的邮箱地址 | 推荐使用常用邮箱 |
| Password | 设置密码 | 至少 8 位，包含数字 |
| Username | 设置用户名 | 例如 `zhangsan2024`，后续会出现在仓库地址中 |

填写完成后点击 **Continue**，完成邮箱验证（输入邮箱收到的验证码）。

### 1.3 选择计划

- 注册过程中会问你选择 **Free（免费）** 还是付费计划
- 选择 **Free** 即可，个人开发完全够用

### 1.4 注册完成

注册成功后会进入 GitHub 首页（https://github.com），右上角可以看到你的头像图标。

> **提示**：记住你的用户名，后面创建仓库和推送代码时会用到。

---

## 第二步：下载安装 Qoder

### 2.1 下载 Qoder IDE

打开浏览器，访问：**https://qoder.com/download**

页面会自动识别你的操作系统，点击下载按钮即可：

| 操作系统 | 下载文件 |
|----------|---------|
| Windows | `.exe` 安装包（推荐 User 版，无需管理员权限） |
| macOS | `.dmg` 安装包 |
| Linux | `.deb` / `.rpm` 包 |

### 2.2 安装 Qoder

**Windows 用户：**
1. 双击下载的 `.exe` 安装包
2. 可自定义安装路径（建议非系统盘，如 `D:\Qoder`）
3. 勾选"创建桌面快捷方式"
4. 点击"安装"，等待完成

**macOS 用户：**
1. 双击 `.dmg` 文件
2. 将 Qoder 图标拖入"应用程序"文件夹
3. 完成安装

### 2.3 启动并登录 Qoder

1. 双击桌面 Qoder 图标启动
2. 首次启动会引导你完成初始配置（选择主题等）
3. 点击右上角用户图标 → **登录**
4. 在弹出的网页中：
   - 可以使用 **GitHub 账号一键登录**（推荐，后续推送代码更方便）
   - 也可以用邮箱注册 Qoder 账号
5. 登录成功后返回 Qoder IDE

> **提示**：Qoder 个人版提供免费试用额度，包含 AI 智能编码功能。

---

## 第三步：在 Qoder 中创建项目

### 3.1 创建项目文件夹

在你的电脑上创建一个新文件夹，用于存放项目文件：

```
# 例如在桌面创建
桌面/
  └── my-todo-app/
```

### 3.2 用 Qoder 打开项目

1. 启动 Qoder IDE
2. 点击菜单 **文件 → 打开文件夹**
3. 选择刚才创建的 `my-todo-app` 文件夹
4. Qoder 会打开该项目（此时文件夹是空的）

### 3.3 使用 Qoder AI 生成项目代码

这是 Qoder 最强大的功能——**你只需要用自然语言描述需求，AI 帮你写代码**。

**方法一：使用 Agent 模式（推荐）**

1. 在 Qoder 右侧打开 AI 助手面板
2. 切换到 **Agent** 模式
3. 输入以下提示词：

```
帮我创建一个个人待办清单（Todo List）网页应用，要求：
1. 使用纯 HTML + CSS + JavaScript，不需要任何框架
2. 所有代码写在一个 index.html 文件中（内联 CSS 和 JS）
3. 功能包括：
   - 输入框 + 添加按钮，可以添加待办事项
   - 每个事项前面有复选框，点击可标记为已完成（文字加删除线）
   - 每个事项右侧有删除按钮
   - 使用 localStorage 保存数据，刷新页面后数据不丢失
4. 界面要美观，使用现代简洁的设计风格
5. 支持回车键快速添加事项
```

4. 按回车发送，Qoder AI 会自动分析需求并生成代码
5. AI 会在你的项目中创建 `index.html` 文件

**方法二：手动创建文件**

如果 AI 助手暂时不可用，你也可以手动创建：

1. 在 Qoder 左侧文件树中右键 → **新建文件**
2. 输入文件名 `index.html`
3. 将以下代码粘贴进去：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的待办清单</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            padding: 40px 20px;
        }
        .container {
            background: white;
            border-radius: 16px;
            padding: 32px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
        }
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 24px;
            font-size: 24px;
        }
        .input-area {
            display: flex;
            gap: 8px;
            margin-bottom: 24px;
        }
        .input-area input {
            flex: 1;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 15px;
            outline: none;
            transition: border-color 0.2s;
        }
        .input-area input:focus { border-color: #667eea; }
        .input-area button {
            padding: 12px 20px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
            transition: background 0.2s;
        }
        .input-area button:hover { background: #5a6fd6; }
        .todo-list { list-style: none; }
        .todo-item {
            display: flex;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
            animation: slideIn 0.2s ease;
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-8px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .todo-item input[type="checkbox"] {
            width: 20px;
            height: 20px;
            margin-right: 12px;
            cursor: pointer;
            accent-color: #667eea;
        }
        .todo-item span {
            flex: 1;
            font-size: 15px;
            color: #333;
            transition: all 0.2s;
        }
        .todo-item.done span {
            text-decoration: line-through;
            color: #aaa;
        }
        .todo-item .delete-btn {
            background: none;
            border: none;
            color: #e74c3c;
            font-size: 18px;
            cursor: pointer;
            padding: 4px 8px;
            border-radius: 4px;
            opacity: 0;
            transition: opacity 0.2s;
        }
        .todo-item:hover .delete-btn { opacity: 1; }
        .empty-msg {
            text-align: center;
            color: #aaa;
            padding: 32px 0;
            font-size: 14px;
        }
        .stats {
            text-align: center;
            color: #888;
            font-size: 13px;
            margin-top: 16px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📝 我的待办清单</h1>
        <div class="input-area">
            <input type="text" id="todoInput" placeholder="输入新的待办事项..." autofocus>
            <button onclick="addTodo()">添加</button>
        </div>
        <ul class="todo-list" id="todoList"></ul>
        <div class="stats" id="stats"></div>
    </div>

    <script>
        let todos = JSON.parse(localStorage.getItem('todos')) || [];

        const input = document.getElementById('todoInput');
        const list = document.getElementById('todoList');
        const stats = document.getElementById('stats');

        // 回车键添加
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') addTodo();
        });

        function addTodo() {
            const text = input.value.trim();
            if (!text) return;
            todos.push({ text, done: false });
            input.value = '';
            saveAndRender();
        }

        function toggleTodo(index) {
            todos[index].done = !todos[index].done;
            saveAndRender();
        }

        function deleteTodo(index) {
            todos.splice(index, 1);
            saveAndRender();
        }

        function saveAndRender() {
            localStorage.setItem('todos', JSON.stringify(todos));
            render();
        }

        function render() {
            list.innerHTML = '';
            if (todos.length === 0) {
                list.innerHTML = '<li class="empty-msg">暂无待办事项，添加一个吧 ✨</li>';
                stats.textContent = '';
                return;
            }
            todos.forEach((todo, index) => {
                const li = document.createElement('li');
                li.className = 'todo-item' + (todo.done ? ' done' : '');
                li.innerHTML = `
                    <input type="checkbox" ${todo.done ? 'checked' : ''} 
                           onchange="toggleTodo(${index})">
                    <span>${todo.text}</span>
                    <button class="delete-btn" onclick="deleteTodo(${index})">✕</button>
                `;
                list.appendChild(li);
            });
            const doneCount = todos.filter(t => t.done).length;
            stats.textContent = `共 ${todos.length} 项，已完成 ${doneCount} 项`;
        }

        render();
    </script>
</body>
</html>
```

### 3.4 预览项目效果

1. 在 Qoder 中打开 `index.html` 文件
2. 右键文件 → **在浏览器中打开**（或用浏览器直接打开该文件）
3. 你应该能看到一个漂亮的待办清单界面，可以添加、完成、删除事项

---

## 第四步：在 GitHub 上创建远程仓库

### 4.1 创建新仓库

1. 登录 GitHub，点击右上角 **+** → **New repository**
2. 填写信息：

| 字段 | 填写内容 |
|------|---------|
| Repository name | `my-todo-app` |
| Description | `我的个人待办清单网页应用`（可选） |
| 可见性 | 选择 **Public** |
| 初始化 | **不要勾选** "Add a README"、".gitignore"、"license" |

3. 点击 **Create repository**

### 4.2 记录仓库地址

创建成功后，页面会显示仓库地址，格式为：

```
https://github.com/你的用户名/my-todo-app.git
```

复制这个地址，后面推送代码要用。

---

## 第五步：用 Qoder 将项目提交到 GitHub

### 5.1 在 Qoder 中初始化 Git 仓库

**方法一：使用 Qoder 内置终端**

1. 在 Qoder 中按快捷键 `` Ctrl + ` ``（反引号）打开终端
2. 依次输入以下命令：

```bash
# 初始化 Git 仓库
git init

# 添加所有文件到暂存区
git add .

# 提交（引号内是本次提交的说明）
git commit -m "init: 创建待办清单应用"

# 设置主分支为 main
git branch -M main

# 添加 GitHub 远程仓库（替换为你的实际地址）
git remote add origin https://github.com/你的用户名/my-todo-app.git

# 推送到 GitHub
git push -u origin main
```

**方法二：使用 Qoder 源代码管理面板**

1. 点击 Qoder 左侧栏的 **源代码管理** 图标（分叉形状）
2. 你会看到 `index.html` 文件显示在"更改"列表中
3. 在输入框中输入提交说明：`init: 创建待办清单应用`
4. 点击 **✓ 提交** 按钮
5. 点击 **... → 推送** 或点击 **同步更改** 按钮
6. 如果是第一次推送，会要求你登录 GitHub 账号进行授权

### 5.2 GitHub 授权登录

第一次推送时，Qoder 会弹出 GitHub 登录窗口：

1. 弹出"登录到 GitHub"提示 → 点击 **登录**
2. 浏览器自动打开 GitHub 登录页面
3. 输入你的 GitHub 账号密码（或使用已登录的会话）
4. 点击 **授权** 允许 Qoder 访问你的 GitHub
5. 返回 Qoder，推送会自动继续

### 5.3 推送成功

看到类似以下输出表示推送成功：

```
Done
```

---

## 第六步：在 GitHub 上查看项目

### 6.1 打开项目页面

在浏览器中访问：

```
https://github.com/你的用户名/my-todo-app
```

你应该能看到：
- `index.html` 文件已经上传
- 提交记录显示 "init: 创建待办清单应用"

### 6.2 使用 GitHub Pages 在线预览（可选）

GitHub 可以免费托管你的网页，让别人也能通过链接访问：

1. 在仓库页面点击 **Settings**（设置）
2. 左侧菜单找到 **Pages**
3. "Source" 选择 **Deploy from a branch**
4. Branch 选择 **main**，文件夹选 **/ (root)**
5. 点击 **Save**
6. 等待 1-2 分钟后，你的应用就可以通过以下地址访问：

```
https://你的用户名.github.io/my-todo-app/
```

---

## 第七步：后续修改与更新

项目开发过程中，你会经常修改代码并推送到 GitHub。流程非常简单：

### 7.1 修改代码

在 Qoder 中直接编辑文件，保存即可。

### 7.2 使用 Qoder AI 辅助修改

你可以继续在 Qoder 的 AI 助手中提出修改需求，例如：

```
帮我在待办清单中添加一个"优先级"功能：
- 每个事项可以选择高/中/低优先级
- 不同优先级用不同颜色标记
- 高优先级的事项排在最前面
```

AI 会自动修改代码文件。

### 7.3 提交并推送

```bash
# 添加修改的文件
git add .

# 提交
git commit -m "feat: 添加优先级功能"

# 推送
git push
```

或者使用 Qoder 的源代码管理面板，操作同第五步。

---

## 完整流程总结

```
┌─────────────────────────────────────────────────────────────┐
│                    完整开发流程一览                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ① 注册 GitHub                                              │
│     └→ github.com/signup → 填写信息 → 验证邮箱               │
│                          ↓                                  │
│  ② 下载安装 Qoder                                           │
│     └→ qoder.com/download → 安装 → 用 GitHub 账号登录        │
│                          ↓                                  │
│  ③ 用 Qoder 开发项目                                        │
│     └→ 打开项目文件夹 → AI 助手描述需求 → 生成代码 → 预览效果  │
│                          ↓                                  │
│  ④ GitHub 创建远程仓库                                       │
│     └→ 右上角 + → New repository → 填写名称 → Create          │
│                          ↓                                  │
│  ⑤ 推送到 GitHub                                            │
│     └→ git init → git add . → git commit → git push          │
│                          ↓                                  │
│  ⑥ 查看与在线预览                                            │
│     └→ 打开仓库页面 → Settings → Pages → 在线访问              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 常见问题

### Q1：推送时提示 "Authentication failed" 怎么办？

**解决方法**：
1. 确保你在 Qoder 中已登录 GitHub 账号
2. 或者使用 **Personal Access Token** 代替密码：
   - GitHub → Settings → Developer settings → Personal access tokens → Generate new token
   - 勾选 `repo` 权限，生成 token
   - 推送密码时输入这个 token

### Q2：推送时提示 "rejected" 或 "non-fast-forward" 怎么办？

这是因为远程仓库有你本地没有的提交（例如创建仓库时勾选了 README）。

**解决方法**：
```bash
git pull origin main --rebase
git push -u origin main
```

### Q3：Qoder AI 生成的代码不满意怎么办？

直接在 AI 助手中描述你想要的修改，例如：
- "把背景颜色改成蓝色"
- "添加一个搜索功能"
- "把按钮改成圆角"

AI 会基于你的反馈继续修改代码。

### Q4：可以在手机上查看 GitHub 上的项目吗？

可以！直接在手机浏览器中访问 `github.com` 即可查看代码。如果使用 GitHub Pages 部署了网页，也可以直接在手机浏览器中打开使用。

---

## 进阶学习

完成本教程后，你可以继续探索：

| 方向 | 说明 |
|------|------|
| **学习 Git 常用命令** | `git log`（查看历史）、`git diff`（查看修改）、`git branch`（分支管理） |
| **使用 Qoder Agent 模式** | 让 AI 自主完成更复杂的开发任务 |
| **学习 GitHub 协作** | Fork、Pull Request、Issue 等协作功能 |
| **部署到 Vercel** | 比 GitHub Pages 更强大的免费部署方案 |
| **探索 Qoder Quest 模式** | 将长时间开发任务委派给 AI 自主完成 |

---

> **恭喜你！** 完成本教程后，你已经掌握了从注册 GitHub 到使用 Qoder 开发项目再到提交代码的完整流程。这就是现代开发者每天都在使用的工作方式，而 Qoder 的 AI 能力让这个过程变得更加高效。
