# cryptaGuard
AES-based file and folder encryption and decryption tool.

Bash-based encryption tool that provides secure file and folder encryption and decryption using AES (Advanced Encryption Standard). It supports multiple key management methods and recursive directory encryption for protecting data at rest.

---

# Features

- Encrypt and decrypt single files
- Encrypt and decrypt entire folders
- Recursive folder support (nested directories)
- AES encryption support:
  - AES-128
  - AES-192
  - AES-256
- Multiple key options:
  - User-provided hexadecimal key
  - Randomly generated cryptographic key
  - Password-based key derivation
- CBC mode encryption using OpenSSL
- Automatic IV generation and storage within encrypted files

---

# Cryptographic Implementation

VaultCrypt uses the following cryptographic components:

- **Encryption Tool:** OpenSSL
- **Algorithm:** AES (CBC mode)
- **Key Handling:**
  - Hexadecimal keys using `-K`
  - Random key generation using `openssl rand`
  - Password-based derivation using SHA-256 hashing
- **Initialization Vector (IV):**
  - Randomly generated per file
  - Stored inside encrypted file for automatic decryption

---

# Requirements

- Bash shell (Git Bash or WSL recommended for Windows)
- OpenSSL installed and available in PATH
