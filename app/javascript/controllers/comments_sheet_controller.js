import { Controller } from "@hotwired/stimulus"

// comments-sheet controller
// - documentイベント（comments:open/close）で開閉（既存設計維持）
// - ドラッグ開始はヘッダー(handle)のみ（スクロール干渉回避）
// - 距離 + 速度（勢い）で「閉じる判定」を行う（Instagramっぽい）
// - backdrop opacity をドラッグ量に連動
export default class extends Controller {
    static targets = ["panel", "backdrop", "handle"]

    connect() {
        // ---- 多重生成ガード（念のため） ----
        const count = document.querySelectorAll("[data-controller~='comments-sheet']").length
        if (count !== 1) console.warn(`[comments-sheet] controller count = ${count}`)

        // ---- documentイベント方式を維持 ----
        this.onOpen = (e) => {
            console.log("[comments-sheet] open", e?.detail)
            this.open()
        }
        this.onClose = () => this.close()
        document.addEventListener("comments:open", this.onOpen)
        document.addEventListener("comments:close", this.onClose)

        // ---- drag state ----
        this.dragging = false
        this.startY = 0
        this.currentY = 0

        // 「最低これ以上引っ張ったら閉じる」固定しきい値（px）
        this.baseThresholdPx = 120

        // 「勢いで閉じる」判定の最低距離（px）
        this.minFlingDistancePx = 40

        // 「勢いで閉じる」判定の最低速度（px/ms）
        // 0.9px/ms ≒ 900px/s（体感で "シュッ" と下に払うと発火）
        this.flingVelocityThreshold = 0.9

        // ---- 速度計算用（最後の移動） ----
        this.lastMoveY = 0
        this.lastMoveTime = 0
        this.velocity = 0

        // ---- rAF 最適化（ヌルヌル化） ----
        this.rafId = null
        this.pendingY = 0
    }

    disconnect() {
        document.removeEventListener("comments:open", this.onOpen)
        document.removeEventListener("comments:close", this.onClose)
        if (this.rafId) cancelAnimationFrame(this.rafId)
    }

    // =========================
    // Open / Close（既存挙動維持）
    // =========================
    open() {
        this.element.classList.remove("hidden")
        this.element.classList.add("is-open")
        this.resetDragStyles()
    }

    close() {
        this.element.classList.remove("is-open")
        this.element.classList.add("hidden")
        this.resetDragStyles()
    }

    // =========================
    // Drag to close
    // =========================
    startDrag(e) {
        // 右クリックは無視
        if (e.pointerType === "mouse" && e.button !== 0) return
        if (this.element.classList.contains("hidden")) return
        if (!this.hasPanelTarget || !this.hasBackdropTarget) return

        this.dragging = true
        this.startY = e.clientY
        this.currentY = 0
        this.pendingY = 0

        // 速度計算初期化
        const now = performance.now()
        this.lastMoveY = 0
        this.lastMoveTime = now
        this.velocity = 0

        // ドラッグ中は追従優先（transitionを切る）
        this.panelTarget.style.transition = "none"
        this.backdropTarget.style.transition = "none"

        // ヘッダー外に出ても追従
        try {
            e.currentTarget.setPointerCapture(e.pointerId)
        } catch (_) { }

        e.preventDefault?.()
    }

    onDrag(e) {
        if (!this.dragging) return
        if (!this.hasPanelTarget || !this.hasBackdropTarget) return

        const dy = e.clientY - this.startY
        const y = Math.max(0, dy)
        this.pendingY = y

        // ---- 速度（最後の移動量/時間）を更新 ----
        // ※ endDrag で最終的な velocity を使う
        const now = performance.now()
        const dt = now - this.lastMoveTime
        if (dt > 0) {
            const dySinceLast = y - this.lastMoveY
            this.velocity = dySinceLast / dt // px/ms
            this.lastMoveY = y
            this.lastMoveTime = now
        }

        // rAFで描画をまとめて滑らかに
        if (this.rafId) return
        this.rafId = requestAnimationFrame(() => {
            this.rafId = null
            this.currentY = this.pendingY
            this.applyDragStyles(this.currentY)
        })
    }

    endDrag() {
        if (!this.dragging) return
        this.dragging = false
        if (!this.hasPanelTarget || !this.hasBackdropTarget) return

        // 指を離したらアニメ復活
        this.panelTarget.style.transition = "transform 180ms ease"
        this.backdropTarget.style.transition = "opacity 180ms ease"

        // ---- 「距離」しきい値：パネル高さに応じて動的にする ----
        // 例: 120px と "パネル高さの55%" の小さい方を採用
        // → 画面が大きい端末でも自然、かつ極端に厳しくならない
        const panelHeight = this.panelTarget.getBoundingClientRect().height || 0
        const distanceThreshold = Math.min(this.baseThresholdPx, panelHeight * 0.55)

        // ---- 「勢い（フリック）」判定 ----
        // velocity は最後の移動の速度なので、終端の "シュッ" に反応しやすい
        const isFling =
            this.velocity >= this.flingVelocityThreshold &&
            this.currentY >= this.minFlingDistancePx

        // ---- close条件：距離 or 勢い ----
        if (this.currentY >= distanceThreshold || isFling) {
            this.close()
            return
        }

        // 閾値未満はスナップバック
        this.resetDragStyles()
    }

    // =========================
    // Helpers
    // =========================
    applyDragStyles(y) {
        this.panelTarget.style.transform = `translateY(${y}px)`

        // backdrop は 0.6 -> 0 へ（bg-black/60 前提）
        const progress = Math.min(1, y / this.baseThresholdPx)
        const opacity = 0.6 * (1 - progress)
        this.backdropTarget.style.opacity = String(opacity)
    }

    resetDragStyles() {
        if (this.hasPanelTarget) {
            this.panelTarget.style.transform = "translateY(0px)"
            this.panelTarget.style.transition = ""
        }
        if (this.hasBackdropTarget) {
            this.backdropTarget.style.opacity = ""
            this.backdropTarget.style.transition = ""
        }

        this.startY = 0
        this.currentY = 0
        this.pendingY = 0
        this.lastMoveY = 0
        this.lastMoveTime = 0
        this.velocity = 0
    }
}
