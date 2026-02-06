# frozen_string_literal: true

RSpec.shared_context 'Ferrum browser setup' do
  let(:browser_mock) { instance_double(Ferrum::Browser) }

  def stub_browser_with_html(html)
    allow(browser_mock).to receive(:body).and_return(html)
    stub_browser_navigation
  end

  def stub_browser_navigation
    allow(browser_mock).to receive(:go_to)
    allow(browser_mock).to receive(:quit)
    allow(browser_mock).to receive(:at_css).with('h2[id*="contribution"]').and_return(true)
    allow(browser_mock).to receive(:at_css).with('title').and_return(
      double(text: 'User - GitHub')
    )
  end

  before do
    allow(Ferrum::Browser).to receive(:new).and_return(browser_mock)
  end
end
