---
name: kling-prompt-generator
description: Kling AIのGUI操作用プロンプトを生成。画像（Image 3.0 Omni）と動画（Video 3.0 Omni / 2.6 Pro / O1）の両方に対応。モデルとメディア形式を確認後、最適なプロンプトと設定ガイドを提供。
user_invocable: true
triggers:
  - /kling
  - Kling プロンプト
  - Kling 画像生成
  - Kling 動画生成
  - Kling 3.0
  - Kling prompt
---

# Kling AI プロンプト生成スキル

Kling AI（可灵AI）のGUI操作に必要なプロンプト作成と素材準備を支援する。
画像生成（Image 3.0 Omni）と動画生成（Video 3.0 / 3.0 Omni / 2.6 Pro / O1）の両方に対応。

- API実行はしない（プロンプトとGUI設定ガイドのみ提供）
- ユーザーとの会話は**日本語**、生成プロンプトは**英語**で出力
- GUI: https://app.klingai.com/

---

## 【必須】Step 0: モデルとメディア形式の確認

**スキル発動時、必ず最初にAskUserQuestionツールで以下2点を確認すること。確認前にプロンプト生成を開始してはならない。**

### 質問1: メディア形式

```
何を生成しますか？

1. 画像（Image 3.0 Omni）
2. 動画（Video 3.0 / 3.0 Omni / 2.6 Pro / O1）
```

### 質問2: モデル選択（メディア形式に応じて選択肢を変える）

**画像の場合:**
```
モデルを選択してください。

1. Image 3.0 Omni（推奨） - 2K/4K高解像度、連続画像、vCoT推論
2. Image 3.0 - 標準的な画像生成
```

**動画の場合:**
```
モデルを選択してください。

1. Video 3.0 Omni（推奨） - マルチショット、ネイティブ音声、Elements 3.0、最大15秒
2. Video 3.0 - マルチショット、最大15秒、1080p
3. Video 2.6 Pro - 音声同期、モーションコントロール、最大10秒
4. Video O1 - 参照合成、スタイル転換、マルチモーダル
```

**モデル選択ガイド（提案時の判断基準）:**

| 用途 | 推奨モデル |
|------|-----------|
| 高解像度画像（2K/4K） | Image 3.0 Omni |
| 連続画像・ストーリーボード | Image 3.0 Omni |
| マルチショット動画（複数カット） | Video 3.0 Omni |
| ネイティブ音声・リップシンク | Video 3.0 Omni |
| キャラクター一貫性（Elements 3.0） | Video 3.0 Omni |
| シンプルな短尺動画 | Video 3.0 |
| モーションコントロール（動作再現） | Video 2.6 Pro |
| 既存動画のスタイル転換 | Video O1 |

---

## Image 3.0 Omni（画像生成）

### 概要

- ネイティブ2K/4K超高解像度出力（アップスケールなし）
- Visual Chain-of-Thought（vCoT）推論でシーン構成を事前分析
- シリーズモード: スタイル・キャラクター・環境を維持した連続画像生成
- テキスト描画: ロゴ、キャプション、タイポグラフィの正確な描画
- プロ品質のテクスチャ・ライティング物理演算

### プロンプト構造（6要素）

```
[シーン/環境] + [被写体] + [ポーズ/アクション] + [照明/光] + [スタイル/美学] + [技術仕様]
```

**推奨長さ:** 30〜100語

### プロンプト例

```
【プロンプト】
A young Japanese woman in a cream-colored linen dress stands in a sunlit
botanical garden. She holds a small bouquet of wildflowers, looking slightly
to the left with a gentle smile. Golden hour lighting creates warm highlights
on her hair. Soft bokeh background with green foliage. Editorial fashion
photography, Canon EOS R5, 85mm f/1.4, shallow depth of field, 4K resolution.

【要素チェック】
- シーン: 日当たりの良い植物園
- 被写体: リネンドレスの若い日本人女性
- アクション: 花束を持ち、左を向いて微笑む
- 照明: ゴールデンアワー、暖色ハイライト
- スタイル: エディトリアルファッション
- 技術仕様: Canon EOS R5, 85mm f/1.4, 4K
```

### シリーズモード（連続画像）

