<h1 align="center">
  OHOS-VAP
</h1>

<p align="center">
 <a href="./README.md">English</a> | <a href="./README_zh.md">简体中文</a> |  <a href="docs/README.ja.md">日本語</a> 
</p>

<p align="center">
  <a href="https://github.com"><img src="https://img.shields.io/badge/LICENSE-LGPLv2.1 or later-orange" alt="License"></a>
  <a><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg"/></a>
</p>

デジタルエンターテインメントとオンラインインタラクションの時代において、視覚効果の美しさはユーザー体験に直接影響を与えます。`OHOS-VAP` は `OpenHarmony` を基盤にし、`OpenGL` 技術と特別なアルゴリズムを用いて構築された強力なアニメーションパーティクルエフェクトレンダリングコンポーネントです。これは、アプリケーションに驚くべきアニメーション効果を提供するだけでなく、ユーザーに没入感のある視覚体験を創出します。

<div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">
<img loading="lazy" width="150px" src='./imgs/1.gif' />
<img loading="lazy" width="150px" src='./imgs/3.gif' />
<img loading="lazy" width="150px" src='./imgs/4.gif' />
<img loading="lazy" width="150px" src='./imgs/5.gif' />
</div>

### 主な特徴

- WebpやApngの動きの提案に比べ、高圧縮率（素材が小さい）、ハードウェアデコード（デコードが速い）という利点があります。
- Lottieに比べ、より複雑なアニメーション効果（例：パーティクルエフェクト）を実現できます。
- 高性能レンダリング：OpenGLの強力な機能により、OHOS-VAPは効率的なパーティクルエフェクトのレンダリングを実現し、スムーズなユーザー体験を保証し、さまざまなデバイスに適しています。
- 簡単な統合：OHOS-VAPはシンプルなデザインで、既存のプロジェクトと簡単に統合でき、開発者がクールなアニメーション効果を迅速に実現し、アプリの魅力を高めるのに役立ちます。
- マルチプラットフォームサポート：複数のデバイスに対応しており、スマートフォン、タブレット、コンピュータのいずれでも、OHOS-VAPは一貫した視覚効果を提供し、クロステンデンアプリケーション開発を支援します。

### アプリケーションシーン

- ライブ配信のエフェクト：TikTok、快手、得物、ペンギンeスポーツなどの短編動画プラットフォームで、OHOS-VAPを利用してライブ配信にクールなギフトエフェクトを追加し、視聴者のインタラクション体験を向上させ、ライブ配信の楽しさを増します。
- 電子商取引のプロモーション：ゲーム分野や電子商取引プラットフォームのイベントで、OHOS-VAPを使用して驚くべき製品展示効果を実現し、ユーザーの目を引き、販売転換を促進します。
- ゲーム体験の向上：ゲームシーンにパーティクルエフェクトを追加し、全体的なゲーム体験を向上させ、プレイヤーをより生き生きとした仮想世界に没入させます。
  ![apps](./imgs/icon.png)

### ビルド依存関係

- IDEバージョン：DevEco Studio 5.0.1.403
- SDKバージョン：ohos_sdk_public 5.0.0 (API Version 12 Release)
- ターミナルデバイスの指定パス`/storage/Users/currentUser/Documents`に`1.mp4`という名前の動画ファイルを保存します（**デモ動画はルートディレクトリの`video_demo`に保存されています**）。
- 開発者は`this.xComponentContext.play()`インターフェースを呼び出してカスタム動画パラメータパスを実現できます（ネットワークURLをサポート）。

#### C/C++層のディレクトリ構造

```
├─include				# マスク、ミックス、レンダラー、ツールクラスのヘッダーファイルを保存
│  ├─mask
│  ├─mix
│  ├─render
│  └─util
├─manager 				# xcomponentのライフサイクル管理
├─mask 					# マスクの実装
├─mix 					# ミックスの実装
├─napi					# Napi層の機能のラッピング
├─render				# レンダラーの実装
├─types   				# インターフェース宣言
│  └─libvap	# soファイルのインターフェース宣言
└─util					# ツールクラスの実装
```

### プロジェクトビルド生成 Har パッケージ

プロジェクトを開いたら、最初にコマンドを実行してHarパッケージを生成します。以下を参考にしてください。

#### IDEのターミナルで以下のコマンドを実行

```bash
hvigorw assembleHar --mode module -p module=vap_module@default -p product=default -p buildMode=release --no-daemon
```

`.\vap_module\build\default\outputs\default\vap_module.har`ディレクトリにHarパッケージが生成されます。

### プロジェクトの起動

テスト担当者は、IDEでデバイスを接続した後、ワンクリックでプロジェクトを迅速に起動できます。

公式の手順に従って署名情報を追加すれば、テストアプリを正しくターミナルデバイスにインストールできます。

### 参照手順

開発者は、生成したHarパッケージをのプロジェクトに取り込むことができます。

#### IDEのターミナルで以下のコマンドを実行

```bash
ohpm install .\vap_module\build\default\outputs\default\vap_module.har
```
以前に生成したHarパッケージをインストールします。

