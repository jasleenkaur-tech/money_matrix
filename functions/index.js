const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.createNewGame = functions.pubsub
  .schedule("every 1 minutes")
  .onRun(async (context) => {
    const db = admin.database();
    const now = Math.floor(Date.now() / 1000);
    const endTime = now + 60;

    const newGame = {
      game_id: `game_${now}`,
      status: "running",
      start_time: now,
      end_time: endTime,
      total_players: 0,
      winner_color: null,
      bets_count: {
        red: 0,
        green: 0,
        violet: 0,
      },
      bets: {},
    };

    const currentRef = db.ref("games/current_game");

    // Purana game history mein save kar do (optional)
    const snapshot = await currentRef.once("value");
    if (snapshot.exists()) {
      const oldGame = snapshot.val();
      await db.ref(`game_history/${oldGame.game_id}`).set(oldGame);
    }

    // Naya game set karo
    await currentRef.set(newGame);

    console.log("New game created:", newGame.game_id);
    return null;
  });