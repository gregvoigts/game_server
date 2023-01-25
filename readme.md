# GameServer

This repository contains all necessary parts to run multiple distributed game servers and cli/gui clients to connect to the servers.

The project is distributed in 3 executable parts: [server](#backend), [GUI](#gui) and [console application](#cli)
as well as 2 supporting libraries: [frontend](#frontend) and [shared Models](#shared_models)

**Important:** The servers need to be started first because the clients automatically connect to the servers.

### Dependencies
* [Docker](https://docs.docker.com)
  * [Traefik](https://doc.traefik.io/traefik/)
* [Dart](https://dart.dev) either alone or through the [FlutterSDK](#dependencies-1)


## Shared_models

shared_models contains all abstractions used in frontend and server application (e.g. game_state and actions send over the network)

## Frontend

frontend contains abstractions used by the [GUI](#gui) and [CLI](#cli) application.
Network communication and client-side specific game-state managing can be found here.

## GUI

A basic flutter application to visualize and interact with the game.
The main purpose is to visualize the changing gamestate.

The GUI itself is a connected client to the game and can enter commands through a text input. Possible inputs:
* ```move <up|down|left|right>``` or abbrevations: ```m <u|d|l|r>```
* ```[heal|h] x y```
* ```[attack|a] x y```


### Usage
execute all commands inside the gui folder:
```shell
flutter run
```

### Dependencies
* [Flutter](https://docs.flutter.dev)

## CLI

A command line interface for one or multiple game client.

Can be used for spawning multiple ai clients. Does not visualize the game-state.

### Usage
execute all commands inside the cli folder:
```shell
dart run cli bots <numberOfBots>
```

## Backend

A server node represents a fully functional game-server with optional synchronisation between multiple server nodes.

Uses docker to containerize and start up to 5 server nodes and let traefik load balance client actions.

### Usage
execute all commands inside the base project folder:
```shell
docker compose up --build
```