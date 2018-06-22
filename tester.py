import sys
import datetime
import psycopg2

N_LOGS = 50000 # 50000
N_RUNS = 1000 # Should eventually test up to 50k runs
N_FLPS_PER_RUN = 500
N_EPNS_PER_RUN = 1500
TRANSACTION_SIZE = 1000 # Commit after this amount of SQL statements

conn = psycopg2.connect("dbname=jiskefet-test user=postgres password=postgres")
cur = conn.cursor()

FORMAT_LOG_PROGRESS = "\rInserted %d / %d logs"
FORMAT_RUN_PROGRESS = "\rInserted %d / %d runs"

for i in range (0, N_LOGS):
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
         'Test #'+ str(i),
         'Testytest test ' + str(i),
         datetime.date(2020,12,21)]
        )
    
    if (i % TRANSACTION_SIZE) == 0:
        sys.stdout.write(FORMAT_LOG_PROGRESS % (i, N_LOGS))
        sys.stdout.flush()
        conn.commit()
print(FORMAT_LOG_PROGRESS % (N_LOGS, N_LOGS))
conn.commit()
        
for i in range (0, N_RUNS):
    cur.execute("""
        INSERT INTO Runs (
          run_type
          )
        VALUES (%s)
        RETURNING run_number;
        """,
        ['PHYSICS'])
    run_number = int(cur.fetchone()[0])

    for j in range (0, N_FLPS_PER_RUN):
        cur.execute("""
            INSERT INTO FlpRoles (
              flp_role_name,
              fk_run_number,
              flp_hostname
              )
            VALUES (%s,%s,%s);
            """,
            ['flp-' + str(j), run_number, 'host-flp-' + str(j)])
    
    for k in range (0, N_EPNS_PER_RUN):
        cur.execute("""
            INSERT INTO EpnRoleSessions (
              epn_role_name,
              fk_run_number,
              epn_hostname
              )
            VALUES (%s,%s,%s);
            """,
            ['epn-' + str(k), run_number, 'host-epn-' + str(k)])
            
    sys.stdout.write(FORMAT_RUN_PROGRESS % (i + 1, N_RUNS))
    sys.stdout.flush()
    conn.commit()
print(FORMAT_RUN_PROGRESS % (N_RUNS, N_RUNS));

conn.commit()
cur.close()
conn.close()
