# Morrill Kombat — Project Plan

A reference document for Claude (and future me) so successive editing
sessions don't drift on conventions, blow up the layout, or rediscover the
same information from scratch every time.

If you find yourself wanting to investigate "how does X work" or "where does
Y live" — read this file first. If something here is wrong, fix it.

---

## What this is

Single-page HTML5 canvas fighting game forked from
[Rumbler](https://github.com/Thad-the-Impaler/rumbler) and reskinned to
**Morrill Kombat**. Everything (game code + every PNG/MP3/WAV) lives
inside a single `index.html` file.

- **Live site**: https://thad-the-impaler.github.io/Morrill-Kombat/
- **Repo**: https://github.com/Thad-the-Impaler/Morrill-Kombat
- **Local working dir**: `/Users/thad/Library/Mobile Documents/com~apple~CloudDocs/Sandbox/Morrill Kombat/`

---

## How to play / edit / deploy

There is intentionally exactly one file that runs the game. No build step.
No HTTP server. No Actions workflow.

| Task | What to do |
|---|---|
| **Play locally** | Double-click `index.html` in Finder. The browser opens it via `file://` and the game runs immediately because every asset is embedded inline. |
| **Edit code** | Edit `index.html` directly (via Claude Code, Cursor, VSCode, whatever). The JS lives inside the `<script>` tag. |
| **Deploy** | `git push`. GitHub Pages serves `index.html` from `main` directly — no build step. The deployed site updates within ~30 seconds. |

That's it. The whole pipeline.

---

## Repo layout

```
.
├── .gitignore       # ignores index copy.html (legacy), .DS_Store, .claude/
├── plan.md          # this file
├── index.html       # THE GAME — single self-contained file (~61 MB)
└── Assets/          # working copies of original asset files (kept for editing)
    ├── Logo2.png
    ├── Music/       # 3 mp3s
    ├── Sound/       # 5 wavs
    ├── Portraits/   # 24 character icons (3 practice + 21 bosses)
    ├── Icons/
    ├── Fighters/    # one folder per fighter (Arnav, Thad, Zyllen, Minh)
    └── Assists/     # one folder per assist (Jayce, King Roller)
```

`Assets/` is a working folder — the originals of every embedded asset,
kept around so you can replace a sprite by dropping in a new file and
asking Claude to re-embed. The runtime game doesn't read from `Assets/`
directly; it reads from the embedded base64 inside `index.html`.

---

## Why the file is so big

`index.html` is ~61 MB because every PNG, MP3, and WAV is embedded as a
base64 data URI inside the JS. That's the price of the
"double-click-and-play" workflow — the alternative (separate asset files
loaded via relative paths) doesn't work via `file://` due to browser
security, and would require running an HTTP server locally.

GitHub's per-file limit is 100 MB; we're under. Git pushes for code-only
changes are still fast because the diff is small (only the JS portion
changes). Adding a new asset is a one-time large-diff push.

If the file ever needs to grow past ~95 MB, we'd need to switch
strategies — but right now there's plenty of headroom.

---

## Source map of `index.html`

The file is one HTML document with structure:

```
<!DOCTYPE html>
<html>
<head>
  <title>MORRILL KOMBAT</title>
  <link rel="icon" ...>
  <style>...</style>
</head>
<body>
  <canvas id="gameCanvas"></canvas>
  <script>
    /* THE GAME LIVES HERE — ~30,000 lines of JS */
  </script>
</body>
</html>
```

The JS body has section markers as comments. **Don't trust line numbers
across sessions** — they shift after every edit. Use these search anchors:

| Section | Anchor (grep these) | Contents |
|---|---|---|
| Asset loaders | `// --- ARNAV SPRITE ASSETS ---` (also `THAD`, `ZYLLEN`, `MINH`, `KING ROLLER`, `JAYCE`, `TITLE LOGO`) | Image objects + per-pose anchor metadata + scale constants. Each fighter/assist has its own block. |
| Difficulty data | `const difficulties = [` | EASY / NORMAL / HARD / BRUTAL stat tables for CPU AI. |
| Levels | `// --- LEVELS ---` | Active stages: CLASSIC, THE TEMPLE. |
| Practice targets | `const punchingBag`, `const mannequin`, `const drone` | Inert "characters" used by practice mode. |
| Roster | `// --- CHARACTERS ---` → `const characters = [` | Active 4: ARNAV, THAD, ZYLLEN, MINH. Each also has a standalone `<name>Char` const right after. |
| Assists | `const assists = [` | Active 2: KING ROLLER, JAYCE. |
| Master passkey | `function activateMasterPasskey()` / `function isMasterPasskeyNeeded()` | Type `imp11` to unlock rumblePractice + mark all bosses defeated. |
| Attacks | `// --- ATTACKS ---` | Damage / startup / hitstun tables for jab, lowKick, uppercut, highKick. |
| Rumbles (finishers) | `// --- RUMBLES (Fatalities) ---` | Per-character finisher metadata. Many entries are dead refs to removed chars — harmless. |
| Bosses | (after the `*Char` consts for active fighters) | 21 boss `*Char` consts referenced by `practiceBossList`. **Don't remove without explicit instructions** — they're live in boss-practice. |
| Game state | `// --- GAME STATE ---` → `let gameState`, `let gameMode` | The reactive globals that drive screen routing. |
| Music routing | `const levelMusicMap = {`, `function playFightMusic` | Stage → audio track map. Falls back to `fightMusic`. |
| SFX | `// --- FIGHTING SOUND EFFECTS ---`, `const _deadSfx = {` | 5 active SFX with backing data URIs. 25 inert SFX names alias the shared `_deadSfx` no-op. |
| Title / menu screens | `function drawTitleScreen`, `drawCharSelectScreen`, `drawAssistSelectScreen`, etc. | Each screen has its own draw function. |
| Versus / Victory | `function drawVersusScreen`, `drawVictoryScreen` | Pre-fight intro, post-fight rendering. |
| Background | `function drawBackground` | Per-stage scenery. |
| Rumble cinematics | (large region) | Per-character finisher animations. Most are inert — leave alone. |
| Fighter class | `class Fighter {` → `Fighter.prototype.X` methods | Constructor, update loop, hit detection, AI, attack execution. |
| Fighter draw | `Fighter.prototype.drawArnav` (etc.), then `Fighter.prototype.draw` | Each sprite-based fighter has its own draw method. The dispatch in `Fighter.prototype.draw` checks `this.char.is<Name>` flags. |
| Assist projectile | `Fighter.prototype.drawAssistProjectile` | Renders all assist projectiles. Branches on `a.is<Name>`. |
| Input dispatch | `function handleKeyPress(key, isRepeat)` | One giant switch on `gameState`. |
| Game flow helpers | `function startVersusScreen`, `startFight`, `startRumblePractice` | State transitions. |
| Main loop | (toward end) | requestAnimationFrame driver. |

---

## Conventions

### Theme

- **Title-screen palette**: orange / yellow / black.
- **Logo**: title-screen logo (1360×768), embedded as `titleLogoImage`.
- **Per-fighter accent colors**: Arnav blue, Thad green, Zyllen gray, Minh beige.
- **Master passkey code**: `imp11` (type on title or char-select).

### Sprite scale

Every sprite-based fighter renders at **~95 px head-to-foot on the 960×540
canvas** to read at the same scale as Rumbler's procedural fighters:

```js
const FOO_SCALE = 95 / (foot_anchor_y - top_y);
```

`top_y` and `foot_anchor_y` come from alpha-mask analysis of the
**stationary** sprite — the foot anchor is the centroid of the
bottom-most opaque band.

### Card preview

Select-card photos use **78 inner units** as the target height, fitting
inside a ~120w × ~100h area centered around y=-15. See any
`if (char.is<Name>)` branch in `drawCharacterPreview`.

### Music routing

- `levelMusicMap[selectedLevel.name] || fightMusic` — falls back to
  default for any unmapped stage.
- Currently mapped: `'CLASSIC'` → `fightMusic`, `'THE TEMPLE'` → `templeFightMusic`.
- `playFightMusic(stageName)` is the only entry point.
- `titleMusic` plays on title / menu via `playTitleMusic()`.

### SFX

- 5 active SFX with embedded data URIs: `sfx_jab`, `sfx_uppercut`,
  `sfx_kick`, `sfx_comboAttack`, `sfx_assistShoot`.
- 25 inert SFX names all alias the shared `_deadSfx` no-op object. Calls
  to `playSfx(sfx_X)` for these silently no-op.

---

## Playbook: adding a new asset

1. **Drop the file in `Assets/`** under the right subfolder
   (`Assets/Fighters/<Name>/`, `Assets/Assists/<Name>/`,
   `Assets/Music/`, etc.).
2. **Ask Claude to embed it** — Claude reads the file, base64-encodes it,
   and substitutes the data URI inline in `index.html` at the right
   place in the asset loader.
3. **Test locally** — double-click `index.html` to verify it loads.
4. **Push** — `git push` deploys.

---

## Playbook: adding a new fighter

The Arnav / Thad / Zyllen / Minh integrations are all the same shape. To
add fighter `Foo`:

1. **Drop sprites into `Assets/Fighters/Foo/`**:
   `FooStationary.PNG`, `FooPunch.PNG`, `FooUppercut.PNG`,
   `FooLowKick.PNG`, `FooHighKick.PNG`, `FooSelect.PNG`.

2. **Compute foot anchors** with a Python script that decodes each PNG
   and finds the alpha-mask centroid of the bottom band. Capture
   `(w, h, anchorX, anchorY)` per pose plus `top_y` of the stationary
   sprite for the scale calc.

3. **In `index.html` (inside the `<script>` tag)**:

   ```js
   // After the previous fighter's block (search for `// --- MINH SPRITE ASSETS ---`)
   // --- FOO SPRITE ASSETS ---
   const fooImages = {};
   const fooSpriteData = {
     'FooStationary': 'data:image/png;base64,<...>',
     'FooPunch':      'data:image/png;base64,<...>',
     // ... etc, with the data URIs Claude generates from the source files
   };
   for (const [name, src] of Object.entries(fooSpriteData)) {
     const img = new Image();
     img.onload = function() { fooImages[name] = img; };
     img.src = src;
   }
   const FOO_ANCHORS = {
     FooStationary: { w, h, anchorX, anchorY },
     // ... etc
     FooSelect: { w, h }, // no anchor needed for the photo
   };
   const FOO_SCALE = 95 / (anchorY - top_y);
   ```

4. **Roster entry** in the `characters[]` array:
   ```js
   {
     name: 'FOO',
     color: '#xxxxxx',
     accent: '#yyyyyy',
     outline: '#000000',
     stats: { speed: 4.0, power: 1.0, defense: 1.0 },
     desc: 'The Whatever',
     quote: '"Catchphrase" - Foo',  // optional
     isFoo: true
   }
   ```

5. **Standalone `fooChar` const** — same fields. Mirror of the roster entry.

6. **Card-preview special case** in `drawCharacterPreview` — copy the
   `if (char.isMinh)` block, change names.

7. **`Fighter.prototype.drawFoo`** — copy `drawMinh`, change all `Min` →
   `Foo`, `MINH_` → `FOO_`. Picks a sprite based on
   `currentAttack.name`, draws shadow + sprite, mirrors via
   `ctx.scale(-1, 1)` when `facing === -1`, calls
   `drawAssistProjectile` after the body.

8. **Early-return** in `Fighter.prototype.draw` — copy the `isMinh` line.

9. Test by double-clicking `index.html`. Push.

---

## Playbook: adding a new assist

See King Roller / Jayce. Six wiring sites:

1. Sprite loader + `<NAME>_ANCHORS` + `<NAME>_SCALE` (data URIs embedded).
2. `assists[]` entry with `is<Name>: true`.
3. `Fighter.prototype.callAssist` branch — spawn the `assistActive`
   object with appropriate position, velocity, timer.
4. `assistActive` update tick — handle motion, hit detection, despawn.
5. `Fighter.prototype.drawAssistProjectile` branch — render the sprite.
6. Assist-select card branch — render the select photo instead of the
   procedural orb.

---

## Reachable vs unreachable code paths

### Reachable from menu
- **FIGHT CPU** → charSelect → assistSelect → levelSelect → versus → fight
- **PRACTICE** → charSelect → practiceTargetSelect →
  - BAG / MANNEQUIN / DRONE → assistSelect → levelSelect → versus → fight
  - Practice Boss → bossSelect → difficultySelect → assistSelect → levelSelect → versus → fight
- **RUMBLE PRACTICE** (only after master passkey) → charSelect →
  assistSelect → levelSelect → versus → fight (with rumble unlock)

### Always-dead code paths (touch with caution)

- **`testYourMight*` machinery** — `testYourMightActive` is declared
  `false` and never set to `true` (its only setter, `setupCampaignFight`,
  is gone). All checks against it are dead-evaluating. **Interleaved
  with Printer-Boss fight code that IS reachable via boss-practice**, so
  removing them requires touching boss code.
- **Old characters' rumble finishers** — `characterRumbles` map entries
  for BLAZE, ARTIK, VENOM, BOJDO, etc. The keys never match a selectable
  fighter, so the per-char render code never triggers.

### Boss-practice mode

Reachable via `Practice → Practice Boss → bossSelect`. The 21 bosses in
`practiceBossList` are all live:

```
BORGUS, ERICTHO, QUELLIC, BOJDOBOJDOBOJDO, SCALENA, BIRDEATER,
SIX IRON-NINE IRON, HANGMAN, TWINS, TUBEWARDEN, ORCUS, HEAD,
DARK BOJDO, SIX DRIVER-NINE IRON, PRINTER, MANEATER, GROOVE MCSMOOTH,
DARK DUPLAIRE, CANIS, RELAPMI, THE COUNT
```

Their `*Char` consts, draw special-cases, AI special-cases, and rumble
cinematics are all still in the source and still execute when those
bosses are fought. **Don't remove boss code without explicit user
direction.**

---

## Editing patterns

### Small surgical edits

Use the `Edit` tool with **multi-line string anchors** that include
enough context to be uniquely matched. Don't rely on line numbers — they
shift after every edit.

The `index.html` file is large (~61 MB) so you can't `Read` it all in
one go. But you CAN edit it via search-and-replace anchors. Always grep
first to find your context.

### Large multi-site refactors

Use a **Python script** with explicit string anchors and assertions:

```python
def replace_once(src, old, new, label):
    cnt = src.count(old)
    assert cnt == 1, f"{label}: expected 1 match, got {cnt}"
    return src.replace(old, new, 1)
```

Assertions catch when an anchor doesn't match (e.g., because the source
already changed) and abort cleanly before partial corruption.

### Multi-line block boundaries (nested braces)

When an edit needs to find the matching `}` for an `if/else/while/function`
block whose body has nested `{...}`:

```python
def find_block_end(lines, start_line):
    """Walk forward, counting braces. Skips a leading `}` that closes
    a previous sibling block (like in `} else if (...) {`)."""
    depth = 0
    inside = False
    for i in range(start_line, len(lines)):
        for c in lines[i]:
            if c == '{':
                if not inside:
                    inside = True
                    depth = 1
                else:
                    depth += 1
            elif c == '}':
                if inside:
                    depth -= 1
                    if depth == 0:
                        return i
    return -1
