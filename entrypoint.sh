#!/bin/bash
# set -e は「エラーが発生するとスクリプトを終了する」オプション
set -e

# Wait for the SQL server to start
while ! nc -z db 3306; do
  sleep 2
  echo "Waiting for the MySQL server to start..."
done

# Rails に対応したファイル server.pid が存在しているかもしれないので削除する
rm -f /football_highlights/tmp/pids/server.pid

bundle exec rails db:create db:migrate
# コンテナのプロセスを実行する。CMDで渡されたコマンドを実行しています(→rails s)
exec "$@"
