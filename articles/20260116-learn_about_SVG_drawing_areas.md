---
title: "SVG の描画領域についてちゃんと勉強する記事" # 記事のタイトル
emoji: "🎨" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["SVG", "viewBox"] # ["markdown", "go", "WSL2"]のように５つまで，go と golang は同じ
published: false # falseで下書き
# published_at: 2030-01-01 08:00 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---

# 概要

この記事では具体的な SVG を例に段階的に説明していく。

記事の執筆中に見つけた次のサイトは。
SVG の viewBox の挙動を動かしながら確かめることに役立つかも知れない。
https://www.webdesignleaves.com/pr/html/svg_biewbox.html

また、この記事では SVG 1.1 を SVG と称している。
SVG 2 は扱わない。
（なお、私の認識違いで SVG 2 が含まれているかもしれないので、ご指摘お願いします。）

## 背景

- SVG を使ってボタンを実装しようとすると、サイズの指定や描画領域（見切れ）で躓いたから

:::warn
見切れは SVG に CSS で `overflow: visible;` を与えると解決する場合がある。
:::

## 対象読者

- SVG の描画方法についてベクター形式であることは知っているが、
  描画領域まわりを知らずに非ベクター形式の画像と同じ感覚でいる人

---

<!-- # 本論 -->

# 1. 前提知識: SVG における座標系

SVG の描画方法を理解するために必要な前提知識として３種類の座標系がある。
これらの違いを意識するだけでも、サイズ指定や描画領域の躓きを減らすことができる。
（と筆者は思う。）

## 1.1. ユーザー座標系（ユーザー空間）

