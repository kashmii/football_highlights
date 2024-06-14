FactoryBot.define do
  factory :game do
    league { 0 }
    game_week { 1 }
    kickoff_time { "2024-06-01 12:00:00" }
    home_team { "広島" }
    away_team { "浦和" }
  end
end
