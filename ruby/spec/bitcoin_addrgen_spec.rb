require 'spec_helper'

describe BitcoinAddrgen do

  let(:master_public_key) { '675b7041a347223984750fe3ab229df0c9f960e7ec98226b7182a2cb1990e39901feecf5a670f1d788ab29f626e20de424f049d216fc6f4c6ec42506763fa28e' }

  context "generate_public_address" do
    subject do
      BitcoinAddrgen.generate_public_address(master_public_key, address_index)
    end

    context "with address index 0" do
      let(:address_index) { 0 }
      it "generates the correct public address" do
        expect(subject).to eq('13EfJ1hQBGMBbEwvPa3MLeH6buBhiMSfCC')
      end
    end

    context "with address index 6" do
      let(:address_index) { 6 }
      it "generates the correct public address" do
        expect(subject).to eq('1jmA5ySdFz7cDwWb15rWQe63ZUo8spiBa')
      end
    end

    context "with address index 9" do
      let(:address_index) { 9 }
      it "generates the correct public address" do
        expect(subject).to eq('1J7yTE8Cm9fMV9nqCjnM6kTTzTkksVic98')
      end
    end

    context "with address index 100" do
      let(:address_index) { 100 }
      it "generates the correct public address" do
        expect(subject).to eq('1LNUmaHWMybREGszq8wiDTULJR3tvsjx7')
      end
    end

    context "with address index 65537" do
      let(:address_index) { 65537 }
      it "generates the correct public address" do
        expect(subject).to eq('1JnjQQ5LcMDYDLNd31bEU2L5wZ9fipvEQ6')
      end
    end

    context "with address index 4294967296" do
      let(:address_index) { 4294967296 }
      it "generates the correct public address" do
        expect(subject).to eq('1KJwuVF7hm7EoT1AYJas2WM3yodCzsEhAQ')
      end
    end

  end
end
