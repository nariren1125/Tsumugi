# db/seeds.rb
puts "🌱 Seeding Tsumugi sample data..."

# --- Family Group ---
family = FamilyGroup.create!(
  name: "成松家"
)

# --- Users ---
mom = User.create!(
  name: "れんママ",
  email: "ren_mama@example.com",
  family_group: family
)

dad = User.create!(
  name: "れんパパ",
  email: "ren_papa@example.com",
  family_group: family
)

# --- Children ---
child1 = Child.create!(
  name: "つむぎ",
  birth_date: Date.new(2023, 5, 12),
  family_group: family
)

# --- Albums ---
album1 = Album.create!(
  title: "はじめてのアルバム",
  description: "家族での思い出を集めたアルバム",
  family_group: family
)

# --- Posts (photo付き投稿イメージ) ---
Post.create!(
  user: mom,
  album: album1,
  content: "初めてのおでかけ！天気も良くて最高だった〜☀️"
)

Post.create!(
  user: dad,
  album: album1,
  content: "つむぎの笑顔がかわいすぎる📸"
)

# --- Notifications (例:家族内お知らせ) ---
Notification.create!(
  title: "アルバムが作成されました！",
  body: "『はじめてのアルバム』が新しく追加されました。",
  family_group: family
)

puts "✅ Seeding complete!"

