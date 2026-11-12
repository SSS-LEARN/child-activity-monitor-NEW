# Project demo: step by step

The whole demo runs on a Windows laptop, standing in for the Raspberry Pi, and takes
about 19 minutes. Do the setup the day before, not in front of the panel.

## Part A: setup (day before)

1. **Install Python 3.12** from <https://www.python.org/downloads/>. Tick **"Add Python to
   PATH"** in the installer.
2. **Unzip** `child-activity-monitor.zip`, for example to your Desktop.
3. **Double-click `START_WINDOWS.bat`.** The first time it installs everything (5 to 10
   minutes), downloads the AI models, loads a week of demo data and opens the dashboard
   in your browser.
   * Already ran an older version? Unzip the new version **over** the old folder (or into
     a new folder), close the dashboard window, double-click `START_WINDOWS.bat` once
     (it installs anything new and downloads the face models), close it again, then
     double-click `RESET_DEMO_DATA.bat` to get Kabir, the classroom camera and the new
     demo events.
4. **Record test clips** on a phone, 15 to 60 seconds each, one activity per clip, with
   the whole body in view: reading a book, using a phone, playing, eating, lying down,
   running across the room, jumping, and a **gentle, safe "fall"** onto a mattress or
   sofa cushions. Copy them to the laptop.
   For the new behaviour flags, also record (with a friend or sibling; act it, nobody
   gets hurt):
   * **zoned out:** sit upright, hands empty in your lap, staring ahead, for **40
     seconds** (it only counts after 20 seconds of stillness);
   * **upset / crying:** sit with your face buried in both hands for 20 seconds;
   * **group:** two or three people standing or sitting side by side, doing different
     things (one reading, one on a phone), 30 seconds;
   * **pretend fight:** two people side by side, close together, both flailing their
     arms quickly at each other (no contact needed) for 5 to 10 seconds.
5. **Optional: face photos for name tags.** On the Admin page, under **Face photos**,
   upload 3 to 5 clear front-facing photos of each person who will be in your group
   clip, under the child names you will use (for example you as Aarav, your friend as
   Diya). Without photos, names go by seat order from left to right, which is fine for
   the demo.
6. **Optional: set up Telegram alerts** so a real message arrives on your phone during
   the demo. See "Setting up Telegram alerts" in the README. It takes about 5 minutes.
7. **Demo backup:** copy your best clips into the `demo_clips` folder. If the webcam
   fails on the day, double-click `START_DEMO_CAMERA.bat` instead of
   `START_LIVE_CAMERA.bat`; the clips play on the Live camera page as if live.
8. **Do a trial run** of Part B once. Do not change the admin password on the demo
   laptop before the demo: the yellow "default password" banner is part of Step 7b.

Demo accounts:

| User | Password | Sees |
| --- | --- | --- |
| `admin` | `admin123` | everything, plus the Admin page |
| `teacher` | `teacher123` | Aarav, Diya and Kabir, plus the **Class** page |
| `parent1` | `parent123` | Aarav only |
| `parent2` | `parent123` | Diya only |
| `parent3` | `parent123` | Kabir only |

The demo classroom camera is set to Aarav, Diya and Kabir, from left to right.

## Part B: the demo

### Step 1: start (before the panel arrives)

Double-click **`START_WINDOWS.bat`**. The browser opens at http://localhost:5000. Keep
the black window open.

### Step 2: the problem and the architecture (1 minute)

Show the architecture diagram in the README:

> camera → MobileNet SSD finds the child and objects → MediaPipe Pose reads the posture
> → classifier decides the activity → stored on the device → report, live view, alerts.

Say: "In the real setup this runs on a Raspberry Pi 4 next to the CCTV camera. Today the
laptop plays the Pi's role and runs the same code."

### Step 3: sign-in, one child per parent (1 minute) [improvement 6]

1. Sign in as **parent1** / **parent123**. Point out that the page only shows **Aarav**.
2. Sign out, then sign in as **teacher** / **teacher123**. A **child selector** appears
   at the top, so the teacher can switch between Aarav, Diya and Kabir.

### Step 3b: the class at a glance (1 minute) [new: group of children]

Still as the teacher, click **Class** and set the date to **yesterday**. Show one card
per child:
* Aarav and Kabir: **Possible fights: 1** (red);
* Diya: **Upset / crying: 1 time** and **Falls: 1**;
* Kabir: **Zoned out: 12m**.

Say: "One classroom camera watches all three children. Each child gets their own
timeline, report and alerts, and the teacher sees the whole class here."

Click a card to open that child's report. The **Behaviour** tile shows the same flags.

