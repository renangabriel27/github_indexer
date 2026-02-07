import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["backdrop", "container"]
  static values = {
    id: String
  }

  connect() {
    // Trap focus within modal when open
    this.boundHandleTab = this.handleTab.bind(this)
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener('keydown', this.boundHandleTab)
  }

  open(event) {
    if (event) {
      event.preventDefault()
    }

    this.backdropTarget.classList.remove('hidden')
    this.backdropTarget.classList.add('flex')

    // Enable focus trap
    document.addEventListener('keydown', this.boundHandleTab)

    // Focus first focusable element in modal
    this.focusFirstElement()
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }

    this.backdropTarget.classList.add('hidden')
    this.backdropTarget.classList.remove('flex')

    // Disable focus trap
    document.removeEventListener('keydown', this.boundHandleTab)
  }

  closeOnBackdrop(event) {
    // Only close if clicking the backdrop itself, not its children
    if (event.target === this.backdropTarget) {
      this.close(event)
    }
  }

  handleTab(event) {
    // Focus trap: keep focus within modal
    if (event.key !== 'Tab') return

    const focusableElements = this.containerTarget.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )

    if (focusableElements.length === 0) return

    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]

    if (event.shiftKey) {
      // Shift + Tab: going backwards
      if (document.activeElement === firstElement) {
        event.preventDefault()
        lastElement.focus()
      }
    } else {
      // Tab: going forwards
      if (document.activeElement === lastElement) {
        event.preventDefault()
        firstElement.focus()
      }
    }
  }

  focusFirstElement() {
    const focusableElements = this.containerTarget.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )

    if (focusableElements.length > 0) {
      // Focus the cancel button (usually first) rather than confirm button
      const cancelButton = Array.from(focusableElements).find(el =>
        el.textContent.toLowerCase().includes('cancelar') ||
        el.textContent.toLowerCase().includes('cancel')
      )

      if (cancelButton) {
        cancelButton.focus()
      } else {
        focusableElements[0].focus()
      }
    }
  }
}
