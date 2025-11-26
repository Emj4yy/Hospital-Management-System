@echo off
echo ========================================
echo Hospital Management System - Quick Start
echo ========================================
echo.

echo Step 1: Checking if MySQL database exists...
echo Please make sure you have created the database 'hospital_db' in MySQL
echo Run this SQL command in MySQL:
echo    CREATE DATABASE hospital_db;
echo.
pause

echo.
echo Step 2: Starting the application...
echo This may take 15-30 seconds...
echo.

call mvnw.cmd spring-boot:run

echo.
echo ========================================
echo Application should now be running!
echo ========================================
echo.
echo Open your browser and go to:
echo    http://localhost:8080
echo.
echo Press Ctrl+C to stop the application
pause