ユーザー座標系 (user coordinate system) と
ユーザー空間 (user space) は同義である。[\*1](#1)
余談だが、mdn の訳ではユーザー空間が使われている。
しかし、SVG は2次元しか扱えないので空間という表現は不適切だと筆者は思う。

ユーザー座標系は、
**SVG キャンバス上で図形を描画するための座標系**であり、無限の広さである。
すべての図形要素はこのユーザー座標系上の位置や長さとして解釈される。
例えば、パスの `d` 属性で指定する座標、`rect`や `circle` 要素の `x` `y`などの属性値など。

ユーザー座標系は、これ自体を変換することも可能である。
例えば、グループ要素(<g>)などにtransform属性で平行移動や拡大縮小等を指定すると、
その要素と子要素に対して新たなユーザー座標系（現在の座標系）が確立される。
これは、以降の子要素が異なる原点・単位系で配置されることを意味する。
変換をネストすれば座標系の入れ子も累積し、
最終的な描画位置は全ての変換行列を乗じた結果となる。

すなわち最も外側の `<svg>` 要素 は何の変換もされていないユーザー座標系を持ち、
このユーザー座標系を特別に **初期ユーザー座標系** (initial user coordinate system)
と呼ぶ事がある。
これは初期ビューポート座標系（後述）と一致し、
原点がビューポートの原点（左上）にあり、基本的に 1単位 = 1 px（CSSピクセル）である。

以上を踏まえると、SVGではビューポートごとおよび各要素ごとに、
それぞれ固有のユーザー座標系（現在のユーザー座標系）が存在し得る。

## 1.2. ビューポート座標系（ビューポート空間）

ビューポート座標系 (viewport coordinate system) と
ビューポート空間 (viewport space) は同義である。[\*1](#1)

ビューポート座標系は、
**SVG のビューポート（表示領域）自体に対応する座標系**であり、有限の広さである。

そもそも SVG におけるビューポートは、
`<svg>` 要素の `width` および `height` 属性で定義される矩形の表示領域である。
この表示とは、前述のユーザー座標系で、どの領域を表示（可視）するかという意味である。

また、ビューポート座標系の原点は通常ビューポートの左上にあリ、
正のX軸は右方向、正のY軸は下方向に取られ、基本的に 1単位 = 1 px（CSSピクセル）である。

つまり、図形の描画が行われるユーザー座標系の一部を切り取った、
実際に表示される領域（ビューポート）の座標系が、ビューポート座標系である。

> SVG 文書では、ビューポートは SVG 画像の可視領域です。 `<svg>` の幅と高さは自由に設定できますが、画像全体が表示されない場合があります。 表示される領域はビューポートと呼ばれます。 ビューポートのサイズは、 `<svg>` 要素の幅と高さの属性を使用して定義することができます。

https://developer.mozilla.org/ja/docs/Web/CSS/Guides/CSSOM_view/Viewport_concepts#svg

## 1.3. その他の座標系

あまり登場頻度が少ない座標系を簡単に述べておく。
（少なくともこの記事においては以下の理解で支障ないと著者は思う。）

- オブジェクト境界ボックス座標系 (Object Bounding Box Coordinate System)
  - 一言で言えば、対象要素の境界ボックスを (0, 0) – (1, 1) に正規化する変換をした座標系
  - SVG 1.1 では、一部の塗りや効果において
    オブジェクトの境界ボックスを基準とした座標系を使用することができる
    - 例えば、グラデーション、パターン、マスク・クリップパスの座標指定がある
    - これらの要素の属性（例えば `<linearGradient>` の `gradientUnits` 属性、
      `<clipPath>` の `clipPathUnits` 属性など）に `objectBoundingBox` を指定すると、
      対象となる描画要素の境界ボックスに対する相対座標で指定が行われる
    - 原点 (0, 0) が対象オブジェクトの境界ボックスの左上に置かれ、
      境界ボックスの幅と高さがそれぞれ1単位と見做される
      - 例えば、線形グラデーションで `x1="0" y1="0" x2="1" y2="0"` と指定すれば、
        グラデーションの起点が図形の左上端、終点が右上端に対応する
  - 属性に `objectBoundingBox` ではなく `userSpaceOnUse` を指定すると、
    通常のユーザー座標系（適用される要素の座標系）で数値を解釈する
  - `clipPathUnits` に `userSpaceOnUse` と `objectBoundingBox` を指定した例
    - https://developer.mozilla.org/ja/docs/Web/SVG/Reference/Attribute/clipPathUnits
  - https://www.w3.org/TR/SVG11/coords.html#ObjectBoundingBoxUnits
- マーカーにおける座標系
  - SVGの矢印マーカー(<marker>要素)も内部の描画に独自の座標系を持つ


# 2. 単純な円を描画する

```xml
<svg xmlns="http://www.w3.org/2000/svg">
  <circle cx="200" cy="200" r="200"/>
</svg>
```

`<svg xmlns="http://www.w3.org/2000/svg">` はいわゆるおまじないで、このファイルが SVG であることを示す。
SVG を HTML などに埋め込む（inline 表示する）場合はこの表記は不要である。
なおこの `svg` 要素の `xmlns` 属性についての詳細は次の mdn を参照すること。
https://developer.mozilla.org/ja/docs/Web/SVG/Reference/Element/svg#:~:text=%E3%83%A1%E3%83%A2%3A-,xmlns,-%E5%B1%9E%E6%80%A7%E3%81%AF%20SVG

`<circle cx="200" cy="200" r="200"/>` は円を描画している。
`cx` が円の中心の x 座標、`cy` が y 座標、`r` が半径を指定していて、
これらの初期値は `0` である。
今回は `r=200` なので円の描画領域は `400*400` のサイズである。
なお、circle 要素について詳細は次の mdn を参照すること。
https://developer.mozilla.org/ja/docs/Web/SVG/Reference/Element/circle

# 3. 高さと横幅の指定

高さの指定 `height="200"` と横幅の指定 `width="200"` を加えてみる。

```xml
<svg xmlns="http://www.w3.org/2000/svg"
  height="200" width="200">
  <circle cx="200" cy="200" r="200"/>
</svg>
```

すると、1/4 の円が描画される。

:::warn
ここで注意することは、2 つの属性 `height` `width` は、
図形の座標系（平面）のうち描画する対象の領域（この記事では描画平面と呼称）
の高さ（または横幅）を指定しているわけではないということ。
こちらを指定したい場合は、後述する `viewBox` 属性を用いる。
あくまでも この 2 つの属性は、
指定された図形平面のうちブラウザで表示される高さ（または横幅）を指定している。
:::

実際に DevTool でサイズを確認すると `circle` 要素はもとの描画範囲 `400*400` のままである。
あくまでも `svg` 要素がその描画範囲の一部 `200*200` を表示している。
また、私の環境では仕上がりの領域は `200*200` ではなく `199.99*199.99` と表示された。
これを踏まえて `height="200.01" width="200.01"`
と指定すると仕上がりの領域は `200*200` になった。

```xml
<svg xmlns="http://www.w3.org/2000/svg"
  height="200.01" width="200.01">
  <circle cx="200" cy="200" r="200"/>
</svg>
```

## 3.1. `height` について

> 矩形ビューポートで表示される高さです。（それ自身の座標系の高さではありません。） 値の型: <length>|<percentage>、デフォルト値: `auto`、アニメーション: 可
> https://developer.mozilla.org/ja/docs/Web/SVG/Reference/Element/svg#height

> `<svg>` の場合、 `height` は SVG ビューポートの描画領域の垂直方向の長さを定義します。
> https://developer.mozilla.org/ja/docs/Web/SVG/Reference/Attribute/height#svg

## 3.2. `width` について

> 矩形ビューポートで表示される幅。（それ自身の座標系の幅ではありません。） 値の型: <length>|<percentage>、デフォルト値: `auto`、アニメーション: 可
> https://developer.mozilla.org/ja/docs/Web/SVG/Reference/Element/svg#width

> `<svg>` の場合、 `height` は SVG ビューポートの描画領域の垂直方向の長さを定義します。
> https://developer.mozilla.org/ja/docs/Web/SVG/Reference/Attribute/width#svg

# 4. 描画平面の位置と大きさを指定する (`viewBox`)

mdn では `viewBox` は次のように説明されている。

> `viewBox` 属性は、 SVG ビューポートのユーザー空間の位置と大きさを定義します。
> https://developer.mozilla.org/ja/docs/Web/SVG/Reference/Attribute/viewBox

2 章の注意点として触れたが、
`viewBox` は図形の座標系（平面）のうち描画する対象の領域について指定できる。
この「図形の座標系（平面）のうち描画する対象の領域」を、この記事では描画平面と呼称する。
これは前述の mdn における「SVG ビューポートのユーザー空間」と同義である。

:::details 補足: 描画平面の命名について
mdn は「空間」と称しているが、SVG は2次元しか扱えないので、平面と呼称する方が正しい。
また `viewBox` という名称より描画平面と呼称した。
なお、OS の文脈のユーザー空間と、mdn の説明にあるユーザー空間は異なるものであるが、前者はアプリケーションが使用するメモリ領域のことであり、なんだか似ている意味である気もする。
:::
具体的に `viewBox` 属性の値は `最小のX座標 最小のY座標 横幅 高さ` が指定できる。
これらは4つ全てを指定する必要があり（省略不可）、区切り文字は ` ` または `,` である。
筆者は、前者の半角スペースによる指定をよく見かける印象がある。

実際に指定してみよう。

## 4.1. 描画平面の位置を指定する

`viewBox="10 10 200 200"` を追加する。

```xml
<svg xmlns="http://www.w3.org/2000/svg"
  height="200.01" width="200.01" viewBox="10 10 200 200">
  <circle cx="200" cy="200" r="200"/>
</svg>
```

`viewBox` の値（大きさ） `200 200` は後述するため、
ここでは扱いやすい `height` と `width` と同じ値を指定する。
（厳密には 0.01 差があるが、DevTool による仕上がり表示領域はいい感じになる。）

さて、本筋の `viewBox` の値（位置） `10 10` について説明する。
これは、描画平面で最小となる図形の座標系の X 座標と Y 座標について指定している。
言い換えると、表示対象である描画平面(`viewBox`)に含まれる、
最小の X 座標と最小の Y 座標を、それぞれ左端と上端に指定している。

そのため、 `viewBox="0 0 200 200"` よりも
平面全体が左に `10` と上に `10` 動いた `200*200` の領域が描画される。

## 4.2. 描画平面の大きさを指定する

`viewBox="0 0 400 400"` を追加す

```xml
<svg xmlns="http://www.w3.org/2000/svg"
  height="200.01" width="200.01" viewBox="0 0 400 400">
  <circle cx="200" cy="200" r="200"/>
</svg>
```

描画平面の位置は前節 3.1. と同様にわかりやすさのため `0 0` を指定した。

さて、`viewBox` の高さ（または横幅）に対する `svg` 要素の高さ（横幅）を考えてみると、
この値は図形の倍率になっていることに気づく。
例えば今回の `viewBox="0 0 400 400"` に対する `svg` 要素の高さは
$$ 200.01 / 400 \approx 1/2 $$
となる。また、図形の半径は `200` だから図形全体の高さは `400` で、
これに求めた倍率 `1/2` をかけると `200` となる。
これは、DevTool で確認した仕上がり表示高さの値 `200` と一致する。

言い換えると、高さについて次の式が成り立つということである。
$$ \text{仕上がり表示高さ} = \text{図形の座標系の高さ} \cdot \text{svg 要素の高さ height} / \text{描画平面の高さ viewBox} $$
横幅も同様。

:::message
`viewBox` は設計に使う座標系なので先に固定し、
サイズは後から `height` や `width` を調整する形が一般的です。
例えば `viewBox="0 0 24 24"` や `viewBox="0 0 20 20" を決めた後、
SVG を作成し、CSS 側で `height`や`width`を調整するなど。

特に、式を見れば分かる通り、`図形の座標系の高さ` と `描画平面の高さ viewBox` が等しい時、
`仕上がり表示高さ` は `svg 要素の高さ height` と同値になる。
:::

# 参考文献

## 1

> The viewport coordinate system is also called viewport space and the user coordinate system is also called user space.
> https://www.w3.org/TR/SVG11/coords.html#Introduction

日本語にすると次あたりの意味。

> ビューポート座標系はビューポート空間とも呼ばれ、ユーザー座標系はユーザー空間とも呼ばれます。
