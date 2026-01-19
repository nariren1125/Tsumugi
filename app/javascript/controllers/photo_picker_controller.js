// 写真選択コントローラー
import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = [
    "input",
    "form",
    "preview",
    "intro",
    "background",
    "nextButton",
    "dropNotice",
  ]

  static values = { maxFiles: { type: Number, default: 5 } }

  connect() {
    console.log("photo-picker connected")
    this.previewObjectUrls = []
    this.trimmedFiles = []

    // ✅ 最低限の二重実行防止だけ
    this.submitting = false

    // ✅ トーストのタイマーを管理（連続選択でのバグ防止）
    this.dropNoticeTimer = null
    this.dropNoticeFadeTimer = null
  }

  disconnect() {
    // ✅ 画面離脱時に objectURL を解放（メモリ対策）
    this.revokePreviewUrls()
    this.clearDropNoticeTimers()
  }

  openPicker() {
    if (!this.hasInputTarget) return
    this.inputTarget.click()
  }

  // =========================
  // ✅ 選び直す：introに戻して、選択状態もリセット
  // =========================
  reselect() {
    // input を空にして「同じファイルを再選択しても change が発火する」ようにする
    if (this.hasInputTarget) this.inputTarget.value = ""

    // 保持しているファイルもリセット
    this.trimmedFiles = []

    // プレビュー画像URL解放
    this.revokePreviewUrls()

    // UIをintroへ戻す
    if (this.hasPreviewTarget) this.previewTarget.classList.add("hidden")
    if (this.hasIntroTarget) this.introTarget.classList.remove("hidden")
    if (this.hasBackgroundTarget) this.backgroundTarget.classList.remove("hidden")

    // 次へボタンを隠す
    if (this.hasNextButtonTarget) this.nextButtonTarget.classList.add("hidden")

    // トーストも消す
    this.hideDropNotice()

    // ✅ submit状態もリセット
    this.resetSubmitting()
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

    // inputの中身も maxFiles に揃える
    const dt = new DataTransfer()
    trimmedFiles.forEach((file) => dt.items.add(file))
    this.inputTarget.files = dt.files

    // コントローラ内にも保持
    this.trimmedFiles = trimmedFiles

    // dropped_files_count を更新（サーバに送るなら使える）
    const droppedInput = this.formTarget.querySelector('input[name="dropped_files_count"]')
    if (droppedInput) droppedInput.value = droppedCount

    // ローカルプレビュー表示
    this.renderLocalPreview(trimmedFiles)

    // 超過トースト
    if (droppedCount > 0) {
      this.showDropNotice(droppedCount, maxFiles)
    } else {
      this.hideDropNotice()
    }

    // 次へボタン表示
    if (this.hasNextButtonTarget) this.nextButtonTarget.classList.remove("hidden")

    // ✅ 選び直し後にまた押せるように
    this.resetSubmitting()
  }

  // =========================
  // ✅ 次へ：DirectUpload → signed_id詰め → prepare_uploadsへPOST
  // =========================
  async next(event) {
    event?.preventDefault()

    // ✅ 二重実行防止（連打対策）
    if (this.submitting) return
    this.submitting = true
    if (this.hasNextButtonTarget) this.nextButtonTarget.disabled = true

    const files = this.trimmedFiles.length
      ? this.trimmedFiles
      : Array.from(this.inputTarget.files || [])

    if (files.length === 0) {
      this.resetSubmitting()
      return
    }

    console.log(`Next clicked. Uploading ${files.length} file(s)...`)

    try {
      await this.uploadAll(files)
      console.log("All uploads finished. Submitting form...")
      this.formTarget.requestSubmit()
    } catch (e) {
      console.error(e)
      alert("アップロードに失敗しました。通信状況をご確認ください。")
      this.inputTarget.disabled = false
      this.resetSubmitting()
    }
  }

  resetSubmitting() {
    this.submitting = false
    if (this.hasNextButtonTarget) this.nextButtonTarget.disabled = false
  }

  // =========================
  // ローカルプレビュー
  // =========================
  renderLocalPreview(files) {
    if (!this.hasPreviewTarget) return

    // 以前のURLを解放してから描画し直す
    this.revokePreviewUrls()

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
      img.loading = "eager"
      img.decoding = "async"

      box.appendChild(img)
      wrapper.appendChild(box)
      container.appendChild(wrapper)
    })

    // UI切り替え
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
  // ✅ 超過トースト
  // =========================
  showDropNotice(droppedCount, maxFiles) {
    if (!this.hasDropNoticeTarget) return

    this.clearDropNoticeTimers()

    this.dropNoticeTarget.textContent =
      `${droppedCount}枚の写真は追加できませんでした（最大${maxFiles}枚まで）`

    this.dropNoticeTarget.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.dropNoticeTarget.classList.remove("opacity-0")
      this.dropNoticeTarget.classList.add("opacity-100")
    })

    this.dropNoticeFadeTimer = setTimeout(() => {
      this.dropNoticeTarget.classList.remove("opacity-100")
      this.dropNoticeTarget.classList.add("opacity-0")
    }, 2500)

    this.dropNoticeTimer = setTimeout(() => {
      this.dropNoticeTarget.classList.add("hidden")
    }, 3000)
  }

  hideDropNotice() {
    if (!this.hasDropNoticeTarget) return
    this.clearDropNoticeTimers()
    this.dropNoticeTarget.classList.add("hidden")
    this.dropNoticeTarget.classList.remove("opacity-100")
    this.dropNoticeTarget.classList.add("opacity-0")
  }

  clearDropNoticeTimers() {
    if (this.dropNoticeTimer) clearTimeout(this.dropNoticeTimer)
    if (this.dropNoticeFadeTimer) clearTimeout(this.dropNoticeFadeTimer)
    this.dropNoticeTimer = null
    this.dropNoticeFadeTimer = null
  }

  // =========================
  // Direct Upload
  // =========================
  uploadAll(files) {
    const url = this.inputTarget.getAttribute("data-direct-upload-url")
    if (!url) throw new Error("data-direct-upload-url is missing on file input")

    // 既存の hidden signed_id をクリア（再選択時の事故防止）
    this.formTarget
      .querySelectorAll('input[type="hidden"][data-direct-upload-hidden="true"]')
      .forEach((el) => el.remove())

    // confirm側は signed_id を受け取るので input は送信しない（2重送信防止）
    this.inputTarget.disabled = true

    return Promise.all(files.map((file) => this.uploadOne(file, url)))
  }

  uploadOne(file, url) {
    return new Promise((resolve, reject) => {
      const upload = new DirectUpload(file, url)

      upload.create((error, blob) => {
        if (error) return reject(error)

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
}
