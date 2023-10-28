import psycopg2, flask
from flask import Flask, jsonify, request

def get_connection():
  return psycopg2.connect(
    port="5432",
  # DOCKER UP code 
    # host="abbasign_db",
    # database="postgres",
    # user="postgres",
    # password="postgres",
    
  # AZURE UP Code  
    host="abbasign.postgres.database.azure.com",
    database="abbasign",
    user="psqladmin",
    password="psqlp4ss",
  )

# Connect to the database
conn = get_connection()
cur = conn.cursor()
cur.execute('CREATE TABLE IF NOT EXISTS visitas (ip VARCHAR(15) PRIMARY KEY);')

app = flask.Flask(__name__)

# App version
VERSION = '1.0.0'

@app.route('/', methods=['GET'])
def index():
    # Get visitor's IP address (Docker)
    # ip = request.remote_addr
    # Get client IP address from headers (Azure)
    ip = request.headers.get("X-Forwarded-For").split(':')[0]
    # Check if IP already exists
    cur.execute("""
    SELECT COUNT(*)
    FROM visitas
    WHERE ip = %s;
    """, (ip,))
    count = cur.fetchone()[0]

    # If IP does not exist, insert it
    if count == 0:
      cur.execute("""
        INSERT INTO visitas (ip)
        VALUES (%s);
      """, (ip,))

    # Commit changes
    conn.commit()

    # Get list of registered IPs
    cur.execute("""
      SELECT ip
      FROM visitas;
    """)
    visitas = cur.fetchall()

    # Convert list to string
    visitas = ','.join([str(ip) for ip in visitas])

    return 'Visit registered' + ' (Registered IPs: ' + visitas + ')'

@app.route('/version', methods=['GET'])
def version():
    return VERSION

if __name__ == '__main__':     app.run(debug=True)

