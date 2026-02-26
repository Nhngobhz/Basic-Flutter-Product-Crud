# Backend API Documentation

This repository contains a Node.js/Express backend for an interview test. The API provides endpoints for user authentication, and managing categories and products. It also supports file uploads for product images.

## Table of Contents

1. [Project Structure](#project-structure)
2. [Getting Started](#getting-started)
   - [Prerequisites](#prerequisites)
   - [Installation](#installation)
   - [Running the Server](#running-the-server)
3. [Environment Configuration](#environment-configuration)
4. [API Endpoints](#api-endpoints)
   - [Authentication](#authentication)
   - [Categories](#categories)
   - [Products](#products)
5. [Middlewares](#middlewares)
6. [Utilities](#utilities)
7. [Error Handling](#error-handling)
8. [Uploads](#uploads)
9. [Notes](#notes)

---

## Project Structure

```
package.json
server.js
src/
  app.js
  config/
    db.js
    jwt.js
  controllers/
    auth.controller.js
    category.controller.js
    product.controller.js
  middlewares/
    auth.middleware.js
    error.middleware.js
    upload.middleware.js
  routes/
    auth.routes.js
    category.routes.js
    product.routes.js
  services/
    auth.service.js
    category.service.js
    product.service.js
  uploads/
    images/          # stores uploaded image files
  utils/
    email.js
    otp.js
    validator.js
```

## Getting Started

### Prerequisites

- Node.js (>=16)
- npm or yarn
- MySQL (if using the `db.js` configuration) or another database as configured

### Installation

```bash
# install dependencies
npm install
```

### Running the Server

```bash
# start the server
npm start
```

The application entry point is `server.js`, which loads `src/app.js` and starts listening on the configured port.

## Environment Configuration

Create a `.env` file at the root of the project (not shown in repo) and set the following variables:

```
DB_HOST=localhost
DB_USER=<Your User>
DB_PASSWORD=<Your Password>
DB_NAME=ecom
DB_PORT=3306
JWT_SECRET=banana
JWT_EXPIRE=1d
EMAIL_USER=<Your Email>
EMAIL_PASS=<Your Email App password>
```

Adjust values as needed.

## API Endpoints

### Authentication

| Method | Endpoint             | Description                    | Request Body                                | Response                          |
|--------|----------------------|--------------------------------|---------------------------------------------|-----------------------------------|
| POST   | `/api/auth/signup`   | Create a new user              | `{ name, email, password }`                 | Newly created user info + token   |
| POST   | `/api/auth/login`    | Authenticate user              | `{ email, password }`                       | Access token + user info          |
| GET    | `/api/auth/me`       | Get authenticated user details | (Requires Bearer token)                     | User information                  |

### Categories

| Method | Endpoint                | Description                         | Request Body                        | Auth Required |
|--------|-------------------------|-------------------------------------|-------------------------------------|---------------|
| GET    | `/api/categories`       | List all categories                 | —                                   | No            |
| POST   | `/api/categories`       | Create a category                   | `{ name }`                          | Yes           |
| PUT    | `/api/categories/:id`   | Update a category                   | `{ name }`                          | Yes           |
| DELETE | `/api/categories/:id`   | Remove a category                   | —                                   | Yes           |

### Products

| Method | Endpoint                  | Description                            | Request Body & Query                 | Auth Required |
|--------|---------------------------|----------------------------------------|--------------------------------------|---------------|
| GET    | `/api/products`           | List products (with optional filters)  | Query params (category, search)      | No            |
| GET    | `/api/products/:id`       | Get product by ID                      | —                                    | No            |
| POST   | `/api/products`           | Create a new product                   | Form data including image upload     | Yes           |
| PUT    | `/api/products/:id`       | Update existing product                | Partial fields / image upload        | Yes           |
| DELETE | `/api/products/:id`       | Delete a product                       | —                                    | Yes           |

> For upload routes, use `multipart/form-data` and send `image` file field.

## Middlewares

- `auth.middleware.js`: verifies JWT token from `Authorization: Bearer <token>` header.
- `error.middleware.js`: centralized error handler sending JSON responses.
- `upload.middleware.js`: handles file uploads for product images and enforces limits/validation.

## Utilities

- `email.js`: send emails (e.g., for OTP or notifications).
- `otp.js`: generate one-time passwords for verification.
- `validator.js`: common data validation functions.

## Error Handling

Errors are passed to `error.middleware`. Specific file upload errors are handled inline in `app.js`:

- `LIMIT_FILE_SIZE`: returns 400 with message "File too large. Max 2MB allowed."
- `Only images are allowed`: returns 400 with message.

The standard structure for errors is:

```json
{ "message": "Error description", "status": 400 }
```

## Uploads

Route `/uploads` serves static files from `src/uploads`. Images (or other files) are stored under `src/uploads/images`.

Access uploaded images via `http://<host>:<port>/uploads/images/<filename>`.

## Notes

- This is a simple demonstration API intended for interview/testing purposes.
- Authentication uses JWT tokens stored in HTTP headers.
- Ensure sensitive information (JWT secrets, DB credentials) are not committed and are provided via environment variables.

---

Feel free to extend or modify functionality based on requirements.