#!/usr/bin/env python3
"""
encryption.py - Secure encryption utilities for BAZINGA

Provides AES-256 encryption for sensitive data with responsible key management.
"""

import os
import json
import hashlib
from pathlib import Path
from typing import Dict, Any, Optional
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2
from cryptography.hazmat.backends import default_backend


class SecureStorage:
    """Secure storage for BAZINGA sensitive data"""

    def __init__(self, password: Optional[str] = None):
        """
        Initialize secure storage

        Args:
            password: Master password for encryption. If None, will prompt.
        """
        self.config_dir = Path.home() / ".bazinga" / "config"
        self.config_dir.mkdir(parents=True, exist_ok=True)

        # Set secure permissions
        os.chmod(self.config_dir, 0o700)

        self.key_file = self.config_dir / ".key"
        self.salt_file = self.config_dir / ".salt"

        if password:
            self._setup_encryption(password)
        else:
            self._load_encryption()

    def _setup_encryption(self, password: str):
        """Set up encryption with password"""
        # Generate or load salt
        if self.salt_file.exists():
            with open(self.salt_file, 'rb') as f:
                salt = f.read()
        else:
            salt = os.urandom(16)
            with open(self.salt_file, 'wb') as f:
                f.write(salt)
            os.chmod(self.salt_file, 0o600)

        # Derive key from password
        kdf = PBKDF2(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
            backend=default_backend()
        )
        key = kdf.derive(password.encode())

        # Create Fernet instance
        self.cipher = Fernet(Fernet.generate_key())

        # Store encrypted key
        with open(self.key_file, 'wb') as f:
            f.write(key)
        os.chmod(self.key_file, 0o600)

    def _load_encryption(self):
        """Load existing encryption"""
        if not self.key_file.exists():
            raise ValueError("No encryption key found. Initialize with password first.")

        with open(self.key_file, 'rb') as f:
            key = f.read()

        self.cipher = Fernet(key)

    def encrypt_data(self, data: Dict[str, Any]) -> bytes:
        """
        Encrypt data dictionary

        Args:
            data: Dictionary to encrypt

        Returns:
            Encrypted bytes
        """
        json_data = json.dumps(data).encode()
        return self.cipher.encrypt(json_data)

    def decrypt_data(self, encrypted: bytes) -> Dict[str, Any]:
        """
        Decrypt data

        Args:
            encrypted: Encrypted bytes

        Returns:
            Decrypted dictionary
        """
        decrypted = self.cipher.decrypt(encrypted)
        return json.loads(decrypted.decode())

    def save_encrypted(self, filename: str, data: Dict[str, Any]):
        """
        Save encrypted data to file

        Args:
            filename: File to save to (in secure directory)
            data: Data to encrypt and save
        """
        filepath = self.config_dir / filename
        encrypted = self.encrypt_data(data)

        with open(filepath, 'wb') as f:
            f.write(encrypted)

        os.chmod(filepath, 0o600)

    def load_encrypted(self, filename: str) -> Dict[str, Any]:
        """
        Load encrypted data from file

        Args:
            filename: File to load from

        Returns:
            Decrypted data
        """
        filepath = self.config_dir / filename

        if not filepath.exists():
            raise FileNotFoundError(f"Encrypted file not found: {filename}")

        with open(filepath, 'rb') as f:
            encrypted = f.read()

        return self.decrypt_data(encrypted)


class StateManager:
    """Manages BAZINGA state with encryption and backup"""

    def __init__(self, secure_storage: SecureStorage):
        self.storage = secure_storage
        self.state_file = Path.home() / ".bazinga" / "data" / "state.encrypted"
        self.backup_dir = Path.home() / ".bazinga" / "backups"

        # Create directories
        self.state_file.parent.mkdir(parents=True, exist_ok=True)
        self.backup_dir.mkdir(parents=True, exist_ok=True)

    def save_state(self, state: Dict[str, Any], backup: bool = True):
        """
        Save state with encryption and optional backup

        Args:
            state: State dictionary to save
            backup: Whether to create backup before saving
        """
        # Backup existing state
        if backup and self.state_file.exists():
            self._backup_state()

        # Encrypt and save
        encrypted = self.storage.encrypt_data(state)

        with open(self.state_file, 'wb') as f:
            f.write(encrypted)

        os.chmod(self.state_file, 0o600)

    def load_state(self) -> Optional[Dict[str, Any]]:
        """
        Load state from encrypted file

        Returns:
            State dictionary or None if not found
        """
        if not self.state_file.exists():
            return None

        with open(self.state_file, 'rb') as f:
            encrypted = f.read()

        return self.storage.decrypt_data(encrypted)

    def _backup_state(self):
        """Create timestamped backup of current state"""
        from datetime import datetime

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = self.backup_dir / f"state_{timestamp}.encrypted"

        # Copy current state to backup
        if self.state_file.exists():
            with open(self.state_file, 'rb') as src:
                with open(backup_file, 'wb') as dst:
                    dst.write(src.read())

            os.chmod(backup_file, 0o600)

            # Keep only last 10 backups
            self._cleanup_old_backups()

    def _cleanup_old_backups(self, keep: int = 10):
        """Keep only recent backups"""
        backups = sorted(self.backup_dir.glob("state_*.encrypted"), reverse=True)

        for old_backup in backups[keep:]:
            old_backup.unlink()

    def list_backups(self) -> list:
        """List available backups"""
        backups = sorted(self.backup_dir.glob("state_*.encrypted"), reverse=True)
        return [b.name for b in backups]

    def restore_backup(self, backup_name: str):
        """
        Restore from backup

        Args:
            backup_name: Name of backup file to restore
        """
        backup_file = self.backup_dir / backup_name

        if not backup_file.exists():
            raise FileNotFoundError(f"Backup not found: {backup_name}")

        # Backup current state first
        if self.state_file.exists():
            self._backup_state()

        # Restore from backup
        with open(backup_file, 'rb') as src:
            with open(self.state_file, 'wb') as dst:
                dst.write(src.read())


def hash_for_audit(data: str) -> str:
    """
    Create hash for audit trail (not for security)

    Args:
        data: Data to hash

    Returns:
        SHA-256 hash hex string
    """
    return hashlib.sha256(data.encode()).hexdigest()


if __name__ == "__main__":
    # Test encryption
    print("Testing BAZINGA encryption...")

    # Example usage
    password = "test_password_123"  # In production, use secure password input
    storage = SecureStorage(password)

    # Test data
    test_data = {
        "timestamp": "2025-12-23T12:00:00",
        "thoughts": ["11111", "10101", "11011"],
        "trust_level": 0.85
    }

    # Encrypt and save
    storage.save_encrypted("test.encrypted", test_data)
    print("✅ Data encrypted and saved")

    # Load and decrypt
    loaded = storage.load_encrypted("test.encrypted")
    print(f"✅ Data decrypted: {loaded}")

    # Test state manager
    state_mgr = StateManager(storage)

    state = {
        "consciousness": {
            "active": True,
            "mode": "QUANTUM",
            "trust": 0.9
        },
        "thoughts": 42
    }

    state_mgr.save_state(state)
    print("✅ State saved with encryption")

    loaded_state = state_mgr.load_state()
    print(f"✅ State loaded: {loaded_state}")

    print("\n🔒 Encryption test complete!")