```

**DO NOT** use non-greedy regex (`.*?`) with `re.S` for multi-line block
matching — it miscounts when bodies have nested braces, prematurely
matching at the first inner `}`.

### Anti-patterns to avoid

1. **Don't trust line numbers across sessions** — they shift. Use
   string anchors.
2. **Don't add new code paths that set `gameMode = 'campaign'` or
   `gameState = 'campaignSelect'`** — those branches were removed; setting
   them would crash on missing handlers.
3. **Don't touch boss code in `practiceBossList` without explicit
   instructions** — boss-practice is live.
4. **Don't add a separate `src/` folder, build script, or HTTP server
   workflow back** — the project is intentionally a single-file game so
   double-click works. The previous "rumbler-style split" was rolled
   back; don't reinstate it without an explicit user request.
5. **Don't introduce relative-path asset loads** like
   `new Image(); img.src = 'Assets/foo.png'`. They break `file://` and
   require a server. Always embed assets as base64 data URIs in the
   sprite-data objects.

---

## Verification checklist before committing

```bash
# 1. Brace / paren / bracket balance
python3 -c "src=open('index.html').read(); \
  print('{', src.count('{'), '} ', src.count('}'), \
        '|', '(', src.count('('), ') ', src.count(')'), \
        '|', '[', src.count('['), '] ', src.count(']'))"
# Each pair should match.

# 2. No leftover relative-path asset loads (would break file://)
grep -oE "'Assets/[^']*'" index.html | head -5
# (silence = clean — everything's embedded)

# 3. Critical strings still present
for s in ARNAV THAD ZYLLEN MINH "KING ROLLER" JAYCE BORGUS ERICTHO imp11; do
  cnt=$(grep -c "$s" index.html)
  printf "  %-25s %d hits\n" "$s" "$cnt"
done

# 4. Double-click index.html in Finder. Title screen should appear with
# the orange logo + menu. If it's a black screen, something broke.
```

