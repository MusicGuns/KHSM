require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context 'Anon' do
    it 'kick from #show' do
      get :show, id: game_w_questions.id
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end
  end

  context 'Usual user' do
    before(:each) { sign_in user }

    it 'creates game' do
      generate_questions(15)

      post :create
      game = assigns(:game)
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)
      expect(response).to redirect_to(game_path(game))
      expect(flash[:notice]).to be
    end

    it '#show game' do
      get :show, id: game_w_questions.id
      game = assigns(:game)
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response.status).to eq(200)
      expect(response).to render_template('show')
    end

    it 'answers correct' do
      put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be_truthy
    end

    it 'uses audience help' do
      expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
      expect(game_w_questions.audience_help_used).to be_falsey

      put :help, id: game_w_questions.id, help_type: :audience_help
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.audience_help_used).to be_truthy
      expect(game.current_game_question.help_hash[:audience_help]).to be
      expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
      expect(response).to redirect_to(game_path(game))
    end

    it 'uses fifty_fifty' do
      expect(game_w_questions.current_game_question.help_hash[:fifty_fifty]).not_to be
      expect(game_w_questions.audience_help_used).to be_falsey

      put :help, id: game_w_questions.id, help_type: :fifty_fifty
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.fifty_fifty_used).to be_truthy
      expect(game.current_game_question.help_hash[:fifty_fifty]).to be
      expect(game.current_game_question.help_hash[:fifty_fifty].size).to eq(2)
      expect(game.current_game_question.help_hash[:fifty_fifty]).to include(game.current_game_question.correct_answer_key)
      expect(response).to redirect_to(game_path(game))
    end
  end
end
