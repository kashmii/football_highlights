require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'validations' do
    context 'when the combination of home_team, league, and game_week is not unique' do
      let(:game) { create(:game) }

      before { 2.times { game } }

      it 'object will not be saved' do
        expect(Game.all.size).to eq(1)
      end
    end
  end
end
