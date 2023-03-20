#!/bin/bash

set -eEuo pipefail

function generate_password() {
    shuf -er -n32  {A..Z} {a..z} {0..9} | tr -d '\n'
}

if [ -f "$DESTINATION/docker" ]
then
    >&2 echo "Using existing Docker secrets."
else
    >&2 echo "Generating new Docker secrets..."
    cat <<-EOF > "$DESTINATION/docker"
	POSTGRES_PASSWORD="$(generate_password)"
	JWT_SECRET="$(generate_password)"
	EOF
fi

source "$DESTINATION/docker"

>&2 echo "Regenerating tokens..."
cat << EOF > "$DESTINATION/tokens"
WRITER_TOKEN="$(jwt encode --secret "$JWT_SECRET" '{"role": "writer"}')"
EOF

>&2 echo "Setup completed."