### Step 4: the report and PDF (2 minutes) [improvement 5]

As the teacher, choose **Diya** and set the date to **yesterday**. Show:
* the summary tiles: screen time against the limit, reading, active play, and **Falls: 1**;
* **How the day was spent**, **Minutes per hour**, the **Timeline** (with the new
  activities: running, jumping, lying down, fall) and **Last 7 days**;
* the **Alerts** panel: "Possible fall detected", "Long inactivity".

Point at **What stands out** at the top: "Instead of making parents read charts, the
system says in plain English what changed against a usual day: screen time up or down,
reading, active play, the longest screen session." Green is good news, red is worth a
look.

Point at the **Screen time** tile's progress bar: each child has their own limit (set
on the Admin page).

Click **Daily report (PDF)** and **Weekly report (PDF)** and open the downloaded files.
The first page is the same plain-English summary.

Say clearly that this week is demo data.

Scroll to **Your data**: "A parent can download everything stored about their child as
a CSV, or delete it all. Records older than 90 days are deleted automatically."

### Step 5: live camera with names, skeleton and privacy (3 minutes) [improvements 2 and 4, names on boxes]

1. Double-click **`START_LIVE_CAMERA.bat`**. A webcam window opens. Because the classroom
   camera is set up, the window's top line says "… children in view, names by position"
   (or "names from face photos").
2. In the browser, sign in as **admin** and click **Live camera** (or **Class**).
3. Show the live view: a box on you with a **name tag**, for example **"Aarav - Idle"**,
   the **pose skeleton**, object boxes (hold up your phone or a book), and your **face
   visible** (set `privacy.blur_faces` to `true` in `config.json` to show privacy mode
   with blurred faces).
4. Ask a friend to step in next to you. They get their own box and name ("Diya - …").
   The person on the left is Aarav, the next one Diya, then Kabir. If you uploaded face
   photos, the names follow each face instead.
5. Do things in front of the camera: hold a phone (gadget use), a book (reading), jump
   (jumping), bury your face in your hands (Upset / crying). Sit very still for 20+
   seconds to see **Zoned out**. The **Right now** panel follows.

Say: "Privacy: faces can be blurred with one setting, no video is recorded, and only activity labels go
into the database."

Press `q` in the webcam window to stop.

### Step 6: test videos and accuracy (3 minutes) [improvements 3 and 7]

Click **Test a video**. For each clip:
1. choose the file;
2. for a clip with one person, leave only the first "Who is in the video?" box filled.
   For a **group or pretend-fight clip**, pick the children from left to right, for
   example Aarav, Diya (and Kabir);
3. pick the correct activity (Reading, Zoned out, Upset / crying, Possible fight, Fall,
   and so on);
4. click **Upload and analyse**.

Show:
* the **labelled video**, with the name tag and the skeleton drawn;
* for the fall clip: **"Fall detected at …s · fall alert sent"**;
* for a group clip: **a name tag on every box**, and under **Each child** a separate
  timeline for every child;
* for the pretend fight: **"Possible fight at …s"** on both children, and the alert;
* the **Accuracy on labelled clips** box at the top, with the **confusion matrix**, the
  **accuracy per activity** table, and **Download results (CSV)** for your report.

Mention that the original uploads are deleted after analysis (privacy mode).

**Learning from feedback (1 minute).** Upload a clip with "Add to the report" ticked and
open **Report** for that child and today. Click the clip's bar on the **Timeline**,
choose what you were really doing and press **Save correction**: the charts change at
once. Then go to **Admin → Learn from corrections**, show the correction in **Latest
corrections**, and press **Retrain the model now**. Say: "The rule-based classifier
gives the first labels; every correction a parent makes becomes a training example, and
the k-NN model is retrained from them. The system improves with use."

### Step 7: alerts (1 minute) [improvement 1]

1. Go to **Admin**. Show **Channels set up**.
2. Pick a child and press **Send a test alert**. If Telegram or email is set up, the
   message arrives on your phone. Show it to the panel.
3. List the alert rules: fall and possible fight (immediate), upset / crying, zoned out
   for 10 minutes, 45 minutes of continuous screen time, the daily screen limit,
   late-night gadget use, long inactivity, and child out of view.
4. Show **Classroom camera** (children from left to right, and how names are found) and
   **Face photos** on the same page.

5. Show **Weekly summary** and press **Send the weekly summary now**. With Telegram set
   up, the summary arrives on your phone; it is also in the Alerts list.

### Step 7b: security (30 seconds)

