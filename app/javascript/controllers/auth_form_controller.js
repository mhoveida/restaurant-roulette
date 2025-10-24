import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auth-form"
export default class extends Controller {
  static targets = [
    "loginTab",
    "signupTab",
    "loginForm",
    "signupForm",
    "loginEmail",
    "loginPassword",
    "loginEmailError",
    "loginPasswordError",
    "firstName",
    "lastName",
    "signupEmail",
    "signupPassword",
    "firstNameError",
    "lastNameError",
    "signupEmailError",
    "signupPasswordError",
    "loginButton",
    "signupButton"
  ]

  connect() {
    this.clearForms()
  }

  switchToLogin() {
    this.loginTabTarget.classList.add("active")
    this.signupTabTarget.classList.remove("active")
    this.loginFormTarget.style.display = "block"
    this.signupFormTarget.style.display = "none"
    this.clearSignupErrors()
  }

  switchToSignup() {
    this.loginTabTarget.classList.remove("active")
    this.signupTabTarget.classList.add("active")
    this.loginFormTarget.style.display = "none"
    this.signupFormTarget.style.display = "block"
    this.clearLoginErrors()
  }

  toggleLoginPassword() {
    const field = this.loginPasswordTarget
    const button = event.currentTarget

    if (field.type === "password") {
      field.type = "text"
      button.textContent = "🙈"
    } else {
      field.type = "password"
      button.textContent = "👁️"
    }
  }

  toggleSignupPassword() {
    const field = this.signupPasswordTarget
    const button = event.currentTarget

    if (field.type === "password") {
      field.type = "text"
      button.textContent = "🙈"
    } else {
      field.type = "password"
      button.textContent = "👁️"
    }
  }

  clearForms() {
    this.clearLoginErrors()
    this.clearSignupErrors()
  }

  clearLoginErrors() {
    this.hideError("loginEmailError")
    this.hideError("loginPasswordError")
  }

  clearSignupErrors() {
    this.hideError("firstNameError")
    this.hideError("lastNameError")
    this.hideError("signupEmailError")
    this.hideError("signupPasswordError")
  }

  hideError(targetName) {
    try {
      this[`${targetName}Target`].style.display = "none"
    } catch (e) {
      // Target doesn't exist, skip
    }
  }
}
