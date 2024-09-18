# SQL Inserter  

## Purpose  

A simple pipeline/environment that will:  

* Send a message to SQS  
* Write an entry into a database (postgres/mysql)  
* Execute SNS to notify when finished or error

## Assumptions  

* Application code written in Python  
* Uses AWS  


## Database  

* Engine - Postgres15  
* DB Name - guest_book

### Schema

| firstName | lastName | timestamp         |
| --------- | -------- | ----------------- |
| John      | Doe      | `2024-01-01 hh:mm:ss` |
