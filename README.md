# H1: Call of Duty: Modern Warfare Remastered 
Developed by [@DoktorSAS](https://twitter.com/DoktorSAS)

![Preview](https://pbs.twimg.com/media/Fn9U5ubXgAEpzCg?format=jpg&name=large)

### Requirements

- The script can only work on Server's, It will not work in private games.
- Server must be hosted on H1-MOD client.

#### How to setup the mapvote step by step 

 1) Copy the file in your Directory %localappdata%\h1-mod\scripts\
 3) Copy the Content of the mapvote.cfg in your .cfg (Exemple: server.cfg, dedicated_mp.cfg, dedicated.cfg, etc ) file that manages the Server.
 4) Edit the Dvars to setup the Server, many Dvars are only for Aesthetic Parameters.
    - set the Dvar mv_maps to decide the maps that will be shown in mapvote, Example:
        - set mv_maps "mp_convoy mp_backlot mp_bog"
    - set the dvar mv_enable to 1 if you want have it active on your server.
    - If you want random gametypes you have to set the dvar mp_gametypes specifying the gametype id (dm, war, sd, etc) and the file to run if necessary. Exemple:
        - set mv_gametypes "dm@freeforall.cfg war@mycustomtdm.cfg"
 5) Run the Server and have fun. Done!
