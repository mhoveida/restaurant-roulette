import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "loginTab",
    "signupTab",
    "loginForm",
    "signupForm",
    "loginPassword",
    "signupPassword"
  ]

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
