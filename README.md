# AI-Based Activity Monitoring and Behaviour Analytics for Children and Teens

A home camera watches the child's room. A Raspberry Pi 4 works out what the child is
doing (reading, gadget use, playing, eating, idle, running, jumping, lying down, or
falling), records it, and shows parents and teachers a report in a web dashboard. When
something needs attention, such as a fall, too much screen time, long inactivity or the
child being out of view, it sends an alert by Telegram, email or phone notification.
In a classroom, one camera can watch 2 to 3 children at once, with each child's name on
their box, and flag a child who looks zoned out or upset, or a possible fight.

Main features:
* **Classroom mode:** several children in one camera, each with their own name tag,
  activity and report, and a **Class** page that shows them side by side
* **Behaviour flags:** zoned out, upset / crying, and possible fights (see how reliable
  they are in "Behaviour flags" below)
* **Live camera page** with the detected person, objects and pose skeleton drawn on
* **Privacy mode:** optional face blurring (off by default, so faces stay visible), and uploaded videos are deleted after analysis
* **Sign-in for parents, teachers and admins:** each person sees only their own child
* **Daily and weekly PDF reports** to download
* **Video testing** with a confusion matrix and accuracy per activity
* **"What stands out"**: plain-English insights such as "Screen time is up 35% on a
  usual day", on the Report page and in the PDF
* **"Correct this"**: click a wrong bar on the timeline to fix it; the fixes retrain the
  model (it learns from feedback)
* **Your data**: download a child's data as CSV, delete it, and automatic deletion of
  records older than 90 days
* **Screen-time limit for each child**, with a progress bar
* **Weekly summary** by Telegram or email every Sunday evening
* **Security**: CSRF protection, a pause after 5 wrong passwords, and a prompt to change
  the default admin password
* **Demo backup mode**: `START_DEMO_CAMERA.bat` plays recorded clips as if they were the
  live camera

![Report page](docs/dashboard.png)

![Live camera page: face blurred, pose skeleton and objects drawn on](docs/live-camera.png)

![Class page: classroom camera with a name tag on each child, and one card per child](docs/class.png)

**Quickest start on Windows:** unzip, then double-click `START_WINDOWS.bat`. It installs
everything the first time and opens the dashboard in your browser. Sign in with one of
the demo accounts: `admin` / `admin123`, `teacher` / `teacher123` (all three children),
`parent1` / `parent123` (Aarav), `parent2` / `parent123` (Diya) or `parent3` / `parent123`
(Kabir). Double-click `START_LIVE_CAMERA.bat` to use the
laptop webcam as the camera.

**Presenting the project?** See [DEMO.md](DEMO.md) for a step-by-step demo script that
runs on a laptop. To test videos without installing anything, open
[colab_demo.ipynb](colab_demo.ipynb) in Google Colab.

## Architecture

```
 CCTV / USB / Pi camera
          │  frames (640x480, ~5 fps)
          ▼
 ┌────────────────────────── Raspberry Pi 4 (edge) ───────────────────────────┐
 │ 1. MobileNet SSD (OpenCV DNN)  -> person boxes + nearby objects            │
 │                                   (cell phone, laptop, tv, book, bowl,      │
 │                                    cup, sports ball, bed, ...)              │
 │    Classroom mode: tracker keeps an ID per child; name from face photos    │
 │    (YuNet + SFace) or from seat order, left to right                       │
 │ 2. MediaPipe Pose (lite)       -> 33 body landmarks on each child's crop    │
 │ 3. Activity classifier         -> reading | gadget_use | playing | eating | │
 │    (posture rules + objects,      idle | running | jumping | lying_down |  │
 │     optional trained k-NN)        falling | zoned_out | crying | fighting   │
 │                                   (+ absent / unknown)                      │
 │ 4. SQLite log (labels only) + live preview frame with faces blurred         │
 │ 5. Alert rules  ─────────────────────► Telegram / email / Firebase ─────────┼──► parents' phones
 │ 6. Flask dashboard + Chart.js  ◄── parents/teachers sign in at :5000       │
 └─────────────────────────────────────────────────────────────────────────────┘
```