### 迅速な使用
- サンプルコード`.\サンプルコード.ets`を参考にできます。サンプルが初めて正常に動作するには、ネットワークを開く必要があります。

#### ヘッダーファイルのインポート

使用するファイルにヘッダーファイルをインポートします。

```typescript
import { VAPPlayer } from 'vap_module';
import { MixInputData } from 'vap_module';
```

#### VAPPlayerコンポーネントの定義

```typescript
private vapPlayer: VAPPlayer | undefined = undefined;
@State buttonEnabled: boolean = true; // この状態はボタンのクリック可能性を制御します
@State src: string = "/storage/Users/currentUser/Documents/1.mp4"; // このパスはネットワークパスでも可能です
```

#### ミックスインターフェース宣言

```typescript
class MixInputDataBean implements MixInputData {
  constructor(txt?: string, imgUri?: string) {
    this.txt = txt || '';
    this.imgUri = imgUri || '';
  }

  txt: string;
  imgUri: string;
}
```

#### ネットワークリソースダウンロードパスの設定
```typescript
// 具体的な使用法はサンプルコードを参考にしてください
// サンドボックスパスを取得
let context : Context = getContext(this) as Context
let dir = context.filesDir
```

#### インターフェース

```typescript
XComponent({
  id: 'xcomponentId', // ユニーク識別子
  type: 'surface',
  libraryname: 'vap'
})
  .onLoad((xComponentContext?: object | Record<string, () => void>) => {
    if (xComponentContext) {
      this.vapPlayer = new VAPPlayer
      this.vapPlayer.setContext(xComponentContext)
      this.vapPlayer.sandDir = dir // ストレージパスを設定
    }
  })
  .backgroundColor(Color.Transparent)
  .height('100%')
  .visibility(this.buttonEnabled ? Visibility.Hidden: Visibility.Visible)
  .width('80%')
```

#### インターフェースの呼び出し（例えばボタンのクリックイベント）

```typescript
this.vapPlayer?.play(this.src, opts, () => {
  this.buttonEnabled = true;
});
```

#### 使用

##### プレイインターフェースPlayの使用

```typescript
let opts: Array<MixInputDataBean> = new Array
let opt: MixInputDataBean = new MixInputDataBean
opt.txt = "星河Harmony NEXT"
opt.imgUri = "/storage/Users/currentUser/Documents/1.png" // ドキュメントディレクトリに1.pngリソースが必要です
opts.push(opt)
opts.push(opt)
opts.push(opt)
this.buttonEnabled = false;
this.vapPlayer?.play("/storage/Users/currentUser/Documents/1.mp4", opts, () => {
  this.buttonEnabled = true;
});
```

##### 一時停止の使用

```typescript
this.vapPlayer?.pause()
```

##### 停止の使用

```typescript
this.vapPlayer?.stop()
```

##### ジェスチャーのリスニング

- アニメーション再生中に再生領域をクリックすると、融合アニメーションリソースにクリックが当たった場合、コールバックがそのリソース（文字列）を返します。
```typescript
this.vapPlayer?.on('click', (state)=>{
  if(state) {
    console.log('js get onClick: ' + state)
  }
})
```

##### 再生ライフサイクルの変化をリスニング

```typescript
this.vapPlayer?.on('stateChange', (state, ret)=>{
  if(state) {
    console.log('js get on: ' + state)
    if(ret)
      console.log('js get on frame: ' + JSON.stringify(ret))
  }
})
```

- コールバックパラメータ `state` は現在の再生状態を反映します
```typescript
enum VapState {
  UNKNOWN,
  READY,
  START,
  RENDER,
  COMPLETE,
  DESTROY,
  FAILED
}
```
- パラメータ `ret` は、`state` が `RENDER` または `START` の場合に `AnimConfig` オブジェクトを返します
- パラメータ `ret` は、`state` が `FAILED` の場合に現在のエラーコードを反映します
- パラメータ `ret` は、の状態では `undefined` になります


#### **権限設定**

**権限の設定に注意してください**

アプリモジュールの`module.json5`に権限を追加する必要があります。例えば：`entry\src\main\module.json5`

```json
"requestPermissions": [
{
"name": 'ohos.permission.READ_MEDIA',
"reason": '$string:read_file',
"usedScene": {
"abilities": [
"EntryAbility"
],
"when": "always"
}
},
{
"name": 'ohos.permission.WRITE_MEDIA',
"reason": '$string:read_file',
"usedScene": {
"abilities": [
"EntryAbility"
],
"when": "always"
}
},
{
"name": "ohos.permission.INTERNET"
}
]
```

### コンパイルビルド

- プロジェクトが正常に作成された後、ビルドを行うには `Build -> Build Hap(s)/APP(s) -> build App(s)` オプションを実行します。
- `/entry/build/default/outputs` に `hap` パッケージが生成されます。
- 生成された `hap` パッケージに署名してインストールします。

### テストデモ

`Play` ボタンをクリックしてアニメーション効果をテストし、再度クリックすることでループ再生に入ります。