Point at the yellow banner: "The default admin password must be changed." Mention that
forms are protected against cross-site request forgery, and that after 5 wrong
passwords sign-in pauses for 5 minutes (try it with `parent1` and a wrong password if
there is time; then wait 5 minutes or restart the dashboard).

### Step 8: hardware (30 seconds)

Show the Raspberry Pi section of the README and the `deploy/` files that start
everything when the Pi boots.

## Questions the panel may ask

* **How does it tell a phone from a book?** By posture (hands close together for a
  phone, apart for a book) together with the object MobileNet SSD detects in the child's
  hands.
* **How is a fall detected?** The torso goes from upright to horizontal and the hips drop
  by more than a third of a torso length, all within 1.5 seconds. Lying down slowly does
  not count. The alert goes out at once.
* **How do parents only see their own child?** Each account is linked to children in the
  database. Every page and data request checks that link, and a parent asking for
  another child's data gets "forbidden". Passwords are stored as salted hashes.
* **What about accuracy?** Show the confusion matrix from Step 6. The rules can be
  tuned, or a k-NN model can be trained on your own clips (`scripts/train_classifier.py`).
* **Privacy?** Faces can be blurred (`privacy.blur_faces`), nothing is recorded, uploads are deleted after
  analysis, and only labels and timestamps are stored. Old records are deleted after 90
  days, and parents can download or delete their child's data.
* **Does it learn?** Yes, from corrections. A corrected moment keeps the classifier's
  feature numbers (no image) and the k-NN model is retrained from corrections (strong
  labels) plus the rule labels (weak labels). The Admin page shows the leave-one-out
  accuracy.
* **What if the camera fails during the demo?** `START_DEMO_CAMERA.bat` plays recorded
  clips through the same pipeline.
* **How does it know which child is which?** Two ways. With **face photos**, OpenCV's
  YuNet finds each face and SFace turns it into 128 numbers that are compared with the
  child's enrolment photos. Without photos, it goes by **seat order**: the first person
  from the left is the first child on the list. A tracker keeps the name on the same
  person from frame to frame. Faces are still blurred in everything shown.
* **Can it really tell crying, zoning out and fighting?** Only roughly, from body pose. It
  cannot see tears or hear sobbing. "Upset / crying" means a hand over the eyes for most
  of the time. "Zoned out" means sitting upright and completely still for over 20
  seconds. "Possible fight" means two children touching while both move their arms fast.
  Rough play can look like a fight, and a still, attentive child can look zoned out, so
  these are prompts for the teacher to look, not facts. Better accuracy would need a
  face-expression model, sound, and training on real classroom clips.
* **Limitations?** At home, one child per camera; in class, up to about 4 people, and the
  Pi gets slower with each one. A TV in the room can count as screen time. Detection is
  weaker in the dark. Running, jumping, falls and the behaviour flags were tuned on
  synthetic data, so test clips are the evidence.

## If something goes wrong

| Problem | Fix |
| --- | --- |
| "Python was not found" | Install Python 3.12 with "Add Python to PATH" ticked |
| `pip install` fails on mediapipe | Use Python 3.11 or 3.12, not 3.13 or newer |
| The sign-in page doesn't accept parent1 / teacher, or there is no Kabir / Class page | Close the dashboard window and run `RESET_DEMO_DATA.bat` |
| Webcam does not open, or the room is too dark | Double-click `START_DEMO_CAMERA.bat` (recorded clips) |
| "Too many wrong passwords" | Wait 5 minutes, or close and restart `START_WINDOWS.bat` |
| Retrain says "No corrected moments with camera data" | The demo week has no feature numbers. Upload a clip, correct its bar on the timeline, then retrain |
| Webcam window shows only one name, or no names | Check **Admin → Classroom camera** has 2 or more children, then restart `START_LIVE_CAMERA.bat` |
| Names are on the wrong people | With seat order, the person on the **left of the webcam window** gets the 1st name on the Admin page. Swap places, or upload face photos |
| Admin page says face models "not downloaded yet" | Run `.venv\Scripts\python.exe scripts\download_models.py --faces` in the folder (needs internet). Seat order works without them |
| Live camera page says "The camera is not running" | Double-click `START_LIVE_CAMERA.bat` and wait about 10 seconds |
| Webcam window is black | Close other apps that use the camera, or change `--source 0` to `--source 1` in `START_LIVE_CAMERA.bat` |
| Uploaded video says "could not open the video" | Use an .mp4 file (most phones record mp4) |
| Test alert says "Sending failed" | Check the token, chat id or app password in `config.json`, and restart |
| Page doesn't load | Check the `START_WINDOWS.bat` window is still open |
