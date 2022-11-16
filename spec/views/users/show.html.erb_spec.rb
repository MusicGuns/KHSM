require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  before(:each) do
    @user = FactoryBot.create(:user, name: 'Артем')
    assign(:user, @user)
    assign(:games, [FactoryBot.build_stubbed(:game, id: 15)])
    stub_template 'users/_game.html.erb' => 'User game goes here'
  end

  it 'render player names' do
    render
    expect(rendered).to match 'Артем'
  end

  it 'render user game' do
    render
    expect(rendered).to match 'User game goes here'
  end

  context 'password change show' do
    before { sign_in @user }

    it 'render when user sign in' do
      render
      expect(rendered).to match 'Сменить имя и пароль'
    end
  end

  context 'password change not show' do
    it 'render when user not sign_in' do
      render
      expect(rendered).not_to match 'Сменить имя и пароль'
    end

    it 'render when other user is sign_in' do
      sign_in FactoryBot.create(:user, name: 'Паша')
      render
      expect(rendered).not_to match 'Сменить имя и пароль'
    end
  end
end
