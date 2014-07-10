require 'rails_helper'

RSpec.describe User, '(creation)', type: :model do
  let :verified_user do
    e = create_user(email: 'a@b.ca', password: 'password').new_email
    e.verify!
    e.user
  end

  describe '#password' do
    it 'is required' do
      u = create_user(password: nil)
      expect(u.errors[:password]).to_not be_empty
    end
  end

  describe '#email' do
    it 'is required' do
      u = create_user(email: nil)
      expect(u.errors[:email]).to_not be_empty
    end

    it 'cannot be blank' do
      u = create_user(email: '')
      expect(u.errors[:email]).to_not be_empty
    end

    it 'must be unique' do
      u = [
        create_user(email: 'hi@example.com'),
        create_user(email: 'hi@example.com')
      ]

      expect(u[0]).to be_valid
      expect(u[1]).to_not be_valid
    end

    it 'must be verified' do
      u = create_user
      u = User.find(u.id)

      expect(u.email).to be_blank
    end

    it 'is available once verified' do
      u = create_user
      e = u.new_email
      e.verify!
      u = User.find(u.id)

      expect(e).to be_valid
      expect(e).to be_is_verified
      expect(u.email).to eq e.address
    end

    describe 'when changed' do
      it 'does not immediately remove the old address' do
        u1 = verified_user
        u1.email = 'c@d.ca'
        e = u1.new_email
        u1.save!
        u2 = User.find(u1.id)

        expect(u2.email).to eq u1.email
      end

      it 'removes the old address once verified' do
        u1 = verified_user
        u1.email = 'c@d.ca'
        e = u1.new_email
        u1.save!
        e.verify!
        u2 = User.find(u1.id)

        expect(u1.email).to eq u2.email
      end
    end
  end

  describe '#name' do
    it 'is required' do
      u = create_user(name: nil)
      expect(u.errors[:name]).to_not be_empty
    end

    it 'can have accent characters' do
      u = create_user(name: 'Ève Picard')
      expect(u).to be_valid
    end

    it 'cannot have non-alphanumeric characters' do
      u = create_user(name: '<script>HI</script>')
      expect(u.errors[:name]).to_not be_empty
    end
  end

  describe '::challenge' do
    it 'returns a verified user with correct credentials' do
      u1 = verified_user
      u2 = User.challenge(email: 'a@b.ca', password: 'password')

      expect(u2.id).to eq u1.id
    end

    it 'returns nil with an unverified user with correct credentials' do
      u1 = create_user(email: 'a@b.ca', password: 'password')
      u2 = User.challenge(email: 'a@b.ca', password: 'password')

      expect(u2).to be_nil
    end

    it 'returns nil with a verified user with incorrect credentials' do
      u1 = verified_user
      u2 = User.challenge(email: 'a@b.ca', password: 'wordpass')

      expect(u2).to be_nil
    end
  end
end
