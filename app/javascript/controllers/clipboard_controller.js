import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  copy(event) {
    const text = event.currentTarget.dataset.clipboardText
    navigator.clipboard.writeText(text)

    const btn = event.currentTarget
    const original = btn.innerHTML
    btn.innerHTML = "✓ Copiado!"
    setTimeout(() => btn.innerHTML = original, 2000)
  }
}