import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "container"]
  static values = {
    id: String
  }

  connect() {
    this.boundHandleTab = this.handleTab.bind(this)
  }

  getBackdrop() {
    if (this._portaledBackdrop) {
      return this._portaledBackdrop
    }
    return this.element.querySelector('[data-modal-target="backdrop"]')
  }

  getContainer() {
    return this.element.querySelector('[data-modal-target="container"]')
  }

  portalModal() {
    const backdrop = this.getBackdrop()
    if (!backdrop || backdrop.hasAttribute('data-portaled')) return

    document.body.appendChild(backdrop)
    backdrop.setAttribute('data-portaled', 'true')

    this._portaledBackdrop = backdrop
    this.setupPortaledListeners(backdrop)
  }

  setupPortaledListeners(backdrop) {
    const closeButtons = backdrop.querySelectorAll('[data-action*="modal#close"]')

    closeButtons.forEach(button => {
      if (!button._modalCloseHandler) {
        button._modalCloseHandler = (e) => this.close(e)
        button.addEventListener('click', button._modalCloseHandler)
      }
    })

    if (!backdrop._modalBackdropHandler) {
      backdrop._modalBackdropHandler = (e) => this.closeOnBackdrop(e)
      backdrop.addEventListener('click', backdrop._modalBackdropHandler)
    }

    if (!this._escKeyHandler) {
      this._escKeyHandler = (e) => {
        if (e.key === 'Escape') {
          const backdrop = this.getBackdrop()
          if (backdrop && !backdrop.classList.contains('hidden')) {
            this.close(e)
          }
        }
      }
      window.addEventListener('keydown', this._escKeyHandler)
    }
  }

  disconnect() {
    const backdrop = this.getBackdrop()
    if (backdrop && backdrop.hasAttribute('data-portaled')) {
      this.cleanupPortaledListeners(backdrop)
      backdrop.remove()
      this._portaledBackdrop = null
    }

    document.removeEventListener('keydown', this.boundHandleTab)
  }

  cleanupPortaledListeners(backdrop) {
    const closeButtons = backdrop.querySelectorAll('[data-action*="modal#close"]')
    closeButtons.forEach(button => {
      if (button._modalCloseHandler) {
        button.removeEventListener('click', button._modalCloseHandler)
        delete button._modalCloseHandler
      }
    })

    if (backdrop._modalBackdropHandler) {
      backdrop.removeEventListener('click', backdrop._modalBackdropHandler)
      delete backdrop._modalBackdropHandler
    }

    if (this._escKeyHandler) {
      window.removeEventListener('keydown', this._escKeyHandler)
      delete this._escKeyHandler
    }
  }

  open(event) {
    if (event) event.preventDefault()

    const backdrop = this.getBackdrop()
    if (!backdrop) return

    this.portalModal()

    backdrop.classList.remove('hidden')
    backdrop.classList.add('flex')

    document.addEventListener('keydown', this.boundHandleTab)
    this.focusFirstElement()
  }

  close(event) {
    if (event) event.preventDefault()

    const backdrop = this.getBackdrop()
    if (!backdrop) return

    backdrop.classList.add('hidden')
    backdrop.classList.remove('flex')

    document.removeEventListener('keydown', this.boundHandleTab)
  }

  closeOnBackdrop(event) {
    const backdrop = this.getBackdrop()
    if (backdrop && event.target === backdrop) {
      this.close(event)
    }
  }

  handleTab(event) {
    if (event.key !== 'Tab') return

    const container = this.getContainer()
    if (!container) return

    const focusableElements = container.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )

    if (focusableElements.length === 0) return

    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]

    if (event.shiftKey) {
      if (document.activeElement === firstElement) {
        event.preventDefault()
        lastElement.focus()
      }
    } else {
      if (document.activeElement === lastElement) {
        event.preventDefault()
        firstElement.focus()
      }
    }
  }

  focusFirstElement() {
    const container = this.getContainer()
    if (!container) return

    const focusableElements = container.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )

    if (focusableElements.length > 0) {
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
