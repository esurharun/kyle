require 'spec_helper'

describe Kyle do
  let!(:passwords) { Kyle.new(hostname, account, port, key).passwords }

  context "Bill Gates' passwords" do
    let(:hostname) { 'microsoft.com' }
    let(:account) { 'bill.gates' }
    let(:port) { '666' }
    let(:key) { 'iKnowWhatYouDidToIBMLastSummer' }

    it 'has the correct passwords' do
      expect(passwords).to eq(
        'Ape'     => 'WW0nQIY.0Rn6D8d2',
        'Bat'     => 'nXzU19faM7*gv7,I',
        'Bear'    => 'cgu0q7*DuT65r3rY',
        'Whale'   => 'ILZ,5vZLl/wRxf9y',
        'Crow'    => 'Od..eF2k6_l3XHxe',
        'Dog'     => 'sedWPnJsSb4DEJw-',
        'Cat'     => 'JEr_SzZBoofgI7Tb',
        'Wasp'    => 'xbbg@ebdz3FA.n6S',
        'Fox'     => '5EMS!XZP7WfPLKpO',
        'Gull'    => 'LcwDHUu0/ynzdSWE',
        'Jackal'  => '5+fDOoY.yrE+ESbj',
        'Lion'    => 'VWKqetfVKZtT,FI9',
        'Panda'   => 'EDe7XvMZ%8tt2vsT',
        'Rat'     => 'vks.HPeDVkklS_qb',
        'Shark'   => 'hcVznOxvT5YvxIlU',
        'Spider'  => 'iBTr-I42uz7h7XnA',
        'Turtle'  => 'fLV,g6%@1G7xpQil',
        'Wolf'    => 'toMFvN@Zd,b*KBC%',
        'Zebra'   => 'FYbi/6Udx_4mO3D0'
      )
    end
  end

  context 'with crazy inputs' do
    let(:hostname) { Constants::PASSWORD_CHARS.join }
    let(:account) { Constants::PASSWORD_CHARS.join }
    let(:port) { Constants::PASSWORD_CHARS.join }
    let(:key) { Constants::PASSWORD_CHARS.join }

    it 'has correct passwords' do
      expect(passwords).to eq(
        'Ape'     => 'cuoTJm!UuIYCcQxs',
        'Bat'     => '3HrQ3s/j53A+Rssm',
        'Bear'    => 'KK+IV7QE9Imd65hi',
        'Whale'   => 'M@FH%uduAIvn/0Fg',
        'Crow'    => 'C@ffelLPbsh!ps68',
        'Dog'     => 'mF%j06cgTaD63v5C',
        'Cat'     => '5pRiaZDk%SY6quet',
        'Wasp'    => 'd56XIGF8PhHu!TfI',
        'Fox'     => '71UES8Six9G48hsc',
        'Gull'    => 'kmtu%gr1.k%T!tPy',
        'Jackal'  => 'zE8*qE+uU.PsOkYY',
        'Lion'    => '77Rbxcaiwp4Fwm.M',
        'Panda'   => 'qWT0K%tFP8w7_H0S',
        'Rat'     => '2uGyZI.SzAOujmkw',
        'Shark'   => '.QhaGPzV_jnnRj@F',
        'Spider'  => '4FsOh0GfaM4MVUUH',
        'Turtle'  => '_3r0DzAdYvEp@dlA',
        'Wolf'    => 'qcWgE@nt9SgUEsjP',
        'Zebra'   => '8F1BJ.OlV5Kj!wmM'
      )
    end
  end
end
