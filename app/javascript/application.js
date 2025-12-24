// Importmap 用の設定（Rails 7 の標準構成）
import "@hotwired/turbo-rails"
import "controllers"

// ✅ Turbo 読み込み完了後に実行
document.addEventListener("turbo:load", () => {
  // ---------------------------
  // ✅ フラッシュメッセージ自動消去
  // ---------------------------
  const flashes = document.querySelectorAll(".flash");
  flashes.forEach((flash) => {
    setTimeout(() => flash.classList.add("opacity-0"), 3000); // フェードアウト
    setTimeout(() => flash.remove(), 3500);                   // DOMから削除
  })
})