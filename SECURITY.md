# AresEdge security

Report security issues privately to team@aresdefencelabs.com with a minimal,
redacted reproduction. Do not post licence keys, customer documents, signing
material or an exploitable bypass in public issues. Do not send private keys.

Customer and owner entitlements are verified offline by pinned native verifiers.
Customer keys cover unlimited Android/iOS apps and need no activation lease.
Sandbox and production issuer trust remain separate; sandbox keys are rejected
by production builds. A portal licence ID is not an SDK credential.
Customer terms expire; signed owner ADLSA2 grants can be non-expiring and remain
bound to the authorised application/platform/signing identities. Native gates
apply the shared 60-second process trial to unauthorised operation. Trial notices
are dismissible, but dismissing them never removes the native access checks.

Compiled native cores reduce exposed implementation source. Offline signatures
prevent token forgery; they do not make code or on-device models unextractable or
unpatchable. Offline use cannot provide immediate revocation or trusted UTC on
an attacker-controlled device. No unhackable or tamper-proof claim is made.

Use release builds, R8, Flutter obfuscation and private debug symbols/mappings.
Never put signing private keys or owner credentials in a public example/repo.

## Encrypted customer model

Customer artifacts contain an authenticated AES-256-GCM `.aem` model container,
with a random nonce and authentication tag. A corrupted/truncated container or
cleartext replacement is rejected. Android loads decrypted bytes into a direct
memory buffer. The current iOS ORT interface accepts a file path: the SDK creates
a protected temporary file and removes it after session creation, including error
paths. The public model-path lookup returns the encrypted resource path.

The offline decryption key is embedded in compiled native code. A developer who
controls the process can recover that key, inspect decrypted memory or patch the
binary. Encryption protects against ordinary archive extraction; it does not
establish model secrecy against the host. OS/runtime copies and inference-provider
caches cannot be guaranteed erased. Owner/store-delivered raw model paths remain
compatible in the private source edition; store assets need their own packaging
review when AresScan migrates to the hosted customer package.

Queued scanner work rechecks access before execution and before successful native
result delivery. The customer edition rejects legacy owner AI/video channel calls.
A process restart resets the evaluation trial by design. Offline wildcard customer
keys can be shared, cannot be immediately revoked and rely on local time at startup.


## Customer offline dependency boundary

Customer native builds exclude owner-only ML Kit image labelling, Play Integrity
and App Attest implementations. Legacy attestation/challenge/lease channel calls
return method-not-implemented. Package guards check the actual native artifacts
for retained Google/DeviceCheck references; the owner source edition keeps its
separate APIs. User-selected purchase links may open the host browser. These are
targeted controls, not proof that every host app or OS component is network-silent.

Third-party licences and covered-source references accompany the customer package
in `THIRD_PARTY_NOTICES.md` and `SOURCE_AVAILABILITY.md`. The unchanged document
model is the hash-verified DocsaidLab DocAligner FastViT-T8 Apache 2.0 checkpoint;
its original licence rights survive renaming and encrypted packaging.
