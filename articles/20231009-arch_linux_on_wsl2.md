---
title: "Arch Linux on WSL2 をやる方法" # 記事のタイトル
emoji: "🐧" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["wsl", "wsl2", "archlinux", "arch"] # タグ。["markdown", "rust", "aws"]のように指定する
published: true # 公開設定（falseにすると下書き）
published_at: 2023-10-09 22:00 # 過去・未来の日時を指定する
---

# 要約

WSL2のディストリビューションを非公式だがArchLinuxにしたい！
→ できた

# 前提

- WSL2のインストール（私は Ubuntu on WSL）
- dockerの実行環境（私は Windows11側にインストール）
- この例では，ArchLinuxのユーザー名を userName にする（任意の名前を使用可能）
- この例では，ArchLinuxのデータを C:\arch\ext4.vhdx に保存する（任意のディレクトリを指定可能）

# 経過観察

- 2023年10月9日以前に利用開始
- 2024年1月30日特に支障無し
  　（Dockerイメージの都合上，[manコマンドのエントリーが導入されない問題](https://zenn.dev/rayfiyo/scraps/53bed39cf5d91a#comment-2f6f24ea9525c9)に遭遇 のみ）

# 手順

## ArchLinuxの準備 in wsl

- wslではなくpwshでも可能だと思われる（未検証）

```sh:wsl
docker run -it --name foo archlinux
```

## ユーザー作成 in arch on docker

:::message
userName というユーザーを作成する場合の例
:::

- ユーザー作成時にパスワードを設定するので標準入力が必要
- pacmanでインストール時の yes/no を尋ねるようにするには `--noconfirm` オプションを外す
- sed ではなく `EDITOR=vim visudo` でも可能（寧ろ そちらの方が一般的）

```sh:arch on docker
useradd -m -G wheel userName
passwd userName
pacman -Syu --noconfirm
pacman -Syu sudo vim --noconfirm
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g" /etc/sudoers | EDITOR=tee visudo >/dev/null
```

## ログインユーザー変更 in arch on docker

:::message
userName というユーザーを作成する場合の例
:::

- wslで実行したときに，ログインするデフォルトユーザー名を変更する
- こちらも任意のエディタで編集しても同じ結果が得られる（未検証）

```sh:arch on docker
cat << EOF > /etc/wsl.conf
[user]
default=userName
EOF
```

- 全部終わったので docker から exit する

```sh:arch on docker
exit
```

## エクスポート in wsl

wslではなくpwshでも可能だと思われる（未検証）
:::message
Cドライブ直下にarchディレクトリを作成し，そのディレクトリ内に ArchLinux のデータを保存する場合の例
:::

```sh:wsl
mkdir /mnt/c/arch
docker export foo > /mnt/c/arch/ArchLinuxImage.tar
```

## インポート in pwsh

pwshではなくwslでも可能だと思われる（未検証）が，wsl内部から別のwslを操作するのは明瞭ではない．
:::message
　C:\arch ディレクトリ直下に ext4.vhdx というファイルにデータを保存する場合の例
:::

- 相対パスで指定も可能

```sh:powershell
wsl --import Arch C:\arch C:\arch\ArchLinuxImage.tar
wsl -d Arch
```

# 追加設定

- 必要に応じて行う
- 一部 Docker のイメージ由来で設定が必要な箇所もあるので一通り目を通すことを勧める

## man コマンドの有効化

```
/etc/pacman.conf
```

にある，

```
NoExtract  = usr/share/man/* usr/share/info/*
```

を`#`でコメントアウトする．

## pacman の package databases 編集

```
/etc/makepkg.conf・
```

にある，`OPTIONS`から始まる行を次のデフォルトに設定しておく．

```
OPTIONS=(!strip docs libtool staticlibs emptydirs !zipman !purge !debug !lto !autodeps)
```

## Dockerの追加設定

WSLとDockerの統合を有効にする．

> The command 'docker' could not be found in this WSL 2 distro.
> We recommend to activate the WSL integration in Docker Desktop settings.
>
> For details about using Docker Desktop with WSL 2, visit:
>
> https://docs.docker.com/go/wsl2/
> というような警告が出た場合に有効．

- Docker Desktop を起動
- 右上の⚙をクリック
- 左のサイドバーから Resources → WSL integration を選択
- Arch のトグルをONにする
- 右下の Apply & restart で保存する

## WindowsTerminalの追加設定

現在，WindowsTerminalでは画面上部の﹀からArchを起動することができないはず．
ここにArch追加するには2つの方法がある．

### 再起動

- WindowsTerminal あるいは Windows 自体を再起動する．

### 手動で追加する

- WindowsTerminalの 設定 → プロファイル
- JSONで追加する方向けに例を記述しておく
- guid は [こちら](https://hogehoge.tk/guid/) などで作成できるはず

```json
{
  "guid": "{a5a97cb8-8961-5535-816d-772efe0c6a3f}",
  "hidden": false,
  "icon": "C:\\images\\arch.png",
  "name": "Arch",
  "source": "Windows.Terminal.Wsl"
}
```

## wslの設定の変更

`/etc/wsl.conf` の設定を自分用に付け足す（以下が完成形）

```sh:/etc/wsl.conf
# https://learn.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig

# Sets the directory where fixed drives will be automatically mounted. This example changes the mount location, so your C-drive would be /c, rather than the default /mnt/c.
root = /

# Network host settings that enable the DNS server used by WSL 2. This example changes the hostname, sets generateHosts to false, preventing WSL from the default behavior of auto-generating /etc/hosts, and sets generateResolvConf to false, preventing WSL from auto-generating /etc/resolv.conf, so that you can create your own (ie. nameserver 1.1.1.1).
[network]
generateResolvConf = true
# generateResolvConf = true

[user]
default = ray

[boot]
systemd = true
```

# 削除方法

削除方法も記しておく．ブックマークなど保存しておくと良いかも？

## ディストリビューション一覧

```sh
wsl -l
```

## 削除

```sh
wsl --unregister ディストリビューション名
```

# 実行環境

## wsl.exe -v

WSL バージョン: 1.2.5.0
カーネル バージョン: 5.15.90.1
WSLg バージョン: 1.0.51
MSRDC バージョン: 1.2.3770
Direct3D バージョン: 1.608.2-61064218
DXCore バージョン: 10.0.25131.1002-220531-1700.rs-onecore-base2-hyp
Windows バージョン: 10.0.22621.2283

## docker -v

Docker version 24.0.6, build ed223bc

# 参考文献

- [Arch Linux on Windows Subsystem for Linux (WSL) - YouTube](https://www.youtube.com/watch?v=h0Wg_aknGdc)
