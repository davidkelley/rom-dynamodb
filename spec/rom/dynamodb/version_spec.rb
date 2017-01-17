module ROM
  describe DynamoDB do
    it "has a version number" do
      expect(ROM::DynamoDB::VERSION).to match /[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}/
    end
  end
end
