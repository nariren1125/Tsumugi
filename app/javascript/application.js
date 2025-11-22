// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
    const flashes = document.querySelectorAll(".flash");
  
    flashes.forEach((flash) => {
      setTimeout(() => {
        flash.classList.add("opacity-0"); // フェードアウト
      }, 3000);
  
      setTimeout(() => {
        flash.remove(); // DOMから削除
      }, 3500);
    });
});