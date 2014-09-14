require 'spec_helper'

describe KyleCommands do
  subject(:cmds) { described_class.new(args) }

  context 'in batch mode' do
    let(:args) { %w(-b filename.txt whale) }

    it 'is in batch mode' do
      expect(cmds.batch?).to eq(true)
    end

    it 'runs #batch_generate' do
      expect(cmds).to receive(:batch_generate)
      cmds.run
    end
  end

  context 'in single mode' do
    let(:args) { %w(microsoft.com evilcommander 8080 panda) }

    it 'is in single mode' do
      expect(cmds.batch?).to eq(false)
    end

    it 'has details set' do
      expect(cmds.hostname).to eq('microsoft.com')
      expect(cmds.account).to eq('evilcommander')
      expect(cmds.port).to eq('8080')
      expect(cmds.animals).to eq(['Panda'])
    end
  end
end
