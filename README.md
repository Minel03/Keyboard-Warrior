# ⌨️ Keyboard Warrior

**Keyboard Warrior** is a high-octane, rhythm-adjacent typing game built with the Godot Engine. Face off against the ultimate online menace: toxic "trash talkers." In this game, your words are your weapons—literally.

## 🎮 Gameplay Overview

The battlefield is filled with enemies descending upon you, hurling classic gamer insults like "Noob," "Scrub," and "Trash." To defeat them, you must type the words floating above their heads. Each completed word launches a projectile that eliminates the threat. 

But beware: as time passes, the toxicity increases. Enemies spawn faster, move quicker, and become more numerous.

### Key Features

*   **Typing-Based Combat:** A pure test of speed and accuracy. Type to attack, and don't let the "trash" reach your base.
*   **Multiple Game Modes:**
    *   **Story Stages:** Progress through Stage 1 and Stage 2, featuring custom dialogue and escalating challenges.
    *   **Infinite Mode:** Test your limits in a never-ending survival mode and compete for the top spot.
*   **Hero Skills:** Use Skill Points (SP) to turn the tide of battle:
    *   **[1] Freeze:** Instantly halt all enemies for 3 seconds, followed by a 2-second slow-down effect.
    *   **[2] Doom:** Cast a powerful spell that clears up to 5 random enemies from the screen instantly.
*   **Boss Encounters:** Face off against powerful Bosses and their minions in intense typing duels.
*   **Leaderboard System:** Track your high scores and typing accuracy. Only the fastest warriors make the cut.
*   **Dynamic Difficulty:** The game scales with your skill, ensuring a constant challenge as you improve your Words Per Minute (WPM).

## 🛠️ Controls

| Key | Action |
| :--- | :--- |
| **A-Z** | Type letters to attack enemies |
| **[1]** | Activate **Freeze** Skill (Costs 1 SP) |
| **[2]** | Activate **Doom** Skill (Costs 1 SP) |
| **ESC** | Pause Game |

## 🚀 Getting Started

### Prerequisites
*   [Godot Engine 3.x](https://godotengine.org/download)

### Installation
1.  Clone this repository:
    ```bash
    git clone https://github.com/Minel03/Keyboard-Warrior.git
    ```
2.  Open Godot Engine.
3.  Click **Import** and navigate to the project folder.
4.  Select the `project.godot` file and click **Open**.
5.  Press **F5** to play!

## 🏗️ Technical Stack

*   **Engine:** Godot 3.x
*   **Language:** GDScript
*   **Storage:** Local save system for Leaderboards (`user://leaderboard.save`)
*   **UI:** Custom CanvasLayer implementation for HUD and Menus

## 📝 Credits

Developed as a project to showcase typing mechanics and game state management in Godot.

---
*Stop the toxicity. Become the ultimate Keyboard Warrior.*
