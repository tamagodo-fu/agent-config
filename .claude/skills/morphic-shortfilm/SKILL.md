---
name: morphic-shortfilm
description: Morphic Studioを使ったAIアニメショートフィルム制作支援。キャラモデル作成、スタイルトレーニング、画像→動画ワークフロー、Compose編集をステップバイステップでガイド。
user_invocable: true
triggers:
  - /morphic
  - Morphic プロンプト
  - Morphic アニメ
  - Morphic 動画
  - morphic studio
  - morphic character
---

# Morphic Studio AIアニメ制作スキル

Morphic Studio（https://morphic.com/）を使ったアニメショートフィルム制作を支援。
会話は**日本語**、プロンプトは**英語**で出力。プロンプトは**mdファイルに書き出す**（ターミナル内出力禁止）。

---

## Morphic Studio 概要

### 3つの画面

| タブ | 用途 |
|------|------|
| **Canvas** | 画像/動画の生成・編集ワークスペース。全アセットを視覚的に配置 |
| **Copilot** | AIアシスタント。ストーリー構想、ストーリーボード生成、質問応答 |
| **Compose** | 内蔵動画エディタ。生成したクリップを並べてストーリーを組み立て |

### モデル選択

**画像生成:**
- デフォルト: フォトリアリズム
- スタイル指定: Anime, 3D Kids, ピクセルなど組み込みスタイル
- カスタムスタイル: 10-15枚のリファレンスでトレーニング可

**動画生成:**
- Default Model
- Sora 2（音声生成対応）
- V3 / V3.1（音声生成対応）

---

## ワークフロー: アニメショートフィルム制作

### Phase 0: スタイルとキャラの準備

#### スタイルモデルのトレーニング

1. Dashboard → 左メニュー「Models」→ 「+ New Model」
2. 「Style」を選択
3. 目標のアニメスタイルを示す**10-15枚のリファレンス画像**をアップロード
   - ジブリ風なら: ジブリ映画のスクリーンショット、似た画風のイラスト等
   - 色調、線画の太さ、背景の描き込み度が一貫するものを選ぶ
4. 名前をつけて（例: "Ghibli Garden"）→ Create
5. 5-10分でトレーニング完了 → 通知

#### キャラクターモデルの作成

**方法A: 1枚からモデル生成（One-Shot）**
1. Canvasで**キャラ画像を1枚生成**（プロンプト + スタイル指定）
2. 画像を右クリック → 「Create model」→ 「Character model」
3. Morphicが自動でバリエーション（角度、表情）を生成
4. 良いバリエーションを選択 → 名前をつけて「Create model」
5. **追加画像を任意でアップロード可**（品質向上）

**方法B: 複数画像からトレーニング**
1. Dashboard → Models → 「+ New Model」→ 「Character」
2. **5-25枚のキャラ画像**をアップロード（異なるポーズ・角度・表情）
3. 名前をつけて → Create
4. 5-10分でトレーニング完了

**推奨:** アニメキャラは**方法A（One-Shot）が楽**。1枚のベスト画像から自動バリエーション生成。

#### マルチキャラクターの使用

- プロンプトで `@キャラ名` でタグ付け
- 画像リファレンス機能（📎アイコン）で複数キャラを1フレームに配置
- 最大3キャラまで同時使用可

---

### Phase 1: Hero Frame（静止画）生成

1. Canvas → プロンプトバーで「Image」選択
2. **Style**ドロップダウンでトレーニング済みスタイルを選択（またはAnime）
3. **Character**ドロップダウンでキャラモデルを選択
4. **アスペクト比**を設定（16:9推奨）
5. プロンプトを入力 → Generate（3枚生成される → ベストを選択）

**プロンプト構造:**
```
[シーン/環境] + [キャラ @Name が何をしているか] + [カメラアングル] + [照明/雰囲気]
```

**フレーム編集:**
- 画像選択 → プロンプトバーで**カメラアングル変更**（"extreme close-up shot", "wide angle shot"）
- 画像選択 → プロンプトで**要素変更**（"make it night", "add sunglasses"）
- Object Selection → 要素を**レイヤー分離**（背景からキャラ抽出等）
- Region Selection → **特定位置に要素追加**（レイヤーとして）

---

### Phase 2: 動画生成

**画像 → 動画:**
1. Canvas上のHero Frameを選択
2. プロンプトバーで「Video」に切替
3. モデル選択（V3.1推奨 = 音声対応）
4. プロンプトで**モーション指示**（"character walks slowly", "camera pans left"）
5. Generate

**テキスト → 動画:**
- キャラモデル + スタイル選択 → プロンプトのみで動画生成

**キーフレーム動画（最大5フレーム）:**
1. 開始フレームと終了フレーム（最大5枚）をドラッグ選択
2. 「Create video」を選択
3. 各フレーム間のアクションをプロンプトで指示
4. 各フレーム間のデュレーション指定可
5. Generate

**カットショット（1プロンプトで複数カット）:**
```
例: "the boy walks on the log. Cut shot to his face showing worry. Cut shot to him jumping off."
```

**リップシンク:**
```
例: The character says "こんにちは、私の名前は悟です"
```
→ V3 or V3.1（Audio ON）を選択

**動画継続:**
- 動画の最終フレームをCanvasに抽出 → そこからVideo生成で継続
- 滑らかな連続性を確保

**Video-to-Video編集:**
- 生成済み動画を選択 → プロンプトで変更（"make it night and rainy"）

**3Dモーション:**
- 画像選択 → 「3D Motion」
- カメラ位置をドラッグで指定（ズーム、パン、回転）
- プレビュー確認 → Generate

---

### Phase 3: Composeで編集

1. Composeタブで生成クリップを並べる
2. 順序・タイミング調整
3. プレビュー確認

---

### Phase 4: エクスポート

1. 4Kにアップスケール可（右メニュー）
2. 動画エクスポート（下部バー）
3. フレームとしてエクスポートも可

---

## アニメスタイルのコツ

### ジブリ風プロンプトの要素

| 要素 | プロンプト例 |
|------|------------|
| 色調 | warm watercolor palette, soft pastel greens and blues |
| 照明 | soft diffused sunlight, golden hour glow, volumetric light through trees |
| 背景 | lush detailed landscape, hand-painted clouds, rolling hills |
| キャラ | expressive large eyes, simple nose, detailed hair movement |
| 質感 | cel-shaded, visible brushstrokes, watercolor texture |
| 雰囲気 | nostalgic, dreamy, peaceful with underlying melancholy |

### スタイル一貫性の維持

- **必ずスタイルモデルをロック**してからScene生成を開始
- 同じシーン内では**同じ照明キーワード**を使用
- キャラモデルは**1枚のベスト画像でOne-Shot**が最も安定
- 複数キャラの場合は画像リファレンス（📎）を活用

---

## 出力フォーマット

プロンプトはmdファイルに書き出す。ターミナル内に長文出力しない。

---

## 関連スキル

- `/shortfilm-pre` — ストーリー企画、シーン構成
- `/shortfilm-prod` — Hero Frame・動画生成ワークフロー（Higgsfield版。Morphicでも考え方は共通）
- `/higgsfield` — Higgsfield固有のプロンプト生成
