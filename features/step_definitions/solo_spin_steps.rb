# features/step_definitions/solo_spin_steps.rb
# COMPLETE FIXED VERSION - Replace your entire file with this

# ==========================================
# CONTEXT-AWARE FORM STEPS
# ==========================================

When('I fill in {string} with {string}') do |field_name, value|
  case field_name
  when "Name"
    if page.has_css?('.solo-spin-container')
      # Solo Spin page
      find('input[data-solo-spin-target="nameInput"]').set(value)
    elsif page.has_css?('.create-room-container')
      # Group Room Create or Join page
      if page.has_field?('owner_name')
        fill_in 'owner_name', with: value
      elsif page.has_field?('guest_name')
        fill_in 'guest_name', with: value
      end
    end
  when "Enter Room Code"
    fill_in 'room_code', with: value
  else
    fill_in field_name, with: value
  end
end

When('I select {string} from the {string} dropdown') do |value, dropdown_name|
  case dropdown_name
  when "Neighborhood"
    if page.has_css?('.solo-spin-container')
      # Solo Spin page
      within('[data-solo-spin-target="locationSelect"]') do
        select value
      end
    else
      # Group Room pages
      select value, from: 'location'
    end
  when "Price Range"
    if page.has_css?('.solo-spin-container')
      # Solo Spin page
      within('[data-solo-spin-target="priceSelect"]') do
        select value
      end
    else
      # Group Room pages
      select value, from: 'price'
    end
  end
end

When('I select {string} from the cuisine grid') do |cuisine|
  using_wait_time(15) do
    # Detect which page we're on
    grid_selector = if page.has_css?('.solo-spin-container')
                      '[data-solo-spin-target="cuisinesGrid"]'
                    elsif page.has_css?('.create-room-container')
                      '[data-create-room-target="cuisinesGrid"]'
                    else
                      raise "Cannot find cuisines grid"
                    end
    
    within(grid_selector) do
      # Wait for JavaScript to populate
      expect(page).to have_css('.cuisine-checkbox', wait: 10)
      
      # Find the label containing this cuisine
      label = find('.cuisine-checkbox', text: cuisine, match: :first)
      
      # Find the checkbox inside the label
      checkbox = label.find('input[type="checkbox"]')
      
      # Click the checkbox (NOT the label) to trigger the JavaScript event
      checkbox.click
      
      # Wait a moment for JavaScript to process
      sleep 0.5
      
      # Verify it was selected
      expect(checkbox).to be_checked
      
      # Verify the label has the 'selected' class added by JavaScript
      expect(label[:class]).to include('selected')
    end
  end
  
  # Extra verification: check that the hidden categoriesInput was updated
  controller_name = if page.has_css?('.solo-spin-container')
                      'solo-spin'
                    else
                      'create-room'
                    end
  
  categories_input = find("[data-#{controller_name}-target='categoriesInput']", visible: false)
  expect(categories_input.value).to include(cuisine)
end

# ==========================================
# HELPER METHODS (if needed elsewhere)
# ==========================================

def select_neighborhood(neighborhood)
  within('[data-solo-spin-target="locationSelect"]') do
    select neighborhood
  end
end

def select_price(price)
  within('[data-solo-spin-target="priceSelect"]') do
    select price
  end
end

def select_cuisine(cuisine)
  using_wait_time(10) do
    within('[data-solo-spin-target="cuisinesGrid"]') do
      expect(page).to have_css('.cuisine-checkbox', wait: 10)
      label = find('.cuisine-checkbox', text: cuisine, match: :first)
      label.click
    end
  end
end

# ==========================================
# VALIDATION STEPS
# ==========================================

Then('I should see a validation message') do
  if page.has_css?('.solo-spin-container')
    expect(page).to have_css('[data-solo-spin-target="validationMessage"]', visible: true)
  elsif page.has_css?('.create-room-container')
    expect(page).to have_css('[data-create-room-target="validationMessage"]', visible: true)
  else
    expect(page).to have_css('.validation-message, .error-message', visible: true)
  end
end

Then('the {string} field should be read-only') do |field_name|
  field = find_field(field_name)
  expect(field[:readonly]).to be_truthy
end

# Note: "the {string} field should contain {string}" is in group_room_steps.rb