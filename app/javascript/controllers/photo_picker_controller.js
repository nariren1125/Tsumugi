// 写真選択コントローラー
import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  // ✅ actions を追加できるなら追加推奨（後述）
  static targets = ["input", "form", "preview", "intro", "background", "nextButton"]
  static values = { maxFiles: { type: Number, default: 5 } }

  connect() {
    console.log("photo-picker connected")

    // ローカルプレビュー用のURL（離脱時に解放）
    this.previewObjectUrls = []

    // 選択済み（最大枚数にトリミング済み）の File 配列
    this.trimmedFiles = []
  }

  disconnect() {
    // ✅ 画面離脱時に objectURL を解放（メモリ対策）
    this.revokePreviewUrls()
  }

  // -------------------------
  // UI: ファイル選択を開く
  // -------------------------
  openPicker() {
    if (!this.hasInputTarget) return
    this.inputTarget.click()
  }

  // -------------------------
  // UI: 選び直す（preview -> introへ戻す）
  // -------------------------
  reselect() {
    // 1) 画面切替（introに戻す）
    if (this.hasPreviewTarget) this.previewTarget.classList.add("hidden")
    if (this.hasIntroTarget) this.introTarget.classList.remove("hidden")
    if (this.hasBackgroundTarget) this.backgroundTarget.classList.remove("hidden")

    // 2) 次へボタンを隠す（ビュー側で hidden 運用ならここで確実に閉じる）
    if (this.hasNextButtonTarget) this.nextButtonTarget.classList.add("hidden")

    // 3) 送信事故防止：hidden signed_id を消す
    this.clearHiddenSignedIds()

    // 4) input を再選択できる状態に戻す（uploadAllでdisabled=trueにするので戻すのが重要）
    if (this.hasInputTarget) this.inputTarget.disabled = false

    // 5) プレビューURLを解放して、選択状態もクリア
    this.revokePreviewUrls()
    this.trimmedFiles = []
    if (this.hasInputTarget) this.inputTarget.value = ""
  }

  // =========================
  // ✅ 写真選択時：ローカルプレビュー表示だけ（遷移しない）
  // =========================
  handleFiles() {
    const maxFiles = this.maxFilesValue
    const files = Array.from(this.inputTarget.files || [])
    if (files.length === 0) return

    // 超過分をカット（最初の maxFiles 枚を固定）
    let trimmedFiles = files
    let droppedCount = 0

    if (files.length > maxFiles) {
      trimmedFiles = files.slice(0, maxFiles)
      droppedCount = files.length - maxFiles
    }

    // inputの中身も maxFiles に揃える（次へでも同じfilesを使える）
    const dt = new DataTransfer()
    trimmedFiles.forEach((file) => dt.items.add(file))
    this.inputTarget.files = dt.files

    // コントローラ内にも保持（次へで使う）
    this.trimmedFiles = trimmedFiles

    // dropped_files_count を更新
    const droppedInput = this.formTarget.querySelector('input[name="dropped_files_count"]')
    if (droppedInput) droppedInput.value = droppedCount

    // ✅ ローカルプレビュー表示（S3待ちゼロ）
    this.renderLocalPreview(trimmedFiles)

    // ✅ 次へボタン表示（ビュー側で hidden 運用の場合に必要）
    if (this.hasNextButtonTarget) this.nextButtonTarget.classList.remove("hidden")
  }

  // =========================
  // ✅ 次へ：ここで DirectUpload → signed_id 詰め → prepare_uploadsへPOST
  // =========================
  async next() {
    const files = this.trimmedFiles.length
      ? this.trimmedFiles
      : Array.from(this.inputTarget.files || [])

    if (files.length === 0) return

    console.log(`Next clicked. Uploading ${files.length} file(s)...`)

    try {
      await this.uploadAll(files)

      console.log("All uploads finished. Submitting form...")
      this.formTarget.requestSubmit()
    } catch (e) {
      console.error(e)
      alert("アップロードに失敗しました。通信状況をご確認ください。")

      // 失敗時は input を戻して再挑戦できるようにする
      this.inputTarget.disabled = false
    }
  }

  // =========================
  // ローカルプレビュー
  // =========================
  renderLocalPreview(files) {
    if (!this.hasPreviewTarget) return

    // 以前のURLを解放してから描画し直す（再選択対応）
    this.revokePreviewUrls()

    // ✅ controller が .flex を探す前提なので、受け皿は必須
    const container = this.previewTarget.querySelector(".flex")
    if (!container) return
    container.innerHTML = ""

    files.forEach((file) => {
      const url = URL.createObjectURL(file)
      this.previewObjectUrls.push(url)

      const wrapper = document.createElement("div")
      wrapper.className = "min-w-full snap-center flex justify-center"

      const box = document.createElement("div")
      box.className = "aspect-square w-full bg-base-200 rounded-xl overflow-hidden"

      const img = document.createElement("img")
      img.src = url
      img.alt = ""
      img.className = "w-full h-full object-cover"
      img.loading = "eager" // ローカルなので即表示優先
      img.decoding = "async"

      box.appendChild(img)
      wrapper.appendChild(box)
      container.appendChild(wrapper)
    })

    // ✅ UI切り替え（intro -> preview）
    this.previewTarget.classList.remove("hidden")
    if (this.hasIntroTarget) this.introTarget.classList.add("hidden")
    if (this.hasBackgroundTarget) this.backgroundTarget.classList.add("hidden")
  }

  revokePreviewUrls() {
    if (!this.previewObjectUrls) this.previewObjectUrls = []
    this.previewObjectUrls.forEach((url) => URL.revokeObjectURL(url))
    this.previewObjectUrls = []
  }

  // =========================
  // Direct Upload
  // =========================
  uploadAll(files) {
    const url = this.inputTarget.getAttribute("data-direct-upload-url")
    if (!url) throw new Error("data-direct-upload-url is missing on file input")

    // 既存の hidden signed_id をクリア（再選択時の事故防止）
    this.clearHiddenSignedIds()

    // ✅ signed_id を送るので input は送信しない（2重送信防止）
    this.inputTarget.disabled = true

    // すべてアップロード（並列）
    return Promise.all(files.map((file) => this.uploadOne(file, url)))
  }

  uploadOne(file, url) {
    return new Promise((resolve, reject) => {
      const upload = new DirectUpload(file, url)

      upload.create((error, blob) => {
        if (error) return reject(error)

        // ✅ 元の input name で signed_id を送る
        const hiddenField = document.createElement("input")
        hiddenField.type = "hidden"
        hiddenField.name = this.inputTarget.name
        hiddenField.value = blob.signed_id
        hiddenField.setAttribute("data-direct-upload-hidden", "true")

        this.formTarget.appendChild(hiddenField)
        resolve(blob)
      })
    })
  }

  // -------------------------
  // helper: hidden signed_id を全削除
  // -------------------------
  clearHiddenSignedIds() {
    if (!this.hasFormTarget) return

    this.formTarget
      .querySelectorAll('input[type="hidden"][data-direct-upload-hidden="true"]')
      .forEach((el) => el.remove())
  }
}
