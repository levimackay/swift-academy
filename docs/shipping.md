---
title: Shipping, signing, and installing
kind: reference
verified: not applicable, this file contains no Swift samples
---

# Shipping

Everything between "it runs in the simulator" and "it is on a phone".

Read it when you reach the capstone. It is reading rather than exercises: the
mechanics are Xcode UI and Apple web forms, both of which change, and a
transcript of button clicks goes stale faster than anything else in this repo.
What does not go stale is the model, so that is what this page is.

**The capstone is done when a signed build is installed on your own device and
you have used it.** App Store submission is a stated post course goal, not a
completion gate, because review latency is measured in days and is not yours
to schedule.

---

## 1. The model: four things, and what each one is

Code signing exists to answer one question at launch: is this binary the one
its author built, and is that author allowed to run it here. Four artifacts
answer it.

| Artifact | What it is | Where it lives |
|---|---|---|
| **Bundle ID** | The app's unique name, reverse DNS, for example `com.levimackay.fieldnotes`. | Set in the target's settings, registered with Apple. |
| **Certificate** | Proves who you are. A public/private key pair; the private key lives in your Keychain and nowhere else. | Keychain Access, plus a copy of the certificate in your developer account. |
| **Provisioning profile** | Ties a certificate, a bundle ID, a set of entitlements, and a list of device UDIDs together. | Downloaded by Xcode, embedded in the built app. |
| **Entitlements** | The capabilities the app claims: push, iCloud, keychain sharing, app groups. | A `.entitlements` file, and mirrored in the profile. |

The failure modes are all mismatches between those four. A signing error is
almost never "the certificate is broken"; it is "the profile does not include
this device", or "the entitlements in the file are not in the profile", or
"the bundle ID does not match the one the profile names".

**Development versus distribution.** A development certificate and profile let
your build run on devices you list. A distribution certificate and profile let
you upload to App Store Connect and cannot run directly on a device. Two
different pipelines, and Xcode will silently pick the wrong one if the scheme
is set to Debug when you meant to archive.

---

## 2. Free account versus the paid program

| | Free Apple ID | Apple Developer Program (99 USD/year) |
|---|---|---|
| Run on your own device | Yes | Yes |
| Profile lifetime | **7 days** | 1 year |
| Number of app IDs | 10 at a time | Unlimited |
| Capabilities | Limited: no push, no CloudKit, no app groups | All |
| TestFlight | No | Yes |
| App Store | No | Yes |

**The seven day expiry is a real design constraint on the capstone, not
trivia.** A build signed with a free Apple ID stops launching after seven
days: tapping the icon shows a "no longer available" alert and the fix is to
reconnect the device and rebuild from Xcode.

The capstone milestone asking you to use your own app for seven consecutive
days without rebuilding collides with that exactly. Either buy the membership
before you reach it, or read that milestone as "reinstall on day seven and
keep going", and write down in `CAPSTONE-SPEC.md` which you chose. Do not
discover the collision on day seven.

---

## 3. The minimum path: onto your own phone

1. Plug the phone in. Trust the computer on the phone, trust the phone in
   Xcode.
2. In the target's Signing and Capabilities tab, tick **Automatically manage
   signing** and pick your team. For a free account the team is your name
   (Personal Team).
3. Set the bundle ID to something nobody else has used. Free-tier IDs are
   claimed globally on first use, so `com.example.myapp` is already taken by
   somebody's tutorial and will fail.
4. Pick the device in the scheme's destination menu and Run.
5. First launch fails with "Untrusted Developer". On the phone: Settings,
   General, VPN and Device Management, your account, Trust. This is once per
   account, not once per build.

That is the whole thing. Automatic signing generates the certificate, requests
the profile, registers the device, and downloads it, and the reason to know
section 1 is that when it goes wrong the error names one of those four
artifacts.

**Configure it by hand once.** Turn automatic signing off, create the App ID
in the developer portal, create the profile, download it, select it. It takes
twenty minutes and it converts every future signing error from magic into a
mismatch you can name. Then turn automatic signing back on and leave it on.

---

## 4. Version and build numbers

Two fields, and confusing them is the most common release-day mistake.

- **Marketing version** (`CFBundleShortVersionString`, "Version"): what users
  see. `1.2.0`. Semantic versioning is convention, not enforcement.
- **Build number** (`CFBundleVersion`, "Build"): what App Store Connect uses
  for uniqueness. Must increase for every upload of the same marketing
  version. Never reused, ever, including for a build you deleted.

App Store Connect rejects a duplicate build number after the upload has
finished processing, which means the failure arrives by email ten minutes
after you thought you were done. Increment the build number as the first step
of archiving, not the last.

---

## 5. The privacy manifest

`PrivacyInfo.xcprivacy`, a property list in your app bundle, **mandatory since
2024**. It declares two things Apple checks at submission:

1. **Data collection.** Which categories of data your app collects, whether it
   is linked to identity, and whether it is used for tracking. If your app
   collects nothing, you still ship the file and say so.
