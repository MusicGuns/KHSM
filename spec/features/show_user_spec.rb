# Как и в любом тесте, подключаем помощник rspec-rails
require 'rails_helper'

# Начинаем описывать функционал, связанный с созданием игры
RSpec.feature 'USER creates a game', type: :feature do
  let(:user) { FactoryBot.create :user }

  let!(:games_w_questions) do
    [
      FactoryBot.create(:game_with_questions, id: 16, user: user, current_level: 10,
                                               created_at: Time.parse('2016.10.08, 13:00'), prize: 2000),
      FactoryBot.create(:game_with_questions, id: 15, user: user, current_level: 5,
                                               created_at: Time.parse('2016.10.09, 13:00'), is_failed: true, finished_at: Time.parse('2016.10.08, 13:00'), prize: 1000)
    ]
  end

  scenario 'unknown user show user page' do
    user
    visit '/'

    click_link "#{user.name}"

    expect(page).to have_current_path '/users/1'

    expect(page).to have_content "#{user.name}"

    expect(page).not_to have_content 'Сменить имя и пароль'

    expect(page).to have_content '15'
    expect(page).to have_content '5'
    expect(page).to have_content 'проигрыш'
    expect(page).to have_content '1 000 ₽'

    expect(page).to have_content '16'
    expect(page).to have_content '10'
    expect(page).to have_content 'в процессе'
    expect(page).to have_content '2 000 ₽'

    expect(page).to have_content(/15.*16/m)
  end
end
