# frozen_string_literal: true

RSpec.shared_context 'GitHub HTML fixtures' do
  let(:github_profile_html) do
    <<~HTML
      <html>
        <head><title>Linus Torvalds - GitHub</title></head>
        <body>
          <span itemprop="name">Linus Torvalds</span>
          <span itemprop="additionalName">torvalds</span>
          <a href="/torvalds?tab=followers">
            <span class="text-bold">185k</span> followers
          </a>
          <a href="/torvalds?tab=following">
            <span class="text-bold">0</span> following
          </a>
          <a href="/torvalds?tab=stars">
            <span data-view-component="true" class="Counter">25</span>
          </a>
          <h2 id="js-contribution-activity">4,123 contributions in the last year</h2>
          <img class="avatar-user" src="https://avatars.githubusercontent.com/u/1024025?v=4&s=64">
          <span itemprop="homeLocation">
            <span class="p-label">Portland, OR</span>
          </span>
          <a itemprop="follows" aria-label="Linux Foundation">
            <img alt="@linuxfoundation">
          </a>
        </body>
      </html>
    HTML
  end

  let(:github_404_html) do
    <<~HTML
      <html>
        <head><title>Page not found · GitHub</title></head>
        <body>
          <h1>404</h1>
          <p>This is not the web page you are looking for</p>
        </body>
      </html>
    HTML
  end

  let(:github_minimal_html) do
    <<~HTML
      <html>
        <head><title>Minimal User - GitHub</title></head>
        <body>
          <span itemprop="name">Minimal User</span>
          <span itemprop="additionalName">minimal</span>
          <a href="/minimal?tab=followers">
            <span class="text-bold">10</span> followers
          </a>
          <h2 id="js-contribution-activity">5 contributions in the last year</h2>
        </body>
      </html>
    HTML
  end

  def github_html_with_numbers(followers:, following:, stars:, contributions:)
    <<~HTML
      <html>
        <head><title>Test User - GitHub</title></head>
        <body>
          <span itemprop="name">Test User</span>
          <span itemprop="additionalName">testuser</span>
          <a href="/testuser?tab=followers">
            <span class="text-bold">#{followers}</span> followers
          </a>
          <a href="/testuser?tab=following">
            <span class="text-bold">#{following}</span> following
          </a>
          <a href="/testuser?tab=stars">
            <span data-view-component="true" class="Counter">#{stars}</span>
          </a>
          <h2 id="js-contribution-activity">#{contributions} contributions in the last year</h2>
        </body>
      </html>
    HTML
  end
end
