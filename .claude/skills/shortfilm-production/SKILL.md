---
name: shortfilm-production
description: AIショートフィルムのプロダクション支援。Hero Frame生成→動画生成→音声のフローと、ショートフィルム特有の手法（4要素品質チェック、シーン間連続性、Soul ID運用）をガイド。実際の画像/動画生成は higgsfield-generate / higgsfield-soul-id skill に委譲。Voice CloneのみGUI。
user_invocable: true
triggers:
  - /shortfilm-prod
  - 短編映画 撮影
  - shortfilm production
  - ヒーローフレーム生成
  - Cinema Studio 撮影
  - shortfilm generate
---

# Short Film プロダクション

ショートフィルムを **Hero Frame（静止画）→ 動画 → 音声** の順で組み立てるフェーズ。
**プリプロの brief.md が完成していること前提**（未作成なら `/shortfilm-pre`）。

会話は**日本語**、生成プロンプトは**英語**。

## 役割分担

| やること | 委譲先 |
|---------|-------|
| 画像/動画の実生成 | **higgsfield-generate** skill（モデル選定・CLI実行・ジョブ管理） |
| Soul Character訓練 | **higgsfield-soul-id** skill |
| Voice Clone | Higgsfield Audio GUI（CLI/skill未提供） |
| **このskillの責務** | ショートフィルム特有のワークフロー設計・品質判断・連続性確保 |

各 Phase で生成が必要になったら、higgsfield-generate / higgsfield-soul-id を呼ぶ。

---

## 【必須】Step 0: プロジェクト確認

1. `projects/shortfilm/[film-name]/brief.md` を読み込む
2. `asset-checklist.md` を起こしてアセット管理開始
3. キャラの Soul ID 状況を確認:
   - 訓練済み → reference_id を控えておく
   - 未訓練 → **higgsfield-soul-id** skill に依頼して訓練（5枚以上の正面画像必要、1度のみ）

ユーザーに確認:
```
1. どのシーンから？（Scene 1/2/3）
2. Soul ID訓練済み？（あれば reference_id を渡してください）
3. キャラクターシート/プロップシートは生成済み？
```

---

## Phase 1: Hero Frame 生成（静止画）

**動画品質の99%は静止画で決まる。Hero Frameを完璧にしてから動画化。**

### モデル選定ガイド（higgsfield-generate に渡す指示）

| 用途 | 推奨モデル | 備考 |
|---|---|---|
| キャラ一貫（Soul ID あり） | `text2image_soul_v2` | `reference_id` で一貫性ロック |
| キャラ一貫（Soul ID なし） | `soul_cast` | テキストのみで一貫性 |
| シネマグレード静止画 | `soul_cinematic` | コンセプトアート級 |
| 高精度リファインメント | `nano_banana_2` | 4K、変更指示への忠実性 |
| ロケーション/環境 | `soul_location` | 風景・背景特化 |

### ワークフロー: Soul Cinema ↔ Nano Banana 反復

```
[A] soul_cinematic で初期生成 → higgsfield-generate に依頼
    ↓
[B] 4要素品質チェック（ライティング/構図/深度/色）  ← このskillの判断
    ↓ 不合格
[C] nano_banana_2 でリファインメント（A の job_id を渡してパッチ生成）
    ↓
[D] 必要なら text2image_soul_v2 でキャラ整合（reference_id 適用）
    ↓
[B] 合格まで繰り返し
```

### 品質チェック（4要素）

| 要素 | チェック | NG時の追加プロンプト |
|---|---|---|
| ライティング | 方向性・影・コントラスト | "cinematic motivated lighting, hard key from left, deep shadows" |
| 構図 | 三分割法、視線誘導 | "subject on left third, leading lines toward face" |
| 深度 | 前景/背景ボケ | "shallow depth of field, background falls out of focus" |
| 色 | 感情に合った色調 | "teal-orange grade" / "muted earth tones" 等具体に |

### リファインメントのコツ

A の結果を **job_id のまま渡す**（ダウンロード不要）。変更点以外は "preserving" で固定明示:

> "Change the man's outfit to a tan canvas jacket layered over a dark sweater **while preserving his exact identity, facial features, hairstyle, pose, camera angle, composition.**"

### 全ショット繰り返し

ショットリストの各カットでPhase 1を実施。完了分は `asset-checklist.md` にマーク（job_id記録）。

---

## Phase 2: 動画生成

Hero Frame が揃ったら動画化。

### モデル選定ガイド

| 目的 | 推奨モデル | 備考 |
|---|---|---|
| 最上位シネマ | `cinematic_studio_3_0` | SOTA、4–15s |
| ジャンル制御シネマ | `cinematic_studio_video_v2` | genre: action/horror/comedy/western/suspense/intimate/spectacle、3–12s |
| マルチショット+音声 | `kling3_0` | 3–15s、`mode: pro`、音声同期 |
| ID一貫・参照駆動 | `seedance_2_0` | image/video/audio参照可、4–15s |
| 超リアル | `veo3_1` | quality: basic/high/ultra、4/6/8s |
| 製品広告 | `marketing_studio_video` | URL駆動、UGC等モード豊富 |

