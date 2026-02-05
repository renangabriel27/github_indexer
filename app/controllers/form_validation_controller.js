// app/javascript/controllers/form_validation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  validateField(event) {
    const field = event.target
    const value = field.value.trim()

    // Remove previous error states
    field.classList.remove('border-red-500', 'focus:ring-red-500/50', 'focus:border-red-500')
    field.classList.add('border-slate-600', 'focus:ring-indigo-500/50', 'focus:border-indigo-500')

    // Validate if empty
    if (!value) {
      this.setFieldError(field, 'Este campo é obrigatório')
      return
    }

    // Validate GitHub URL format
    if (field.name === 'profile[github_url]') {
      const githubUrlPattern = /^https?:\/\/(www\.)?github\.com\/[\w-]+\/?$/
      if (!githubUrlPattern.test(value)) {
        this.setFieldError(field, 'URL do GitHub inválida. Use o formato: https://github.com/username')
        return
      }
    }

    // Clear error if validation passes
    this.clearFieldError(field)
  }

  setFieldError(field, message) {
    field.classList.remove('border-slate-600', 'focus:ring-indigo-500/50', 'focus:border-indigo-500')
    field.classList.add('border-red-500', 'focus:ring-red-500/50', 'focus:border-red-500')

    // Add shake animation
    field.classList.add('animate-shake')
    setTimeout(() => field.classList.remove('animate-shake'), 500)
  }

  clearFieldError(field) {
    field.classList.remove('border-red-500', 'focus:ring-red-500/50', 'focus:border-red-500')
    field.classList.add('border-slate-600', 'focus:ring-indigo-500/50', 'focus:border-indigo-500')
  }
}