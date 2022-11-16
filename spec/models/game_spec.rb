require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user) }

  let(:game_w_questions) do
    FactoryBot.create(:game_with_questions, user: user)
  end

  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      generate_questions(60)

      game = nil

      expect do
        game = Game.create_game_for_user!(user)
      end.to change(Game, :count).by(1).and(
        change(GameQuestion, :count).by(15).and(
          change(Question, :count).by(0)
        )
      )

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    let(:q) do
      game_w_questions.current_game_question
    end

    it 'answer correct continues game' do
      level = game_w_questions.current_level
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)

      expect(game_w_questions.current_game_question).not_to eq(q)

      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    describe '#take_money!' do
      it 'should award a prize and finish the game' do
        game_w_questions.answer_current_question!(q.correct_answer_key)
        game_w_questions.take_money!

        expect(game_w_questions.prize).to eq(100)
        expect(game_w_questions.user.balance).to eq(100)
        expect(game_w_questions.finished?).to be_truthy
      end
    end

    describe '#status' do
      it 'should return correct status game when timeout' do
        expect(game_w_questions.status).to be :in_progress

        game_w_questions.finished_at = Time.now + 36 * 60 * 60
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to be :timeout
      end

      it 'should return correct status game when fail' do
        game_w_questions.answer_current_question!('')

        expect(game_w_questions.status).to be :fail
      end

      it 'should return correct status game when won' do
        15.times do
          expect(game_w_questions.status).to be :in_progress
          game_w_questions.answer_current_question!(game_w_questions.current_game_question.correct_answer_key)
        end

        expect(game_w_questions.status).to be :won
      end

      it 'should return correct status game when take money' do
        game_w_questions.answer_current_question!(q.correct_answer_key)
        game_w_questions.take_money!

        expect(game_w_questions.status).to be :money
      end

      describe '#current_game_question' do
        it 'should return game_question corresponding to this level' do
          game_w_questions.answer_current_question!(q.correct_answer_key)
          expect(game_w_questions.current_game_question.level).to eq(1)
        end
      end

      describe '#previous_level' do
        it 'should return prvious level' do
          game_w_questions.answer_current_question!(q.correct_answer_key)
          expect(game_w_questions.previous_level).to eq(0)
        end
      end

      describe '#answer_current_qyestion!' do
        it 'should return false when time out' do
          game_w_questions.created_at = 1.day.ago
          expect(game_w_questions.answer_current_question!(q.correct_answer_key)).to be false
        end

        it 'should return false when game finished' do
          game_w_questions.finished_at = Time.now
          expect(game_w_questions.answer_current_question!(q.correct_answer_key)).to be false
        end

        it 'should return false when answer incorrect' do
          5.times do
            game_w_questions.answer_current_question!(q.correct_answer_key)
          end

          expect(game_w_questions.answer_current_question!('a')).to be false
          expect(game_w_questions.prize).to eq(1000)
        end

        it 'should return true when answer correct' do
          expect(game_w_questions.answer_current_question!(q.correct_answer_key)).to be true
          expect(game_w_questions.current_level).to eq(1)
        end

        it 'should return true when answer correct and you won game' do
          14.times do
            game_w_questions.answer_current_question!(q.correct_answer_key)
          end
          expect(game_w_questions.answer_current_question!(q.correct_answer_key)).to be true
          expect(game_w_questions.current_level).to eq(15)
          expect(game_w_questions.prize).to eq(1_000_000)
        end
      end
    end
  end
end