### 基本パターン: Hero Frame → 動画

higgsfield-generate に以下を依頼:
- model: `cinematic_studio_3_0`（用途で切替）
- start_image: Hero Frame の job_id
- prompt: 動き・カメラワーク・対話に集中（画像で固まってるので外見は既知）
- duration / aspect_ratio はショットリスト準拠

### プロンプト構造（動画）

```
[Camera] + [Subject] + [Action] + [Environment] + [Lighting] + [Audio/Dialogue]
```

**コツ:**
- 画像で固まっているので、プロンプトは**動き**にフォーカス
- 対話はプロンプトに直書き: `Dave says teasingly, "Happy birthday."`
- 感情副詞: dryly / teasingly / calmly / coldly
- 環境音も指定: "Natural police radio ambience. Slight engine vibration."

### マルチショット（kling3_0）

`kling3_0` は単一APIコールで1ショットのみ。シーン全体は **複数ショット** + 後段編集で組む:
- 同じ Hero Frame 派生の `start_image` を使う
- 直前ショット末尾フレームを次ショットの `start_image` にする → 連続性

### スクリーンショット連鎖（連続性Tip）

ショットNの結果動画から良いフレームをキャプチャ → ショットN+1 の `start_image` にローカルパスで渡す（higgsfield-generate が自動アップロード）。これで生成同士が地続きになる。

### シーン間ビジュアル変化

各シーンで意図的に色調・カメラ・露出を変える:
- Scene 1: シネマ・暖色・浅い被写界深度
- Scene 2: ダッシュカム風・過露出・ドキュメンタリー
- Scene 3: 暖色・感動的・ソフト

### 失敗時

- 結果が悪い → **同じパラメタで再生成**（ランダム性あり）
- それでも × → プロンプト微調整、またはモデル切替（`cinematic_studio_3_0` ↔ `seedance_2_0` ↔ `veo3_1`）
- 完了分は `asset-checklist.md` に job_id で記録

---

## Phase 3: B-Roll 生成

`soul_cinematic` または `soul_location` でシンプルプロンプトから（higgsfield-generate に依頼）:

例:
- "Extreme close-up of a police radio mic clipped to a uniform, badge slightly out of focus, dark cinematic"
- "A patrol car drives through a quiet suburban neighborhood, dry grass, palm trees"

そのまま `cinematic_studio_video_v2` で動画化（B-Rollはプロンプト軽めでOK）。

ユーザーが平文で書いたB-Roll説明をシネマプロンプトに変換するのを支援する。

---

## Phase 4: Voice & Audio（GUI）

**CLI/skill に音声/Voice Cloneツールは未提供。** ここだけGUIで進める。

### Higgsfield Audio で声クローン

1. https://higgsfield.ai/ → Audio
2. 自分の声 or 既存音声をアップロード
3. **Change Voice:** 対話トラック全体を処理
   - 感情・ペーシング・デリバリーは維持、声だけ変換
4. キャラごとにトラック分離

### プリセットボイス

自分の声を使わないキャラはプリセット選択。

### トラック構成

| トラック | 内容 |
|---|---|
| キャラ1 | Voice Clone済み |
| キャラ2 | プリセット |
| BGM | 別途用意 |
| SFX | 環境音・効果音 |

### 代替: 音声同期動画モデル

セリフ短く、リップシンクが主目的なら、動画生成時に音声を直接渡せる:
- `seedance_2_0`（audio リファレンス）
- `wan2_7`（audio リファレンス）
- `kling3_0`（音声同期内蔵）

higgsfield-generate に「audio参照付きで動画生成」と依頼すればOK。

---

## Phase 5: アセット最終確認

`asset-checklist.md`:
- [ ] 全キャラの Soul Character（or soul_cast 標準フレーム）確定
- [ ] 全シーンの Hero Frame 承認（job_id記録）
- [ ] 全ショットの動画クリップ生成済み（job_id記録）
- [ ] B-Roll 生成済み
- [ ] 音声トラック完成
- [ ] ローカルにダウンロード

完了 → `/shortfilm-post` でポストプロダクション。

---

## トラブルシュート

| 問題 | 対処 |
|---|---|
| キャラ顔が一致しない | `text2image_soul_v2` + reference_id、または直前 job_id を image参照に追加 |
| 動画ぼやける | Hero Frame解像度上げ（`nano_banana_2` 4K で再生成） |
| カメラ動きが意図と違う | プロンプトのカメラ用語を簡素化、別モデル試す |
| 対話タイミングずれ | シーン分割、タイムライン副詞追加（"in the first 2 seconds..."） |
| シーン間色調不一致 | 全プロンプトに共通カラーグレード句を入れる |
| 生成エラー | higgsfield-generate skill が CLI 詳細を扱う、メッセージそのまま渡す |

---

## 関連スキル

- **higgsfield-generate** — 画像/動画の実生成（モデル選定・CLI実行）
- **higgsfield-soul-id** — Soul Character訓練
- **higgsfield-product-photoshoot** — ブランド商品画像（このskillでは通常使わない）
- `/shortfilm-pre` — プリプロ（企画・キャラ設計）
- `/shortfilm-post` — ポスト（編集・カラグレ・出力）
