---
title: "ソースを更新できませんでした: wingetについて" # 記事のタイトル
emoji: "📝" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["winget"] # タグ。["markdown", "rust", "aws"]のように指定する
published: true # 公開設定（falseにすると下書き）
published_at: 2023-10-5 01:11 # 過去・未来の日時を指定する
---

# 現在の状況
2023年10月5日1時10分現在，stable release での解決は見られず．

---

# 流れ
1.2023年10月4日wingetを用いてinstallを試みる
2.```ソースを更新できませんでした: winget``` と表示される
3.ダウンロード完了後 ```インストーラーのハッシュが一致しません。``` と出力される

# バージョン
v1.6.2721 (Latest of stable release)

# 関連しそうなissues
* https://github.com/microsoft/winget-cli/issues/3687
* https://github.com/microsoft/winget-cli/issues/3652

# その他
* Pre-release版のLatest(1.7.2722)であれば改善する可能性がある（未検証）
* ```winget source reset winget``` を実行すれば改善する場合がある
→ 検証したが，改善されなかった．また，当然だがリセットされるので直すのが面倒