| Part | Technology | Code |
| --- | --- | --- |
| Person detection | MobileNet SSD v2 (COCO) via OpenCV DNN. The classic Caffe MobileNet SSD (VOC) is also supported | `monitor/detector.py` |
| Activity detection | MediaPipe Pose (Pose Landmarker lite) + rule-based classifier | `monitor/pose.py`, `monitor/features.py`, `monitor/classifier.py` |
| Edge computing | Raspberry Pi 4 (4 or 8 GB), everything runs on the device | `monitor/pipeline.py` |
| Several children, names | Simple box tracker; face recognition (OpenCV YuNet + SFace) or seat order; fight check between pairs | `monitor/tracker.py`, `monitor/identity.py`, `monitor/scene.py` |
| Report generation | Flask + Chart.js (bundled, works without internet) | `dashboard/` |
| Video testing | Upload recorded clips in the dashboard, see labelled video and accuracy | `monitor/video_analysis.py`, `dashboard/templates/videos.html` |
| Alerts | Telegram bot, email (SMTP) and Firebase Cloud Messaging, each optional | `monitor/alerts.py` |
| Live view and privacy | Annotated MJPEG stream; faces blurred with OpenCV | `monitor/overlay.py`, `dashboard/templates/live.html` |
| Accounts | Sign-in with hashed passwords; parents/teachers linked to children | `monitor/storage.py`, `dashboard/app.py` |
| PDF reports | matplotlib, daily and weekly | `dashboard/pdf_report.py` |
| Storage | SQLite (WAL mode so the dashboard can read while the Pi writes) | `monitor/storage.py` |

### How activities are recognised

Pose alone cannot tell a phone from a book, so the classifier combines body posture with
the objects that MobileNet SSD sees near the child. Each frame gets a score for every
activity, and the final label is a majority vote over the last 10 frames so it does not
flicker.

| Activity | Posture cues (MediaPipe) | Object cues (MobileNet SSD) |
| --- | --- | --- |
| Reading | head tilted down, hands in front, hands apart (holding a book open) | book |
| Gadget use | head down, hands close together in front (phone or tablet); or still and upright with a TV in the room | cell phone, laptop, keyboard, remote, tv |
| Playing | fast body movement, arms raised, standing | sports ball, frisbee, teddy bear, ... |
| Eating | hand moves to the mouth again and again | bowl, spoon, fork, food, cup, dining table |
| Idle | very little movement and none of the above | |
| Running | the whole body travels across the room fast while upright | |
| Jumping | the whole body bounces up and down while upright | |
| Lying down / sleeping | torso close to horizontal | bed, couch |
| Fall | upright to lying, with the hips dropping, within about 1.5 seconds | |
| Zoned out | idle while sitting or standing upright, for more than 20 seconds (`classifier.zoned_out_seconds`) | nothing in the hands |
| Upset / crying | a hand held over the eyes most of the time (face in hands, wiping eyes), often with the head down | no food, phone or book |
| Possible fight | two children close together (boxes touching) and both moving their arms fast for about a second (classroom mode only) | |

A fall is an event rather than an activity. It is reported straight away instead of
waiting for the majority vote, held for 3 seconds, and triggers an immediate alert.
Lying down slowly (for example going to bed) is not counted as a fall.

All distances are measured in torso lengths, so the rules work whether the child is near
or far from the camera. Movement speed is also in torso lengths per second.

