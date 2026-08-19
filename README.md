# BiteBay — a food delivery app demo

**Live web app:** https://thatsourabhguy.github.io/bitebay/
**Android app:** `BiteBay-v1.0.apk` (built with `flutter build apk --release`)

A Swiggy-style food ordering app built with Flutter. Everything you see —
restaurants, dishes, prices, ratings, addresses, payment options — is sample
data stored inside the app. There is **no server, no login and no real
payment**.

The app runs from the same code on **Android, iOS and the web**.

---

## What you can do in the app

1. **Home** — see your delivery location, search, food categories, offer
   banners, top-rated restaurants and every restaurant nearby.
2. **Search / All restaurants** — type to search, filter by Pure Veg,
   Rating 4.0+, Fast Delivery or Great Offers, and sort by rating, delivery
   time or price.
3. **Restaurant details** — photo header, rating, delivery time, cost for
   two, the full menu grouped into sections, and a "Veg only" switch.
4. **Cart** — change quantities, remove dishes, apply a coupon and see the
   full bill.
5. **Checkout** — pick an address, review the order, choose a payment
   method and place the order.
6. **Order placed** — a confirmation screen with your order number and
   estimated arrival time.

### Sample coupon codes

| Code       | What it does                  | Minimum order |
| ---------- | ----------------------------- | ------------- |
| `BITE50`   | 50% off, up to ₹100           | ₹199          |
| `FEAST125` | Flat ₹125 off                 | ₹399          |
| `FREEDEL`  | Free delivery                 | ₹299          |

Delivery is free automatically on orders of ₹499 or more.

---

## How the project is organised

Think of `lib/` as the app's brain. Each folder has one job:

```
lib/
  main.dart                  The starting point. Creates the app and its shared state.

  core/                      Things used everywhere
    theme/                   Colours, text sizes, spacing — the app's "look"
    router/                  The list of screens and how to move between them
    utils/                   Rupee formatting and responsive-layout helpers

  data/                      Where information comes from
    models/                  The shape of a Restaurant, MenuItem, CartItem...
    sources/                 The actual fake restaurants, menus and addresses
    repositories/            The "supplier" of data (see note below)

  state/                     Information shared across screens
    cart_controller.dart     The cart and all the bill maths
    navigation_controller.dart  Which bottom tab is open

  widgets/                   Reusable pieces used on many screens
                             (restaurant card, rating badge, quantity
                             stepper, bill card, cart bar...)

  features/                  One folder per screen
    home/  restaurants/  restaurant_details/  cart/  checkout/  account/  shell/
```

### Why the `repositories` folder matters

`restaurant_repository.dart` describes **what** data the app needs, without
saying where it comes from. `fake_restaurant_repository.dart` answers those
requests from the local sample data.

When you are ready for a real backend, you write one new file that answers
the same requests from your server, and change a single line in
`main.dart`. **No screen has to be rewritten.** That is the whole point of
building it this way.

---

## Running the app

Flutter lives at `C:\src\flutter` on this machine. Open a terminal in the
`bitebay` folder and use one of these.

### Web (works today on this laptop)

```bash
C:\src\flutter\bin\flutter run -d chrome
```

### Android emulator

Requires **Intel Virtualization (VT-x) to be switched on in the BIOS** —
see the note below. Once it is on:

```bash
C:\src\flutter\bin\flutter emulators --launch swiggy_emu
C:\src\flutter\bin\flutter run
```

### A real Android phone (fastest option on this laptop)

Turn on Developer Options and USB Debugging on the phone, plug it in, then:

```bash
C:\src\flutter\bin\flutter run
```

### iOS

iOS apps can only be built on an Apple Mac. On a Mac with Xcode installed:

```bash
flutter run -d ios
```

---

## Checking the code is healthy

```bash
C:\src\flutter\bin\flutter analyze
```

```bash
C:\src\flutter\bin\flutter test
```

`analyze` looks for mistakes in the code. `test` runs 13 automated checks
covering the cart maths (totals, coupons, quantity changes) and the screens
opening and responding to taps.

---

## What is deliberately not built yet

- Sign in / sign up
- A real backend or database
- **Live** payments — Razorpay is wired up in **test mode** only, and needs a
  server before it can safely take real money (see the Payments section)
- Live restaurant data
- Order tracking and order history

The code is structured so each of these can be added without redesigning
what already exists.

---

## A note on images

Food photographs are loaded from a free public photo service. If the device
is offline, each photo is replaced by a soft coloured placeholder, so the
app still looks complete without an internet connection.

---

## Payments (Razorpay)

The checkout screen opens a real Razorpay payment window, in **test mode**.
Every payment method except Cash on Delivery goes through Razorpay.

