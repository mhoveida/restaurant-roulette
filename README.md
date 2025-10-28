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

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing.

### Prerequisites

Before you begin, ensure you have the following software installed on your machine:

* **Ruby** (version 3.3.9)
* **Bundler** (gem for managing dependencies)
* **Git** (version control)
* **PostgreSQL** (database)
    * For macOS users, it is highly recommended to install and manage PostgreSQL using [Homebrew](https://brew.sh/).

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

3.  **Install Ruby Dependencies**
    Use Bundler to install all the necessary gems specified in the `Gemfile`:
    ```sh
    bundle install
    ```

4.  **Set Up the Database**
    This project uses PostgreSQL.

    * First, make sure your PostgreSQL server is running. If you installed it with Homebrew, you can start it with:
        ```sh
        brew services start postgresql
        ```

    * Next, create the development and test databases for the application:
        ```sh
        rails db:create
        ```

    * Finally, run the database migrations to set up the schema:
        ```sh
        rails db:migrate
        ```

## Usage

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

This project includes both **RSpec** and **Cucumber** tests.

## Run All RSpec Tests
    ```sh
    bundle exec rspec
    ```

## Run Cucumber Feature Tests
    ```sh
    bundle exec cucumber
    ```

## Run Specific Feature (Example)
    ```sh
    bundle exec cucumber features/home_page.feature
    ```
