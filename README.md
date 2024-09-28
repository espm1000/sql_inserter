# SQL Inserter  

## Purpose  

A simple pipeline/environment that will:  

* Event will be pushblished to SNS Topic  
* SNS Topic will publish message to SQS Queue(s)  
* Lambda service will retrieve message from Queue  
* Lambda will write an entry into a database (postgres/mysql)  
* Explore Lambda -> Notify client  

## Practical Idea  

* Get the weather from the National Weather Service and publish via SNS  

## Assumptions  

* Application code written in Python  
* Uses AWS  


## Database  

* Engine - Postgres15  
* DB Name - guest_book

### Schema

| firstName | lastName | timestamp         |
| --------- | -------- | ----------------- |
| John      | Doe      | `2024-01-01_00:00:00` |
