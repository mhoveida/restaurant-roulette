// app/javascript/controllers/room_spin_controller.js

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
    console.log("Room spin controller connected")
    this.roomId = this.element.dataset.roomId
    this.currentMemberId = this.element.dataset.currentMemberId
    this.isRoomCreator = this.element.dataset.isRoomCreator === "true"
    this.myVote = null

    if (this.hasWheelTarget) {
      this.drawWheel()
    }
    
    // Subscribe to room channel for real-time updates
    this.subscribeToRoom()
    
    // Poll for status updates (fallback if ActionCable not available)
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
      console.log("ActionCable not available, using polling only")
      return
    }

    this.subscription = App.cable.subscriptions.create(
      { channel: "RoomChannel", room_id: this.roomId },
      {
        received: (data) => {
          console.log("Received:", data)
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
    // Store current state
    this.lastKnownState = this.element.dataset.roomState
    
    // Poll every 2 seconds for status updates
    this.pollingInterval = setInterval(() => {
      this.fetchStatus()
    }, 2000)
  }

  async fetchStatus() {
    try {
      const response = await fetch(`/rooms/${this.roomId}/status`)
      if (!response.ok) return
      
      const data = await response.json()
      
      // Store current state and turn on first load
      if (!this.lastKnownState) {
        this.lastKnownState = data.state
        this.lastKnownTurnIndex = data.current_turn?.turn_index || 0
        this.lastKnownVoteCount = data.votes_count || 0
        return
      }
      
      // Check if state has changed
      if (data.state !== this.lastKnownState) {
        console.log('🔄 State changed from', this.lastKnownState, 'to', data.state)
        window.location.reload()
        return
      }
      
      // Check if turn changed during spinning phase
      if (data.state === 'spinning' && data.current_turn) {
        const newTurnIndex = data.current_turn.turn_index || 0
        if (newTurnIndex !== this.lastKnownTurnIndex) {
          console.log('🔄 Turn changed from', this.lastKnownTurnIndex, 'to', newTurnIndex)
          this.lastKnownTurnIndex = newTurnIndex
          window.location.reload()
          return
        }
      }
      
      // Check for vote count changes during voting phase
      if (data.state === 'voting') {
        const newVoteCount = data.votes_count || 0
        if (newVoteCount !== this.lastKnownVoteCount) {
          console.log('🔄 Vote count changed from', this.lastKnownVoteCount, 'to', newVoteCount)
          this.lastKnownVoteCount = newVoteCount
          
          // Update vote count displays
          this.updateVoteCountsFromStatus(data)
        }
      }
      
      // Check if new member joined during waiting
      if (data.state === 'waiting' && data.members) {
        const currentMemberCount = document.querySelectorAll('.member-item').length
        if (data.members.length !== currentMemberCount) {
          console.log('🔄 New member joined')
          window.location.reload()
          return
        }
      }
      
    } catch (error) {
      console.error("Status polling error:", error)
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
    
    if (!confirm("Start the spinning phase? Everyone will take turns!")) {
      return
    }

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
        // Page will reload or update via broadcast
        window.location.reload()
      } else {
        alert(data.error || "Could not start spinning")
      }
    } catch (error) {
      console.error("Start spinning error:", error)
      alert("An error occurred")
    }
  }


  async spin(event) {
    event.preventDefault()
    
    // Disable button to prevent double spins
    const button = event.target
    button.disabled = true

    try {
      // Show spinning animation
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
        // Match solo spin duration: 2-3 seconds
        const spinDuration = 2000 + Math.random() * 1000
        
        setTimeout(() => {
          if (this.hasWheelTarget) {
            this.wheelTarget.classList.remove('spinning')
          }
          
          // Reload to show next turn or revealing phase
          window.location.reload()
        }, spinDuration)
      } else {
        alert(data.error || "Could not spin")
        button.disabled = false
        if (this.hasWheelTarget) {
          this.wheelTarget.classList.remove('spinning')
        }
      }
    } catch (error) {
      console.error("Spin error:", error)
      alert("An error occurred")
      button.disabled = false
      if (this.hasWheelTarget) {
        this.wheelTarget.classList.remove('spinning')
      }
    }
  }


  async reveal(event) {
    event.preventDefault()

    // Show countdown
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

    // Wait for countdown
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
        // Reload to show voting interface
        window.location.reload()
      } else {
        alert(data.error || "Could not reveal options")
      }
    } catch (error) {
      console.error("Reveal error:", error)
      alert("An error occurred")
    }
  }


  async voteForOption(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const optionIndex = parseInt(event.currentTarget.dataset.optionIndex)
    const clickedElement = event.currentTarget // ⭐ STORE THIS BEFORE ASYNC!
    
    console.log('Voting for option:', optionIndex)
    
    try {
      const csrfToken = document.querySelector('[name="csrf-token"]')?.content || 
                      document.querySelector('meta[name="csrf-token"]')?.content
      
      if (!csrfToken) {
        console.error('CSRF token not found!')
        alert('Security token missing. Please refresh the page.')
        return
      }
      
      const response = await fetch(`/rooms/${this.roomId}/vote`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({ option_index: optionIndex })
      })
      
      console.log('Response status:', response.status)
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      console.log('Vote response:', data)
      
      if (data.success) {
        // Remove previous selection styling
        document.querySelectorAll('.voting-option').forEach(opt => {
          opt.classList.remove('selected-vote')
        })
        
        // Add selection styling to clicked option (use stored reference!)
        clickedElement.classList.add('selected-vote')
        
        // Show/update confirm button
        this.showConfirmVoteButton()
        
        console.log('Vote recorded successfully!')
      } else {
        alert(data.error || 'Failed to record vote')
      }
    } catch (error) {
      console.error('Vote error:', error)
      alert('Error casting vote. Please try again.')
    }
  }

  showConfirmVoteButton() {
    let confirmBtn = document.getElementById('confirmVoteBtn')
    
    if (!confirmBtn) {
      // Create confirm button if it doesn't exist
      const votingSection = document.querySelector('.voting-section')
      confirmBtn = document.createElement('button')
      confirmBtn.id = 'confirmVoteBtn'
      confirmBtn.className = 'button button-primary'
      confirmBtn.textContent = '✅ Confirm My Vote'
      confirmBtn.style.cssText = 'width: 100%; max-width: 400px; margin: 2rem auto; display: block; padding: 1rem; font-size: 1.1rem;'
      confirmBtn.onclick = () => this.confirmVote()
      votingSection.appendChild(confirmBtn)
    }
    
    confirmBtn.style.display = 'block'
  }

  async confirmVote() {
    if (!confirm('Are you sure? Once confirmed, you cannot change your vote.')) {
      return
    }
    
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
        alert('Vote confirmed! ✅')
        
        // Hide confirm button
        const confirmBtn = document.getElementById('confirmVoteBtn')
        if (confirmBtn) confirmBtn.style.display = 'none'
        
        // Disable all voting options
        document.querySelectorAll('.voting-option').forEach(opt => {
          opt.style.pointerEvents = 'none'
          opt.style.opacity = '0.6'
        })
        
        // Fetch updated vote counts immediately
        this.updateVoteCountsFromServer()
        
        // Continue polling for other votes
        console.log('Vote confirmed, waiting for others...')
      }
    } catch (error) {
      console.error('Confirm vote error:', error)
      alert('Error confirming vote. Please try again.')
    }
  }

  async updateVoteCountsFromServer() {
    try {
      const response = await fetch(`/rooms/${this.roomId}/status`)
      if (!response.ok) return
      
      const data = await response.json()
      
      if (data.state === 'voting') {
        // Update vote count displays
        this.updateVoteCountDisplay(data)
      } else if (data.state === 'complete') {
        // All votes are in, reload to show winner
        window.location.reload()
      }
    } catch (error) {
      console.error('Error fetching vote counts:', error)
    }
  }

  updateVoteCountDisplay(statusData) {
    // Get vote counts from status
    const voteCounts = {}
    
    if (statusData.votes_count) {
      // The status endpoint should return vote counts per option
      // We need to calculate this from the votes
      document.querySelectorAll('.voting-option').forEach((option, index) => {
        const optionIndex = parseInt(option.dataset.optionIndex)
        
        // Count how many votes this option has
        let count = 0
        // This will be populated by the polling
        
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
    event.stopPropagation() // Don't trigger vote
    const button = event.currentTarget
    button.style.backgroundColor = 'rgba(34, 197, 94, 0.3)'
    
    // TODO: Send feedback to server for user preferences
    setTimeout(() => {
      button.style.backgroundColor = 'rgba(34, 197, 94, 0.1)'
    }, 500)
  }

  async thumbsDown(event) {
    event.stopPropagation() // Don't trigger vote
    const button = event.currentTarget
    button.style.backgroundColor = 'rgba(239, 68, 68, 0.3)'
    
    // TODO: Send feedback to server for user preferences
    setTimeout(() => {
      button.style.backgroundColor = 'rgba(239, 68, 68, 0.1)'
    }, 500)
  }


  onSpinningStarted(data) {
    window.location.reload()
  }

  onTurnChanged(data) {
    // Update turn indicator without full reload
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

  // Share winner result
  shareWinner(event) {
    const button = event.currentTarget
    const name = button.dataset.restaurantName
    const address = button.dataset.restaurantAddress

    const shareText = `Check out ${name}! 📍 ${address}`

    if (navigator.share) {
      navigator.share({
        title: "Restaurant Roulette",
        text: shareText
      }).catch(err => console.log("Error sharing:", err))
    } else {
      navigator.clipboard.writeText(shareText).then(() => {
        const originalHTML = button.innerHTML
        button.innerHTML = '✓ Copied!'
        button.style.background = '#22c55e'
        
        setTimeout(() => {
          button.innerHTML = originalHTML
          button.style.background = ''
        }, 2000)
      }).catch(err => {
        console.log("Error copying:", err)
        alert("Copied to clipboard!")
      })
    }
  }
}