Optional light classifier: if the rules do not fit your room or camera angle, record a
few minutes of each activity and train a small k-NN model (see "Train your own
classifier" below). It uses the same features, and it replaces the rules when it is
switched on in `config.json`.

### Alerts

| Rule | Default | Setting in `config.json` → `alerts.rules` |
| --- | --- | --- |
| Fall detected | on; alert at once, at most every 2 minutes | `fall_detected` |
| Continuous gadget use | 45 min without a break | `continuous_gadget_minutes` |
| Daily screen-time limit | 120 min (once a day) | `daily_gadget_minutes` |
| Long inactivity during the day | 60 min idle or lying down between 09:00 and 19:00 | `daytime_idle_minutes`, `daytime_hours` |
| Late-night gadget use | gadget use after 22:00 (until 05:00) | `late_night_hour` |
| Child out of view | 60 min during the day (0 turns it off) | `child_absent_minutes` |
| Possible fight | on; alert at once, at most every 2 minutes | `fight_detected` |
| Upset / crying | on; at most every 10 minutes | `crying_detected` |
| Zoned out | 10 min during the day (0 turns it off) | `zoned_out_minutes` |

Each rule has a 30-minute cooldown (`cooldown_minutes`) so parents are not spammed.
Every alert is saved and shown on the dashboard, even if sending fails. The alert title
starts with the child's name. An admin can press **Send a test alert** on the Admin page.

#### Setting up Telegram alerts (free, about 5 minutes)

1. In Telegram, open **@BotFather**, send `/newbot` and follow the steps. It gives you a
   **bot token** like `7123456789:AAH...`.
2. Open your new bot in Telegram and send it any message (for example "hi").
3. In a browser, open `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates`. Find
   `"chat":{"id": 123456789` in the text. That number is your **chat id**. To alert a
   group of parents, add the bot to a group, send a message there, and use the group's id
   (it starts with `-`).
4. In `config.json`, set:
   ```json
   "telegram": {"enabled": true, "bot_token": "7123456789:AAH...", "chat_ids": ["123456789"]}
   ```
5. Restart the app and press **Send a test alert** on the Admin page.

#### Setting up email alerts (Gmail)

1. Turn on 2-step verification for the Gmail account, then create an **app password**
   at <https://myaccount.google.com/apppasswords>.
2. In `config.json`, set:
   ```json
   "email": {"enabled": true, "smtp_host": "smtp.gmail.com", "smtp_port": 587,
             "username": "you@gmail.com", "password": "the 16-letter app password",
             "to": ["parent@example.com"]}
   ```
3. Restart the app and send a test alert.

Keep `config.json` private once it holds a token or password.

### Classroom mode: 2 to 3 children, with names on the boxes

One camera can watch a small group. Every person in view gets a **track** (an ID that
follows them from frame to frame), their own pose model and activity history, and a
**name tag** on their box: "Aarav - Reading", "Diya - Upset / crying". Someone not on the
list (a teacher walking past) gets a grey "Person" tag and is not logged.

Turn it on in the dashboard: **Admin → Classroom camera**. Pick the children in the order
they sit **from left to right as the camera sees them**, and choose how names are found.
Then restart `START_LIVE_CAMERA.bat` (or `python -m monitor.pipeline`, or
`python -m monitor.pipeline --group child1,child2,child3`). To test with a recorded clip,
pick the children from left to right on the **Test a video** page.

**How a child's name is worked out:**

| Method | How it works | Good | Watch out |
| --- | --- | --- | --- |
| **Seat order** (no setup) | The 1st person from the left gets the 1st name, and so on. A name stays with that person while they are tracked. | Works straight away, no photos | Names swap if children change places or leave and come back on the other side |
| **Face photos** | Admin uploads 3 to 5 photos per child (**Admin → Face photos**). OpenCV's YuNet finds faces and SFace turns each one into 128 numbers; a person is named when two looks at their face match a child's photos (cosine similarity at least 0.363). | Names follow the child around the room | Needs a visible, reasonably large face; the camera must see faces from the front; small children far away are hard |

**Automatic** (the default) uses face photos when the face models are downloaded
(`python scripts/download_models.py --faces`, about 37 MB, done by `START_WINDOWS.bat`) and
at least one child has photos; otherwise it uses seat order. If a face is not recognised
after about 3 seconds, that person is named by seat order instead. Face recognition runs
on the original frame in memory; everything that is shown or saved still has the faces
blurred. Enrolment photos stay on the device in `data/faces/` and can be deleted from the
Admin page. In a real school, get the parents' written consent before using face photos.

The **Class** page (for teachers, and anyone who can see more than one child) shows the
classroom camera, what each child is doing right now, and one card per child with screen
time, reading, active play, zoned-out time, crying, fights, falls and alerts.

### Behaviour flags: zoned out, upset / crying, possible fight (how reliable?)

These come from body pose only: the system cannot see eyes or tears and cannot hear.
Treat them as **"please look"** prompts for an adult, not as facts.

| Flag | What it really measures | Fairly reliable when | Misses or false alarms |
| --- | --- | --- | --- |
| Zoned out | Upright and completely still, with nothing in the hands, for over 20 s | the child faces the camera and sits still | A child listening carefully, or thinking, looks the same. It cannot tell where the child is looking |
| Upset / crying | Fingers or a hand over the eyes at least half the time (the fingers count, not just the wrist), often head down, not eating or drinking | the face is buried in the hands | Rubbing tired eyes, yawning, hiding in a game. Crying with the hands down is missed. Labelled "Upset / crying" for this reason |
| Possible fight | Two people touching, both arms moving fast for about 1 second. Works in classroom mode and also with one child per camera when someone else (a sibling or friend) is right next to them | a real scuffle in clear view | Rough play, dancing, clapping games and high fives look the same. A fight between children who overlap a lot can confuse the pose model |

**Tips for testing them.** Crying: sit facing the camera, upper body in view, and hold
your face in your hands (fingers over your eyes) for 10 seconds or more. Fight: two
people side by side, close enough that their boxes touch, both swinging their arms fast
for 3 seconds or more. If the people stand apart, it is not counted as a fight. Both
flags stay on screen for 3 seconds and appear on the Report timeline and in Alerts.

Better accuracy would need extra inputs: a face-expression model for crying, a
microphone for sobbing or shouting, eye or head direction for attention, and a model
trained on real labelled classroom clips. Test with your own clips on the **Test a video**
page and quote the confusion matrix, rather than assuming these work.

### Privacy mode

Settings in `config.json` → `privacy`, all on by default:

* `blur_faces` (**off by default**, so faces are visible on the Live page and in labelled
  videos; set it to `true` for real use in a home or school): faces are blurred in every picture the system shows: the live camera
  page, the `--display` window, and labelled videos from uploads. It uses the pose face
  points, and also blurs the head area of every person box, so other people in the room
  are covered too.
* `delete_uploads_after_analysis`: an uploaded video is deleted as soon as it has been
  analysed. Only the blurred, labelled copy is kept.
* `live_preview`: the camera writes only the latest blurred frame for the Live page. It is
  overwritten every frame and never recorded. Set it to `false` to have no images at all.

The database only holds activity labels, confidence values, timestamps and, for the
"Correct this" feature, the classifier's feature numbers for each moment (posture,
movement and objects: about 15 numbers, no image). Nothing is uploaded anywhere except
the alert text.

