# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::Runnable do
  shared_context 'with an error' do
    before { instance.errors.add(:base) }
  end

  shared_context 'with a validator' do
    before { klass.validate { errors.add(:base) } }
  end

  shared_context 'with #execute defined' do
    before { klass.send(:define_method, :execute) { rand } }
  end

  let(:klass) do
    Class.new do
      include ActiveModel::Validations
      include ActiveInteraction::Runnable

      def self.name
        SecureRandom.hex
      end
    end
  end

  subject(:instance) { klass.new }

  context 'validations' do
    it
  end

  describe 'ActiveRecord::Base.transaction' do
    it 'raises an error' do
      expect { ActiveRecord::Base.transaction }.to raise_error LocalJumpError
    end

    context 'with a block' do
      it 'yields to the block' do
        expect { |b| ActiveRecord::Base.transaction(&b) }.to yield_with_no_args
      end

      it 'accepts an argument' do
        expect { ActiveRecord::Base.transaction(nil) {} }.to_not raise_error
      end
    end
  end

  describe '#errors' do
    it 'returns the errors' do
      expect(instance.errors).to be_an ActiveInteraction::Errors
    end
  end

  describe '#execute' do
    it 'raises an error' do
      expect { instance.execute }.to raise_error NotImplementedError
    end
  end

  describe '#result' do
    it 'returns the result' do
      expect(instance.result).to be_nil
    end
  end

  describe '#result=' do
    let(:result) { double }

    it 'returns the result' do
      expect(instance.result = result).to eq result
    end

    it 'sets the result' do
      instance.result = result
      expect(instance.result).to eq result
    end

    context 'with an error' do
      include_context 'with an error'

      it 'does not set the result' do
        instance.result = result
        expect(instance.result).to be_nil
      end
    end

    context 'with a validator' do
      include_context 'with a validator'

      it 'sets the result' do
        instance.result = result
        expect(instance.result).to eq result
      end
    end
  end

  describe '#valid?' do
    let(:result) { double }

    it 'returns true' do
      expect(instance.valid?).to be_true
    end

    context 'with an error' do
      include_context 'with an error'

      it 'returns true' do
        expect(instance.valid?).to be_true
      end
    end

    context 'with a validator' do
      include_context 'with a validator'

      it 'returns nil' do
        expect(instance.valid?).to be_nil
      end

      it 'sets the result to nil' do
        instance.result = result
        instance.valid?
        expect(instance.result).to be_nil
      end
    end
  end

  describe '.run' do
    let(:outcome) { klass.run }

    it 'raises an error' do
      expect { outcome }.to raise_error NotImplementedError
    end

    context 'with #execute defined' do
      include_context 'with #execute defined'

      it 'returns an instance of Runnable' do
        expect(outcome).to be_a klass
      end

      it 'sets the result' do
        expect(outcome.result).to_not be_nil
      end

      context 'with a validator' do
        include_context 'with a validator'

        it 'returns an instance of Runnable' do
          expect(outcome).to be_a klass
        end

        it 'sets the result to nil' do
          expect(outcome.result).to be_nil
        end
      end
    end
  end

  describe '.run!' do
    let(:result) { klass.run! }

    it 'raises an error' do
      expect { result }.to raise_error NotImplementedError
    end

    context 'with #execute defined' do
      include_context 'with #execute defined'

      it 'returns the result' do
        expect(result).to_not be_nil
      end

      context 'with a validator' do
        include_context 'with a validator'

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidInteractionError
        end
      end
    end
  end
end
