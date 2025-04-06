# LegalForum

LegalForum is a web application designed to facilitate discussions and queries on legal topics. This README provides instructions on how to set up the project, configure the environment, and run the application.

## Prerequisites

Before setting up the project, ensure you have the following tools installed:

- [Node.js](https://nodejs.org/) (v18 or higher recommended)
- [npm](https://www.npmjs.com/) (comes with Node.js)
- [MongoDB](https://www.mongodb.com/) (ensure MongoDB is running locally or provide a connection URL)

## Setting Up the Project

1. Clone the repository to your local machine:
   ```bash
   git clone <repository-url>
   cd LegalForum

2. Install the required dependencies:
    ```
    npm install
    ```

3. Set up the .env file in the root directory. Create a file named .env and add the following variables:
    ```
    PROJECT_NAME="legalForum"
    NODE_ENV="dev"
    MONGODB_CONNECTION_URL="mongodb://localhost:27017/legalForum"
    ```
    - PROJECT_NAME: The name of the project.
    - NODE_ENV: The environment in which the application is running (dev, production, etc.).
    - MONGODB_CONNECTION_URL: The connection URL for your MongoDB instance. Replace localhost:27017 with your MongoDB server's address if necessary.

4. Initialize the database (optional, if required):
    ```
    npm run initDB
    ```

## Running the Project

1. Start the development server:
    ```
    npm run dev
    ```
    This will start the server with nodemon, which automatically restarts the server when changes are made.

2. Alternatively, start the production server:
    ```
    npm start
    ```

3. The application will be accessible at:

    Replace 3000 with the port specified in the .env file if you have changed it.

## Additional Notes

- Ensure MongoDB is running before starting the application.
- If you encounter any issues, check the logs or ensure all dependencies are installed correctly.

Enjoy using LegalForum! 
