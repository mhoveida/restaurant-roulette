import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "loginTab",
    "signupTab",
    "loginForm",
    "signupForm",
    "loginError",
    "signupError",
    "loginPassword",
    "signupPassword"
  ]

  switchToLogin() {
    this.loginTabTarget.classList.add("active")
    this.signupTabTarget.classList.remove("active")
    this.loginFormTarget.style.display = "block"
    this.signupFormTarget.style.display = "none"
    this.loginErrorTarget.style.display = "none"
  }

  switchToSignup() {
    this.loginTabTarget.classList.remove("active")
    this.signupTabTarget.classList.add("active")
    this.loginFormTarget.style.display = "none"
    this.signupFormTarget.style.display = "block"
    this.signupErrorTarget.style.display = "none"
  }

  toggleLoginPassword(e) {
    const field = this.loginPasswordTarget
    if (field.type === "password") {
      field.type = "text"
      e.currentTarget.textContent = "🙈"
    } else {
      field.type = "password"
      e.currentTarget.textContent = "👁️"
    }
  }

  toggleSignupPassword(e) {
    const field = this.signupPasswordTarget
    if (field.type === "password") {
      field.type = "text"
      e.currentTarget.textContent = "🙈"
    } else {
      field.type = "password"
      e.currentTarget.textContent = "👁️"
    }
  }

  submitLogin(e) {
    e.preventDefault()
    this.loginErrorTarget.style.display = "none"

    const form = e.target
    const formData = new FormData(form)

    fetch(form.action, {
      method: 'POST',
      body: formData,
      headers: { 'Accept': 'application/json' },
      credentials: 'same-origin'
    })
    .then(response => {
      if (response.ok) {
        window.location.href = '/'
      } else {
        this.loginErrorTarget.textContent = 'Invalid email or password'
        this.loginErrorTarget.style.display = 'block'
      }
    })
    .catch(() => {
      this.loginErrorTarget.textContent = 'Something went wrong'
      this.loginErrorTarget.style.display = 'block'
    })
  }

  submitSignup(e) {
    e.preventDefault()
    this.signupErrorTarget.style.display = "none"

    const form = e.target
    const formData = new FormData(form)

    fetch(form.action, {
      method: 'POST',
      body: formData,
      headers: { 'Accept': 'application/json' },
      credentials: 'same-origin'
    })
    .then(response => {
      if (response.ok) {
        window.location.href = '/'
      } else {
        this.signupErrorTarget.textContent = 'Missing or invalid credentials'
        this.signupErrorTarget.style.display = 'block'
      }
    })
    .catch(() => {
      this.signupErrorTarget.textContent = 'Something went wrong'
      this.signupErrorTarget.style.display = 'block'
    })
  }
}
