import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "loginTab",
    "signupTab",
    "loginForm",
    "signupForm",
    "loginPassword",
    "signupPassword",
    "signupPasswordConfirmation"
  ]

  connect() {
    this.setupEmailValidation()
  }

  setupEmailValidation() {
    const signupForm = this.signupFormTarget
    const emailField = signupForm?.querySelector('input[type="email"]')
    const validationMessage = signupForm?.querySelector('.validation-message')
    const signupButton = signupForm?.querySelector('button[type="submit"]')

    if (emailField && validationMessage && signupButton) {
      const validateEmail = () => {
        const email = emailField.value.trim()
        const emailValid = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)
        
        if (!emailValid && email !== "") {
          validationMessage.textContent = "Invalid email format"
          validationMessage.style.display = "block"
          signupButton.disabled = true
          signupButton.classList.add('disabled')
        } else {
          validationMessage.textContent = ""
          validationMessage.style.display = "none"
          signupButton.disabled = false
          signupButton.classList.remove('disabled')
        }
      }

      emailField.addEventListener('input', validateEmail)
      emailField.addEventListener('blur', validateEmail)
    }
  }

  switchToLogin() {
    this.loginTabTarget.classList.add("active")
    this.signupTabTarget.classList.remove("active")
    this.loginFormTarget.style.display = "block"
    this.signupFormTarget.style.display = "none"
  }

  switchToSignup() {
    this.loginTabTarget.classList.remove("active")
    this.signupTabTarget.classList.add("active")
    this.loginFormTarget.style.display = "none"
    this.signupFormTarget.style.display = "block"
  }

  toggleLoginPassword(e) {
    this.togglePassword(this.loginPasswordTarget, e)
  }

  toggleSignupPassword(e) {
    this.togglePassword(this.signupPasswordTarget, e)
  }

  toggleSignupPasswordConfirmation(e) {
    this.togglePassword(this.signupPasswordConfirmationTarget, e)
  }

  togglePassword(field, e) {
    if (field.type === "password") {
      field.type = "text"
      e.currentTarget.textContent = "🙈"
    } else {
      field.type = "password"
      e.currentTarget.textContent = "👁️"
    }
  }
}
