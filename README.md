# AppleMusicPlayer

A SwiftUI-only implementation of Apple Music's pop-up UI. This project is a study in accurately replicating the original app's animations and functionalities using SwiftUI.

<img src="https://github.com/pavlo-tereshchuk/AppleMusicPlayer/assets/16036695/2b1c284e-1bdc-4a41-ab76-762c0760ea86" alt="Simulator Screenshot - iPhone 14 Pro - 2023-08-16 at 10 43 06" width="300" />

## Features

### Pop-out/Pop-in Animations
Simulate the Apple Music pop-out and pop-in animations.
- **Pop-in**: Pull down to pop the screen back in. The content dynamically compresses as you pull.
  
<img src= "https://github.com/pavlo-tereshchuk/AppleMusicPlayer/assets/16036695/0c92bb42-c3fd-4981-a36c-0e86d158166c" alt="1" width="300" />

### Rewind
Replicates Apple Music's rewind animation perfectly.
  
![Rewind Animation](./path_to_rewind_gif.gif)

### Song & Background Change
Changes the background and song image dynamically based on the song. The background is influenced by the dominant colors of the song poster.
  
![Song Change Animation](./path_to_song_change_gif.gif)

### Song List
Open the song list with a beautiful animation. Reorder songs or change the playback mode (random, cyclical, infinite).
  
![Song List Animation](./path_to_song_list_gif.gif)

### Lyrics
Open lyrics with a smooth animation.
  
![Lyrics Animation](./path_to_lyrics_gif.gif)

### Volume Control
Change the sound with a slick animation.
  
![Volume Control Animation](./path_to_volume_gif.gif)

### Play/Pause
Play or pause your songs with a delightful animation.
  
![Play/Pause Animation](./path_to_play_pause_gif.gif)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/pavlo-tereshchuk/AppleMusicPlayer.git
2. Insert disered songs in Songs folder (ideally with inbuilt poster and lyrics)
