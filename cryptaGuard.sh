#!/bin/bash

echo "========================="
echo " AES Encryption Tool"
echo "========================="

# -------------------------
# CHECK OPENSSL
# -------------------------
if ! command -v openssl &> /dev/null; then
    echo "OpenSSL not installed!"
    exit 1
fi

# -------------------------
# MODE
# -------------------------
echo "Choose mode:"
echo "1) Encrypt"
echo "2) Decrypt"
read mode

# -------------------------
# TARGET
# -------------------------
echo "Enter file or folder path:"
read target

if [ ! -e "$target" ]; then
    echo "Invalid path!"
    exit 1
fi

# -------------------------
# AES MODE
# -------------------------
echo "Choose AES strength:"
echo "1) AES-128"
echo "2) AES-192"
echo "3) AES-256"
read aes_choice

if [ "$aes_choice" == "1" ]; then
    CIPHER="aes-128-cbc"
    KEY_BYTES=16
elif [ "$aes_choice" == "2" ]; then
    CIPHER="aes-192-cbc"
    KEY_BYTES=24
else
    CIPHER="aes-256-cbc"
    KEY_BYTES=32
fi

# -------------------------
# KEY SELECTION
# -------------------------
echo "Choose key type:"
echo "1) Provide HEX key"
echo "2) Generate random key"
echo "3) Password-based key"
read key_type

if [ "$key_type" == "1" ]; then
    echo "Enter HEX key:"
    read KEY

elif [ "$key_type" == "2" ]; then
    KEY=$(openssl rand -hex $KEY_BYTES)
    echo "Generated Key: $KEY"

elif [ "$key_type" == "3" ]; then
    echo "Enter password:"
    read -s PASSWORD
    echo ""

    # derive key using SHA-256 (simple but acceptable)
    FULL_HASH=$(echo -n "$PASSWORD" | openssl dgst -sha256 | awk '{print $2}')

    # truncate based on AES size
    if [ "$KEY_BYTES" -eq 16 ]; then
        KEY=${FULL_HASH:0:32}
    elif [ "$KEY_BYTES" -eq 24 ]; then
        KEY=${FULL_HASH:0:48}
    else
        KEY=${FULL_HASH:0:64}
    fi
fi

# -------------------------
# VALIDATE KEY LENGTH
# -------------------------
EXPECTED_LEN=$((KEY_BYTES * 2))

if [ ${#KEY} -ne $EXPECTED_LEN ]; then
    echo "Error: Key must be $EXPECTED_LEN hex characters for selected AES size."
    exit 1
fi

# -------------------------
# ENCRYPT FUNCTION
# -------------------------
encrypt_file() {
    file="$1"

    # skip already encrypted files
    if [[ "$file" == *.enc ]]; then
        echo "Skipping already encrypted: $file"
        return
    fi

    echo "Encrypting: $file"

    IV=$(openssl rand -hex 16)

    openssl enc -$CIPHER -in "$file" -out "$file.enc.tmp" -K "$KEY" -iv "$IV"

    # prepend IV
    echo "$IV" | xxd -r -p > "$file.enc"
    cat "$file.enc.tmp" >> "$file.enc"
    rm "$file.enc.tmp"

    echo "Encrypted -> $file.enc"
}

# -------------------------
# DECRYPT FUNCTION
# -------------------------
decrypt_file() {
    file="$1"

    # only decrypt .enc files
    if [[ "$file" != *.enc ]]; then
        echo "Skipping non-encrypted file: $file"
        return
    fi

    echo "Decrypting: $file"

    IV=$(xxd -p -l 16 "$file")
    tail -c +17 "$file" > "$file.body"

    output="${file%.enc}.dec"

    openssl enc -d -$CIPHER -in "$file.body" -out "$output" -K "$KEY" -iv "$IV"

    rm "$file.body"

    echo "Decrypted -> $output"
}

# -------------------------
# PROCESS FILE
# -------------------------
process_file() {
    if [ "$mode" == "1" ]; then
        encrypt_file "$1"
    else
        decrypt_file "$1"
    fi
}

# -------------------------
# PROCESS FOLDER (RECURSIVE)
# -------------------------
process_folder() {
    folder="$1"

    for item in "$folder"/*; do
        if [ -f "$item" ]; then
            process_file "$item"
        elif [ -d "$item" ]; then
            process_folder "$item"
        fi
    done
}

# -------------------------
# RUN
# -------------------------
if [ -f "$target" ]; then
    process_file "$target"

elif [ -d "$target" ]; then
    process_folder "$target"
fi

echo "Done."
