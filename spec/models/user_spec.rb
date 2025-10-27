require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    # Add any associations as the model grows
  end

  describe 'devise modules' do
    it { is_expected.to have_db_column(:encrypted_password) }
    it { is_expected.to have_db_column(:email) }
    it { is_expected.to have_db_column(:reset_password_token) }
    it { is_expected.to have_db_column(:reset_password_sent_at) }
    it { is_expected.to have_db_column(:remember_created_at) }
    it { is_expected.to have_db_column(:confirmation_token) }
    it { is_expected.to have_db_column(:confirmed_at) }
    it { is_expected.to have_db_column(:confirmation_sent_at) }
  end

  describe 'validations' do
    describe 'name validations' do
      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_presence_of(:last_name) }
    end

    describe 'devise validations' do
      it { is_expected.to validate_presence_of(:email) }

      it 'validates email uniqueness case-insensitively via Devise' do
        user1 = create(:user, email: 'test@example.com')
        user2 = build(:user, email: 'TEST@EXAMPLE.COM')
        expect(user2).not_to be_valid
        expect(user2.errors[:email]).to be_present
      end
    end

    describe 'login validation' do
      context 'when validating with :login context' do
        it 'requires email' do
          user = build(:user, email: '')
          user.validate(:login)
          expect(user.errors[:email]).to include('is required')
        end

        it 'requires password' do
          user = build(:user, password: '')
          user.validate(:login)
          expect(user.errors[:password]).to include('is required')
        end

        it 'is valid when both email and password are present' do
          user = build(:user, email: 'test@example.com', password: 'password123')
          user.validate(:login)
          expect(user.errors[:email]).to be_empty
          expect(user.errors[:password]).to be_empty
        end
      end
    end
  end

  describe 'instance methods' do
    let(:user) { create(:user, first_name: 'John', last_name: 'Doe') }

    describe '#full_name' do
      it 'returns first and last name combined' do
        expect(user.full_name).to eq('John Doe')
      end

      it 'handles empty first name gracefully' do
        user.update(first_name: '')
        expect(user.full_name).to eq('Doe')
      end

      it 'handles empty last name gracefully' do
        user.update(last_name: '')
        expect(user.full_name).to eq('John')
      end

      it 'handles both names empty gracefully' do
        user.update(first_name: '', last_name: '')
        expect(user.full_name).to eq('')
      end
    end

    describe '#short_name' do
      it 'returns first name' do
        expect(user.short_name).to eq('John')
      end

      it 'returns empty string if first name is blank' do
        user.update(first_name: '')
        expect(user.short_name).to eq('')
      end
    end
  end

  describe 'user creation' do
    it 'creates a user with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'encrypts password on creation' do
      user = create(:user, password: 'test_password_123', password_confirmation: 'test_password_123')
      expect(user.encrypted_password).not_to eq('test_password_123')
      expect(user.encrypted_password).to be_present
    end

    it 'generates a unique email for each user from factory' do
      user1 = create(:user)
      user2 = create(:user)
      expect(user1.email).not_to eq(user2.email)
    end

    it 'requires password to be at least 6 characters' do
      user = build(:user, password: 'short', password_confirmation: 'short')
      expect(user).not_to be_valid
    end

    it 'requires password confirmation to match password' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
    end
  end

  describe 'user authentication' do
    let(:user) { create(:user, email: 'test@example.com', password: 'secure_password_123', password_confirmation: 'secure_password_123') }

    it 'can authenticate with correct password' do
      # Devise uses different methods, so we'll just verify the user exists and password is correct
      expect(user.valid_password?('secure_password_123')).to be true
    end

    it 'does not authenticate with incorrect password' do
      expect(user.valid_password?('wrong_password')).to be false
    end
  end
end
