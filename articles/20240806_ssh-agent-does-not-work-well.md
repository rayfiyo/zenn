---
title: "WSL2上でssh-agentが起動はするがうまく動作しない" # 記事のタイトル
emoji: "🐧" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["wsl", "wsl2", "ssh", "ssh-agent", "keychain"] # ["markdown", "go", "WSL2"]のように５つまで
published: true # falseで下書き
published_at: 2024-08-06 12:00 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---

# 概要

# 背景

WSL2上で，公開鍵を使った ssh をするときの
パスワードを正しく１度入力するとそれ以降はデーモンを再起動させたり，
ログアウトさせたりしない限り，
パスワードが聞かれないような設定にしているはずだが，
最近うまく動作していなかったから．

# 対象読者

- 最近 ssh がうまく動作していない
  1. WSL2（以降wsl）上で 公開鍵を使った ssh をしている
  1. keychain を経由して ssh-agent で管理している

## 非対象読者

- 最近 ssh がうまく動作していないが，前述の条件２つに当てはまらない

# 環境

今回の環境は次である．

```fish:terminal
$ wsl.exe --version
WSL バージョン: 2.2.4.0
カーネル バージョン: 5.15.153.1-2
WSLg バージョン: 1.0.61
MSRDC バージョン: 1.2.5326
Direct3D バージョン: 1.611.1-81528511
DXCore バージョン: 10.0.26091.1-240325-1447.ge-release
Windows バージョン: 10.0.22631.3880
```

また，ディストリビューションは Arch Linux である．

```fish:terminal
$ cat /eNAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
VERSION_ID=20231001.0.182270
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://bugs.archlinux.org/"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logotc/os-release
```

さらに，ターミナルは fish を使っている．

```fish:terminal
$ fish --version
fish, version 3.7.1
```

その他の keychain や systemd のバージョンについても記しておく．

```fish:terminal
$ keychain --version

 * keychain 2.8.5 ~ http://www.funtoo.org

   Copyright 2002-2006 Gentoo Foundation;
   Copyright 2007 Aron Griffis;
   Copyright 2009-2017 Funtoo Solutions, Inc;
   lockfile() Copyright 2009 Parallels, Inc.

 Keychain is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License version 2 as
 published by the Free Software Foundation.
```

```fish:terminal
$ systemctl --version
systemd 256 (256.2-1-arch)
+PAM +AUDIT -SELINUX -APPARMOR -IMA +SMACK +SECCOMP +GCRYPT +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN +IPTC +KMOD +LIBCRYPTSETUP +LIBCRYPTSETUP_PLUGINS +LIBFDISK +PCRE2 +PWQUALITY +P11KIT +QRENCODE +TPM2 +BZIP2 +LZ4 +XZ +ZLIB +ZSTD +BPF_FRAMEWORK +XKBCOMMON +UTMP -SYSVINIT +LIBARCHIVE
```

---

# 本論

## 前提条件の共有

環境は前述の通りだが，具体的な構成も述べておく．

[この記事\[1\]](#参考文献)を参考に，`eval \`ssh-agent\``で管理していた．

## 解決策

調べてみると次の記事が見つかったが私には効果がなかった．

- [WSL2のUbuntuでkeychain経由でssh-agentを使う](https://zenn.dev/kaityo256/articles/ssh_agent_on_wsl)
- [SSH パスフレーズ 省略したい！~ config 設定するか Keychain 登録自動化するか ~](https://zenn.dev/luvmini511/articles/65786667221313)

効果があった方法は，次の２つの設定を行った後 `wsl --shutdown` で再起動することだった．

## 設定1

次のページを参考にしたので，詳細はこのページを参照してほしい．

- [Systemd user serviceで起動したssh-agentをfish shellで使う](https://zenn.dev/yakumo/articles/03c8b89630e5be)

```service:~/.config/systemd/user/ssh-agent.service
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
```

この設定の有効化のコマンドは次である．

```bash
systemctl --user enable --now ssh-agent.service
```

続いて，環境変数の設定も行う．

```fish:~/.config/fish/config.ssh
set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
```

## 設定2

`~/.ssh/config` に ssh key を有効にする旨を記述する．
各 host 毎にかけば良い．

```
AddKeysToAgent yes
```

なお，調べていると次を記述している記事が見られた，これは MacOS での設定といった WSL2 on Arch 向けではない．

```
AddToAgent yes
UseKeychain yes
```

## 補足

この２つの設定で，keychain を使用する必要が無くなったのでアンインストールや無効化しても良い．

:::details 無効化やアンインストールの注意点
依存関係の確認:
他の設定やスクリプトがkeychainに依存している場合，
それらが動作しなくなる可能性がある．
無効化する前に，影響範囲を確認しておくと安心である．

他のシステムでの利用:
異なる環境間でSSH設定を共有している場合は注意など，
WSL2ではないシステムでkeychainを使用している場合，
致命的な影響を与える可能性がある．
:::

また，この２つの設定は systemd を利用していることを覚えておきたい．
これは，WSL2 と systemd の相性が悪いので今後手詰まる可能性があるからである．

---

# 参考文献

1.[WSL2のUbuntuでkeychain経由でssh-agentを使う](https://zenn.dev/kaityo256/articles/ssh_agent_on_wsl)
