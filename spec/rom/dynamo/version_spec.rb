module ROM
  describe Dynamo do
    it "has a version number" do
      expect(ROM::Dynamo::VERSION).to match /[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}/
    end
  end
end