**Your data (bottom of the Report page).** A parent (or admin) can:
* **Download all data (CSV)**: every activity record and alert stored for the child;
* **Delete all data**: type the child's name to confirm. The activity log, alerts,
  corrections, face photos and video results for that child are erased. Teachers can
  download but not delete.

**Automatic deletion.** Records older than `privacy.keep_days` (90 by default; 0 keeps
everything) are deleted every 10 minutes while the dashboard runs. The admin can change
the number of days on the Admin page under **Privacy and data retention**.

### What stands out (insights)

The Report page opens with a short list in plain English, also printed on the first
page of the PDF. Green is good news, red is worth a look, blue is for information:

* screen time against the child's limit;
* changes against a **usual day** (the average of the previous 7 days that have data)
  in screen time, reading, active play and zoned-out time. Changes under 15% are normal
  noise and are not mentioned. For today, the comparison is with the same hours of
  earlier days ("by this time"), so a morning is not compared with whole days;
* the longest screen session without a break, the most active hour, and any falls,
  possible fights or upset moments.

Code: `monitor/insights.py`.

### Correct this: learning from feedback

Rule-based labels are sometimes wrong. On the Report page, click a bar on the
**Timeline**, pick what the child was really doing and press **Save correction**. Three
things happen:

1. the report is fixed at once (charts, totals, PDF);
2. the correction is logged (who, when, from what to what; Admin page, **Latest
   corrections**);
