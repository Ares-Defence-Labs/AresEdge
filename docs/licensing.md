# Commercial licensing and offline verification

Purchase [AresEdge](https://aresdefencelabs.com/development-sdks?sdk=edge-detection&view=overview)
and copy your signed customer licence key from the portal. One AresEdge customer
licence covers an unlimited number of your apps on every platform supported by
the SDK. The same key can be used across those apps and platforms; there is no
per-app or per-platform licence purchase. AresEdge currently supports Android and
iOS. This does not include licences for other SDK products or permit resale or
sharing of your licence with other developers or organisations.

Pass the key through the `licenceKey` field in developer source or private build
configuration. End users do not enter keys in the application. The SDK verifies
the signature, SDK product, signed customer entitlement, start date and expiry
locally. No activation HTTP request or periodically renewed device lease is required.

## Licence keys and licence IDs

Pass the full signed licence **key** to `licenceKey`, not the licence ID shown in
the portal. The licence ID identifies a purchase/term/product record for billing
and support; it is not itself an SDK credential. The SDK checks the key's signed
payload locally and never looks up the ID over the network.

An annual customer key uses the `EDSDK2` format. Current portal-issued customer
keys contain a signed `licenceScope: customer` and `applicationId: *`, covering
unlimited apps on Android and iOS. Customer keys require no app registration,
per-app certificate, activation server or installation limit. Use the same key
for both `AresEdgeEmbedded` and `AresEdgeScreen` across your apps.

Classification follows signature and entitlement validation: a valid signed
customer grant authorizes customer use; a valid signed owner grant authorizes
only its listed app/platform/signing identities. Changing a prefix, claim, expiry
or the name of a build variable cannot turn a customer key into an admin key.
Missing, malformed, tampered, wrong-product or expired keys use the trial.

## Sandbox and production

Stripe sandbox purchases issue sandbox-signed keys. Copy the new key from the
portal only after payment is confirmed; an open checkout or unpaid invoice does
not grant access. The SDK key and portal licence ID belong to that paid term.

Sandbox and production have separate issuer trust. Sandbox keys work only with
an explicitly supplied sandbox-trusted test build. The production customer
package intentionally rejects sandbox keys. For a production app, purchase in
the production portal and embed the production-issued key. There is no public
runtime option for replacing issuer trust; do not modify a release package's
verification certificate or include test issuer/private signing material.

To evaluate your integration, check the same sandbox key in two different app
identities on Android and iOS, then check a missing or altered key and the trial
boundary. Use a valid key for performance runs longer than the trial allowance.
The [platform guide](platforms.md) covers environment mismatch and other errors.

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
replacement one month before expiry, giving the developer about 30 days to ship
updates. Renewal issues a replacement licence key; it does not update keys already
embedded in distributed apps.

You are responsible for copying the renewed key from the portal, replacing it in
the source or private build configuration of every app using AresEdge, and shipping
those updates to customers on every supported platform before the current key
expires. Allow time for store review, rollout and customers installing the update.
The existing signed key remains valid until its own expiry; receiving a new key
does not update or extend it automatically.

If a customer device still runs an app containing an expired key, the SDK enters
trial mode: customers see the trial popup and protected scanning deactivates after
the 60-second live-session allowance. Dismissing the popup does not unlock the SDK.
Access returns when the installed app contains a valid key. There is no extra
grace month after expiry. The SDK does not charge end users, fetch replacement
keys or silently renew an embedded token. Billing terms are governed by the
portal/order.

## Owner access

AresScan's non-expiring owner entitlement is signed and restricted to its allowed
apps/platforms/products and signing identities. It is not a magic admin string.
No owner/admin key is included in the customer package or example. Customer
integrations use a purchased customer licence covering all of the licensee's apps
across supported platforms.

## Security limits

Compiled Android/iOS cores keep proprietary implementation out of the public Dart
wrapper. Offline digital signatures prevent licence forgery without the issuer's
private key. They cannot prevent a developer patching a binary they control.
On-device models, including store-delivered models, can be extracted. Offline
verification cannot provide immediate server revocation or guarantee resistance to
a modified device clock. Do not describe the SDK as unhackable.

Keep licence keys out of public logs/issues. No signing private key belongs in an
app. See [commercial terms](../LICENSE) and [security reporting](../SECURITY.md).

### Model protection

The customer package bundles an authenticated encrypted model. Android decrypts
it into memory; iOS loads it through a protected temporary file removed after
session creation. Model encryption and compiled native implementations increase
inspection effort. They cannot prevent extraction or patching by an app owner.
See the package SECURITY.md for the offline security boundaries.
