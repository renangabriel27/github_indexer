Profile.destroy_all

Profile.create!([
  {
    name: "Yukihiro Matsumoto",
    short_github_url: "https://github.com/matz",
    followers: 7700,
    location: "Japan"
  },
  {
    name: "DHH",
    short_github_url: "https://github.com/dhh",
    followers: 5000,
    location: "Chicago"
  }
])

puts "✅ #{Profile.count} profiles created"
