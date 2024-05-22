---
title: "GoogleスライドにGASで任意のフォントを追加する" # 記事のタイトル
emoji: "✍️" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["google", "slides", "font" "gas", "googleスライド"] #５つまで
published: false # falseで下書き
# published_at: 2024-05-22 19:30 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---

# 概要

Google スライド (Google slides) に Google Apps Script を用いて
任意のフォントを追加する方法を記した．

# 背景

Google スライドにNoto Serif JP がなく困ったから．

# 対象読者

スクリプトキディ以上の能力を持つ人．

---

# 本論

## スクリプトを書き込む準備

任意の Google スライドを開き，
上部のタブ（リボン？）から以下を選択<br>
拡張機能 -> Apps Script

## スクリプトの記述

以下を記述する

```
function NewFonts() {
  var presentation = SlidesApp.getActivePresentation();
  var slide = presentation.appendSlide(SlidesApp.PredefinedLayout.BLANK);
  var textBox = slide.insertTextBox("テキストです"); // Insert a text box with your text
  var textRange = textBox.getText(); // Get the text range of the inserted text

  // Apply the font family to the text range
  textRange.getTextStyle().setFontFamily("Noto Serif JP");
}
```

## 実行

上部のタブに ▶実行 があるのでクリックする．<br>
認証のポップアップが出るので指示に従う．<br>
エラーが出たら頑張って直す．<br>

## 結果

すると，ページの最後に新規ページが追加され，
そのページの左上に テキストです というテキストボックが挿入されている．
このテキストに設定したフォントが適用されている．<br>
また，フォント一覧にも設定したフォントが追加されているはずである．

---

# 参考文献

[【GAS】Googleドキュメントで Noto Sans JP などの日本語Google Fontsを使う](https://qiita.com/katou_/items/0c294f566284bb7b6353)
