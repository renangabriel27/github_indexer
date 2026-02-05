Profile.destroy_all

Profile.create!([
  {
    name: "Yukihiro Matsumoto",
    short_github_url: "https://github.com/matz",
    github_username: "matz",
    avatar_url: "https://avatars2.githubusercontent.com/u/30733?s=460&v=4",
    followers: 7700,
    location: "Japan"
  },
  {
    name: "DHH",
    short_github_url: "https://github.com/dhh",
    github_username: "dhh",
    avatar_url: "https://avatars.githubusercontent.com/u/2741?v=4",
    followers: 5000,
    location: "Chicago"
  }
])

puts "✅ #{Profile.count} profiles created"
