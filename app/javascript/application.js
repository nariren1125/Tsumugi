// Configure your import map in config/importmap.rb.
// Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Turbo読み込み完了時に処理
document.addEventListener("turbo:load", () => {

  // ---------------------------
  // ✅ フラッシュメッセージ自動消去
  // ---------------------------
  const flashes = document.querySelectorAll(".flash");

  flashes.forEach((flash) => {
    setTimeout(() => {
      flash.classList.add("opacity-0"); // フェードアウト
    }, 3000);

    setTimeout(() => {
      flash.remove(); // DOMから削除
    }, 3500);
  });


  // ---------------------------
  // ✅ Swiper 初期化（複数対応）
  // ---------------------------
  document.querySelectorAll(".swiper").forEach((swiperElement) => {
    new Swiper(swiperElement, {
      loop: true,               // ループあり
      pagination: {
        el: ".swiper-pagination",
        clickable: true,
      },
      slidesPerView: 1,         // 1枚ずつ表示
      spaceBetween: 10,         // スライド間の余白
      centeredSlides: true,     // 中央寄せ
    });
  });

});
