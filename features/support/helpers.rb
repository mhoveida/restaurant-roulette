module CucumberHelpers
  def select_neighborhood(neighborhood)
    within('[data-solo-spin-target="locationSelect"], [data-create-room-target="locationSelect"]') do
      select neighborhood
    end
  end
  
  def select_price(price)
    within('[data-solo-spin-target="priceSelect"], [data-create-room-target="priceSelect"]') do
      select price
    end
  end
  
  def select_cuisine(cuisine)
    using_wait_time(10) do
      within('[data-solo-spin-target="cuisinesGrid"], [data-create-room-target="cuisinesGrid"]') do
        find('.cuisine-button', text: cuisine, match: :first).click
      end
    end
  end
end

World(CucumberHelpers)