スタイル・キャラクター・環境を一貫させた複数画像を生成:

```
【シリーズプロンプト例】
Panel 1: A detective in a trench coat stands outside a rain-soaked building,
looking up at a lit window. Film noir, high contrast, 1940s aesthetic.

Panel 2: Same detective now inside a dimly lit office, examining a letter
under a desk lamp. Same film noir style, rain visible through window.

Panel 3: Close-up of the detective's face, eyes narrowing as he reads.
Dramatic chiaroscuro lighting, same trench coat, same 1940s aesthetic.
```

### GUI設定

```
1. 「画像生成」セクションを選択
2. モデル: Image 3.0 Omni
3. プロンプト入力
4. アスペクト比: 1:1 / 16:9 / 9:16 / 4:3 / 3:4
5. 解像度: 2K または 4K
6. （シリーズモードの場合）シリーズ設定をON
7. 生成をクリック
```

---

## Video 3.0 Omni（動画生成 - 最上位）

### 概要

- 最大15秒のネイティブ生成（3.0の50%増し vs 2.6の10秒）
- マルチショット: 最大6カットを1回の生成で作成
- ネイティブ音声同期: セリフ・環境音・効果音をワンパスで生成
- 5言語対応リップシンク: 中国語、英語、日本語、韓国語、スペイン語（方言対応）
- Elements 3.0: 参照動画/画像からキャラクター特徴・声を抽出し一貫性維持
- 3人同時会話のリップシンク対応
- テキスト描画安定（ロゴ、タイトルが動画中で崩れにくい）

### プロンプト構造（マスターフォーミュラ）

```
[シーン/環境] + [被写体と外見] + [アクションタイムライン] + [カメラワーク] + [音声/雰囲気] + [技術仕様]
```

**推奨長さ:** 50〜200語

**重要な違い（2.6以前 vs 3.0）:**
- 3.0は「映画の演出指示」として理解する（オブジェクトの羅列ではない）
- 時間的シーケンスを明示: 「First... then... finally...」
- カメラワークは映画用語で: Dolly Zoom, Truck Left, Low-Angle Tracking, FPV

### シングルショット プロンプト例

```
【プロンプト】
A cyberpunk alleyway at midnight, illuminated by flickering neon signs
reflecting off wet pavement. A woman in a leather jacket walks toward
the camera with determined steps. First, she glances over her shoulder,
then turns forward and pulls up her hood. Camera tracks backward at
street level, maintaining eye contact. Rain falls steadily, puddles
ripple underfoot. Ambient city hum with distant sirens.
Cinematic lighting, anamorphic lens flare, 16:9, photorealistic.

【要素チェック】
- シーン: サイバーパンクの路地、深夜、ネオン
- 被写体: レザージャケットの女性
- タイムライン: 振り返る → 前を向く → フード上げる
- カメラ: ストリートレベルで後退トラッキング
- 音声: 都市のハム音、遠くのサイレン、雨音
- 技術: アナモルフィックフレア、16:9、フォトリアル
```

### マルチショット プロンプト例

最大6ショットを1回の生成で。各ショットにフレーミング・被写体・動き・音声を明記:

```
【マルチショットプロンプト】

Shot 1 (0-5s): Wide establishing shot of a Mars colony greenhouse.
Red desert visible through glass dome. A botanist in a space suit
tends to green plants. Camera slowly dollies in. Ambient hum of
life support systems.

Shot 2 (5-10s): Macro close-up of a water droplet falling onto a leaf.
The botanist's helmet visor reflects in the droplet. Rack focus from
droplet to botanist's face behind visor. Sound of water dripping.

Shot 3 (10-15s): Over-the-shoulder shot as botanist looks out at the
Martian sunset through the dome. Orange light bathes the greenhouse.
She removes her helmet, takes a deep breath.
[Speaker: Woman, calm voice] "It's finally growing."
Camera slowly pulls back to reveal the full greenhouse.

【技術仕様】
- アスペクト比: 21:9（シネマティック）
- 解像度: 1080p
- 音声: ネイティブ生成ON
```

### 音声・セリフの書き方

