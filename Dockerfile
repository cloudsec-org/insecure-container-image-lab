#Dockerfile — intentionally insecure-by-design image for testing in an isolated environment
#DO NOT use in production. DO NOT include real keys/credentials.

FROM python:3.8-slim

# Metadata
LABEL maintainer="you@example.com"
LABEL purpose="Test image for CI/CD scanners — contains example 'secrets' placeholders and outdated deps"

# FAKE SECRETS
ENV AWS_ACCESS_KEY_ID="AKIAEXAMPLEFAKEKEY"
ENV AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
ENV JDBC_URL="jdbc:postgresql://db.example.local:5432/appdb"
ENV JDBC_USER="db_user"
ENV JDBC_PASS="P@ssw0rd_example"

# Intentionally install old/vulnerable Python packages (examples)
RUN pip install --no-cache-dir Flask==1.0.2 requests==2.18.4

# Add artifacts to test scanners (files containing "secrets" and a harmless 'fake-malware' sample)
WORKDIR /app

# File containing "secrets" baked into the build (example placeholders)
RUN printf "aws_access_key_id=${AWS_ACCESS_KEY_ID}\naws_secret_access_key=${AWS_SECRET_ACCESS_KEY}\n" > /app/fake_creds.ini \
 && printf "jdbc.url=%s\njdbc.user=%s\njdbc.pass=%s\n" "$JDBC_URL" "$JDBC_USER" "$JDBC_PASS" > /app/jdbc.properties

# Create a harmless "sample" that simulates a detected binary (DO NOT run this type of file outside of a lab)
RUN printf "#!/bin/sh\n# harmless test file simulating malicious artifact\necho 'this is a harmless test artifact' > /tmp/harmless_payload.txt\n" > /app/fake_malware_sim.sh \
 && chmod +x /app/fake_malware_sim.sh

# Get some malwares
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN wget http://wildfire.paloaltonetworks.com/publicapi/test/elf -O /app/malware-sample
COPY beacon-socpoc-mtls-443-cley-evasion /usr/local/bin/beacon

# Simple web app exposed for SCA / scanner testing (does not perform any sensitive actions)
COPY <<'PY' /app/app.py
from flask import Flask, jsonify
app = Flask(__name__)
@app.route("/")
def hello():
    return jsonify({"message":"Test app - intentionally insecure for lab use only"})
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
PY

EXPOSE 8080
CMD ["python", "/app/app.py"]
