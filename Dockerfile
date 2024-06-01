FROM --platform=linux/x86_64 ruby:3.2.2
ARG RUBYGEMS_VERSION=3.3.20

# WORKDIR命令は指定したディレクトリが存在しない場合、自動的にそのディレクトリを作成する
WORKDIR /football_highlights

# パッケージリストを更新 システムは最新のパッケージ情報を取得する
RUN apt-get update -qq && apt-get install -y netcat-openbsd

# ホストのGemfileをコンテナ内の作業ディレクトリにコピー
COPY Gemfile .
COPY Gemfile.lock .

# bundle installを実行
RUN bundle install

# ホストのファイルをコンテナ内の作業ディレクトリにコピー
COPY . .

# entrypoint.shの実行権限を付与
RUN chmod +x ./entrypoint.sh
# コンテナ起動時にentrypoint.shを実行するように設定
ENTRYPOINT ["/football_highlights/entrypoint.sh"]

# コンテナ起動時に実行するコマンドを指定
CMD ["rails", "server", "-b", "0.0.0.0"]

