# Chat Application
## 1. Outline
![Chat Application](../../../../assets/images/projects/chat-application.png)

간단한 실시간 채팅 어플리케이션을 만들어봅니다.

  - 데모 사이트: https://samchon.org/chat
  - 코드 저장소: https://github.com/samchon/tgrid.projects.chat-application

네트워크 프로그래밍을 실습할 때, 대부분은 실시간 채팅 어플리케이션을 만드는 것에서부터 시작하더라구요. 저희도 그렇게 하겠습니다. **TGrid** 의 첫 예제 프로젝트로써, 실시간 채팅 서버 프로그램을 만들겠습니다. 해당 서버에 접속하여 채팅에 참여할 클라이언트 프로그램 (웹 어플리케이션) 역시 만들어볼 것입니다.

단, *Chat Application* 은 **TGrid** 의 첫 예제 프로젝트인만큼, 난이도를 매우 낮춰 아주 간단하게 만들도록 하겠습니다. 서버에는 <u>오로지 단 하나의 채팅방</u>만이 존재할 것입니다. 따라서 해당 서버에 접속하는 모든 클라이언트들 다같이 모여 대화하게 됩니다. 클라이언트 어플리케이션 역시, [ReactJS](https://ko.reactjs.org/) 로 매우 간결하게 만들 것입니다.

만일 다수의 방이 존재하는 채팅 어플리케이션의 코드가 궁금하시다면, 이 다음 예제 프로젝트인 [Omok Game](omok-game.md) 을 참고해주세요. 물론, 제목은 보시다시피 오목 게임이지만, 게임 내에 <u>다수의 대진방</u>이 존재하며 각 대진방에서는 대국자와 관람자들이 <u>상호 대화</u>할 수 있습니다.


## 2. Design
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
#### [`controllers/IChatService.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/controllers/IChatService.ts)
`IChatService` 는 서버가 클라이언트에게 제공하는 기능들을 정의한 인터페이스로써, 클라이언트에서 [Controller](../concepts.md#23-controller) 로 사용됩니다. 정확히는 클라이언트 프로그램이 [Driver](../concepts.md#24-driver)<`IChatService`> 객체를 사용하여 서버의 [함수들을 원격 호출](../concepts.md#13-remote-function-call)하게 됩니다.

자, 그럼 서버에 접속한 클라이언트가 제일 먼저 해야할 일은 무엇일까요? 그것은 바로 자신의 이름을 정하는 일입니다 (*setName*). 이후에 클라이언트는 채팅방에 참여한 모두에게 이야기하거나 (*talk*), 특정한 누군가에게 귓속말로 속삭이거나 하겠지요 (*whisper*). `IChatService` 는 이처럼 클라이언에서 서버로 [호출하는 원격 함수](../concepts.md#13-remote-function-call)들을 정의한 인터페이스입니디.

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

#### [`controllers/IChatPrinter.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/controllers/IChatPrinter.ts)
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
#### [`providers/ChatService.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/providers/ChatService.ts)
```typescript
import { Driver } from "tgrid/components/Driver";
import { HashMap } from "tstl/container/HashMap";

import { IChatService } from "../controllers/IChatService";
import { IChatPrinter } from "../controllers/IChatPrinter";

export class ChatService implements IChatService
{
    private participants_: HashMap<string, Driver<IChatPrinter>>;
    private printer_: Driver<IChatPrinter>;
    private name_?: string;

    /* ----------------------------------------------------------------
        CONSTRUCTORS
    ---------------------------------------------------------------- */
    public constructor
        (
            participants: HashMap<string, Driver<IChatPrinter>>, 
            printer: Driver<IChatPrinter>
        )
    {
        this.participants_ = participants;
        this.printer_ = printer;
    }

    public destructor(): void
    {
        if (this.name_ === undefined)
            return;

        // ERASE FROM PARTICIPANTS
        this.participants_.erase(this.name_);

        // INFORM TO OTHERS
        for (let it of this.participants_)
        {
            let p: Promise<void> = it.second.erase(this.name_);
            p.catch(() => {});
        }
    }

    /* ----------------------------------------------------------------
        INTERACTIONS
    ---------------------------------------------------------------- */
    public setName(name: string): string[] | false
    {
        if (this.participants_.has(name))
            return false;

        // ASSIGN MEMBER
        this.name_ = name;
        this.participants_.emplace(name, this.printer_);

        // INFORM TO PARTICIPANTS
        for (let it of this.participants_)
        {
            let printer: Driver<IChatPrinter> = it.second;
            if (printer === this.printer_)
                continue;

            let promise: Promise<void> = printer.insert(name);
            promise.catch(() => {});
        }
        return [...this.participants_].map(it => it.first);
    }

    public talk(content: string): void
    {
        // MUST BE NAMED
        if (this.name_ === undefined)
            throw new Error("Name is not specified yet.");

        // INFORM TO PARTICIPANTS
        for (let it of this.participants_)
        {
            let p: Promise<void> = it.second.talk(this.name_, content);
            p.catch(() => {});
        }
    }

    public async whisper(to: string, content: string): Promise<void>
    {
        // MUST BE NAMED
        if (this.name_ === undefined)
            throw new Error("Name is not specified yet.");
        else if (this.participants_.has(to) === false)
            throw new Error("Unable to find the matched name");

        //----
        // INFORM TO PARTICIPANTS
        //----
        // TO SPEAKER
        let from: string = this.name_;
        this.printer_.whisper(from, to, content).catch(() => {});
        
        // TO LISTENER
        if (from !== to)
        {
            let target: Driver<IChatPrinter> = this.participants_.get(to);
            target.whisper(from, to, content).catch(() => {});
        }
    }
}
```

#### [`server.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/server.ts)
서버 프로그램의 메인 코드는 정말 간단합니다. 

웹소켓 서버를 개설하고, 접속해오는 각 클라이언트들에게 [ChatService](#providerschatservicets) 객체를 [Provider](../concepts.md#22-provider) 로써 제공해주면 됩니다. 그리고 클라이언트가 접속을 종료했을 때, 해당 클라이언트를 채팅방의 참여자 목록에서 제거해주면 됩니다.

```typescript
import { WebServer, WebAcceptor } from "tgrid/protocols/web";
import { Driver } from "tgrid/components/Driver";
import { HashMap } from "tstl/container/HashMap";

import { IChatPrinter } from "./controllers/IChatPrinter";
import { ChatService } from "./providers/ChatService";

async function main(): Promise<void>
{
    let server: WebServer<ChatService> = new WebServer();
    let participants: HashMap<string, Driver<IChatPrinter>> = new HashMap();

    await server.open(10103, async (acceptor: WebAcceptor<ChatService>) =>
    {
        // PROVIDE SERVICE
        let printer: Driver<IChatPrinter> = acceptor.getDriver<IChatPrinter>();
        let service: ChatService = new ChatService(participants, printer);

        await acceptor.accept(service);

        // DESTRUCTOR
        await acceptor.join();
        service.destructor();
    });
}
main();
```

### 3.3. Client Application
#### [`providers/ChatPrinter.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/providers/ChatPrinter.ts)
```typescript
import { IChatPrinter } from "../controllers/IChatPrinter";

export class ChatPrinter implements IChatPrinter
{
    private listener_?: ()=>void;

    public readonly name: string;
    public readonly participants: string[];
    public readonly messages: ChatPrinter.IMessage[];

    /* ----------------------------------------------------------------
        CONSTRUCTOR
    ---------------------------------------------------------------- */
    public constructor(name: string, participants: string[])
    {
        this.name = name;
        this.participants = participants;
        this.messages = [];
    }

    public assign(listener: ()=>void): void
    {
        this.listener_ = listener;
    }

    private _Inform(): void
    {
        if (this.listener_)
            this.listener_();
    }

    /* ----------------------------------------------------------------
        METHODS FOR REMOTE FUNCTION CALL
    ---------------------------------------------------------------- */
    public insert(name: string): void
    {
        this.participants.push(name);
        this._Inform();
    }

    public erase(name: string): void
    {
        let index: number = this.participants.findIndex(str => str === name);
        if (index !== -1)
            this.participants.splice(index, 1);

        this._Inform();
    }

    public talk(from: string, content: string): void
    {
        this.messages.push({ 
            from: from, 
            content: content 
        });
        this._Inform();
    }

    public whisper(from: string, to: string, content: string): void
    {
        this.messages.push({ 
            from: from, 
            to: to,
            content: content 
        });
        this._Inform();
    }
}

export namespace ChatPrinter
{
    export interface IMessage
    {
        from: string;
        content: string;
        to?: string;
    }
}
```

#### [`app.tsx`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/app.tsx)
클라이언트의 메인 프로그램 코드 역시 매우 짧고 간단합니다.

일단 웹소켓 채팅 서버에 접속합니다. 그리고 [JoinMovie](#moviesjoinmovietsx) 를 이동합니다. [JoinMovie](#moviesjoinmovietsx) 에서는 채팅방에 참여하기 위하여 자신의 이름 (닉네임) 을 정하는 단계인데, 이 곳에서는 또 무슨 일이 일어나는지, 다음 절을 통해 한 번 알아볼까요?

```typescript
import React from "react";
import ReactDOM from "react-dom";

import { WebConnector } from "tgrid/protocols/web/WebConnector";
import { JoinMovie } from "./movies/JoinMovie";

window.onload = async function ()
{
    let connector: WebConnector = new WebConnector();
    await connector.connect(`ws://${window.location.hostname}:10103`);

    ReactDOM.render(<JoinMovie connector={connector} />, document.body);
}
```

#### [`movies/JoinMovie.tsx`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/movies/JoinMovie.tsx)
```typescript
import React from "react";
import ReactDOM from "react-dom";
import { Panel, Button, Glyphicon } from "react-bootstrap";

import { WebConnector } from "tgrid/protocols/web/WebConnector";
import { Driver } from "tgrid/components/Driver";

import { IChatService } from "../controllers/IChatService";
import { ChatPrinter } from "../providers/ChatPrinter";
import { ChatMovie } from "./ChatMovie";

export class JoinMovie extends React.Component<JoinMovie.IProps>
{
    /* ----------------------------------------------------------------
        CONSTRUCTOR
    ---------------------------------------------------------------- */
    public componentDidMount()
    {
        let input: HTMLInputElement = document.getElementById("name_input") as HTMLInputElement;
        input.select();
    }

    /* ----------------------------------------------------------------
        EVENT HANDLERS
    ---------------------------------------------------------------- */
    private _Handle_keyUp(event: React.KeyboardEvent): void
    {
        if (event.keyCode === 13)
            this._Participate();
    }

    private async _Participate(): Promise<void>
    {
        let input: HTMLInputElement = document.getElementById("name_input") as HTMLInputElement;
        let name: string = input.value;

        if (name === "")
        {
            alert("Name cannot be empty");
            return;
        }
        
        let connector: WebConnector = this.props.connector;
        let service: Driver<IChatService> = connector.getDriver<IChatService>();
        let participants: string[] | false = await service.setName(name);
        
        if (participants === false)
        {
            alert("Duplicated name");
            return;
        }

        let printer: ChatPrinter = new ChatPrinter(name, participants);
        connector.setProvider(printer);

        ReactDOM.render(<ChatMovie service={service} printer={printer} />, document.body);
    }

    /* ----------------------------------------------------------------
        RENDERER
    ---------------------------------------------------------------- */
    public render(): JSX.Element
    {
        return <Panel>
            <Panel.Heading>
                <Panel.Title> 
                    <Glyphicon glyph="list" />
                    {" Chat Application "}
                </Panel.Title>
            </Panel.Heading>
            <Panel.Body>
                Insert your name: 
                <input id="name_input" 
                       type="text" 
                       onKeyUp={this._Handle_keyUp.bind(this)}
                       />
            </Panel.Body>
            <Panel.Footer>
                <Button bsStyle="primary"
                        onClick={this._Participate.bind(this)}> 
                    <Glyphicon glyph="share-alt" />
                    {" Participate in"}
                </Button>
            </Panel.Footer>
        </Panel>
    }
}
namespace JoinMovie
{
    export interface IProps
    {
        connector: WebConnector;
    }
}
```

#### [`movies/ChatMovie.tsx`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/movies/ChatMovie.tsx)
```typescript
import React from "react";
import { Panel, 
    ListGroup, ListGroupItem, 
    Button, FormControl, InputGroup, 
    Glyphicon 
} from "react-bootstrap";

import { Driver } from "tgrid/components/Driver";
import { IChatService } from "../controllers/IChatService";
import { ChatPrinter } from "../providers/ChatPrinter";

export class ChatMovie
    extends React.Component<ChatMovie.IProps>
{
    private to_: string | null = null;

    private get input_(): HTMLInputElement
    {
        return document.getElementById("message_input") as HTMLInputElement;
    }

    /* ----------------------------------------------------------------
        CONSTRUCTOR
    ---------------------------------------------------------------- */
    public constructor(props: ChatMovie.IProps)
    {
        super(props);

        // WHENEVER EVENT COMES
        let printer: ChatPrinter = props.printer;
        printer.assign(() => 
        {
            // ERASE WHISPER TARGET WHEN EXIT
            if (this.to_ !== null)
            {
                let index: number = printer.participants.findIndex(name => name === this.to_);
                if (index === -1)
                    this.to_ = null;
            }
            
            // REFRESH PAGE
            this.setState({})
        });
    }

    public componentDidMount()
    {
        let input: HTMLInputElement = document.getElementById("message_input") as HTMLInputElement;
        input.select();
    }

    public componentDidUpdate()
    {
        let element: HTMLElement = document.getElementById("message_body")!;
        element.scrollTop = element.scrollHeight - element.clientHeight;
    }

    /* ----------------------------------------------------------------
        EVENT HANDLERS
    ---------------------------------------------------------------- */
    private _Handle_keyUp(event: React.KeyboardEvent<FormControl>): void
    {
        if (event.keyCode === 13)
            this._Send_message();
    }

    private _Send_message(): void
    {
        let content: string = this.input_.value;
        let service: Driver<IChatService> = this.props.service;

        if (this.to_ === null)
            service.talk(content);
        else
            service.whisper(this.to_, content);
        
        this.input_.value = "";
        this.input_.select();
    }

    private _Select_participant(name: string): void
    {
        this.to_ = (this.to_ === name)
            ? null
            : name;
        
        this.input_.select();
        this.setState({});
    }

    /* ----------------------------------------------------------------
        RENDERER
    ---------------------------------------------------------------- */
    public render(): JSX.Element
    {
        let printer: ChatPrinter = this.props.printer;

        let myName: string = printer.name;
        let participants: string[] = printer.participants;
        let messages: ChatPrinter.IMessage[] = printer.messages;

        return <div className="main">
            <Panel bsStyle="info" 
                   className="participants">
                <Panel.Heading className="panel-pincer">
                    <Panel.Title> 
                        <Glyphicon glyph="user" />
                        {` Participants: #${participants.length}`}
                    </Panel.Title> 
                </Panel.Heading>
                <Panel.Body id="message_body" 
                            className="panel-body">
                    <ListGroup>
                    {participants.map(name => 
                    {
                        return <ListGroupItem active={name === myName} 
                                              bsStyle={name === this.to_ ? "warning" : undefined}
                                              onClick={this._Select_participant.bind(this, name)}>
                        {name === this.to_
                            ? "> " + name
                            : name
                        }
                        </ListGroupItem>;
                    })}
                    </ListGroup>
                </Panel.Body>
                <Panel.Footer className="panel-pincer">
                    Example Project of TGrid
                </Panel.Footer>
            </Panel>
            <Panel bsStyle="primary"
                   className="messages">
                <Panel.Heading className="panel-pincer">
                    <Panel.Title> 
                        <Glyphicon glyph="list" />
                        {" Message"}
                    </Panel.Title>
                </Panel.Heading>
                <Panel.Body className="panel-body">
                    {messages.map(msg =>
                    {
                        let fromMe: boolean = (msg.from === myName);
                        let style: React.CSSProperties = {
                            textAlign: fromMe ? "right" : undefined,
                            fontStyle: msg.to ? "italic" : undefined,
                            color: msg.to ? "gray" : undefined
                        };
                        let content: string = msg.content;

                        if (msg.to)
                        {
                            let head: string = (msg.from === myName)
                                ? `(whisper to ${msg.to})`
                                : "(whisper)";
                            content = `${head} ${content}`;
                        }

                        return <p style={style}>
                            <b style={{ fontSize: 18 }}> {msg.from} </b>
                            <br/>
                            {content}
                        </p>;
                    })}
                </Panel.Body>
                <Panel.Footer className="panel-pincer">
                    <InputGroup>
                        <FormControl id="message_input" 
                                     type="text"
                                     onKeyUp={this._Handle_keyUp.bind(this)} />
                        <InputGroup.Button>
                            <Button onClick={this._Send_message.bind(this)}>
                            {this.to_ === null
                                ? <React.Fragment>
                                    <Glyphicon glyph="bullhorn" />
                                    Talk to everyone
                                </React.Fragment>
                                : <React.Fragment>
                                    <Glyphicon glyph="screenshot" />
                                    Whisper to {this.to_}
                                </React.Fragment>
                            }
                            </Button>
                        </InputGroup.Button>
                    </InputGroup>
                </Panel.Footer>
            </Panel>
        </div>;
    }
}
export namespace ChatMovie
{
    export interface IProps
    {
        service: Driver<IChatService>;
        printer: ChatPrinter;
    }
}
```