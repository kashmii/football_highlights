FROM --platform=linux/x86_64 ruby:3.2.2
ARG RUBYGEMS_VERSION=3.3.20

# WORKDIR命令は指定したディレクトリが存在しない場合、自動的にそのディレクトリを作成する
WORKDIR /football_highlights

# パッケージリストを更新 システムは最新のパッケージ情報を取得する
RUN apt-get update -qq && apt-get install -y netcat-openbsd

# Google Chromeのインストール
RUN wget https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_125.0.6422.141-1_amd64.deb \
    && dpkg -i google-chrome-stable_125.0.6422.141-1_amd64.deb; apt-get -fy install \
    && google-chrome-stable --version

# ChromeDriverのバージョンを設定
ENV CHROME_DRIVER_VERSION=125.0.6422.141

# ChromeDriverをダウンロードしてインストール
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://storage.googleapis.com/chrome-for-testing-public/125.0.6422.141/linux64/chromedriver-linux64.zip \
    && unzip /tmp/chromedriver_linux64.zip -d /usr/local/bin \
    && rm /tmp/chromedriver_linux64.zip \
    && chmod 755 /usr/local/bin/chromedriver-linux64/chromedriver \
    && mv /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver

# ChromeDriverが見つけられるようにパスを設定
ENV PATH $PATH:/usr/local/bin

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

