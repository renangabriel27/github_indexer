# frozen_string_literal: true

RSpec.shared_context 'Ferrum browser setup' do
  let(:browser_mock) { instance_double(Ferrum::Browser) }
  let(:circuit_breaker_mock) { instance_double(Profiles::Github::CircuitBreaker) }

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

  def stub_circuit_breaker
    allow(circuit_breaker_mock).to receive(:call).and_yield
    allow(circuit_breaker_mock).to receive(:record_success)
    allow(circuit_breaker_mock).to receive(:record_failure)
    allow(Profiles::Github::CircuitBreaker).to receive(:new).and_return(circuit_breaker_mock)
  end

  before do
    allow(Ferrum::Browser).to receive(:new).and_return(browser_mock)
    stub_circuit_breaker
  end
end
