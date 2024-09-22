import psycopg2 as pgsql
import sys

sys.tracebacklimit=1

conn = pgsql.connect(database = "guest_book",
                     user     = "postgres",
                     password = "admin7818",
                     host     = "localhost",
                     port     = 5432)

conn.set_isolation_level(pgsql.extensions.ISOLATION_LEVEL_AUTOCOMMIT)

file = "database/create_db.sql"
q_createTable = open(file, "r").read()

def run_query(query):
    cursor = conn.cursor()
    try:
        cursor.execute(query)
        response = cursor.fetchall()
        conn.commit()   
        cursor.close()
    except pgsql.OperationalError as e:
        print(e)
    
    return response

def delete_table(query):
    cursor = conn.cursor()
    try:
        cursor.execute(query)
        conn.commit()
        cursor.close()
        conn.close()
    except pgsql.OperationalError as e:
        print(f'Error: {e}')


def create_database(query):
    cursor = conn.cursor()
    try:
        cursor.execute(query)
        #response = cursor.fetchall()
        conn.commit()
        cursor.close()
        conn.close()
    except pgsql.OperationalError as e:
        print("Error: ", e)

    return query

def main(query=None):
    print(f'Creating database...')
    try:
        create_database(q_createTable)
        response = create_database()
    except pgsql.OperationalError as e:
        response = print("Unable to create DB.", e)

    more = input("Run query? ")
    if more == "y":
        response = run_query(query)

        return response

if __name__ == '__main__':
    main()