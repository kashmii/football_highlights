class Game < ApplicationRecord
  enum league: {
  j_league: 0,
  premier_league: 1,
  bundesliga: 2,
  serie_a: 3,
  la_liga: 4
}
end