3. the moments keep their feature numbers, so they become training examples.

On the Admin page, **Retrain the model now** builds a k-nearest-neighbour model
(`data/knn_feedback.json`) from:
* the corrected moments, counted three times (strong labels);
* the other logged moments with the label the rules gave (weak labels), so the model
  still knows every activity and changes only where people said the rules were wrong;
* `data/training_samples.csv` if you recorded one (see "Train your own classifier").

It reports the leave-one-out accuracy. Restart the camera to use the model; **Go back to
the rules** switches it off. Falls, fights and zoned-out still come from their own checks.
Only moments recorded by this version (live camera or uploaded clips) have feature
numbers; the demo data does not, so for the demo upload a clip first and correct that.

Code: `storage.py` (`correct`, `training_rows`), `monitor/training.py`.

### Security

* **CSRF protection**: every form and every request that changes something must carry a
  secret token from the signed-in session, so another website cannot make your browser
  submit them.
* **Sign-in limit**: after 5 wrong passwords for a user name, or from one computer,
  within 10 minutes, sign-in is paused for 5 minutes.
* **Default password**: while `admin` still uses `admin123`, a yellow banner on every
  page asks to change it. Anyone can change their own password under **Account** (at
  least 8 characters).
* Passwords are stored as salted hashes; each account only sees its own children.

### Accounts: parents, teachers and admins

Everyone signs in. A home camera watches one child (`camera.child_id` in `config.json`); a
classroom camera watches the children set on the Admin page.

| Role | Sees |
| --- | --- |
| Parent | only the children linked to their account (usually one) |
| Teacher | the children linked to them (for example a whole class), with a child selector |
| Admin | all children, plus the **Admin** page to add children and accounts and send test alerts |

On first start the app creates `admin` / `admin123`. Change that password under
**Account** (top right); a banner reminds you until you do. Passwords are stored as
salted hashes, never as plain text. `python scripts/seed_demo_data.py --reset` (or
`RESET_DEMO_DATA.bat`) loads the demo children and accounts.

### Reports

The Report page has **Daily report (PDF)** and **Weekly report (PDF)** buttons. Both
start with the **What stands out** page. The daily report has the summary, a chart of the day, minutes per hour and the alerts. The weekly
report adds minutes per day, weekly totals, daily averages, days over the screen-time
limit and the number of falls, possible fights and times the child was upset.

**Screen-time limit for each child.** The Admin page, under **Children**, has a daily
limit for each child (empty = `alerts.rules.daily_gadget_minutes` from `config.json`).
It drives the progress bar on the Screen time tile (green, orange from 80%, red when
over), the PDF, the Class page and the "Daily screen-time limit reached" alert.

**Weekly summary.** Every Sunday at 19:00 (`alerts.weekly_digest` in `config.json`:
`enabled`, `weekday` 0 = Monday to 6 = Sunday, `hour`) the dashboard sends one message
per child to every alert channel: average screen time, reading and active play a day,
the trend against the week before, days over the limit, and falls, fights and upset
moments. It also appears in the Alerts list. **Send the weekly summary now** on the
Admin page sends it straight away (useful in a demo). The dashboard must be running.

