# Chat Application
## 1. Outline
![Chat Application](../../../assets/images/projects/chat/chat-movie.png)

간단한 실시간 채팅 어플리케이션을 만들어봅니다.

  - 데모 사이트: http://samchon.org/chat
  - 코드 저장소: https://github.com/samchon/tgrid.projects.chat

네트워크 프로그래밍을 실습할 때, 대부분은 실시간 채팅 어플리케이션을 만드는 것에서부터 시작하더라구요. 저희도 그렇게 하겠습니다. **TGrid** 의 첫 예제 프로젝트로써, 실시간 채팅 서버 프로그램을 만들겠습니다. 채팅에 참여할 클라이언트 프로그램 (웹 어플리케이션) 역시 만들어볼 것입니다.

단, *Chat Application* 은 **TGrid** 의 첫 예제 프로젝트인만큼, 난이도를 매우 낮춰 아주 간단하게 만들도록 하겠습니다. 서버에는 <u>오로지 단 하나의 채팅방</u>만이 존재할 것입니다. 따라서 해당 서버에 접속하는 모든 클라이언트들 다같이 모여 대화하게 됩니다. 클라이언트 어플리케이션 역시, [ReactJS](https://ko.reactjs.org/) 로 매우 간결하게 만들 것입니다.

만일 다수의 방이 존재하는 채팅 어플리케이션의 코드가 궁금하시다면, 이 다음 예제 프로젝트인 [Othello Game](othello-game.md) 을 참고해주세요. 물론, 제목은 보시다시피 오델로 게임이지만, 게임 내에 <u>다수의 대진방</u>이 존재하며 각 대진방에서는 대국자와 관람자들이 <u>상호 대화</u>할 수 있습니다.




## 2. Design
![Class Diagram](../../../assets/images/projects/chat/class-diagram.png)

우리가 처음으로 만들어볼 *Chat Application* 은 매우 간단합니다. 서버에는 오로지 단 하나의 채팅방만이 존재하며, 해당 서버에 접속하는 모든 클라이언트는 오로지 이 곳에서 서로 대화하게 됩니다. 따라서 서버와 클라이언트가 각각 서로에게 제공해야 할 기능 또한 매우 간결합니다.

서버가 클라이언트에게 제공해야 할 기능이란, 그저 클라이언트가 자신의 <u>이름 (닉네임) 을 설정</u>하고 채팅방 본연의 목적인 <u>대화를 나누는 것</u>이 전부입니다. 클라이언트가 서버에게 제공하는 기능은 훨씬 더 쉽고 간단하여, 이를 단 한 마디로 요약할 수 있습니다. 그것은 바로 클라이언트에게 <u>채팅방에서 일어난 일을 알려주는 것</u>입니다.

  - 서버가 클라이언트에게 제공해야 할 기능
    - 이름 (닉네임) 설정
    - 모두에게 대화하기
    - 개인에게 귓속말하기
  - 클라이언트가 서버에게 제공해야 할 기능
    - 참여자 추가 및 삭제
    - 전체 대화 출력하기
    - 귓속말 출력하기




## 3. Implementation
### 3.1. Features
#### [`controllers/IChatService.ts`](https://github.com/samchon/tgrid.projects.chat/blob/master/src/controllers/IChatService.ts)
`IChatService` 는 서버가 클라이언트에게 제공하는 기능들을 정의한 인터페이스로써, 클라이언트에서 [Controller](../concepts.md#23-controller) 로 사용됩니다. 정확히는 클라이언트 프로그램이 [Driver](../concepts.md#24-driver)<`IChatService`> 객체를 사용하여 서버의 [함수들을 원격 호출](../concepts.md#13-remote-function-call)하게 됩니다.

자, 그럼 서버에 접속한 클라이언트가 제일 먼저 해야할 일은 무엇일까요? 그것은 바로 자신의 이름을 정하는 일입니다 (*setName*). 이후에 클라이언트는 채팅방에 참여한 모두에게 이야기하거나 (*talk*), 특정한 누군가에게 귓속말로 속삭이거나 하겠지요 (*whisper*).

```typescript
export interface IChatService
{
    /**
     * 이름 설정하기
     * 
     * @param name 설정할 이름값
     * @return 채팅방 참여자 리스트, 중복 이름 존재시 false 리턴
     */
    setName(name: string): string[] | boolean;

    /**
     * 모두에게 이야기하기
     * 
     * @param content 이야기할 내용
     */
    talk(content: string): void;

    /**
     * 귓속말로 속삭이기
     * 
     * @param to 속삭일 대상의 이름
     * @param content 속삭일 내용
     */
    whisper(to: string, content: string): void;
}
```

#### [`controllers/IChatPrinter.ts`](https://github.com/samchon/tgrid.projects.chat/blob/master/src/controllers/IChatPrinter.ts)
`IChatPrinter` 는 클라이언트가 서버에게 제공하는 기능들을 정의한 인터페이스로써, 서버에서 [Controller](../concepts.md#23-controller) 로 사용됩니다. 정확히는 서버 프로그램이 [Driver](../concepts.md#24-driver)<`IChatPrinter`> 객체를 사용하여 클라이언트가 (서버에게) 제공하는 함수들을 원격 호출하게 됩니다.

더불어 `IChatPrinter` 에 정의된 함수들을 보면, 클라이언트가 서버에게 무엇을 원하는지, 무슨 이유로 저러한 함수들을 서버에게 제공하는지, 그 목적이 뚜렷하게 보입니다. 그것은 바로 "서버야, 채팅방에서 일어난 일들을 나에게 알려줘" 입니다. 

서버는 [Driver](../concepts.md#24-driver)<`IChatPrinter`> 의 *insert* 와 *erase* 함수를 호출함으로써, 클라이언트에게 새로운 참여자가 입장하였거나 기존의 참여자가 퇴장했다는 사실을 알려줍니다. 그리고 *talk* 나 *whisper* 함수들을 호출함으로써, 클라이언트에게 대화방에서 이루어지는 대화내역들 역시 전달해줄 수 있습니다.

```typescript
export interface IChatPrinter
{
    /**
     * 새 참여자 추가
     */
    insert(name: string): void;

    /**
     * 기존 참여자 삭제
     */
    erase(name: string): void;

    /**
     * 모두에게 대화하기 출력
     * 
     * @param from 발언자
     * @param content 내용
     */
    talk(from: string, content: string): void;

    /**
     * 귓속말 내용 출력
     * 
     * @param from 발언자
     * @param to 청취자
     * @param content 내용
     */
    whisper(from: string, to: string, content: string): void;
}
```

### 3.2. Server Program
#### [`providers/ChatService.ts`](https://github.com/samchon/tgrid.projects.chat/blob/master/src/providers/ChatService.ts)
`ChatService` 는 서버가 클라이언트에게 제공하는 [Provider](../concepts.md#22-provider) 클래스입니다. 

동시에 클라이언트가 [Driver](../concepts.md#24-driver)<[IChatService](#controllersichatservicets)> 를 사용하여 `ChatService` 의 메서드를 원격 호출할 때마다, `ChatService` 는 이를 모든 참여자 (클라이언트) 들에게 전파하는 역할도 맡고 있습니다. 이 때 사용하게 되는 멤버변수는 `participants_: HashMap<string, Driver<IChatPrinter>>` 입니다.

클라이언트가 서버와의 접속을 종료하거든, 서버의 [메인 함수](#serverts)는 `ChatService.destructor()` 메서드를 호출함으로써, 클라이언트의 퇴장을 여타 모든 참여자들에게 알려주게 됩니다. 이 때에 사용하게 되는 멤버 변수도 역시 `participants_: HashMap<string, Driver<IChatPrinter>>` 입니다.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat/master/src/providers/ChatService.ts") -->
```

#### [`server.ts`](https://github.com/samchon/tgrid.projects.chat/blob/master/src/server.ts)
서버 프로그램의 메인 코드는 정말 간단합니다. 

웹소켓 서버를 개설하고, 접속해오는 각 클라이언트들에게 [ChatService](#providerschatservicets) 객체를 [Provider](../concepts.md#22-provider) 로써 제공해주면 됩니다. 그리고 클라이언트가 접속을 종료했을 때, [ChatService.destructor()](#providerschatservicets) 메서드를 호출하여, 해당 클라이언트를 채팅방의 참여자 목록에서 제거해주시면 됩니다.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat/master/src/server.ts") -->
```

### 3.3. Client Application
#### [`providers/ChatPrinter.ts`](https://github.com/samchon/tgrid.projects.chat/blob/master/src/providers/ChatPrinter.ts)
`ChatPrinter` 는 클라이언트가 서버에 제공하는 [Provider](../concepts.md#22-provider) 클래스입니다.

 `ChatPrinter` 는 서버가 [Driver](../concepts.md#24-driver)<[IChatPrinter](#controllersichatprinter)> 를 사용하여 자신의 메서드를 원격 호출할 때마다, 해당 내역을 자신의 멤버 변수에 기록해둡니다. 그리고 자신에게 할당된 이벤트 리스너 (멤버변수 `listener_: ()=>void`, 메서드 `assign()` 을 통하여 등록할 수 있다) 를 호출하여, 채팅방에 무언가 변화가 있음을 [ChatMovie](#movieschatmovietsx) 에게 알려줍니다.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat/master/src/providers/ChatPrinter.ts") -->
```

#### [`app.tsx`](https://github.com/samchon/tgrid.projects.chat/blob/master/src/app.tsx)
클라이언트의 메인 프로그램 코드 역시 매우 짧고 간단합니다.

일단 웹소켓 채팅 서버에 접속합니다. 그리고 [JoinMovie](#moviesjoinmovietsx) 를 이동합니다. [JoinMovie](#moviesjoinmovietsx) 에서는 채팅방에 참여하기 위하여 자신의 이름 (닉네임) 을 정하는 단계인데, 이 곳에서는 또 무슨 일이 일어나는지, 다음 절을 통해 한 번 알아볼까요?

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat/master/src/app.tsx") -->
```

#### [`movies/JoinMovie.tsx`](https://github.com/samchon/tgrid.projects.chat/blob/master/src/movies/JoinMovie.tsx)
`JoinMovie` 에서 사용자는 자신의 이름을 정합니다.

사용자가 자신의 이름을 입력하고 "Participate in" 버튼을 누르거든, [Driver](../concepts.md#24-driver)<[IChatService](#controllersichatservicets)> 를 통하여 [ChatService.setName()](#providerschatservicets) 메서드를 원격 호출합니다. 리턴값의 타입이 기존의 채팅방 참여자들을 의미하는 `string` 배열이거든, 그 즉시로 [ChatMovie](#movieschatmovietsx) 로 화면을 전환합니다.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat/master/src/movies/JoinMovie.tsx") -->
```

#### [`movies/ChatMovie.tsx`](https://github.com/samchon/tgrid.projects.chat/blob/master/src/movies/ChatMovie.tsx)
`ChatMovie` 에서 본격적으로 대화가 이루어집니다.

이 곳에서 사용자가 대화를 입력하거나, 또는 특정 대상에게 귓속말로 속삭이거든, `ChatMovie` 는 그 즉시로 [Driver](../concepts.md#24-driver)<[IChatService](#controllersichatservicets)> 를 통하여 서버의 함수를 원격 호출합니다; [ChatService.talk()](#providerschatservicets) 또는 [ChatService.whisper()](#providerschatservicets).

또한 `ChatMovie` 는 [ChatPrinter](#providerschatprinterts) 에 이벤트 리스너를 등록해놨습니다. 그리고 이벤트 리스너는 호출될 때마다, 그 즉시로 화면을 갱신합니다. 따라서 채팅 서버에 참여한 다른 이들의 유입/이탈 이나 대화내역도 [ChatPrinter](#providerschatprinterts) 를 통하여 실시간으로 인지, 가장 최신 상태의 화면을 지속적으로 유지할 수 있습니다.

```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.chat/master/src/movies/ChatMovie.tsx") -->
```