```
# 話者タグ付きセリフ（マルチキャラクター対応）
[Speaker: Man, deep authoritative voice] "We need to leave now."
[Speaker: Woman, trembling whisper] "I can't."

# 感情・トーン指定
[Speaker: Old man, warm grandfatherly tone] "Let me tell you a story."

# 方言・アクセント指定
[Speaker: Man, British accent, controlled serious voice] "Proceed."

# 環境音指定
Ambient: rain on metal roof, distant thunder, clock ticking
```

### Elements 3.0（キャラクター一貫性）

参照素材からキャラクターの外見・声を抽出し、新しいシーンで再現:

```
【素材】
- 参照動画: キャラクターAの3-8秒クリップ（外見+声を抽出）
- 参照画像: キャラクターBの写真2-4枚

【プロンプト】
Character A walks into a coffee shop and orders.
[Speaker: Character A] "One espresso, please."
Character B, the barista, smiles and nods.
Warm interior lighting, morning atmosphere.
```

### ネガティブプロンプト

不要な要素を明示的に除外:

```
Negative: morphing, blurry text, disfigured hands, extra fingers,
cartoonish, low resolution, watermark
```

### GUI設定

```
1. 「動画生成」セクションを選択
2. モデル: Video 3.0 Omni
3. タブ: テキストから動画 / 画像から動画
4. プロンプト入力
5. 設定:
   - アスペクト比: 16:9 / 9:16 / 1:1 / 21:9
   - 長さ: 3〜15秒（柔軟に指定）
   - 音声生成: ON/OFF
6. （Elements使用時）参照動画/画像をアップロード
7. （マルチショット時）ストーリーボード設定で各ショットの尺・構図を指定
8. 生成をクリック
```

---

## Video 3.0（標準動画生成）

### 概要

- 最大15秒（カスタムタイミング制御）
- マルチショット: 最大6カット
- 1080p出力
- Elements非対応（キャラクター参照不要なシンプルな用途向け）
- テキスト描画対応

### プロンプト構造

Video 3.0 Omniと同じマスターフォーミュラを使用。
Elements 3.0とネイティブ音声は使えないため、ビジュアルとカメラワークに集中。

### GUI設定

```
1. 「動画生成」セクションを選択
2. モデル: Video 3.0
3. タブ: テキストから動画 / 画像から動画
4. プロンプト入力
5. 設定:
   - アスペクト比: 16:9 / 9:16 / 1:1
   - 長さ: 3〜15秒
6. 生成をクリック
```

---

## Video 2.6 Pro（レガシー - 音声同期・モーションコントロール）

### 概要

- 最大10秒
- 音声同期: セリフに合わせたリップシンク（中国語・英語が最適）
- モーションコントロール: キャラ画像 + 動作参照動画で制御
- 1080p出力
- @音色 機能で声質指定

### プロンプト構造（4要素）

```
[シーン設定] + [被写体] + [モーション] + [スタイル]
```

**推奨長さ:** 50〜150語

### ワークフロー

**1. テキストから動画へ:**
- プロンプトのみで生成
- 音声同期ON/OFF選択可

**2. 画像から動画へ:**
- 静止画をアップロードして動画化
- エンドフレーム画像（オプション）

**3. モーションコントロール（2.6 Pro専用）:**
- キャラクター参照画像（JPEG/PNG）
- 動作参照動画（MP4/MOV、3〜30秒）

### @音色（音声指定）

```
「セリフ内容」 @音色 キャラクター・声質の説明

例:
"If you drink hot water every morning..." @calm male voice
```

### プロンプト例

```
【プロンプト】
A young Buddhist monk in orange robes sits peacefully in an ancient
Zen temple. Soft morning light filters through paper screens.
The monk speaks gently: "If you drink hot water every morning on
an empty stomach, listen carefully because this simple habit can
truly change your life." @calm male voice. Camera slowly zooms in
on his serene face. Wooden floor and Buddha statue in background.
Sacred, tranquil atmosphere. Cinematic lighting, shallow depth of field.

【GUI設定】
- モデル: Video 2.6 Pro
- タブ: 画像から動画へ
- 音声と映像の同期: ON
- アスペクト比: 9:16
- 長さ: 10秒
```

---

## Video O1（レガシー - 参照合成・スタイル転換）

### 概要

