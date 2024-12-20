# LeagueSandbox <span style="opacity: 0.1">// The source of evil</span>
old repo: https://github.com/LeagueSandbox/GameServer<br>
new repo: https://github.com/cabeca1143/GameServer<br>
discord: [League Sandbox Developers](https://discord.gg/8HbHaVtf)<br>
discord: [League Sandbox Public](https://discord.gg/UKaMUg3Y)<br>

# Chronobreak <span style="opacity: 0.1">// LeagueSandbox v2.0</span>
forum post: [RaGEZONE](https://forum.ragezone.com/threads/𝗥𝗘𝗟𝗘𝗔𝗦𝗘-𝗖𝗵𝗿𝗼𝗻𝗼𝗯𝗿𝗲𝗮𝗸-𝘁𝗵𝗲-𝗟𝗲𝗮𝗴𝘂𝗲-𝗼𝗳-𝗟𝗲𝗴𝗲𝗻𝗱𝘀-𝗽𝗿𝗶𝘃𝗮𝘁𝗲-𝘀𝗲𝗿𝘃𝗲𝗿.1231008)<br>
discord: [League Sandstorm](https://discord.gg/aquQGUAXuW) (please note that this discord server is dedicated to LoL clones/custom-servers in general)<br>
download link: [magnet](magnet:?xt=urn:btih:e4043fdc210a896470d662933f7829ccf3ed781b&xt=urn:btmh:1220cf9bfaba0f9653255ff5b19820ea4c01ac8484d0f8407b109ca358236d4f4abc&dn=Chronobreak.GameServer.7z) (please help to seed)<br>
download link: [mega.nz](https://mega.nz/file/D35i0YaD#P08udvnbUByZHGBvCTbC1XDPkKdUGgp4xtravAlECbU) (won't last forever)<br>

The main difference from its predecessor (apart from the fact that many systems were improved, added or rewritten) was the transition from custom scripts (which had to be written by enthusiasts together with the server) to original scripts (supplied with the game up until version 1.0.0.133).<br>
However, like its predecessor, it uses client version 4.20, so it suffers from a mismatch between the version of scripts used on the server side and the version of resources and configs on the client side.
Therefore, only those **champions and items that were added before 1.0.0.133 and did not change untill 4.20 work best**. Anything added or reworked after 1.0.0.132 - doesn't work.<br>
<small>There is a version that uses the old client, but it has not been released publicly.<br>An alternative solution would be to port resources from the old client to the new one.</small>

## FAQ
<details>
<summary>
Has anyone developed bots for Chronobreak?
</summary>
Although it is technically possible to convert and use bot behavior trees leaked with version 1.0.0.142 of the game client, as of 12/20/2024 only Garen is publicly available (functionality not confirmed).
</details>

## Running the server
### Prerequisites
Install [.NET 8 or newer](https://dotnet.microsoft.com/en-us/download)

### Manual Setup (Windows)
If you have Microsoft Visual Studio 2019 or newer (Community Edition is fine too) installed, then open the GameServer Solution in VS, build and run GameServerConsole project.

### Manual Setup (Linux)
```bash
# Build:
cd GameServer/GameServerConsole
dotnet build .
# Run:
cd GameServerConsole/bin/Debug/net8.0
./GameServerConsole
# Build & Run:
cd GameServer/GameServerConsole
dotnet run .
```
<br>

# League of Legends 4.20 game client
download link: [magnet](magnet:?xt=urn:btih:4bb197635194f4242d9f937f0f9225851786a0a8&dn=League%20of%20Legends_UNPACKED.7z) (please help to seed)<br>
download link: [mega.nz](mega.nz/file/Hr5XEAqT#veo2lfRWK7RrLUdFBBqRdUvxwr_gd8UyUL0f6b4pHJ0) (won't last forever)<br>

## Running the game client
### Prerequisites
Download and unpack the 4.20 version of League game client.

### Automatic launch from Visual Studio or GameServerConsole.exe
* Open `GameServer\GameServerConsole\bin\Debug\net8.0\Settings\GameServerSettings.json` in any text editor
* Replace `false` in `"autoStartClient": false` to `true`
* Set the path to your League of Legends' `deploy` folder (`Path\To\Your\League420\RADS\solutions\lol_game_client_sln\releases\0.0.1.68\deploy`), which shown by the example already in the file. Don't forget to replace all backslashes (`\\`) with double backslashes (`\\\\`)

### Manually Launching from command line (Windows)
```bat
cd "Path\To\Your\League420\RADS\solutions\lol_game_client_sln\releases\0.0.1.68\deploy"
start "" "League of Legends.exe" "" "" "" "127.0.0.1 5119 17BLOhi6KZsTtldTsizvHg== 1"
```
### Manually Launching from command line (Linux)
* Install `wine` and `winetricks` using your package manager.
* Run `winetricks d3dx9` - without this you will get into the game, but your screen will be black.
* Enter the directory containing the client  and run the game:
```bash
cd /path/to/your/League-of-Legends-4-20/RADS/solutions/lol_game_client_sln/releases/0.0.1.68/deploy
wine "./League of Legends.exe" "" "" "" "127.0.0.1 5119 17BLOhi6KZsTtldTsizvHg== 1"
```
<br>

# Userful links
It may be a good idea to save their contents to preserve.

Old clients with debug data to revers engineer: <br>
https://archive.org/details/league-of-legends-0.9.22.14-beta <br>
https://archive.org/details/LOL-1.0.0.106 <br>
https://archive.org/details/LOL-1.0.0.126 <br>

1.0.0.131 client (solution 0.0.0.64):<br>
[magnet](magnet:?xt=urn:btih:eb6dd0165ac7216d6e87247102e79fcf7099dcb2&xt=urn:btmh:12208e9e8d50ee6a8ebbfd7c8f69cd53ae48c4b6ba55fff736ea899eae68b79cc5dd&dn=131.7z) (please help to seed)<br>
[mega.nz](https://mega.nz/file/jrZxwa5C#TVArHIw64R44tfI9FAjCYhD1qh64SqbfxObUZ2hdyHM) (won't last forever)<br>

1.0.0.131 up to 1.0.0.132 client (solution 0.0.0.70) patch:<br>
<small>The last patch before the scripts were removed from the client</small><br>
[magnet](magnet:?xt=urn:btih:aa53c3407b8b63abd2afce85a73aa97057e288d8&xt=urn:btmh:122078ae447d63e10a8657a8a2253d33d00aa01afe669ef4dda6e3bb4d2712002d11&dn=0.0.0.65-70.7z) (please help to seed)<br>
[mega.nz](https://mega.nz/file/bywGwQ7T#QjlebplO2zyKDbKHdb2RTkuKZHYL1b-bhfu1UjLRFLI) (won't last forever)<br>
