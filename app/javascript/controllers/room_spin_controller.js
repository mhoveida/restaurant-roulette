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
  console.log('🚀 ROOM SPIN CONTROLLER - FINAL ROBUST VERSION')
  this.roomId = this.element.dataset.roomId
  this.roomCode = this.element.dataset.roomCode
  this.currentMemberId = this.element.dataset.currentMemberId
  this.isRoomCreator = this.element.dataset.isRoomCreator === "true"
  
  // 1. Read confirmation state from the HTML data attribute
  this.voteConfirmed = this.element.dataset.voteConfirmed === "true"
  this.myVote = null

  if (this.hasWheelTarget) {
    this.drawWheel()
  }
  
  // 2. CHECK: If confirmed, lock everything immediately
  if (this.voteConfirmed) {
    this.lockVotingUI()
  } 
  // 3. RESTORE: If NOT confirmed, check if user has voted
  else {
    // Find if user has a selected vote
    const selectedOption = document.querySelector('.voting-option.selected-vote')
    if (selectedOption) {
      console.log('🔄 Restoring Confirm Button - user has voted but not confirmed')
      const optionIndex = parseInt(selectedOption.dataset.optionIndex)
      this.myVote = optionIndex
      this.showConfirmVoteButton()
    }
  }
  
  this.subscribeToRoom()
  this.startStatusPolling()
}

  // Helper to visually and functionally lock the interface
  lockVotingUI() {
    console.log('🔒 Locking Voting UI')
    
    // Disable all options
    document.querySelectorAll('.voting-option').forEach(opt => {
      opt.removeAttribute('data-action')
      opt.style.pointerEvents = 'none'
      opt.style.opacity = '0.6'
      opt.style.cursor = 'not-allowed'
      
      // Highlight the winner/selected option
      if (opt.classList.contains('selected-vote') || opt.classList.contains('vote-confirmed')) {
        opt.style.border = '3px solid #22c55e'
        opt.style.opacity = '1'
        opt.style.boxShadow = '0 0 10px rgba(34, 197, 94, 0.5)'
        
        if (!opt.querySelector('.lock-icon')) {
          const lockIcon = document.createElement('div')
          lockIcon.className = 'lock-icon'
          lockIcon.textContent = '🔒'
          lockIcon.style.cssText = 'position: absolute; top: 10px; right: 10px; font-size: 2rem; z-index: 10;'
          opt.style.position = 'relative'
          opt.appendChild(lockIcon)
        }
      }
    })

    // Hide button
    const confirmBtn = document.getElementById('confirmVoteBtn')
    if (confirmBtn) {
      confirmBtn.style.display = 'none'
    }

    // Show "Waiting" message
    const votingSection = document.querySelector('.voting-section')
    if (votingSection && !document.getElementById('voteConfirmedMessage')) {
      const msg = document.createElement('div')
      msg.id = 'voteConfirmedMessage'
      msg.style.cssText = 'background: #22c55e; color: white; padding: 1.5rem; border-radius: 12px; margin: 1.5rem auto; max-width: 500px; text-align: center; font-weight: bold; font-size: 1.1rem; box-shadow: 0 4px 6px rgba(0,0,0,0.1);'
      msg.innerHTML = '<div style="font-size: 2rem; margin-bottom: 0.5rem;">✓</div>Your vote has been confirmed!<br><span style="font-size: 0.9rem; opacity: 0.9;">Waiting for other members...</span>'
      
      if (confirmBtn) {
        votingSection.insertBefore(msg, confirmBtn)
      } else {
        votingSection.appendChild(msg)
      }
    }
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
    console.log('📡 Broadcast received:', data.type, data)
    
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
      
      // Initialize on first poll
      if (!this.lastKnownState) {
        this.lastKnownState = data.state
        this.lastKnownTurnIndex = data.current_turn?.turn_index || 0
        this.lastKnownTurnMember = data.current_turn?.member_id  // ADD THIS
        this.lastKnownVoteCount = data.votes_count || 0
        return
      }
      
      // State changed (waiting → spinning, etc.)
      if (data.state !== this.lastKnownState) {
        console.log(`State changed: ${this.lastKnownState} → ${data.state}`)
        window.location.reload()
        return
      }
      
      // Turn changed during spinning
      if (data.state === 'spinning' && data.current_turn) {
        const newTurnIndex = data.current_turn.turn_index || 0
        const newTurnMember = data.current_turn.member_id
        
        // Reload if turn index changed OR if it's now MY turn
        if (newTurnIndex !== this.lastKnownTurnIndex || 
            (newTurnMember === this.currentMemberId && newTurnMember !== this.lastKnownTurnMember)) {
          
          console.log(`Turn changed: index ${this.lastKnownTurnIndex} → ${newTurnIndex}, member: ${newTurnMember}`)
          this.lastKnownTurnIndex = newTurnIndex
          this.lastKnownTurnMember = newTurnMember
          window.location.reload()
          return
        }
      }
      
      // Voting phase - don't reload to avoid disrupting voters
      if (data.state === 'voting') {
        const newVoteCount = data.votes_count || 0
        if (newVoteCount !== this.lastKnownVoteCount) {
          this.lastKnownVoteCount = newVoteCount
          // Intentionally do NOT reload here
        }
      }
      
      // Waiting phase - reload when members join/leave
      if (data.state === 'waiting' && data.members) {
        const currentMemberCount = document.querySelectorAll('.member-item').length
        if (data.members.length !== currentMemberCount) {
          console.log(`Member count changed: ${currentMemberCount} → ${data.members.length}`)
          window.location.reload()
          return
        }
      }
      
    } catch (error) {
      console.error('Status polling error:', error)
    }
  }

  updateVoteCountsFromStatus(statusData) {
    // Hidden during voting
  }

  async startSpinning(event) {
    event.preventDefault()
    try {
      const response = await fetch(`/rooms/${this.roomId}/start_spinning`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': this.getCsrfToken() }
      })
      const data = await response.json()
      if (data.success) window.location.reload()
    } catch (error) { }
  }

  async spin(event) {
    event.preventDefault()
    const button = event.target
    button.disabled = true

    try {
      if (this.hasWheelTarget) this.wheelTarget.classList.add('spinning')

      const response = await fetch(`/rooms/${this.roomId}/spin`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': this.getCsrfToken() }
      })

      const data = await response.json()

      if (data.success) {
        const spinDuration = 2000 + Math.random() * 1000
        setTimeout(() => {
          if (this.hasWheelTarget) this.wheelTarget.classList.remove('spinning')
          window.location.reload()
        }, spinDuration)
      } else {
        button.disabled = false
        if (this.hasWheelTarget) this.wheelTarget.classList.remove('spinning')
      }
    } catch (error) {
      button.disabled = false
      if (this.hasWheelTarget) this.wheelTarget.classList.remove('spinning')
    }
  }

  async reveal(event) {
    event.preventDefault()
    if (this.hasCountdownTarget) {
      let count = 3
      const countdownInterval = setInterval(() => {
        this.countdownTarget.textContent = count
        count--
        if (count < 0) clearInterval(countdownInterval)
      }, 1000)
    }

    await new Promise(resolve => setTimeout(resolve, 3000))

    try {
      const response = await fetch(`/rooms/${this.roomId}/reveal`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': this.getCsrfToken() }
      })
      const data = await response.json()
      if (data.success) window.location.reload()
    } catch (error) { }
  }

  async voteForOption(event) {
    event.preventDefault()
    event.stopPropagation()
    
    // Stop if confirmed
    if (this.voteConfirmed) return false
    
    const optionIndex = parseInt(event.currentTarget.dataset.optionIndex)
    const clickedElement = event.currentTarget
    
    try {
      // FIX: Use robust CSRF token check (matches your original code)
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || 
                        document.querySelector('input[name="csrf-token"]')?.value || ''
      
      if (!csrfToken) {
        console.error('CSRF token not found')
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
      
      if (!response.ok) {
        console.error('Vote failed:', response.status)
        return
      }
      
      const data = await response.json()
      
      if (data.success) {
        document.querySelectorAll('.voting-option').forEach(opt => {
          opt.classList.remove('selected-vote')
        })
        clickedElement.classList.add('selected-vote')
        this.myVote = optionIndex
        this.showConfirmVoteButton()
      }
    } catch (error) {
      console.error('Vote error:', error)
    }
    return false
  }

  showConfirmVoteButton() {
    if (this.voteConfirmed) return
    
    let confirmBtn = document.getElementById('confirmVoteBtn')
    
    if (!confirmBtn) {
      const votingSection = document.querySelector('.voting-section')
      // Safety check (logging if missing)
      if (!votingSection) {
        console.error('Voting section not found')
        return
      }

      confirmBtn = document.createElement('button')
      confirmBtn.id = 'confirmVoteBtn'
      confirmBtn.className = 'button button-primary'
      confirmBtn.textContent = 'Confirm My Vote'
      confirmBtn.style.cssText = 'width: 100%; max-width: 400px; margin: 2rem auto; display: block; padding: 1rem; font-size: 1.1rem; transition: all 0.3s ease;'
      confirmBtn.onclick = () => this.confirmVote()
      votingSection.appendChild(confirmBtn)
    }
    
    confirmBtn.disabled = false
    confirmBtn.textContent = 'Confirm My Vote'
    confirmBtn.style.display = 'block'
    
    // FIX: Scroll to button so user definitely sees it
    confirmBtn.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
  }

  async confirmVote() {
    if (this.voteConfirmed) return
    
    const confirmBtn = document.getElementById('confirmVoteBtn')
    if (confirmBtn) {
      confirmBtn.disabled = true
      confirmBtn.textContent = 'Confirming...'
    }
    
    try {
      const response = await fetch(`/rooms/${this.roomId}/confirm_vote`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': this.getCsrfToken() }
      })
      
      const data = await response.json()
      
      if (data.success) {
        this.voteConfirmed = true
        this.lockVotingUI() 
        this.updateVoteCountsFromServer()
      } else {
        this.voteConfirmed = false
        if (confirmBtn) {
          confirmBtn.disabled = false
          confirmBtn.textContent = 'Confirm My Vote'
        }
      }
    } catch (error) {
      this.voteConfirmed = false
      if (confirmBtn) {
        confirmBtn.disabled = false
        confirmBtn.textContent = 'Confirm My Vote'
      }
    }
  }

  async updateVoteCountsFromServer() {
    try {
      const response = await fetch(`/rooms/${this.roomId}/status`)
      if (!response.ok) return
      const data = await response.json()
      if (data.state === 'voting') {
        this.updateVoteCountsFromStatus(data)
      } else if (data.state === 'complete') {
        window.location.reload()
      }
    } catch (error) { }
  }

  onSpinningStarted(data) { window.location.reload() }

  onTurnChanged(data) {
  console.log('🔄 Turn changed:', data)
  
  // CRITICAL: If it's now MY turn, reload the page to show the spin button
  if (data.current_turn && data.current_turn.member_id === this.currentMemberId) {
    console.log('⭐ It\'s MY turn now! Reloading...')
    window.location.reload()
    return
  }
  
  // Update turn indicators visually (for other members watching)
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
  
  // Update the "X is spinning..." message
  const waitingMessage = document.querySelector('.other-member-turn')
  if (waitingMessage && data.current_turn) {
    const nameElement = waitingMessage.querySelector('strong')
    if (nameElement) {
      nameElement.textContent = data.current_turn.member_name
    }
  }
}

  onRoundComplete(data) { window.location.reload() }
  onRevealOptions(data) { window.location.reload() }
  
  onVoteUpdate(data) {
    console.log('📊 Vote update received:', data)
  }

  onVotingComplete(data) {
    setTimeout(() => { window.location.reload() }, 1000)
  }

  getCsrfToken() {
    // UPDATED: Robust fallback mechanism from original code
    return document.querySelector('meta[name="csrf-token"]')?.content || 
           document.querySelector('input[name="csrf-token"]')?.value || ''
  }

  copyRoomCode() {
    const code = this.element.dataset.roomCode
    navigator.clipboard.writeText(code).then(() => {
      const confirmation = document.getElementById("copyConfirmation")
      if (confirmation) {
        confirmation.style.display = "block"
        setTimeout(() => { confirmation.style.display = "none" }, 2500)
      }
    })
  }

  shareWinner(event) {
    const button = event.currentTarget
    const name = button.dataset.restaurantName
    const address = button.dataset.restaurantAddress
    const shareText = `Check out ${name}! 📍 ${address}`

    if (navigator.share) {
      navigator.share({ title: "Restaurant Roulette", text: shareText }).catch(() => {})
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