- マルチモーダル統合動画基盤モデル
- 複数参照画像対応（最大4枚）
- 既存動画のスタイル転換・リマスター
- ビジュアルアイデンティティ維持
- 最大10秒

### ワークフロー

**動画から動画へ（Video-to-Video Reference）:**
- 参照動画（MP4/MOV、3〜10秒）
- 参照画像（最大4枚）でスタイル・キャラクター指定

### プロンプト例

```
【参照画像】
- 参照画像1: アニメ風キャラクターデザイン
- 参照画像2: 禅寺の背景イラスト

【プロンプト】
Transform to the anime style of reference image 1. Vivid colors,
cel-shaded shadows. Place in the Zen temple background of reference
image 2. Hand-drawn texture, warm color palette.

【GUI設定】
- モデル: Video O1
- 元音声保持: ON
- アスペクト比: 16:9
- 長さ: 5秒
```

---

## プロンプトガイドライン（全モデル共通）

### ベストプラクティス

**具体性が重要:**
- NG: 「日没時に街を走る車」
- OK: 「ツヤのある銀色のスポーツカーが雨で濡れた東京の街を加速、金色の夕焼け光が嵐雲を突き抜け、ストリートレベルで追跡するカメラ、映画的照明」

**時間的シーケンス（3.0で特に重要）:**
- 「First [A], then [B], finally [C]」の形式で動きの順序を明示
- 3.0は時系列を理解するため、順序が結果に大きく影響

**カメラワーク（映画用語を使う）:**
- Dolly Zoom: 劇的なめまい効果
- Truck Left/Right: 被写体に並行して横移動
- Low-Angle Tracking: ヒーロー的・威圧的な視点
- FPV (First Person View): 没入型の高エネルギーモーション
- Rack Focus: 前景↔背景のフォーカス切り替え

**重み付け:**
- `++重要な要素++` で強調
- ネガティブプロンプトで不要要素を除外

**矛盾を避ける:**
- 「ゴールデンアワー」と「スタジオライティング」を同時指定しない
- カメラワークはシンプルに（複数の同時変換は歪みの原因）

### モデル別プロンプトのコツ

| モデル | ポイント |
|--------|---------|
| Image 3.0 Omni | カメラ仕様（レンズ焦点距離、F値）を技術仕様に含めると品質向上 |
| Video 3.0 Omni | 映画監督のように演出指示を書く。話者タグ必須。タイムライン明示 |
| Video 3.0 | ビジュアルとカメラに集中。音声指定は不可 |
| Video 2.6 Pro | @音色で声質指定。カメラ設定用語を活用 |
| Video O1 | 参照画像の要素マッピングを明確に。同じ用語で一貫性維持 |

---

## スキル実行フロー

### Step 0: モデルとメディア形式の確認（必須）

AskUserQuestionで上記「Step 0」を実施。**ここをスキップしてはならない。**

### Step 1: ゴール・用途のヒアリング

```
- 何を作りたいか（商品紹介、SNS投稿、教育コンテンツ、アート等）
- 用途とプラットフォーム（TikTok、Instagram、YouTube、Web等）
- 参照イメージがあるか
```

### Step 2: 素材確認チェックリスト

選択されたモデル・ワークフローに応じて必要素材を提示:

```
【Image 3.0 Omni】
□ プロンプトのみ（素材不要）
□ （シリーズモード）各パネルの内容イメージ

【Video 3.0 Omni - Text-to-Video】
□ プロンプトのみ（素材不要）
□ （Elements使用時）参照動画 3-8秒 / 参照画像 2-4枚

【Video 3.0 Omni - Image-to-Video】
□ 入力画像（JPEG/PNG、1080p以上推奨）

【Video 2.6 Pro - モーションコントロール】
□ キャラクター参照画像
□ 動作参照動画（3〜30秒）

【Video O1 - Video-to-Video】
□ 参照動画（3〜10秒）
□ 参照画像（最大4枚）
```

### Step 3: プロンプト生成

ユーザーのヒアリング結果を基に、選択モデルに最適化されたプロンプトを生成。

