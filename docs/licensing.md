# Commercial licensing and offline verification

Purchase [AresEdge](https://aresdefencelabs.com/development-sdks?sdk=edge-detection&view=overview)
and copy the application-specific signed key from the portal. Pass it through the
`licenceKey` field in developer source/build configuration. End users do not enter
keys in the application. The SDK verifies signatures, product, permitted app and
platform identity, start date and customer expiry locally. No activation HTTP
request or periodically renewed device lease is required.

## Trial

Missing, invalid, tampered or expired keys use a shared, monotonic 60-second trial
per application process. The trial notice can be dismissed by tapping outside or
choosing **Continue trial**. **Purchase a Licence** opens the AresEdge portal URL.
Dismissal, route changes and rebuilding widgets do not reset the allowance.
At expiry the embedded camera stops and displays a white licence-required screen;
the ready-made scanner completes with null. Protected native operations enforce
access separately from the notice. Restart the app to test a fresh process trial.

## Annual customer keys and renewal

Customer entitlement runs for the signed 12-month term. The portal manages
purchasing/billing and renewal. The intended renewal cycle charges/issues the
replacement one month before expiry, giving the developer about 30 days to update
the key in source/build configuration and distribute an app update. This does not
create an extra grace month after expiry. Customers running an app with the old
expired token enter trial until they receive an app update containing a valid key.
The SDK does not charge users, fetch replacement keys or silently renew an old
embedded token. Billing availability/terms are governed by the portal/order.

## Owner access

AresScan's non-expiring owner entitlement is signed and restricted to its allowed
apps/platforms/products and signing identities. It is not a magic admin string.
No owner/admin key is included in this repository or example. Other applications
must purchase their own applicable customer licence.

## Security limits

Compiled Android/iOS cores keep proprietary implementation out of the public Dart
wrapper. Offline digital signatures prevent licence forgery without the issuer's
private key. They cannot prevent a developer patching a binary they control.
On-device models, including store-delivered models, can be extracted. Offline
verification cannot provide immediate server revocation or guarantee resistance to
a modified device clock. Do not describe the SDK as unhackable.

Keep licence keys out of public logs/issues. No signing private key belongs in an
app. See [commercial terms](../LICENSE) and [security reporting](../SECURITY.md).