### Demo backup mode

`START_DEMO_CAMERA.bat` (or `python -m monitor.pipeline --source demo_clips --loop`)
plays the clips in `demo_clips/` one after another, at normal speed and in a loop, and
the system treats them exactly like a live camera: Live camera page, Report, Class page
and alerts all update. With no clips there, it plays `docs/test-media/test_clip.mp4`. Use
it if the webcam or the lighting fails during the demo, and say that it is a recording.

## Project layout

```
config.json                 all settings (camera, privacy, thresholds, alert rules and channels)
START_WINDOWS.bat           Windows: install everything and start the dashboard
START_LIVE_CAMERA.bat       Windows: use the laptop webcam as the camera
RESET_DEMO_DATA.bat         Windows: reload the demo week and demo accounts
monitor/
  detector.py               MobileNet SSD person + object detection
  pose.py                   MediaPipe Pose on the person crop
  features.py               posture features from landmarks
  classifier.py             activity rules, smoothing, optional k-NN
  storage.py                SQLite log, report queries, children and accounts
  alerts.py                 alert rules + Telegram, email and Firebase senders
  insights.py               plain-English insights and the weekly summary text
  training.py               k-NN training, including from parents' corrections
  overlay.py                face blurring, boxes, skeleton, name tags and labels
  tracker.py                keeps an ID on each person (classroom mode)
  identity.py               names: face recognition or seat order
  scene.py                  one frame -> who is doing what; fight check
  pipeline.py               main loop that runs on the Pi (live camera, or --loop for demo clips)
  video_analysis.py         same pipeline over a recorded video file
dashboard/
  app.py                    Flask app: sign-in, JSON API, live stream, video upload jobs
  pdf_report.py             daily and weekly PDF reports
  templates/, static/       Report, Class, Live camera, Test a video, Admin, Account and sign-in pages
demo_clips/                 put recorded clips here for START_DEMO_CAMERA.bat
scripts/
  download_models.py        fetches the model files (any OS); download_models.sh for bash
  evaluate_videos.py        scores a folder of labelled clips (accuracy, confusion matrix)
  seed_demo_data.py         fills the database with a fake week for demos
  train_classifier.py       trains the optional k-NN model
deploy/*.service            systemd units to start everything on boot
tests/                      unit tests (no camera needed)
```

## Setup on the Raspberry Pi 4

1. **Operating system.** Flash **Raspberry Pi OS (64-bit) Bookworm** with Raspberry Pi
   Imager. MediaPipe only has wheels for 64-bit ARM, so the 32-bit OS will not work.

2. **System packages.**
   ```bash
   sudo apt update
   sudo apt install -y python3-venv python3-pip libgl1 libegl1 libgles2 curl
   ```

3. **Copy the project** to `/home/pi/child-activity-monitor` and create a virtual
   environment:
   ```bash
   cd ~/child-activity-monitor
   python3 -m venv .venv
   source .venv/bin/activate
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

4. **Download the models** (about 75 MB):
   ```bash
   python scripts/download_models.py          # COCO MobileNet SSD + MediaPipe Pose lite
   python scripts/download_models.py --voc    # optional: classic Caffe MobileNet SSD
   ```

5. **Connect a camera** and set `camera.source` in `config.json`:
   * USB webcam: `0`
   * CCTV / IP camera: its RTSP address, for example
     `"rtsp://user:password@192.168.1.50:554/stream1"`
   * Raspberry Pi Camera Module: enable it, then use `0` (with the libcamera V4L2 driver)
     or stream it over RTSP.

   Mount the camera high in a corner so the child's whole body is visible, and avoid
   pointing it straight at a window (backlight ruins pose detection).

6. **Test it with a screen attached:**
   ```bash
   python -m monitor.pipeline --display
   ```
   You should see boxes around people and objects, pose points, and the current activity.
   Press `q` to quit. On a headless Pi leave out `--display` and watch the log.

7. **Start the dashboard:**
   ```bash
   python -m dashboard.app
   ```
   Open `http://<pi-ip-address>:5000` from a phone or laptop on the same Wi-Fi and sign in
   as `admin` / `admin123`. Change that password, then create the parent and teacher
   accounts on the Admin page.

