# One Second

A tiny iPhone app that makes you take a few slow breaths before Instagram, Facebook, or any app you add will open. Everything stays on the phone. No accounts, no network calls, no analytics.

## Quickest option: home screen web app (no Mac needed)

`docs/` has a single web page that does the breathing. You add one home screen icon per app. Tapping it makes you breathe first, then it offers to open the real app.

1. Make this repo public (Settings > General > Danger Zone > Change visibility). Nothing in it is secret.
2. Turn on GitHub Pages (Settings > Pages > Deploy from a branch > `claude/mindfulness-app-gate-u2ighx`, folder `/docs` > Save).
3. On your iPhone, open https://austinbaggio.github.io/onesecond/ in Safari and follow the steps on the page.

After the first load, the page is cached on the phone and makes no network calls. It only catches opens from your home screen icon. Opening the real app from the App Library, Spotlight, or a notification skips it.

## Native app version

## How it works

iOS doesn't let one app block another directly. Instead, a Shortcuts automation fires whenever a gated app opens and runs this app's **Breathe Before Opening** action:

1. You open Instagram. The automation runs.
2. One Second jumps to the front with a breathing circle (3 breaths by default).
3. When you're done, you choose: **Open Instagram** or **I don't need it right now**.
4. If you pick Open, you get a free pass for 10 minutes (adjustable) so the automation lets you through without looping.

## Install

Requires a Mac with Xcode 26 and an iPhone on iOS 26.

1. Open `OneSecond.xcodeproj` in Xcode.
2. Select the OneSecond target > Signing & Capabilities, then pick your Team (a free Apple ID works). Change the bundle ID if Xcode complains.
3. Plug in your iPhone, select it as the run destination, and press Run.
4. On the phone, trust the developer profile if asked (Settings > General > VPN & Device Management).

With a free Apple ID the app expires after 7 days. Just hit Run again to reinstall. A paid developer account extends this to a year.

## Set up an app (once per app)

1. Open One Second once so iOS registers its action. Add the apps you want gated (Instagram and Facebook are there already).
2. Open the **Shortcuts** app > **Automation** > **+** > **App**.
3. Choose the app (e.g. Instagram), check **Is Opened**, and select **Run Immediately**. Tap Next.
4. Tap **New Blank Automation** > **Add Action**, search for **Breathe Before Opening**, and add it.
5. Tap **App** in the action and pick the matching app.

Repeat for each app. To add an app that isn't in the preset list, you need its URL scheme (e.g. `instagram://`) so One Second can send you back to it.
