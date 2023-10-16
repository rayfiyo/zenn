---
title: "nvimで:wq！みたいな全角つかいたい" # 記事のタイトル
emoji: "📝" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["nvim", "neovim"] # ["markdown", "rust", "aws"]のように５つまで
published: ture # falseで下書き
published_at: 2023-10-16 13:00 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---
# 概要
タイトルの通り．
# 背景
私は現在 Windows で neovim と Google日本語入力を用いている．
日常で，!より！のほうが便利なため，日本語入力時には！を入力するようにしているが，nvimを使う際には不便である．
そこで，対策を簡単にできたので，メモ感覚で記事にする．
# 対象読者
私と同じように悩んでいて，nvimの設定をluaで記述している人．
# 本文
~~~ lua
local map = vim.keymap.set
map("n", "！", "!")    -- :wq！用
map("n", "っd", "dd")  -- 全角・半角間違い用
map("n", "っy", "yy")  -- 全角・半角間違い用
map("n", "うう", "uu") -- 全角・半角間違い用
~~~
luaのconfigに，以上を記入すれば よい．
```:wq！``` だけでは飽き足らず，```dd```, ```yy```, ```uu``` なども対策した．