8. **Run both on boot:**
   ```bash
   sudo cp deploy/*.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now child-monitor child-dashboard
   journalctl -u child-monitor -f      # see the log
   ```

### Performance on a Pi 4

The pipeline is set up for the Pi: 300x300 SSD input, the lite pose model, pose run only
on the child's crop, and `target_fps: 5`. Five frames a second is plenty for activities
that last minutes. Expect roughly 3 to 6 frames a second on a Pi 4. This is an estimate
and has not been measured on real hardware. If it is too slow:

* switch to `"backend": "voc"` (smaller Caffe model, but no phone/book detection),
* lower `camera.width/height` to 480x360,
* add a heatsink and fan, because the Pi 4 slows itself down when hot.

## Firebase Cloud Messaging (push alerts)

1. Create a project at <https://console.firebase.google.com>.
2. **Project settings → Service accounts → Generate new private key.** Save the file as
   `firebase-service-account.json` in the project folder (it is in `.gitignore`; never
   commit it).
3. The parents' phones need an app that receives FCM messages. Two options:
   * **Topic (default):** the app subscribes to the topic `parents`
     (`FirebaseMessaging.getInstance().subscribeToTopic("parents")` on Android, or
     `FirebaseMessaging.instance.subscribeToTopic('parents')` in Flutter). Every phone on
     that topic gets the alerts.
   * **Device tokens:** put the phones' FCM registration tokens in
     `alerts.fcm_tokens` in `config.json`.

   A minimal Android or Flutter app made from Firebase's "Cloud Messaging" quick-start is
   enough. Its only job is to show notifications.
4. Restart the pipeline. Its log prints `alert channels: Firebase`. If it says
   `none (dry run)`, the credentials file was not found: alerts are still saved and
   shown on the dashboard, but are not pushed.

## Testing with recorded videos

Until the camera is installed, the system can be tested with recorded clips:

* **In the dashboard:** open **Test a video** (`http://<host>:5000/videos`), upload a
  clip and, optionally, say which activity it shows. The clip is analysed in the
  background, exactly as the live camera would be at 5 frames a second. You then get a
  labelled video (boxes, pose points, activity), the share of each activity, a timeline,
  and the objects seen. Labelled clips build an accuracy table, and results can be added
  to today's report.
* **From the command line,** for a whole folder of clips sorted into subfolders named
  after the activity (`reading/`, `gadget_use/`, ...):
  ```bash
  python scripts/evaluate_videos.py test_videos --annotate out/ --csv results.csv
  ```

Switching to the live camera later needs no code changes: run `python -m monitor.pipeline`
with `camera.source` set to the webcam or RTSP address.

## Running without a Pi or camera

Everything except the camera works on a normal Linux, macOS or Windows computer.

```bash
pip install -r requirements-dev.txt
python scripts/download_models.py

# Run the tests (synthetic poses, database, alerts, dashboard API)
python -m pytest -q

# Demo the dashboard with a fake week of data
python scripts/seed_demo_data.py
python -m dashboard.app            # open http://localhost:5000, sign in, pick yesterday's date

# Run the full pipeline on a recorded video instead of a live camera
python -m monitor.pipeline --source my_clip.mp4 --display
```

## Train your own classifier (optional)

The rule thresholds were written for a typical camera angle. To fit your own room, record
short labelled sessions and train the k-NN model:

