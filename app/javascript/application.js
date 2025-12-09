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
  });

  // ---------------------------
  // ✅ Swiper 初期化（複数対応）
  // ---------------------------
  document.querySelectorAll(".swiper").forEach((swiperElement) => {
    const slideCount = swiperElement.querySelectorAll(".swiper-slide").length;

    new Swiper(swiperElement, {
      loop: slideCount > 1, // スライドが2枚以上のときだけループ
      pagination: {
        el: ".swiper-pagination",
        clickable: true,
      },
      slidesPerView: 1,
      spaceBetween: 10,
      centeredSlides: true,
    });
  });
});
