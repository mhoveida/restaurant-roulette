# Restaurant Roulette

A Rails application to help you decide where to eat. This project is built with Ruby on Rails and uses PostgreSQL as its database.

---

## 👥 Team Members

| Name | UNI |
|------|-----|
| Benjamin Benscher | beb2181 |
| Celine Lee | cl4179 |
| Maddison Hoveida | mh4572 |
| Olivia Caulfield | ogc2111 |

---
## Heroku Deployment
https://restaurant-roulette-app-db5e3f7eb0f2.herokuapp.com/

## Instructions to Run Locally
Follow these instructions to get a copy of the project up and running on your local machine for development and testing.

### Prerequisites

Before you begin, ensure you have the following software installed on your machine:

* **Ruby** (version 3.3.9)
* **Rails** (Version 8.x)
* **Node.js** (Version 18.x or later recommended)
* **Yarn** (Version 1.22.x or later)
* **Bundler** (gem for managing dependencies)
* **PostgreSQL** (database server)

### Installation

Follow these steps to set up your development environment.

1.  **Clone the Repository**
    Open your terminal and run the following command to download the project files:
    ```sh
    git clone https://github.com/mhoveida/restaurant-roulette.git
    ```

2.  **Navigate to the Project Directory**
    ```sh
    cd restaurant-roulette
    ```

3.  **Checkout the correct branch**
    ```sh
    git checkout proj-iter1
    ```

4.  **Install Ruby Dependencies**
    Use Bundler to install all the necessary gems specified in the `Gemfile`:
    Make sure you're using 2.7.2 version of bundler, and 3.3.9 version of ruby.
    ```sh
    bundle install
    ```
    
6.  **Install JavaScript dependencies:**
    ```bash
    yarn install
    ```

7.  **Set Up the Database**
    This project uses PostgreSQL.

    * First, make sure your PostgreSQL server is running. If you installed it with Homebrew, you can start it with:
        ```sh
        brew services start postgresql
        ```

    * Next, create the development and test databases for the application:
        ```sh
        rails db:create
        ```

    * Then, Load seed data (restaurants)n:
        ```sh
        rails db:seed
        ```

    * Then, run the database migrations to set up the schema:
        ```sh
        rails db:migrate
        ```

## Running the Application

To run the application locally:

1.  **Start the Rails Server**
    ```sh
    rails server
    ```

2.  **View the Application**
    Open your favorite web browser and navigate to:
    [http://localhost:3000](http://localhost:3000)

You should see the application's homepage.

---

### Running Tests

Make sure your test database is migrated (`rails db:migrate RAILS_ENV=test`) before running tests.
This project includes both **RSpec** and **Cucumber** tests.

1.  **Run RSpec (Unit Tests):**
    ```bash
    bundle exec rspec
    ```

2.  **Run Cucumber (Feature/Acceptance Tests):**
    ```bash
    bundle exec cucumber
    ```

3.  **Run Both & Check Coverage:**
    * Run all tests (RSpec and Cucumber) and generate a coverage report:
      ```bash
      # Run Cucumber first to generate the report
      bundle exec cucumber
      # Then run RSpec
      bundle exec rspec
      ```
    * Open `coverage/index.html` in your browser to view the detailed report.
