# Call of Duty: Modern Warfare Remastered Mapvote

<div id="header" align="center">
 
  ![Preview](https://pbs.twimg.com/media/Fn9U5ubXgAEpzCg?format=jpg&name=large)
  [![Build Badge](https://img.shields.io/badge/Developed_by-DoktorSAS-brightgreen?style=for-the-badge&logo=x)](https://twitter.com/DoktorSAS)
  [![License](https://img.shields.io/badge/LICENSE-GPL--3.0-blue?style=for-the-badge&logo=appveyor)](LICENSE)

   Special thanks to [@Sab]() & [@zdetix](https://twitter.com/zdetix) for their contributions to the development.

</div>

## Requirements

- The script only works on servers and does not function in private games.
- The server must be hosted on the H1-MOD and H2-MOD clients.

## Installation

Setting up the mapvote for your Call of Duty: Modern Warfare Remastered server is a straightforward process. Follow these steps to ensure a smooth installation:

1. **File Placement:**
   * H1 Mod: Copy the downloaded file into your server's script directory, typically located at `%localappdata%\h1-mod\scripts\`.
   * H2 Mod: Copy the downloaded file into your server's script directory, typically located at `<game>\userscripts\mp\`.

2. **Configuration Integration:**
   Open your server configuration file (e.g., `server.cfg`, `dedicated_mp.cfg`, `dedicated.cfg`, etc.) using a text editor of your choice. Paste the contents of the `mapvote.cfg` file into this configuration file. This step ensures that the mapvote script is properly integrated into your server settings.

3. **Customizing Server Parameters:**
   Edit the provided Dvars in the configuration file to tailor the mapvote experience according to your preferences. Key parameters include:
   - `mv_maps`: Specify the maps that will appear in the mapvote.
     ```
     set mv_maps "mp_convoy mp_backlot mp_bog"
     ```
   - `mv_enable`: Activate the mapvote by setting this Dvar to 1.
   - `mv_gametypes`: For random gametypes, define gametype IDs and associated files.
     ```
     set mv_gametypes "dm;freeforall.cfg war;mycustomtdm.cfg"
     ```
5. **Save Changes:**
   Save the modifications to your configuration file.
6. **Server Restart or Script Reload:**
   Restart your Call of Duty: Modern Warfare Remastered server if was on during the installation to apply the changes (map_restart or fast_restart will load or re-load the gsc script).

## Configuration Variables

| Dvar                | Default Value  | Description                                            |
|--------------------|----------------|--------------------------------------------------------|
| `mv_enable`        | 1              | Enable/Disable the mapvote (1 for enable, 0 for disable). |
| `mv_maps`          | ""             | Lists of maps that can be voted on the mapvote; leave empty for all maps. |
| `mv_time`          | 20             | Time (in seconds) allotted for voting.                  |
| `mv_credits`       | 1              | Enable/Disable credits of the mod creator.              |
| `mv_socialname`    | "Discord"      | Name of the server's social platform (Discord, Twitter, Website, etc.). |
| `mv_sociallink`    | "discord.gg/^3xlabs^7" | Link to the server's social platform.             |
| `mv_sentence`      | "Thanks for playing" | Thankful sentence displayed.                        |
| `mv_votecolor`     | "5"            | Color of the vote number.                               |
| `mv_arrowcolor`    | "white"        | RGB color of the arrows.                                |
| `mv_selectcolor`   | "lighgreen"    | RGB color when a map gets voted.                        |
| `mv_backgroundcolor`| "grey"         | RGB color of the map background.                        |
| `mv_blur`          | 3              | Blur effect power.                                      |
| `mv_gametypes`     | ""             | Dvar to have multiple gametypes with different maps. Specify gametype IDs and associated files. |
| `mv_allowchangevote`| 1             | Enable/Disable the possibility to change the vote while the time is still running (1 for enable, 0 for disable). |
| `mv_randomoption`    | 1             | If set to 1 it will not display which map and which gametype the last option will be (Random) |
| `mv_gametypes_norepeat`| 1             |  If set to 1 it will not repeat the maps gametypes  |
| `mv_maps_norepeat`   | 1             | If set to 1 it will not repeat the maps  |
| `mv_minplayerstovote`| 1             | Set the minimum number of players required to start the mapvote  |
| `mv_extended`| 1             | If set to 1 it will allow to choose between 6 maps  |
