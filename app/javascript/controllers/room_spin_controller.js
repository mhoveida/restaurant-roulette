import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "wheel",
    "countdown",
    "membersList",
    "waitingSection",
    "spinningSection",
    "revealSection",
    "votingSection"
  ]

  static values = {
    roomId: String,
    currentMemberId: String,
    isRoomCreator: Boolean
  }

  connect() {
    this.roomId = this.element.dataset.roomId
    this.roomCode = this.element.dataset.roomCode
    this.currentMemberId = this.element.dataset.currentMemberId
    this.isRoomCreator = this.element.dataset.isRoomCreator === "true"
    this.myVote = null

    if (this.hasWheelTarget) {
      this.drawWheel()
    }
    
    this.subscribeToRoom()
    this.startStatusPolling()
  }

  drawWheel() {
    if (!this.hasWheelTarget) return
    
    const canvas = this.wheelTarget
    const ctx = canvas.getContext("2d")
    const radius = canvas.width / 2
    const colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F"]

    const slices = 6
    const sliceAngle = (Math.PI * 2) / slices

    ctx.clearRect(0, 0, canvas.width, canvas.height)

    for (let i = 0; i < slices; i++) {
      ctx.beginPath()
      ctx.arc(radius, radius, radius * 0.8, i * sliceAngle, (i + 1) * sliceAngle)
      ctx.lineTo(radius, radius)
      ctx.closePath()
      ctx.fillStyle = colors[i]
      ctx.fill()
      ctx.strokeStyle = "#2B2B2B"
      ctx.lineWidth = 2
      ctx.stroke()
    }

    ctx.beginPath()
    ctx.arc(radius, radius, radius * 0.15, 0, Math.PI * 2)
    ctx.fillStyle = "#FEE440"
    ctx.fill()
    ctx.strokeStyle = "#2B2B2B"
    ctx.lineWidth = 2
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo(radius, 0)
    ctx.lineTo(radius - 10, 20)
    ctx.lineTo(radius + 10, 20)
    ctx.closePath()
    ctx.fillStyle = "#FEE440"
    ctx.fill()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval)
    }
  }

  subscribeToRoom() {
    if (typeof App === 'undefined' || !App.cable) {
      return
    }

    this.subscription = App.cable.subscriptions.create(
      { channel: "RoomChannel", room_id: this.roomId },
      {
        received: (data) => {
          this.handleBroadcast(data)
        }
      }
    )
  }

  handleBroadcast(data) {
    switch(data.type) {
      case "spinning_started":
        this.onSpinningStarted(data)
        break
      case "turn_changed":
        this.onTurnChanged(data)
        break
      case "round_complete":
        this.onRoundComplete(data)
        break
      case "reveal_options":
        this.onRevealOptions(data)
        break
      case "vote_update":
        this.onVoteUpdate(data)
        break
      case "voting_complete":
        this.onVotingComplete(data)
        break
    }
  }

  startStatusPolling() {
    this.lastKnownState = this.element.dataset.roomState
    
    this.pollingInterval = setInterval(() => {
      this.fetchStatus()
    }, 2000)
  }

  async fetchStatus() {
    try {
      const response = await fetch(`/rooms/${this.roomId}/status`)
      if (!response.ok) return
      
      const data = await response.json()
      
      if (!this.lastKnownState) {
        this.lastKnownState = data.state
        this.lastKnownTurnIndex = data.current_turn?.turn_index || 0
        this.lastKnownVoteCount = data.votes_count || 0
        return
      }
      
      if (data.state !== this.lastKnownState) {
        window.location.reload()
        return
      }
      
      if (data.state === 'spinning' && data.current_turn) {
        const newTurnIndex = data.current_turn.turn_index || 0
        if (newTurnIndex !== this.lastKnownTurnIndex) {
          this.lastKnownTurnIndex = newTurnIndex
          window.location.reload()
          return
        }
      }
      
      if (data.state === 'voting') {
        const newVoteCount = data.votes_count || 0
        if (newVoteCount !== this.lastKnownVoteCount) {
          this.lastKnownVoteCount = newVoteCount
          this.updateVoteCountsFromStatus(data)
        }
      }
      
      if (data.state === 'waiting' && data.members) {
        const currentMemberCount = document.querySelectorAll('.member-item').length
        if (data.members.length !== currentMemberCount) {
          window.location.reload()
          return
        }
      }
      
    } catch (error) {
      // Silent fail
    }
  }

  updateVoteCountsFromStatus(statusData) {
    const voteCounts = statusData.vote_counts_by_option || {}
    
    document.querySelectorAll('.voting-option').forEach((option) => {
      const optionIndex = parseInt(option.dataset.optionIndex)
      const count = voteCounts[optionIndex] || 0
      
      const voteCountElement = option.querySelector('.vote-count')
      if (voteCountElement) {
        voteCountElement.textContent = `${count} ${count === 1 ? 'vote' : 'votes'}`
      }
    })
  }

  async startSpinning(event) {
    event.preventDefault()

    try {
      const response = await fetch(`/rooms/${this.roomId}/start_spinning`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCsrfToken()
        }
      })

      const data = await response.json()

      if (data.success) {
        window.location.reload()
      }
    } catch (error) {
      // Silent fail
    }
  }

  async spin(event) {
    event.preventDefault()
    
    const button = event.target
    button.disabled = true

    try {
      if (this.hasWheelTarget) {
        this.wheelTarget.classList.add('spinning')
      }

      const response = await fetch(`/rooms/${this.roomId}/spin`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCsrfToken()
        }
      })

      const data = await response.json()

      if (data.success) {
        const spinDuration = 2000 + Math.random() * 1000
        
        setTimeout(() => {
          if (this.hasWheelTarget) {
            this.wheelTarget.classList.remove('spinning')
          }
          window.location.reload()
        }, spinDuration)
      } else {
        button.disabled = false
        if (this.hasWheelTarget) {
          this.wheelTarget.classList.remove('spinning')
        }
      }
    } catch (error) {
      button.disabled = false
      if (this.hasWheelTarget) {
        this.wheelTarget.classList.remove('spinning')
      }
    }
  }

  async reveal(event) {
    event.preventDefault()

    if (this.hasCountdownTarget) {
      let count = 3
      const countdownInterval = setInterval(() => {
        this.countdownTarget.textContent = count
        count--
        if (count < 0) {
          clearInterval(countdownInterval)
        }
      }, 1000)
    }

    await new Promise(resolve => setTimeout(resolve, 3000))

    try {
      const response = await fetch(`/rooms/${this.roomId}/reveal`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCsrfToken()
        }
      })

      const data = await response.json()

      if (data.success) {
        window.location.reload()
      }
    } catch (error) {
      // Silent fail
    }
  }

  async voteForOption(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const optionIndex = parseInt(event.currentTarget.dataset.optionIndex)
    const clickedElement = event.currentTarget
    
    try {
      const csrfToken = document.querySelector('[name="csrf-token"]')?.content || 
                      document.querySelector('meta[name="csrf-token"]')?.content
      
      if (!csrfToken) return
      
      const response = await fetch(`/rooms/${this.roomId}/vote`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({ option_index: optionIndex })
      })
      
      if (!response.ok) return
      
      const data = await response.json()
      
      if (data.success) {
        document.querySelectorAll('.voting-option').forEach(opt => {
          opt.classList.remove('selected-vote')
        })
        
        clickedElement.classList.add('selected-vote')
        this.showConfirmVoteButton()
      }
    } catch (error) {
      // Silent fail
    }
  }

  showConfirmVoteButton() {
    let confirmBtn = document.getElementById('confirmVoteBtn')
    
    if (!confirmBtn) {
      const votingSection = document.querySelector('.voting-section')
      confirmBtn = document.createElement('button')
      confirmBtn.id = 'confirmVoteBtn'
      confirmBtn.className = 'button button-primary'
      confirmBtn.textContent = 'Confirm My Vote'
      confirmBtn.style.cssText = 'width: 100%; max-width: 400px; margin: 2rem auto; display: block; padding: 1rem; font-size: 1.1rem;'
      confirmBtn.onclick = () => this.confirmVote()
      votingSection.appendChild(confirmBtn)
    }
    
    confirmBtn.style.display = 'block'
  }

  async confirmVote() {
    try {
      const response = await fetch(`/rooms/${this.roomId}/confirm_vote`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      
      const data = await response.json()
      
      if (data.success) {
        const confirmBtn = document.getElementById('confirmVoteBtn')
        if (confirmBtn) {
          confirmBtn.textContent = 'Vote Confirmed!'
          confirmBtn.disabled = true
          confirmBtn.style.backgroundColor = '#22c55e'
        }
        
        document.querySelectorAll('.voting-option').forEach(opt => {
          opt.style.pointerEvents = 'none'
          opt.style.opacity = '0.6'
        })
        
        this.updateVoteCountsFromServer()
      }
    } catch (error) {
      // Silent fail
    }
  }

  async updateVoteCountsFromServer() {
    try {
      const response = await fetch(`/rooms/${this.roomId}/status`)
      if (!response.ok) return
      
      const data = await response.json()
      
      if (data.state === 'voting') {
        this.updateVoteCountDisplay(data)
      } else if (data.state === 'complete') {
        window.location.reload()
      }
    } catch (error) {
      // Silent fail
    }
  }

  updateVoteCountDisplay(statusData) {
    const voteCounts = {}
    
    if (statusData.votes_count) {
      document.querySelectorAll('.voting-option').forEach((option, index) => {
        const optionIndex = parseInt(option.dataset.optionIndex)
        
        const voteCountElement = option.querySelector('.vote-count')
        if (voteCountElement && voteCounts[optionIndex] !== undefined) {
          voteCountElement.textContent = `${voteCounts[optionIndex]} ${voteCounts[optionIndex] === 1 ? 'vote' : 'votes'}`
        }
      })
    }
  }

  updateVoteCounts(voteCounts) {
    Object.keys(voteCounts).forEach(optionIndex => {
      const count = voteCounts[optionIndex]
      const optionElement = document.querySelector(`[data-option-index="${optionIndex}"]`)
      if (optionElement) {
        const voteCountElement = optionElement.querySelector('.vote-count')
        if (voteCountElement) {
          voteCountElement.textContent = `${count} ${count === 1 ? 'vote' : 'votes'}`
        }
      }
    })
  }

  async thumbsUp(event) {
    event.stopPropagation()
    const button = event.currentTarget
    button.style.backgroundColor = 'rgba(34, 197, 94, 0.3)'
    
    setTimeout(() => {
      button.style.backgroundColor = 'rgba(34, 197, 94, 0.1)'
    }, 500)
  }

  async thumbsDown(event) {
    event.stopPropagation()
    const button = event.currentTarget
    button.style.backgroundColor = 'rgba(239, 68, 68, 0.3)'
    
    setTimeout(() => {
      button.style.backgroundColor = 'rgba(239, 68, 68, 0.1)'
    }, 500)
  }

  onSpinningStarted(data) {
    window.location.reload()
  }

  onTurnChanged(data) {
    const currentTurnElements = document.querySelectorAll('.turn-item')
    currentTurnElements.forEach((el, index) => {
      if (index === data.turn_index) {
        el.classList.add('current-turn')
        el.classList.remove('completed-turn')
      } else if (index < data.turn_index) {
        el.classList.add('completed-turn')
        el.classList.remove('current-turn')
      } else {
        el.classList.remove('current-turn', 'completed-turn')
      }
    })
  }

  onRoundComplete(data) {
    window.location.reload()
  }

  onRevealOptions(data) {
    window.location.reload()
  }

  onVoteUpdate(data) {
    this.updateVoteCounts(data.vote_counts)
  }

  onVotingComplete(data) {
    setTimeout(() => {
      window.location.reload()
    }, 1000)
  }

  getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ''
  }

  copyRoomCode() {
    const code = this.element.dataset.roomCode
    navigator.clipboard.writeText(code).then(() => {
      const confirmation = document.getElementById("copyConfirmation")
      if (confirmation) {
        confirmation.style.display = "block"
        setTimeout(() => {
          confirmation.style.display = "none"
        }, 2500)
      }
    })
  }

  shareWinner(event) {
    const button = event.currentTarget
    const name = button.dataset.restaurantName
    const address = button.dataset.restaurantAddress

    const shareText = `Check out ${name}! 📍 ${address}`

    if (navigator.share) {
      navigator.share({
        title: "Restaurant Roulette",
        text: shareText
      }).catch(() => {})
    } else {
      navigator.clipboard.writeText(shareText).then(() => {
        const originalHTML = button.innerHTML
        button.innerHTML = '✓ Copied!'
        button.style.background = '#22c55e'
        
        setTimeout(() => {
          button.innerHTML = originalHTML
          button.style.background = ''
        }, 2000)
      }).catch(() => {})
    }
  }
}