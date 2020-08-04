# slack-afk

Slackで不在時に代理応答します。

## 概要
Slack App経由でRedisに情報を登録して、ボットがそれらの情報を基にチャンネルを監視して、メンションを検知したら代理応答します。

## セットアップ
### アプリの作成
1. [Slack API](https://api.slack.com/apps) の画面でCreate Appを押下してください。
2. アプリを作成したら、 `Slack Commands` に下記のように登録します。
  1. `/afk` リクエストエンドポイント `https://<your domain>/register`
  2. `/afk_(number)` リクエストエンドポイント `https://<your domain>/register` (指定した数字分経過で自動解除)
  3. `/lunch` リクエストエンドポイント `https://<your domain>/register`(60分経過で自動解除)
  3. `/finish` リクエストエンドポイント `https://<your domain>/register`(翌日9時に自動解除)
  5. `/comeback` リクエストエンドポイント `https://<your domain>/delete`

### ボットユーザーの作成

ボットユーザーを作成して、トークンを取得してください

### k8sへのデプロイ
`SLACK_API_TOKEN`はボットユーザーのトークン、`SLACK_USER_API_TOKEN` は一般ユーザーのトークンです。一般ユーザーのトークンは、ボットユーザーを公開チャンネルに自動でinviteするのに利用します。

```
$ kubectl create secret generic away-from-keyboard-secret --from-literal=slack-api-token=$SLACK_API_TOKEN --from-literal=slack-user-api-token=$SLACK_USER_API_TOKEN
$ kubectl apply -f manifests
```
