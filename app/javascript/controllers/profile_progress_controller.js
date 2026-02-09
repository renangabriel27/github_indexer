import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["message", "closeButton", "backdrop", "content"]
  static values = {
    profileId: String,
    status: String
  }

  connect() {
    // Auto-open modal if status is pending or processing
    if (this.statusValue === "pending" || this.statusValue === "processing") {
      this.openModal()
      this.subscribeToChannel()

      // Safety check: if no updates received in 3 seconds, check status
      this.safetyCheckTimer = setTimeout(() => {
        this.checkStatusOnce()
      }, 3000)
    }
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.fallbackTimer) {
      clearTimeout(this.fallbackTimer)
    }
    if (this.safetyCheckTimer) {
      clearTimeout(this.safetyCheckTimer)
    }
  }

  openModal() {
    const modal = this.element
    if (modal) {
      modal.style.display = "flex"
      // Add animation classes
      setTimeout(() => {
        if (this.hasBackdropTarget) {
          this.backdropTarget.classList.add('opacity-100')
        }
        if (this.hasContentTarget) {
          this.contentTarget.classList.remove('scale-95')
          this.contentTarget.classList.add('scale-100')
        }
      }, 10)
    }
  }

  close(event) {
    if (event) event.preventDefault()
    this.closeModal()
  }

  closeModal() {
    const modal = this.element
    if (modal) {
      if (this.hasBackdropTarget) {
        this.backdropTarget.classList.remove('opacity-100')
      }
      if (this.hasContentTarget) {
        this.contentTarget.classList.remove('scale-100')
        this.contentTarget.classList.add('scale-95')
      }

      setTimeout(() => {
        modal.style.display = "none"
      }, 300)
    }
  }

  subscribeToChannel() {
    const consumer = createConsumer()

    this.subscription = consumer.subscriptions.create(
      { channel: "ProfileStatusChannel", id: this.profileIdValue },
      {
        received: (data) => {
          this.handleUpdate(data)
        },
        connected: () => {
          // Cancel safety check and fallback if connection succeeds
          if (this.safetyCheckTimer) {
            clearTimeout(this.safetyCheckTimer)
            this.safetyCheckTimer = null
          }
          if (this.fallbackTimer) {
            clearTimeout(this.fallbackTimer)
            this.fallbackTimer = null
          }
        },
        disconnected: () => {
          // Connection lost
        }
      }
    )

    // Fallback to polling if no updates received after 5 seconds
    this.fallbackTimer = setTimeout(() => {
      this.enableFallbackPolling()
    }, 5000)
  }

  handleUpdate(data) {
    // Cancel timers since we're receiving updates
    if (this.fallbackTimer) {
      clearTimeout(this.fallbackTimer)
      this.fallbackTimer = null
    }
    if (this.safetyCheckTimer) {
      clearTimeout(this.safetyCheckTimer)
      this.safetyCheckTimer = null
    }

    switch (data.action) {
      case "update_status":
        this.updateMessage(data.message)
        break
      case "completed":
        this.handleCompletion(data)
        break
      case "failed":
        this.handleError(data)
        break
    }
  }

  async checkStatusOnce() {
    try {
      const response = await fetch(`/profiles/${this.profileIdValue}/status`, {
        headers: { 'Accept': 'application/json' }
      })

      if (response.ok) {
        const data = await response.json()

        if (data.status === 'completed') {
          // Job already completed, close modal and reload
          this.closeModal()
          setTimeout(() => {
            window.location.reload()
          }, 500)
        } else if (data.status === 'failed') {
          this.handleError({ message: data.message || 'Erro ao atualizar perfil' })
        } else {
          // Still processing, enable fallback polling
          this.enableFallbackPolling()
        }
      }
    } catch (error) {
      // Enable fallback polling on error
      this.enableFallbackPolling()
    }
  }

  updateMessage(message) {
    if (this.hasMessageTarget) {
      this.messageTarget.textContent = message
    }
  }

  handleCompletion(data) {
    this.updateMessage(data.message)

    // Show success state briefly, then close modal and reload
    setTimeout(() => {
      this.closeModal()

      // Show success flash message
      this.showSuccessFlash(data.message)

      // Reload the page to show updated data
      setTimeout(() => {
        window.location.reload()
      }, 500)
    }, 1500)
  }

  handleError(data) {
    this.updateMessage(data.message)

    // Show close button on error
    if (this.hasCloseButtonTarget) {
      this.closeButtonTarget.classList.remove('hidden')
    }

    // Show error flash
    this.showErrorFlash(data.error || data.message)

    // Auto-close modal after 5 seconds on error
    setTimeout(() => {
      this.closeModal()
    }, 5000)
  }

  showSuccessFlash(message) {
    const flashContainer = document.querySelector('[data-controller="flash"]') ||
                          this.createFlashContainer()

    const flash = this.createFlashElement(message, 'success')
    flashContainer.appendChild(flash)

    // Trigger flash controller's auto-dismiss
    setTimeout(() => flash.remove(), 5000)
  }

  showErrorFlash(message) {
    const flashContainer = document.querySelector('[data-controller="flash"]') ||
                          this.createFlashContainer()

    const flash = this.createFlashElement(message, 'error')
    flashContainer.appendChild(flash)

    setTimeout(() => flash.remove(), 7000)
  }

  createFlashContainer() {
    const container = document.createElement('div')
    container.setAttribute('data-controller', 'flash')
    container.className = 'fixed top-4 right-4 z-50'
    document.body.appendChild(container)
    return container
  }

  createFlashElement(message, type) {
    const flash = document.createElement('div')
    const bgColor = type === 'success' ? 'bg-green-500/10 border-green-500/30' : 'bg-red-500/10 border-red-500/30'
    const textColor = type === 'success' ? 'text-green-400' : 'text-red-400'

    flash.className = `${bgColor} border rounded-xl p-4 mb-3 flex items-center gap-3 min-w-80 shadow-lg animate-slide-in`
    flash.innerHTML = `
      <svg class="w-5 h-5 ${textColor} flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        ${type === 'success'
          ? '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>'
          : '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>'
        }
      </svg>
      <span class="${textColor} font-medium flex-1">${message}</span>
    `
    return flash
  }

  enableFallbackPolling() {
    // Lightweight polling - only check status, don't fetch full profile
    this.pollingInterval = setInterval(async () => {
      try {
        const response = await fetch(`/profiles/${this.profileIdValue}/status`, {
          headers: { 'Accept': 'application/json' }
        })

        if (response.ok) {
          const data = await response.json()

          if (data.status === 'completed') {
            clearInterval(this.pollingInterval)
            this.handleCompletion({ message: data.message || 'Perfil atualizado com sucesso!' })
          } else if (data.status === 'failed') {
            clearInterval(this.pollingInterval)
            this.handleError({ message: data.message || 'Erro ao atualizar perfil' })
          }
        }
      } catch (error) {
        // Polling error, will retry on next interval
      }
    }, 3000) // Poll every 3 seconds
  }
}
