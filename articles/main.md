# CachyOS + Hyprland

# インストール

公式より ISO ファイルをダウンロードし、
チェックサムを確認して Rufus でインストールメディアを作成した。
https://cachyos.org/download/

詳細な手順が欲しい場合は次を参照すると良さそう。
https://wiki.cachyos.org/ja/installation/installation_prepare/

基本、表示に沿ってインストールを行った。
変更箇所は次（覚えているもののみ）で、
Windows11 には別れを告げず
^[プロダクトキーを明示的に控えておけばよかったと後悔している。
きっと、過去に控えていると信じている。] フォーマットした。

- ブートマネージャ: Limine
- ファイルシステム: BTRFS
- デスクトップ環境: Hyprland
- キーボード: Generic 104 keyboard
  - 正しい名称は覚えていないが、
    ブランドPCではなかったので　Generic だった
  - US 配列を使うので 104 キーボードを選択した

# 設定

設定アプリが起動した。
おそらく Hyprland の GUI でできる設定じゃないだろうか。
タスクバーを中心に変更した。

設定ファイルはエクスポートできたので、
あとで dotfiles とまとめて公開する。

# インストール

取り急ぎ、ブラウザとターミナルをインストールした。

- ブラウザ: Vivaldi
- ターミナル: WezTerm

```fish
shelly install standard vivaldi
shelly install standard wezterm
```

余談だが、デフォルトで fish が使えて嬉しかった。
また、shelly という aur に対応している
パッケージマネージャがデフォルトで入っていた。
これまた感動した。

# 日本語

## 入力

ド定番の fcitx5 + Mozc を使う。

```fish
shelly install standard fcitx5 fcitx5-configtool fcitx5-mozc
```

依存関係で勝手に Mozc も入れてくれそうな雰囲気だった。

## ユーザーディレクトリ

ホームディレクトリ直下が日本語になっていたので、
英語にした。root 直下ではないので sudo は不要。

```fish
LANG=C xdg-user-dirs-update --force
```
# SSH to GitHub

GitHub に SSH できるようにした。

[自身が過去に書いた記事](https://zenn.dev/rayfiyo/articles/20231122-ssh_key_gen) を参考に、SSH キーを作成した。

```fish
ssh-keygen -t ed25519 -C "git@github.com"
```

生成された鍵のディレクトリを変更し、
`~/.ssh/config` を作成し、中身は次を書いた。

```text
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github/rayfiyo
```

その後、公開鍵を次に登録した。

https://github.com/settings/keys

あとは、`ssh github.com` で正常に接続できたことを確認した。

# サスペンドの無効化

Linux（systemd）自体が一定時間でスリープするのを
強制的に禁止（マスク）した。

```fish
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

解除したい場合は、`mask` を `unmask` に変えて実行する。

# dotfiles

chezmoi を使って dotfiles を管理しているので導入した。

```fish
shelly install standard chezmoi
chezmoi init --ssh rayfiyo
```

# GPG
