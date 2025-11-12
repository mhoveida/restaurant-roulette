# Ensure session data (like OmniAuth CSRF tokens) persists between requests
Rails.application.config.session_store :cookie_store, key: "_restaurant_roulette_session", same_site: :lax
