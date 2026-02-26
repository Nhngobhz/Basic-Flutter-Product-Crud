# Interview Test - Full Stack Application

This is a full-stack application consisting of a **Node.js/Express backend** and a **Flutter frontend**. 

---

## Prerequisites

Before you begin, ensure you have the following installed on your system:

### 1. **Flutter SDK**
- Download and install from [flutter.dev](https://flutter.dev/docs/get-started/install)
- Version: >= 3.0
- Run `flutter doctor` to verify installation

### 2. **MySQL Database**
- Download and install from [mysql.com](https://www.mysql.com/downloads/)
- Make sure MySQL server is running on your machine
- You may need the database credentials and connection details for the backend setup

---

## Setup Instructions

Follow these steps in order:

### Step 1: Backend Setup

1. Navigate to the `backend` folder:
   ```bash
   cd backend
   ```

2. Follow all instructions in [backend/README.md](backend/README.md) to:
   - Install backend dependencies
   - Configure environment variables
   - Set up the database
   - Run the backend server

### Step 2: Frontend Setup

Once the backend is running, navigate to the `frontend` folder:
   ```bash
   cd ../frontend
   ```

2. Follow all instructions in [frontend/README.md](frontend/README.md) to:
   - Install frontend dependencies
   - Configure API endpoints
   - Run the Flutter app

---

## Project Structure

```
├── backend/           # Node.js/Express API server
│   ├── src/          # Application source code
│   ├── package.json  # Backend dependencies
│   └── README.md     # Backend setup instructions
│
├── frontend/         # Flutter mobile & web app
│   ├── lib/          # Flutter source code
│   ├── pubspec.yaml  # Flutter dependencies
│   └── README.md     # Frontend setup instructions
│
└── set up.sql        # Database schema setup
```

---

## Quick Start Summary

1.  Install **Flutter** and **MySQL**
2.  Go to `backend/` and follow its README
3.  Go to `frontend/` and follow its README
4.  Start both backend and frontend
5.  Test the application

---

## Support

For detailed information about each component:
- **Backend**: See [backend/README.md](backend/README.md)
- **Frontend**: See [frontend/README.md](frontend/README.md)
- **Database**: See [set up.sql](set%20up.sql)

---

## Notes

- Make sure MySQL is running before starting the backend server
- The backend must be running before you can use the Flutter frontend
- Follow the README files in each folder for specific configuration details
