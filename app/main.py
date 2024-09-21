import psycopg2 as pgsql

conn = pgsql.connect(database = "postgres",
                     user     = "postgres",
                     password = "admin7818",
                     host     = "localhost",
                     port     = 5432)

cursor = conn.cursor()
q_createTable = """CREATE TABLE guest_book(
               firstName VARCHAR(50) NOT NULL,
               lastName VARCHAR(50) NOT NULL,
               timestamp date NOT NULL);
               """

def create_database(query):
    
    try:
        cursor.execute(query)
        conn.commit()
        output = cursor.fetchall() 
        cursor.close()
        conn.close()
    except pgsql.OperationalError as e:
        print(e)

    return output

def main():
    print(f'Creating database...')
    create_database(q_createTable)
    response = create_database()

    return response

main()
