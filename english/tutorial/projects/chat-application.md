# Chat Application
## 1. Outline
![Chat Application](../../../assets/images/projects/chat-application/chat-movie.png)

Create a simple live chat application.

  - Demo site: http://samchon.org/chat
  - Code repository: https://github.com/samchon/tgrid.projects.chat-application

When practicing network programming, most of them start from creating live chat application. We'll also follow the custom. As the first example project of **TGrid**, we will create a live chat server program. We will also create a client program (web application) to participate in the chat.

However, since *Chat Application* is the first tutorial project of the **TGrid**, we will make it very simple with low difficulty. There will only be <u>one chat room</u> on the server. Therefore, all clients connecting to the server will gather and talk together. The client application will also be made very simple with [ReactJS](https://reactjs.org/).

If you are curious about the code of a chat application with multiple rooms, please refer to this next example project,  [Omok Game](omok-game.md). Of course, the sbuject is *Omok Game*, as you can see, but there are a number of rooms in the game, where players and observers can talk to each other.




## 2. Design
![Class Diagram](../../../assets/images/projects/chat-application/class-diagram.png)

The *Chat Application* we'll build is very simple. There is only one chat room on the server, and all clients connecting to that server will only talk to each other here. Therefore, the features server and client must provide to each other is also very concise.

The features must be provided from server to clients are, just let client to <u>set its name</u> and let having <u>conversation</u> with each other. The other features provided fromn clients to server are much easier and simpler, which can be summarized in just one word. It is <u>informing the client what happened</u> in the chat room.

  - What the server must provide to clients
    - to specify name
    - to talk to everyone
    - to whisper to an individual
  - What clients must provide to the server
    - to add and remove participants
    - to print conversation content
    - to print whispered content




## 3. Implementation
### 3.1. Features
#### [`controllers/IChatService.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/controllers/IChatService.ts)
`IChatService` is a [Controller](../concepts.md#23-controller) defining provided freatures from server to clients. Precisely, the client programs [call remote functions](../concepts.md#13-remote-function-call) using the [Driver](../concepts.md#24-driver)<`IChatService`> object.

So what's the first thing a client connecting to a server should do? It's just naming itself (*setName*). After that, the client will talk to everyone (*talk*) or whisper to a special participant (*whisper*).

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat-application/master/src/controllers/IChatService.ts") -->
```

#### [`controllers/IChatPrinter.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/controllers/IChatPrinter.ts)
`IChatPrinter` is a [Controller](../concepts.md#23-controller) defining provided features from client to server. Precisely, the server program [call remote functions](../concepts.md#13-remote-function-call) using the [Driver](../concepts.md#24-driver)<`IChatPrinter`> object.

Also, looking at the functions defined in the IChatPrinter, its purpose is clearly shown up. The purpose is, the client wants server to inform it what is happening in the chat room.

Server informs clients which participants are nelwy come and which participants are existed by calling *insert* or *erase* methods of [Driver](../concepts.md#24-driver)<`IChatPrinter`> object. Also, server delivers conversations by calling *talk* and *whisper* methods of the [Driver](../concepts.md#24-driver)<`IChatPrinter`> object.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat-application/master/src/controllers/IChatPrinter.ts") -->
```

### 3.2. Server Program
#### [`providers/ChatService.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/providers/ChatService.ts)
`ChatService` is a [Provider](../concepts.md#22-provider) class provided from server to client. 

At the same time, `ChatService` has a responsibility to propagating events from chat room to all participants. Whenever client remotely call functions of `ChatService` using [Driver](../concepts.md#24-driver)<[IChatService](#controllersichatservicets), the `ChatService` object delivers the event to all of the participants using `participants_: HashMap<string, Driver<IChatPrinter>>`.

When a client has ben disconnected, main function of the server program calls `ChatService.destructor()` to inform other participants. Of course, same member variable `participants_: HashMap<string, Driver<IChatPrinter>>` would be used again.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat-application/master/src/providers/ChatService.ts") -->
```

#### [`server.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/server.ts)
The main code of the server program is really simple.

You can create a *websocket* server and provide a [ChatService](#providerschatservicets) object as a [Provider](../concepts.md#22-provider) to each client . When the client closes the connection, call the `ChatService.destructor()` method to remove the client from the chat room's participants list.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat-application/master/src/server.ts") -->
```

### 3.3. Client Application
#### [`providers/ChatPrinter.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/providers/ChatPrinter.ts)
`ChatPrinter` is a [Provider](../concepts.md#22-provider) class provided from client to server .

Whenever server remotely calls function of `ChatPrinter` using [Driver](../concepts.md#24-driver)<[IChatPrinter](#controllersichatprinter)>, `ChatPrinter` archives writes it into its member variables. After the archiving, `ChatPrinter` calls the event listener (which registerted into `listener_: ()=>void` through `assign()` method) to inform [ChatMovie](#movieschatmovietsx) that something has been changed in the chat room.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat-application/master/src/providers/ChatPrinter.ts") -->
```

#### [`app.tsx`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/app.tsx)
The main function code of the client program is also very short and simple.

The main function connects to the websocket chat server and moves to the [JoinMovie](#moviesjoinmovietsx). [JoinMovie](#moviesjoinmovietsx) is designed to set your name to join the chat room, but it would be much better to see its detailed code by yourself.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat-application/master/src/app.tsx") -->
```

#### [`movies/JoinMovie.tsx`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/movies/JoinMovie.tsx)
In `JoinMovie` is desinged to set name and inform it to server.

When user inputs its name and clicks the "Participate in" button, JoinMovie remotely calls [ChatService.setName()](#providerschatservicets) method using [Driver](../concepts.md#24-driver)<[IChatService](#controllersichatservicets)> object. If returned type is Array of `string` which means participants of the chat room, then `JoinMovie` converts screen to [ChatMovie](#movieschatmovietsx) directly.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat-application/master/src/movies/JoinMovie.tsx") -->
```

#### [`movies/ChatMovie.tsx`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/movies/ChatMovie.tsx)
Conversations are done in the `ChatMovie`.

When user inputs conversation or whisper to someone, ChatMovie remotely calls server's method through [Driver](../concepts.md#24-driver)<[IChatService](#controllersichatservicets)>; [ChatService.talk()](#providerschatservicets) or [ChatService.whisper()](#providerschatservicets).

Also, `ChatMovie` registers an event listeners to the [ChatPrinter](#providerschatprinterts). Therefore, whenever the event listener is called, `ChatMovie` refreshes the screen immediately and it helps `ChatMovie` to keep the most-up-date screen of the chat room continuosly.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat-application/master/src/movies/ChatMovie.tsx") -->
```