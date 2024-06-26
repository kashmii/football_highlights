require 'selenium-webdriver'
require 'nokogiri'

# ページにアクセスする
# 各gameの情報を取得してDBにいれる

class JleagueGamesService < ApplicationService
  # Service Objectが自らの責務を果たすために複数の手順が必要になった場合、手順をトランザクションでラップするとよい
  def call
    tmp_file = get_webpage_html
    game_attrs = collect_game_attributes(tmp_file)
    save_games(game_attrs)
  end

  private
    # 該当ページのHTMLをtmpファイルに保存
    def get_webpage_html
      driver = setup_driver
      html = fetch_html(driver)
      doc = Nokogiri::HTML.parse(html)
      file_path = save_html(doc)

      driver.quit
      file_path
    end

    def setup_driver
      # Selenium WebDriverの設定
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless') # ヘッドレスモード（GUIなし）で実行する場合
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-dev-shm-usage')

      # Selenium WebDriverの初期化
      driver = Selenium::WebDriver.for :chrome, options: options
    end

    def fetch_html(driver)
      # ブラウザを開いて指定したURLにアクセス
      driver.get(ENV["J1SHOW_URL"])
      # JavaScriptの実行を待つ
      sleep 10
      html = driver.page_source
    end

    def save_html(doc)
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      filename = "tmpfile_#{timestamp}.html"
      file_path = File.join(Dir.tmpdir, filename)

      # TODO: tmpfileは削除されずに残るので、後で削除するようにする
      File.open(file_path, 'w') do |file|
        file.write(doc)
      end

      file_path
    end

    # ===========================
    # get_webpage_html 関連ここまで
    # ===========================

    def collect_game_attributes(file)
      game_attrs = []
      target_text = "第 #{ENV["GAME_WEEK_NUM"]} 日（全 38 日）"

      doc = parse_html_from_file(file)
      # 節テーブル(class OcbAbf)のtbodyを取得している
      target_element = find_target_element(doc, target_text)
      # # <tr> = 2試合が入っている行 | <td> = 1試合が入っている列
      # # this_tbodyの子要素である<tr>要素の中の<td>要素すべてを選択します
      td_arr = target_element.css('> tr > td')

      td_arr.each do |td|
        home, away, date_str, time_str = extract_game_info(td)

        if home && away && date_str && time_str
          game_attrs << [ENV["GAME_WEEK_NUM"], parse_datetime(date_str, time_str), home.text, away.text]
        end
      end

      # 本番は puts 除去
      game_attrs
    end

    def parse_html_from_file(file)
      html = File.read(file)
      Nokogiri::HTML(html)
    end

    def find_target_element(doc, target_text)
      doc.css(".GVj7ae:contains('#{target_text}')")[0].parent.parent.at('tbody')
    end

    def extract_game_info(td)
      # tr 3つ目 日時
      third_tr = td&.at('tr:nth-child(3)')

      date_div = third_tr&.at('.imspo_mt__date')
      time_div = date_div&.next_element

      date_str = date_div&.text
      time_str = time_div&.text

      # tr 5つ目 ホーム/ 6つ目 アウェイ
      fifth_tr = td&.at('tr:nth-child(5)')
      sixth_tr = td&.at('tr:nth-child(6)')

      home = fifth_tr&.at('.liveresults-sports-immersive__hide-element')
      away = sixth_tr&.at('.liveresults-sports-immersive__hide-element')

      [home, away, date_div&.text, time_div&.text]
    end

    # ===========================
    # collect_game_attributes 関連ここまで
    # ===========================

    def save_games(game_attrs)
      # attrs をループしてGameを作成
      game_attrs.each do |attr|
        # 作ったGameを保存
        Game.create!(
          league: 0,
          game_week: attr[0],
          kickoff_time: attr[1],
          home_team: attr[2],
          away_team: attr[3],
        )
      end
    end

    # 文字列の日付と時刻をDateTimeオブジェクトに変換
    def parse_datetime(date_part, time_part)
      if date_part == '今日'
        date_part = DateTime.now.strftime('%m/%d')
      elsif date_part == '明日'
        date_part = (DateTime.now + 1).strftime('%m/%d')
      else
        date_part = date_part.split('(').first if date_part.include?('(')
      end

      date_format = "%m/%d"

      date_str = "#{date_part}/#{DateTime.now.year}"  # 年は現在の年を使用
      parsed_date = DateTime.strptime(date_str, date_format)

      time_format = "%H:%M"
      parsed_time = DateTime.strptime(time_part, time_format)

      # 日付と時刻を合成して返す
      parsed_date + Rational(parsed_time.hour, 24) + Rational(parsed_time.minute, 24 * 60)
    end
end
