# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubUsernameFormatValidator do
  subject(:validator) { described_class.new(attributes: [ :github_username ]) }

  let(:model_class) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :github_username

      validates :github_username, github_username_format: true

      def self.name
        "TestModel"
      end
    end
  end

  let(:model) { model_class.new }

  describe "valid usernames" do
    it "accepts single character username" do
      model.github_username = "a"
      expect(model).to be_valid
    end

    it "accepts username with letters and numbers" do
      model.github_username = "torvalds"
      expect(model).to be_valid
    end

    it "accepts username with hyphens in the middle" do
      model.github_username = "my-user"
      expect(model).to be_valid
    end

    it "accepts username with multiple hyphens" do
      model.github_username = "user-name-test"
      expect(model).to be_valid
    end

    it "accepts alphanumeric username" do
      model.github_username = "user123"
      expect(model).to be_valid
    end

    it "accepts blank username" do
      model.github_username = nil
      expect(model).to be_valid
    end
  end

  describe "invalid usernames" do
    it "rejects username starting with hyphen" do
      model.github_username = "-start"
      expect(model).not_to be_valid
      expect(model.errors[:github_username]).to include("não pode começar ou terminar com hífen")
    end

    it "rejects username ending with hyphen" do
      model.github_username = "end-"
      expect(model).not_to be_valid
      expect(model.errors[:github_username]).to include("não pode começar ou terminar com hífen")
    end

    it "rejects username with consecutive hyphens" do
      model.github_username = "double--hyphen"
      expect(model).not_to be_valid
      expect(model.errors[:github_username]).to include("não pode conter hífens consecutivos")
    end

    it "rejects username with multiple consecutive hyphens" do
      model.github_username = "triple---hyphen"
      expect(model).not_to be_valid
      expect(model.errors[:github_username]).to include("não pode conter hífens consecutivos")
    end

    it "rejects username starting and ending with hyphen" do
      model.github_username = "-both-"
      expect(model).not_to be_valid
      expect(model.errors[:github_username]).to include("não pode começar ou terminar com hífen")
    end
  end
end
