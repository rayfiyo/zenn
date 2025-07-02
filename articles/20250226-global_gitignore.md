---
title: "グローバルなgitignoreの設定を大公開！" # 記事のタイトル
emoji: "🔧" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["git", "ignore", "config"] # ["markdown", "go", "WSL2"]のように５つまで、go と golang は同じ
published: true # falseで下書き
published_at: 2025-02-26 18:00 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---

# 概要

Git 初学者向けに、Git のグローバルな設定の gitignore （`~/.config/git/ignore` ファイル）のおすすめ設定を書いてみる。

# 背景

身近な人に Git/GitHub を勧めているが、初学者故に設定をしらないことがあるので、秘匿せずに設定ファイルを紹介する。みんなハッピー！！

# 対象読者

- Git 初学者

# 環境

今回の環境は次である。

```fish:terminal
$ git --version
git version 2.48.1
```

---

# 本論

## gitignore とは

この節は読み飛ばしても構わない。
手短に言うと、Git に「これらのファイルはバージョン管理の対象外です」と伝えるためのもの。
無視したいファイル名やパターン（正規表現）を記述する設定ファイル。
対象の例として、コンパイル後の成果物、ログ、個人設定ファイルなどが挙げられる。

指定する方法はいくつかある。

第一に、ローカル（レポジトリ毎）に設定する方法。
これはリポジトリのルートに `.gitignore` ファイルを置き、それに記述する。
ちなみに、`!` を付けた行は無視の否定ができる。
これは特定のレポジトリではグローバルの設定を適用したくない場合などに有効である。

第二に、グローバル（全リポジトリ共通）に設定する方法。
本記事の対象がこれなので以下に詳しく述べる。

## グローバルな gitignore

`~/.config/git/ignore` ファイルに記述する。
ドキュメントとしては [Git のドキュメント](#2) や [GitHub Docs](#3) を参照されたし。

具体的には `~/.config/git` ディレクトリを作成する。
Windows風に言えば `$home/.config/git` だろうか。
`.` から始まるのでGUIで作成する場合は隠しファイルになることを念頭に。
Linux なら次のコマンドが使える。

```bash
mkdir -p ~/.config/git
```

そしたら、そのディレクトリ直下に`ignore`ファイルを作成する。例えば次のコマンド。

```bash
touch ~/.config/git/ignore
```

## おすすめの設定

次をおすすめの紹介として紹介する。
`#`以降は行コメントになるのでコピペで全てを記載しても構わない。

```gitignore
# macOS
.DS_Store
.AppleDouble
.Spotlight-V100
.Trashes

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# WSL
*Zone.Identifier

# エディタ/IDE
.vscode/

# ログ・一時ファイルなど
*.log
*.tmp
*.temp
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# ビルド成果物・依存関係など
/.pnp
.pnp.js
node_modules/

# 環境変数や機密情報など
.env
.env.*
.secrets
*.key
*.pem
*.crt
```

## 関連の紹介

プロジェクトによっては次のようなサイトが役立つ。
頻繁に使用する言語やフレームワークがあればグローバルに記載しても良いかもしれない。

- https://github.com/github/gitignore
- https://www.toptal.com/developers/gitignore

## 私の設定

私の ignore ファイルをここに乗せておく。バックアップを兼ねている。

```
# macOS
.DS_Store
.AppleDouble
.Spotlight-V100
.Trashes

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# WSL
*Zone.Identifier

# エディタ/IDE
.vscode/

# ログ・一時ファイルなど
*.log
*.tmp
*.temp
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# ビルド成果物・依存関係など
/.pnp
.pnp.js
node_modules/
tmp/

# 環境変数や機密情報など
.env
.env.*
.secrets
*.key
*.pem
*.crt
cookies.*

# 個人的なもの
!.gitignore
!.gitkeep
template.pdf
cover.pdf
conf.pdf
*.secret.*
*.aup3
bin/

# - - - Go - - - #

# https://github.com/github/gitignore/blob/main/community/Golang/Go.AllowList.gitignore

# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# Dependency directories (remove the comment below to include it)
# vendor/

# Go workspace file
go.work
go.work.sum

# env file
.env
```

---

# 参考文献

## 1

- [_DS_Storeは~_.config_git_ignoreに入れろとあれほど](https://zenn.dev/thousanda/articles/5c7dcd8d6bd9bd#%E4%B8%BB%E5%BC%B5)

## 2

- [Git - gitignore Documentation](https://git-scm.com/docs/gitignore)

## 3

- [ファイルを無視する - GitHub Docs](https://docs.github.com/ja/get-started/getting-started-with-git/ignoring-files)
