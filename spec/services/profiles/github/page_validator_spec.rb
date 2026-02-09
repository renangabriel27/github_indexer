# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::Github::PageValidator do
  let(:browser) { double('Browser') }
  subject(:validator) { described_class.new(browser) }

  def stub_browser(status: 200, title: 'torvalds - GitHub', body: '<span class="vcard-username">torvalds</span>')
    allow(browser).to receive(:respond_to?).with(:status).and_return(true)
    allow(browser).to receive(:status).and_return(status)
    allow(browser).to receive(:at_css).with('title').and_return(title ? double(text: title) : nil)
    allow(browser).to receive(:body).and_return("<html>#{body}</html>")
  end

  describe '#validate!' do
    it 'does not raise error for valid profile page' do
      stub_browser
      expect { validator.validate! }.not_to raise_error
    end

    it 'raises ProfileNotFoundError for HTTP 404' do
      stub_browser(status: 404)
      expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError, /404/)
    end

    it 'raises StandardError for HTTP 500' do
      stub_browser(status: 500)
      expect { validator.validate! }.to raise_error(StandardError, /500/)
    end

    it 'raises ProfileNotFoundError when title contains "not found"' do
      stub_browser(title: 'Page Not Found - GitHub', body: '')
      expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError)
    end

    %w[vcard-username avatar-user p-name].each do |marker|
      it "accepts page with #{marker} marker" do
        stub_browser(body: "<div>#{marker}</div>")
        expect { validator.validate! }.not_to raise_error
      end
    end

    [
      'This is not the web page you are looking for',
      'Page not found',
      '404 - Not Found'
    ].each do |error_text|
      it "raises ProfileNotFoundError for '#{error_text}'" do
        stub_browser(title: 'Some Page', body: error_text)
        expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError)
      end
    end
  end
end