**出力フォーマット:**
```
【プロンプト】
（英語プロンプト本文）

【ネガティブプロンプト】（必要に応じて）
（除外要素）

【語数】XX語 ✓/✗
【要素チェック】
✓/✗ シーン設定
✓/✗ 被写体
✓/✗ アクション/モーション
✓/✗ カメラワーク
✓/✗ 音声/雰囲気（動画のみ）
✓/✗ 技術仕様
```

### Step 4: GUI設定ガイド

```
【Kling AI GUI設定】
1. セクション: 画像生成 / 動画生成
2. モデル: （選択されたモデル）
3. タブ: （ワークフロー）
4. プロンプト入力: 上記をコピー&ペースト
5. 設定:
   - アスペクト比:
   - 解像度/長さ:
   - 音声: ON/OFF
   - その他:
6. 生成をクリック
```

### Step 5: 生成前チェックリスト

```
□ プロンプト語数が推奨範囲内
□ 矛盾する指定がない
□ カメラワークがシンプル
□ （動画）話者タグが正しく付与されている
□ （画像）解像度設定が用途に合っている
□ アスペクト比がプラットフォームに合っている
```

---

## 制約事項

### 素材要件

| 種類 | 形式 | 解像度 | サイズ |
|------|------|--------|--------|
| 入力画像 | JPEG, PNG, WebP | 1080p以上推奨 | 10MB以下 |
| 参照動画（Elements） | MP4, MOV | 1080p推奨 | 3-8秒 |
| 動作参照動画（2.6） | MP4, MOV | 短辺300px以上 | 3-30秒 |
| 参照動画（O1） | MP4, MOV, WebM | 1080p推奨 | 3-10秒 |

### 言語対応（リップシンク）

| 言語 | Video 3.0 Omni | Video 2.6 Pro |
|------|---------------|---------------|
| 英語 | 最適 | 最適 |
| 中国語 | 最適 | 最適 |
| 日本語 | 対応 | 品質要検証 |
| 韓国語 | 対応 | 非対応 |
| スペイン語 | 対応 | 非対応 |

---

## トラブルシューティング

| 症状 | 対処法 |
|------|--------|
| 動画が意図と異なる | プロンプトの具体性を上げる。タイムライン「First...then...finally」を明示 |
| 品質が低い・ぼやける | 入力画像の解像度向上。技術仕様（レンズ、解像度）を追加 |
| 音声同期がずれる | 話者タグ `[Speaker: ...]` を明記。セリフは短めに |
| マルチショットが不自然 | 各ショットにフレーミング・被写体・カメラを個別指定 |
| キャラが変わる | Elements 3.0で参照素材をアップロード。外見記述を全ショットで統一 |
| 生成失敗 | ファイルサイズ確認（10MB以下）。プロンプト2500文字以内。リトライ |

---

## 参考リンク

### 公式
- [Kling AI GUI](https://app.klingai.com/)
- [Image 3.0 User Guide](https://app.klingai.com/global/quickstart/klingai-image-3-model-user-guide)
- [Video 3.0 Omni User Guide](https://app.klingai.com/global/quickstart/klingai-video-3-omni-model-user-guide)
- [Video 2.6 User Guide](https://app.klingai.com/global/quickstart/klingai-video-26-audio-user-guide)
- [Video O1 User Guide](https://app.klingai.com/global/quickstart/klingai-video-o1-user-guide)
- [Kling AI API](https://app.klingai.com/global/dev/document-api/quickStart/productIntroduction/overview)

### プロンプトガイド
- [fal.ai - Kling 3.0 Prompting Guide](https://blog.fal.ai/kling-3-0-prompting-guide/)
- [Kling 3.0 Prompt Guide](https://klingaio.com/blogs/kling-3-prompt-guide)
- [fal.ai - Kling 2.6 Pro Prompt Guide](https://fal.ai/learn/devs/kling-2-6-pro-prompt-guide)
- [fal.ai - Kling O1 Prompt Guide](https://fal.ai/learn/devs/kling-o1-prompt-guide)

### リリース情報
- [Kling 3.0 公式リリース（PR Newswire）](https://www.prnewswire.com/news-releases/kling-ai-launches-3-0-model-ushering-in-an-era-where-everyone-can-be-a-director-302679944.html)
- [Kling 3.0 Feature Guide](https://gaga.art/blog/kling-3-0/)
