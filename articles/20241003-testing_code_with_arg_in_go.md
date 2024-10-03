---
title: "Go言語で flag.Arg を使ったコードのテスト" # 記事のタイトル
emoji: "💨" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["go", "test", "testing", "flag", "arg"] # ["markdown", "go", "WSL2"]のように５つまで
published: true # falseで下書き
published_at: 2024-10-04 18:00 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---

# 概要

- Go言語の flag パッケージの Arg を使ったコードでテストをする

# 背景

flag パッケージのうち，フラグを指定しているコードのテストは見つかったものの，
（Arg を使った）実行時の引数を指定しているコードのテストが見つからなかったから．

# 対象読者

- Go言語を使っている
- テストを書いている
- flagパッケージを使っている
- flag.Arg(0) などの引数を使ったコードのテストを書きたい

# 環境

今回の環境は次である．

```bash
$ go version
go version go1.23.1 linux/amd64
```

---

# 本論

フラグ: `$main -flag="hoge"`
引数: `$main "hoge"`

## フラグを指定

まず，前提知識的にフラグを使ったテストコードについて述べる．
`go テスト フラグ` などで Google 検索すれば出てくる情報である．\*[1](#1)
`flag.CommandLine.Set` を使って，フラグをプログラム内で設定する方法となる．

```go
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {

        // $main -flag="hoge" と同じ
        flag.CommandLine.Set("flag", "hoge")

        if got := hoge(); got != tt.want {
            t.Errorf("hoge() = %v, want %v", got, tt.want)
        }
    })
}
```

## 引数を指定

今回やりたかった，実行時の引数を指定したテストコードについて述べる．
os.Args を直接設定することで、実行時の引数をエミュレートする方法となる．

```go
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {

        // $main "hoge" と同じ
		os.Args = "hoge"

        if got := hoge(); got != tt.want {
            t.Errorf("hoge() = %v, want %v", got, tt.want)
        }
	})
}
```

### コード全体の例

```
package flags

import (
	"os"
	"testing"
)

func TestParse(t *testing.T) {
	tests := []struct {
		name string
		args []string
		want string
	}{
		{
			name: "引数が1つの場合",
			args: []string{"program", "hello"},
			want: "hello",
		},
		{
			name: "引数が複数の場合",
			args: []string{"program", "hello", "world"},
			want: "hello",
		},
		{
			name: "引数がない場合",
			args: []string{"program"},
			want: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			os.Args = tt.args
			if got := Parse(); got != tt.want {
				t.Errorf("hoge() = %v, want %v", got, tt.want)
			}
		})
	}
}
```

# 参考

## 1

- [【Go】 ユニットテストでflagへ引数を渡す際のハマりどころ #Go - Qiita](https://qiita.com/vengavengavnega/items/874212b929ba53ce2810)
