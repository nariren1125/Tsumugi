document.addEventListener("turbo:load", () => {
  const input = document.getElementById("photo-input");
  const preview = document.getElementById("photo-preview");

  if (!input || !preview) return

  input.addEventListener("change", () => {
    preview.innerHTML = "";

  const files = Array.from(input.files).slice(0, 3);

    files.forEach((file) => {
      const wrapper = document.createElement("div");
      wrapper.className = "aspect-square overflow-hidden rounded bg-base-200";

      const img = document.createElement("img");
      img.src = URL.createObjectURL(file);
      img.className = "w-full h-full object-cover";

      wrapper.appendChild(img);
      preview.appendChild(wrapper);
    });
  });
});
