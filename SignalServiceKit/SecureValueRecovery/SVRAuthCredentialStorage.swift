//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

extension SVR {
    static let maxSVRAuthCredentialsBackedUp: Int = 10
}

public protocol SVRAuthCredentialStorage {

    /// Stores an `SVR2AuthCredential` to both local storage and iCloud storage, overwriting
    /// any existing credentials for the same username.
    /// Also marks the credential as "current", using it for future SVR requests until a new credential
    /// is provided to this method.
    /// Stores up to `SVR.maxSVRAuthCredentialsBackedUp` credentials; if more are inserted,
    /// they are dropped in FIFO order.
    ///
    /// Note multiple accounts can share an iCloud and so more than one user may be present in storage.
    /// iCloud storage is used to re-register on other devices without the need for OTP verification via phone number.
    func storeAuthCredentialForCurrentUsername(_ auth: SVR2AuthCredential, _ transaction: DBWriteTransaction)

    /// Gets all stored `SVR2AuthCredential`s, from local disk if available, or iCloud otherwise.
    /// Credentials may be expired or invalid for a particular e164; callers should poke the registration
    /// server to validate them as a set.
    /// Returns up to `SVR.maxSVRAuthCredentialsBackedUp` credentials.
    func getAuthCredentials(_ transaction: DBReadTransaction) -> [SVR2AuthCredential]

    /// Gets the `SVR2AuthCredential` that was most recently stored on this device.
    /// Returns nil if there are no backed up credentials, or if all credentials came from iCloud
    /// storage and therefore there is no concept of a "current" username.
    /// In such cases, the user should go through registration using the full list with
    /// `getAuthCredentials`.
    func getAuthCredentialForCurrentUser(_ transaction: DBReadTransaction) -> SVR2AuthCredential?

    /// Removes the provided credentials from storage.
    /// Should be called when the server tells the client the credential(s) are invalid.
    func deleteInvalidCredentials(_: [SVR2AuthCredential], _ transaction: DBWriteTransaction)

    // MARK: - KBS (SVR1)

    // Everything below here can be cleanly removed alongisde KeyBackupServiceImpl
    // once KBS is deprecated in favor of SVR2.

    /// Stores an `KBSAuthCredential` to both local storage and iCloud storage, overwriting
    /// any existing credentials for the same username.
    /// Also marks the credential as "current", using it for future KBS requests until a new credential
    /// is provided to this method.
    /// Stores up to `SVR.maxSVRAuthCredentialsBackedUp` credentials; if more are inserted,
    /// they are dropped in FIFO order.
    ///
    /// Note multiple accounts can share an iCloud and so more than one user may be present in storage.
    /// iCloud storage is used to re-register on other devices without the need for OTP verification via phone number.
    func storeAuthCredentialForCurrentUsername(_ auth: KBSAuthCredential, _ transaction: DBWriteTransaction)

    /// Gets all stored `KBSAuthCredential`s, from local disk if available, or iCloud otherwise.
    /// Credentials may be expired or invalid for a particular e164; callers should poke the registration
    /// server to validate them as a set.
    /// Returns up to `SVR.maxSVRAuthCredentialsBackedUp` credentials.
    func getAuthCredentials(_ transaction: DBReadTransaction) -> [KBSAuthCredential]

    /// Gets the `KBSAuthCredential` that was most recently stored on this device.
    /// Returns nil if there are no backed up credentials, or if all credentials came from iCloud
    /// storage and therefore there is no concept of a "current" username.
    /// In such cases, the user should go through registration using the full list with
    /// `getAuthCredentials`.
    func getAuthCredentialForCurrentUser(_ transaction: DBReadTransaction) -> KBSAuthCredential?

    /// Removes the provided credentials from storage.
    /// Should be called when the server tells the client the credential(s) are invalid.
    func deleteInvalidCredentials(_: [KBSAuthCredential], _ transaction: DBWriteTransaction)
}