Android and iOS use Razorpay's official Flutter package. The web uses
Razorpay's own `checkout.js` script. The right one is picked automatically, and
both are driven through a single `PaymentService` in `lib/payments/`, so no
screen knows which payment company is being used.

### Changing the key

The Key Id lives on one line in `lib/payments/razorpay_config.dart`:

```dart
static const String _keyIdWrittenInCode = 'rzp_test_...';
```

To use a different key, get it from **https://dashboard.razorpay.com** →
**Account & Settings** → **API Keys** (with the dashboard in **Test Mode**),
paste it on that line, and rebuild.

Leave the line empty (`''`) and the app quietly goes back to the old pretend
checkout with no payment window — handy if you want to demo without payments.

### Testing a payment

In test mode use Razorpay's test card — **any** future expiry date and **any**
CVV work:

| Field  | Value                 |
| ------ | --------------------- |
| Card   | `4111 1111 1111 1111` |
| Expiry | any future date       |
| CVV    | any 3 digits          |

No real money moves. Test payments appear in your Razorpay dashboard while it
is in Test Mode.

### The two keys, and which one is safe

Razorpay gives you a **Key Id** and a **Key Secret**.

- The **Key Id** is safe in this project. It is meant to be visible inside apps
  and web pages.
- The **Key Secret** must **never** go into this project. Anyone can open up an
  installed app or a web page and read whatever is inside it. The secret
  belongs only on a server you control.

### Before you take real money — please read

This build has no server, which has one important consequence: **the app cannot
prove a payment really happened.** It simply believes the phone when the phone
says "paid". In test mode that does not matter. With real money, someone
technical could fake a successful payment and order food for free.

To take real payments safely you need a small server that:

1. creates each order through Razorpay's Orders API before checkout, and
2. verifies Razorpay's signature afterwards using the Key Secret.

That server is the only place the Key Secret should ever live. The app is
already structured for this: everything payment-related sits behind
`PaymentService` in `lib/payments/`, so adding the server steps does not
require changing any screen.

You will also need a Razorpay account with KYC completed before live mode can
be enabled, which takes a few days.

---

## Updating the live website

The live site is served from the `gh-pages` branch of this repository, using
a second copy of the project kept in `../bitebay-ghpages`.

After changing the code, run these three steps from the `bitebay` folder:

```bash
C:/src/flutter/bin/flutter build web --release --base-href /bitebay/
```

```bash
cp -r build/web/. ../bitebay-ghpages/
```

```bash
cd ../bitebay-ghpages && git add -A && git commit -m "Update live site" && git push
```

The website refreshes about a minute after the push. If you still see the old
version, do a hard refresh in the browser (**Ctrl + Shift + R**) — the app
caches itself so it can work offline.

**Important:** `--base-href /bitebay/` must match the repository name. If you
ever rename the repository, change that value too or the live page will load
a blank screen.

### Rebuilding the Android file

```bash
C:/src/flutter/bin/flutter build apk --release
```

The file appears at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Troubleshooting on this laptop

Two machine-specific problems were found and fixed while setting this up.
If you ever see them again, this is what they mean.

### "PKIX path building failed" when building for Android

Avast antivirus inspects secure web traffic by replacing website certificates
with its own. Windows trusts Avast's certificate, but Java — which Android
builds run on — keeps a completely separate list of trusted certificates, and
Avast is not on it. So Gradle could not download anything.

**Already fixed.** Avast's certificate was copied into a Java trust store at
`C:\Users\lenovo\.gradle\certs\cacerts-with-avast`, and
`android/gradle.properties` now points Java at it.

Command-line tools like `sdkmanager` do not read that file, so if one of them
fails the same way, set this first in the same terminal:

```bash
set JAVA_OPTS=-Djavax.net.ssl.trustStore=C:/Users/lenovo/.gradle/certs/cacerts-with-avast -Djavax.net.ssl.trustStorePassword=changeit
```

### The Android emulator will not start

The emulator needs **Intel Virtualization (VT-x)**, which is currently
switched **off in this laptop's BIOS**. No software can turn it on — it has to
be changed on the setup screen that appears before Windows loads:

1. **Start** → **Power** → hold **Shift** and click **Restart**
2. **Troubleshoot** → **Advanced options** → **UEFI Firmware Settings** → **Restart**
3. Find **Intel Virtual Technology** / **VT-x** / **Virtualization Technology**
   under a tab named Configuration, Advanced or Security
4. Set it to **Enabled**, press **F10** to save and exit

Even once enabled, this laptop (Core i3-8130U, 8 GB RAM, Intel UHD 620) is
below the emulator's recommended specification and the graphics fall back to
software rendering, so the emulator will run slowly.

**A real Android phone over USB is much faster** and needs no BIOS change.
