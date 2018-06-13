import sys
import datetime
import psycopg2

conn = psycopg2.connect("dbname=jiskefet-test user=postgres password=postgres")
cur = conn.cursor()

#n_rows = sys.argv[1]
n_rows = 50000

print("Dumping " + str(n_rows) + " rows");

for x in range (0, n_rows):
    cur.execute("""
        INSERT INTO Logs (
          log_subtype,
          fk_user_id,
          origin,
          entry_type,
          title,
          text,
          announcement_valid_until)
        VALUES (%s,%s,%s,%s,%s,%s,%s);
        """,
        ['announcement',
         '0',
         'human',
         'general',
         'Test #'+ str(x),
         'Testytest test ' + str(x),
         datetime.date(2020,12,21)]
        )
    # Commit every 1000 queries to avoid giant transactions
    if ((x % 1000) == 0):
        conn.commit();
        
conn.commit();
cur.close();
conn.close();
