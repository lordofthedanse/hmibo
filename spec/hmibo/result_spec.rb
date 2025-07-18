# frozen_string_literal: true

require "spec_helper"

RSpec.describe Hmibo::Result do
  describe "#initialize" do
    it "initializes with all parameters" do
      result = Hmibo::Result.new(true, "Success", { id: 1 }, ["error1"])
      
      expect(result.success).to be(true)
      expect(result.message).to eq("Success")
      expect(result.data).to eq({ id: 1 })
      expect(result.errors).to eq(["error1"])
    end

    it "converts errors to array" do
      result = Hmibo::Result.new(false, "Failed", nil, "single error")
      
      expect(result.errors).to eq(["single error"])
    end
  end

  describe "#success?" do
    it "returns true for successful results" do
      result = Hmibo::Result.new(true, "Success")
      expect(result.success?).to be(true)
    end

    it "returns false for failed results" do
      result = Hmibo::Result.new(false, "Failed")
      expect(result.success?).to be(false)
    end
  end

  describe "#failure?" do
    it "returns false for successful results" do
      result = Hmibo::Result.new(true, "Success")
      expect(result.failure?).to be(false)
    end

    it "returns true for failed results" do
      result = Hmibo::Result.new(false, "Failed")
      expect(result.failure?).to be(true)
    end
  end

  describe "#to_h" do
    it "returns hash representation" do
      result = Hmibo::Result.new(true, "Success", { id: 1 }, ["error1"])
      
      expect(result.to_h).to eq({
        success: true,
        message: "Success",
        data: { id: 1 },
        errors: ["error1"]
      })
    end
  end

  describe ".success" do
    it "creates successful result" do
      result = Hmibo::Result.success("All good", { id: 1 })
      
      expect(result.success?).to be(true)
      expect(result.message).to eq("All good")
      expect(result.data).to eq({ id: 1 })
      expect(result.errors).to eq([])
    end
  end

  describe ".failure" do
    it "creates failed result" do
      result = Hmibo::Result.failure("Something went wrong", ["error1", "error2"])
      
      expect(result.success?).to be(false)
      expect(result.message).to eq("Something went wrong")
      expect(result.data).to be_nil
      expect(result.errors).to eq(["error1", "error2"])
    end
  end
end