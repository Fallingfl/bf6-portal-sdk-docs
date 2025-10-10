# Round-Based Systems

Build multi-round game modes with state management and transitions.

**Difficulty:** ★★★★☆ | **Time:** 45 minutes

---

## What You'll Build

- Round state machine
- Round transitions and cleanup
- Score persistence across rounds
- Best-of-N victory conditions

---

## Round State Machine

```typescript
enum RoundState {
  Waiting,
  Countdown,
  Active,
  RoundEnd,
  MatchEnd
}

let currentRound = 0;
let roundState = RoundState.Waiting;
const MAX_ROUNDS = 5;
```

---

## Round Flow

```typescript
export async function OnGameModeStarted() {
  roundState = RoundState.Waiting;

  // Wait for players
  await waitForPlayers(2);

  // Start rounds
  for (currentRound = 1; currentRound <= MAX_ROUNDS; currentRound++) {
    await runRound();

    if (checkMatchVictory()) {
      break;
    }
  }

  roundState = RoundState.MatchEnd;
  endMatch();
}

async function runRound() {
  console.log(`Starting round ${currentRound}`);

  // Countdown
  roundState = RoundState.Countdown;
  await countdown(3);

  // Active round
  roundState = RoundState.Active;
  await playRound();

  // Round end
  roundState = RoundState.RoundEnd;
  await showRoundResults();
}

async function playRound() {
  // Wait for round end condition
  // (e.g., team elimination, time limit, objective)
  while (roundState === RoundState.Active) {
    if (checkRoundEnd()) {
      break;
    }
    await mod.Wait(1);
  }
}
```

---

## Score Persistence

```typescript
const teamRoundWins = new Map<mod.Team, number>();

function initializeScores() {
  teamRoundWins.set(mod.Team.Team1, 0);
  teamRoundWins.set(mod.Team.Team2, 0);
}

function awardRoundWin(team: mod.Team) {
  const wins = (teamRoundWins.get(team) || 0) + 1;
  teamRoundWins.set(team, wins);

  console.log(`${mod.GetTeamName(team)} wins round ${currentRound}. Total wins: ${wins}`);
}

function checkMatchVictory(): boolean {
  const requiredWins = Math.ceil(MAX_ROUNDS / 2);

  for (const [team, wins] of teamRoundWins.entries()) {
    if (wins >= requiredWins) {
      mod.SetWinningTeam(team);
      return true;
    }
  }

  return false;
}
```

---

## Round Cleanup

```typescript
async function cleanupRound() {
  // Reset player states
  const players = modlib.ConvertArray(mod.AllPlayers());

  for (const player of players) {
    // Remove equipment
    mod.RemoveAllEquipment(player);

    // Reset health
    mod.SetPlayerHealth(player, 100);

    // Reset position (teleport to spawn)
    // ... teleport code ...
  }

  // Clear UI
  // Remove round-specific widgets
}
```

---

## Team Switching (Halftime)

```typescript
async function runRound() {
  // ... existing code ...

  // Switch teams at halftime
  if (currentRound === Math.ceil(MAX_ROUNDS / 2)) {
    await halftimeSwitch();
  }
}

async function halftimeSwitch() {
  console.log("Halftime! Switching teams...");

  const players = modlib.ConvertArray(mod.AllPlayers());

  for (const player of players) {
    const currentTeam = mod.GetTeam(player);

    const newTeam = currentTeam === mod.Team.Team1
      ? mod.Team.Team2
      : mod.Team.Team1;

    mod.SetTeam(player, newTeam);
  }

  mod.DisplayCustomNotificationMessage(
    mod.Message("Halftime - Teams Switched!"),
    mod.CustomNotificationSlots.HeaderText,
    5
  );

  await mod.Wait(5);
}
```

---

## Complete Example

See [BombSquad](/examples/bombsquad) for a full round-based implementation with:
- 14 rounds with halftime
- Buy phase between rounds
- Round win conditions (bomb detonation/defusal/time)
- Overtime system

---

## Next Steps

- [Economy & Buy Phase](/tutorials/economy-system)
- [BombSquad Example](/examples/bombsquad)

---

★ Insight ─────────────────────────────────────
**Round-Based Architecture**
1. **State Machine** - Explicit state enum prevents race conditions and makes transitions predictable
2. **Async Flow Control** - Sequential `await` calls in round loop ensure proper cleanup between rounds
3. **Score Decoupling** - Separate round wins from player/team scores allows flexible victory conditions
─────────────────────────────────────────────────
