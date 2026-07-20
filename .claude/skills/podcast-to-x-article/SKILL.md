---
name: podcast-to-x-article
description: AI Nakedのエピソード内容からX長文記事を作成する。2週に1回の運用。Use when "podcast記事", "AI Naked記事", "エピソードからX記事", "podcast to article".
---

# Podcast → X Article ワークフロー

AI Naked Podcastのエピソード原稿・リサーチからX長文記事（Articles）の下書きをObsidianに作成する。X ArticlesはAPI非対応のため、x.comで手動公開する。

## 前提

- Podcast: AI Naked（toyama & consome）
- ソースディレクトリ: `/Users/takuya.toyama/Projects/ai-naked/episodes/`
- 投稿アカウント: @0xtouyan
- 頻度: 2週に1回（エピソード公開に合わせて）
- 言語: 日本語
- 公開方法: x.com デスクトップ → Articles → Write（API非対応）

## ワークフロー

### Step 0: エピソード特定

ユーザーがエピソード番号を明示していない場合、先にエピソード一覧を取得してユーザーに選んでもらう。

1. `ls /Users/takuya.toyama/Projects/ai-naked/episodes/` でエピソード一覧を取得
2. AskUserQuestion で対象エピソードを確認:
   - 選択肢: 各エピソードのディレクトリ名（例: `#1_Every`, `#2_Higgsfield`, `#3_NikitaBier`）
   - 「最新のエピソード」が指定された場合は番号が最大のものを使う

### Step 1: エピソード内容の読み取り

対象エピソードのディレクトリからすべての関連ファイルを読む:

```
/Users/takuya.toyama/Projects/ai-naked/episodes/#N_Topic/
├── *.md          # メイン構成案・ノート
└── references/   # リサーチ資料
```

読み取るべきもの:
- メインの構成案（話した内容・論点）
- description.md があれば配信用説明文
- references/ 内のリサーチ資料（深い考察の材料）

### Step 2: 記事の構成を決める

エピソードの内容から、X Article として最も価値のある切り口を1つ選ぶ。

**選定基準:**
- Podcastで話した中で最も独自の視点・分析があった部分
- 「使ったことだけ語る」というAI Nakedのポリシーに沿った実体験ベースの洞察
- 読者が「これは保存しておきたい」と思う深掘り

**記事タイプ:**
| タイプ | 向いているケース |
|--------|-----------------|
| 企業/プロダクト分析 | EP1: Every, EP2: Higgsfield のような深掘り回 |
| グロース原則・フレームワーク | EP3: Nikita Bier のような戦術回 |
| 対談から得た独自の気づき | 2人の議論から生まれた新しい視点 |

### Step 3: X Article 下書き作成

以下のフォーマットでObsidianに保存する。

**保存先:** `Zettelkasten/PermanentNote/X/articles/YYYYMMDDHHMM_ainaked_ep{N}_{summary}.md`

```markdown
---
title: {記事タイトル}
created: YYYY-MM-DD
status: draft
type: article
source: ai-naked-ep{N}
topic: {メイントピック}
word_count: {概算}
estimated_read_time: {X}分
tags:
  - x-article
  - ai-naked
  - {トピック関連タグ}
---

# {記事タイトル}

{本文}

---

この記事はPodcast「AI Naked」EP{N}の内容をベースにしています。

Spotify: {SPOTIFY_URL}
Apple Podcasts: {APPLE_PODCASTS_URL}

#AINaked
```

**記事の書き方ガイド:**

1. **タイトル**: 8-15語。具体的な価値 or 意外性を含める
   - 良い例: 「同じアプリを2回売った男のグロース戦術 — AI時代に何が通用するか」
   - 悪い例: 「AI Naked EP3まとめ」

2. **冒頭2-3文**: X Articlesのプレビューに表示される。最も引きのある事実 or 問いを置く

3. **構成**: Podcastの時系列ではなく、読者にとって価値の高い順に再構成する
   - Podcast「まとめ」にしない。Podcastで話した素材を使って、独立した記事として成立させる
   - 「Podcastで〜と話しました」は最小限に。記事単体で読んで面白いこと

4. **段落**: 2-4行で改行。短く歯切れよく

5. **見出し**: 3-5段落ごとに小見出し

6. **引用・データ**: Podcastのリサーチ資料から具体的な数字や事例を入れる

7. **末尾**: Podcast へのリンク（Spotify + Apple Podcasts）と #AINaked ハッシュタグ

### Step 4: ユーザーへの最終確認

以下を提示して確認を求める:

1. **X Article 下書きファイルパス** → Obsidian で確認・編集してもらう
2. **公開手順のリマインド**:
   - x.com デスクトップ → Articles → Write
   - Obsidianから本文をコピー → X のリッチテキストエディタで整形
   - 公開

## Podcast リンクのテンプレート

ユーザーがURLを提供するまでプレースホルダーを使う:

```
Spotify: [エピソードURL]
Apple Podcasts: [エピソードURL]
```

URLが判明したら記事内を置換する。

## 注意事項

- 記事は「Podcastの書き起こし」や「まとめ」にしない。独立した読み物として成立させる
- AI Nakedの「使ったことだけ語る」ポリシーを記事でも維持する
- 番組のコンテキストを知らない読者にもわかるように書く
- consomeの発言を引用する場合は「AI Naked共同MCのconsome」と紹介する