```bash
python -m monitor.pipeline --record-label reading    --source reading.mp4
python -m monitor.pipeline --record-label gadget_use --source phone.mp4
python -m monitor.pipeline --record-label playing    --source playing.mp4
python -m monitor.pipeline --record-label eating     --source lunch.mp4
python -m monitor.pipeline --record-label idle_sleeping --source nap.mp4
python scripts/train_classifier.py data/training_samples.csv models/knn.json
```

Then set `"knn_model": "models/knn.json"` in `config.json`. The training script prints a
leave-one-out accuracy you can quote in the project report.

## What was tested, and what still needs real hardware

Tested in a Linux container (Python 3.13, OpenCV 4.14, MediaPipe 1.2):

* 68 tests pass. They cover:
  * the classifier on synthetic poses: all activities, running, jumping, falls (and that
    lying down slowly is not a fall), absence, object cues and label smoothing;
  * zoned out (and that lying down or reading for a long time is not), face in hands as
    upset (and that eating is not);
  * classroom mode with a fake camera: tracking, names left to right, two children
    hitting each other flagged as a possible fight, and waving far apart or sitting
    quietly side by side not flagged;
  * a two-child video (the test clip next to a mirrored copy) uploaded end to end, with
    a name and a timeline for each child;
  * storage, upgrading an old database, keeping children apart, and all alert rules and
    cooldowns;
  * Telegram and email sending (with the network replaced by a fake);
  * face blurring;
  * sign-in, and that a parent cannot see another child's data;
  * the Admin page, PDF reports, every dashboard API endpoint, and a video upload
    analysed end to end.
* The live camera page was checked in a browser, with the pipeline running on a video
  file: face blurred, skeleton and objects drawn, and the "Right now" panel updating.
* The real MobileNet SSD (COCO and VOC) and MediaPipe Pose models load and run. On a
  sample photo of a footballer they found the person and the ball, and the pipeline run
  on a short video logged "playing".
* The dashboard renders with no browser errors on desktop and phone widths
  (screenshot above, from the demo data).
* The Firebase sender builds and sends a real FCM request. With a dummy service account,
  Google rejected it as expected and the alert was still saved.

Not yet tested, because it needs hardware or accounts:

* Speed and accuracy on a real Raspberry Pi 4 with a real camera.
* How well the posture thresholds fit real children at your camera angle. Expect to
  tune `config.json` or train the k-NN model.
* Alerts arriving on a phone. Telegram and email need your own bot token or app
  password, and Firebase needs your project and a receiving app.
* Running, jumping and fall detection on real people. These were tuned on synthetic
  poses only. Record a few test clips and use the Test a video page to check them.
* Zoned out, crying and fight detection on real children. Also tuned on synthetic poses
  only, and limited by what pose can show (see "Behaviour flags").
* Face recognition for name tags. The code uses OpenCV's documented YuNet and SFace
  API, but the face model files could not be downloaded in the build environment, so it
  has not been run with real faces. If it fails, names fall back to seat order.

## Known limitations

* **Home camera: one child.** The largest person in view is treated as the child, so
  siblings or adults in the frame can confuse it. Use classroom mode for a group.
* **Classroom mode: up to about 4 people.** Each extra person adds a pose model, so a
  Pi 4 slows down (an estimate of 2 to 3 frames per second with 3 children, not measured). Children hiding
  behind each other lose their track for a moment; with seat-order naming a returning
  child can get the wrong name.
* **Falls.** The fall rule needs the camera to see the whole body. A fall behind
  furniture, or one that is mostly towards the camera, may be missed.
* **TV in the room.** A child sitting still with a TV in view counts as gadget use, even
  if the TV is off. Set `"tv_counts_as_screen_time": false` if that happens a lot.
* **Small objects.** Phones and books held at an angle, or far from the camera, are
  sometimes missed. The posture rules then decide on their own.
* **Lighting.** Pose detection gets worse in a dark room. An IR camera helps at night.
