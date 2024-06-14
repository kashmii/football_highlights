class Game < ApplicationRecord
  enum league: {
  j_league: 0,
  premier_league: 1,
  bundesliga: 2,
  serie_a: 3,
  la_liga: 4
}

  validates :home_team, uniqueness: { scope: [:league, :game_week], message: "combination with league and game_week must be unique" }
end
