
//Stimulus アプリケーションのエントリーポイント
import { application } from "controllers/application"
//controllers フォルダを自動読み込みするためのヘルパー
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// controllers/**/*_controller.js を自動読み込み
eagerLoadControllersFrom("controllers", application)
