require 'spec_helper'

describe BitcoinAddrgen do

  let(:master_public_key) { '675b7041a347223984750fe3ab229df0c9f960e7ec98226b7182a2cb1990e39901feecf5a670f1d788ab29f626e20de424f049d216fc6f4c6ec42506763fa28e' }

  context "generate_public_address" do
    subject do
      BitcoinAddrgen.generate_public_address(master_public_key, address_index)
    end

    context "with first address index" do
      let(:address_index) { 0 }

      it "generates the correct public address" do
        expect(subject).to eq('13EfJ1hQBGMBbEwvPa3MLeH6buBhiMSfCC')
      end
    end

    context "with seventh address index" do
      let(:address_index) { 6 }

      it "generates the correct public address" do
        expect(subject).to eq('1jmA5ySdFz7cDwWb15rWQe63ZUo8spiBa')
      end
    end

    context "with 10th address index" do
      let(:address_index) { 9 }

      it "generates the correct public address" do
        expect(subject).to eq('1J7yTE8Cm9fMV9nqCjnM6kTTzTkksVic98')
      end
    end
  end
end