2. **Required reason APIs.** A specific list of APIs (file timestamps,
   `UserDefaults`, disk space, active keyboards, system boot time) that
   require a declared reason code, because they were historically used for
   fingerprinting. `UserDefaults` is on that list, which surprises everyone:
   using it at all requires declaring a reason.

Third-party SDKs ship their own manifests and Xcode aggregates them into one
privacy report at archive time. This is one more argument for the capstone's
"adopt at most one dependency" rule.

A missing or wrong manifest is an automated rejection on upload, not a review
rejection, so you find out in minutes rather than days. That is the good case.

---

## 6. Archive, validate, distribute

The sequence, in order, with what each step actually catches:

1. **Set the destination to "Any iOS Device".** Archiving with a simulator
   destination produces an archive that cannot be distributed, and the menu
   item is greyed out with no explanation.
2. **Product, Archive.** Builds Release. Everything that was fine in Debug and
   is broken in Release surfaces here: a `#if DEBUG` block hiding a
   compilation error, an optimization exposing undefined behavior, a missing
   asset that was in a debug-only bundle.
3. **Validate App.** Checks the signature, the entitlements against the
   profile, the privacy manifest, the icon set, and the build number against
   what App Store Connect already has. Free, fast, and it catches most of what
   distribution would reject.
4. **Distribute App.** Uploads. Then App Store Connect processes it, which
   takes minutes to an hour, and emails you if processing fails.

Screenshots are required for submission and are per device size class. The
sizes change. Generate them from the simulator at the exact required
resolutions rather than resizing, because App Store Connect rejects
off-by-one dimensions.

---

## 7. TestFlight

The step this course cares about most, and the one it does not currently
require.

Getting a build to **one real external tester who is not you** finds a class
of problem nothing else does: an app that only works because your device has
state on it from development, an onboarding flow that assumes knowledge you
have, a permission prompt whose denied path you never took. It is also the
only realistic way to read a crash report from a machine you do not control.

Internal testers (up to 100, from your team) get builds immediately. External
testers (up to 10,000) require a review of the first build of each version,
which is usually a day and is much faster than App Store review.

Feedback arrives in App Store Connect, and crash reports arrive symbolicated
if you uploaded the dSYMs, which the archive does by default.

---

## 8. App Review

Not a completion gate for this course. What to know anyway:

- **Latency is external.** Usually a day or two, sometimes much longer, never
  yours to schedule. Do not plan around a date.
- **The most common rejections are not technical.** Incomplete metadata,
  missing demo account credentials, a privacy policy URL that 404s, screenshots
  that do not match the app, and guideline 4.2 ("minimum functionality") for
  apps that are a wrapper around a website.
- **A rejection is a message, not a verdict.** You reply in Resolution Center,
  and most rejections are resolved by answering the question rather than by
  changing the app.
- **Demo credentials.** If anything is behind a login, supply working
  credentials in App Review Information. Omitting them is an automatic
  rejection and costs you a full review cycle.

---

## 9. Crash reports

Two sources: App Store Connect (from users who opted into sharing) and Xcode's
Organizer, which is the same data with a better view.

A crash report is useless unsymbolicated: it is addresses. Symbolication maps
addresses back to your function names using the **dSYM** produced at build
time, which is why the dSYM for every build you ship must be kept. Xcode
uploads them with the archive by default; if you build in CI, keeping the
dSYMs is a step you must add.

Three things to read first, in order: the exception type (`EXC_BAD_ACCESS` is
a memory error, `EXC_CRASH (SIGABRT)` is usually a Swift runtime trap or an
uncaught Objective C exception), the crashed thread's top frames, and whether
the crashed thread is thread 0 (the main thread). A Swift force unwrap of nil
appears as `SIGABRT` with `Fatal error: Unexpectedly found nil while
unwrapping an Optional value` in the log, which is the one crash you should
never see in a build from this repo.

---

## 10. Checklist before you call the capstone shipped

- [ ] Bundle ID registered and unique, and I chose it rather than a tutorial.
- [ ] I configured signing by hand once and can name the four artifacts.
- [ ] Build number increments on every upload, and I never reused one.
- [ ] `PrivacyInfo.xcprivacy` exists and is accurate, including any required
      reason APIs I use.
- [ ] Archive validates with no warnings.
- [ ] A signed build is installed on my own iPhone and I have used it for real
      work, not for a demo.
- [ ] I know when my provisioning profile expires and what happens then.
- [ ] Every diagnostic that cost more than ten minutes is in
      [../NOTES/errors.md](../NOTES/errors.md), including the signing ones.

---

Related: [../PREREQUISITES.md](../PREREQUISITES.md) for the cost and the
device requirement, and
[../projects/06-capstone/SPEC.md](../projects/06-capstone/SPEC.md) for the
acceptance criteria. The deeper version of this material, including
certificates built by hand and a real TestFlight round trip, is item 8 in
[ROADMAP-NEXT.md](ROADMAP-NEXT.md) and is not authored yet.
