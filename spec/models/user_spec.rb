require 'spec_helper'

describe User, '(creation)' do
  describe '#password' do
    it 'is required' do
      u = User.create(name: 'Carsten', email: 'hi@example.com')
      expect(u.errors[:password]).to_not be_empty
    end
  end

  describe '#email' do
    it 'is required' do
      u = User.create(name: 'Carsten', password: 'testcheck')
      expect(u.errors[:email]).to_not be_empty
    end

    it 'cannot be blank' do
      u = User.create(name: 'Carsten', password: 'testcheck', email: '')
      expect(u.errors[:email]).to_not be_empty
    end

    it 'must be unique' do
      u1 = User.create(name: 'Carsten', password: 'testcheck', email: 'hi@example.com')
      u2 = User.create(name: 'Carsten', password: 'testcheck', email: 'hi@example.com')
      expect(u1).to be_valid
      expect(u2).to_not be_valid
    end
  end

  describe '#name' do
    it 'is required' do
      u = User.create(email: 'hi@example.com', password: 'testcheck')
      expect(u.errors[:name]).to_not be_empty
    end

    it 'can have accent characters' do
      u = User.create(name: 'Ève Picard', email: 'hi@example.com', password: 'testcheck')
      expect(u).to be_valid
    end

    it 'cannot have non-alphanumeric characters' do
      u = User.create(name: '<script>HI</script>', email: 'hi@example.com', password: 'testcheck')
      expect(u.errors[:name]).to_not be_empty
    end
  end
end
