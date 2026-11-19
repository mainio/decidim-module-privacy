# frozen_string_literal: true

require "spec_helper"

describe Decidim::Privacy do
  describe ".apply_extensions?" do
    around do |spec|
      original_env = ENV.to_h
      spec.run
      ENV.replace(original_env)
    end

    before do
      stub_const("Rake", Class.new) unless defined?(Rake)
      allow(Rake).to receive(:application).and_return(double(tol_level_tasks: []))
    end

    it "returns true if NODE_ENV is test" do
      ENV["NODE_ENV"] = "test"

      expect(Decidim::Privacy.apply_extensions?).to be(true)
    end

    it "returns false if seeding?" do
      ENV["NODE_ENV"] = nil
      allow(Decidim::Privacy).to receive(:seeding?).and_return(true)

      expect(Decidim::Privacy.apply_extensions?).to be(false)
    end

    it "returns false if DEV_APP_GENERATION is true" do
      ENV["NODE_ENV"] = nil
      ENV["DEV_APP_GENERATION"] = "true"

      allow(Decidim::Privacy).to receive(:seeding?).and_return(false)

      expect(Decidim::Privacy.apply_extensions?).to be(false)
    end

    it "returns true if Rake is not defined" do
      hide_const("Rake")
      ENV["NODE_ENV"] = nil
      ENV["DEV_APP_GENERATION"] = nil

      expect(Decidim::Privacy.apply_extensions?).to be(true)
    end

    it "returns true if no conditions match" do
      ENV["NODE_ENV"] = nil
      ENV["DEV_APP_GENERATION"] = nil
      allow(Decidim::Privacy).to receive(:seeding?).and_return(false)

      expect(Decidim::Privacy.apply_extensions?).to be(true)
    end
  end
end