If any of these fail, **revert** (`git checkout index.html`) and
re-attempt the edit with a smaller scope or different anchor strategy.

---

## Common gotchas

1. **iCloud sync**: this project lives in iCloud Drive. macOS may evict
   files from local disk ("Optimize Mac Storage") and they'll show as `D`
   (deleted) in `git status` even though they're still in iCloud and in
   the GitHub repo. Run `brctl download Assets/` from the project root to
   pull them back to local disk.

2. **`index copy.html` is dead**: a legacy 171 MB monolith from the early
   refactor. Gitignored. If it reappears in your working tree, it's
   stale — never the source of truth.

3. **Master-passkey code is `imp11`**. Type on title or char-select.
   Unlocks rumblePractice + marks all bosses defeated.

4. **`gameMode === 'campaign'` is dead**: campaign mode was removed.
   Don't add code paths gated on it.

5. **Don't bother with `secretCharOrder`, `secretCharHints`,
   `insertCharOrdered`** — all gone. There is no longer a "locked
   characters" system. The 4 active fighters are it (plus the 21
   boss-practice bosses).

6. **`testYourMight*` is dormant** but referenced — see
   [Always-dead code paths](#always-dead-code-paths-touch-with-caution).

---

## Recent history (for context drift)

- **Tier 1**: removed legacy 171 MB monolith, 11 unused stage music
  tracks, `Logo1.png`, fixed cosmetic glitch.
- **Tier 2 Phase 1**: trimmed portraits 55 → 24.
- **Tier 2 Phase 2**: removed campaign data (115-line `campaigns`
  object literal, rumbler functions, 3 campaign-only chars).
- **Tier 2 Phase 3**: collapsed 24 secret-char defs to stubs.
- **Tier 2 Phase 4**: deleted entire secret-char system (passkeys,
  unlock-flash overlays, vars, `drawLockedCharPreview`,
  `secretCharOrder`, `insertCharOrdered`).
- **Tier 2 Phase 5**: collapsed 25 dead-sfx stubs, removed campaign
  machinery + all `gameMode === 'campaign'` checks.
- **Architecture rollback**: rolled back the rumbler-style src/
  template + build pipeline. Re-embedded all assets back into a single
  self-contained `index.html` so double-click in Finder works without
  needing an HTTP server. GitHub Pages now serves directly from `main`
  (no Actions workflow).

`git log --oneline` shows the full sequence.
