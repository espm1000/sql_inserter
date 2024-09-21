import psycopg2 as pgsql
import sys

sys.tracebacklimit=0



conn = pgsql.connect(database = "postgres",
                     user     = "postgres",
                     password = "admin7818",
                     host     = "localhost",
                     port     = 5432)

q_createTable = """CREATE TABLE guest_book(
               firstName VARCHAR(50) NOT NULL,
               lastName VARCHAR(50) NOT NULL,
               timestamp date NOT NULL);
               """

q_deleteTable = """DROP TABLE guest_book;"""

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
    try:
        cursor.execute(query)
        conn.commit()
        cursor.close()
        conn.close()
    except pgsql.OperationalError as e:
        print(f'Error: {e}')


def create_database(query):
    
    try:
        cursor.execute(query)
        conn.commit()
        cursor.close()
        conn.close()
    except pgsql.OperationalError as e:
        print("Error: ", e)



def foo():
    # Delete database
    try:
        response = delete_table(q_deleteTable)
    except:
        response = print("didnt work")
    
    return response

def main():
    print(f'Creating database...')
    try:
        create_database(q_createTable)
        response = create_database()
    except pgsql.OperationalError as e:
        response = print("Unable to create DB.", e)

        return response


#foo()
#main()