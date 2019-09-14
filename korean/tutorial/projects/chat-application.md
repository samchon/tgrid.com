# Chat Application
> https://github.com/samchon/tgrid.projects.chat-application

## 1. Outline
## 2. Design
## 3. Implementation
### 3.1. Features
#### [`controllers/IChatPrinter.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/controllers/IChatPrinter.ts)
```typescript
export interface IChatPrinter
{
    assign(participants: string[]): void;
    insert(name: string): void;
    erase(name: string): void;

    talk(from: string, content: string): void;
    whisper(from: string, to: string, content: string): void;
}
```

#### [`controllers/IChatService.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/controllers/IChatService.ts)
```typescript
export interface IChatService
{
    setName(name: string): boolean;
    talk(content: string): void;
    whisper(name: string, content: string): void;
}
```

### 3.2. Server Program
#### [`providers/ChatService.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/providers/ChatService.ts)
```typescript
import { Driver } from "tgrid/components/Driver";
import { HashMap } from "tstl/container/HashMap";

import { IChatPrinter } from "../controllers/IChatPrinter";

export class ChatService
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

    public async destructor(): Promise<void>
    {
        if (this.name_ === undefined)
            return;

        // ERASE FROM PARTICIPANTS
        this.participants_.erase(this.name_);

        // INFORM TO OTHERS
        let promises: Promise<void>[] = [];
        for (let it of this.participants_)
            promises.push( it.second.erase(this.name_) );
            
        await Promise.all(promises);
    }

    /* ----------------------------------------------------------------
        INTERACTIONS
    ---------------------------------------------------------------- */
    public async setName(name: string): Promise<boolean>
    {
        if (this.participants_.has(name))
            return false;

        // ASSIGN MEMBER
        this.name_ = name;
        this.participants_.emplace(name, this.printer_);

        //----
        // INFORM TO PARTICIPANTS
        //----
        let nameList: string[] = [...this.participants_].map(it => it.first);
        let promiseList: Promise<void>[] = [];

        for (let it of this.participants_)
        {
            let printer: Driver<IChatPrinter> = it.second;
            let promise: Promise<void> = (printer === this.printer_)
                ? printer.assign(nameList) // ITSELF
                : printer.insert(name); // OTHER ONE

            promiseList.push(promise);
        }

        await Promise.all(promiseList);
        return true;
    }

    public async talk(content: string): Promise<void>
    {
        // MUST BE NAMED
        if (this.name_ === undefined)
            throw new Error("Name is not specified yet.");

        //----
        // INFORM TO PARTICIPANTS
        //----
        let promises: Promise<void>[] = [];
        for (let it of this.participants_)
        {
            let p: Promise<void> = it.second.talk(this.name_, content);
            promises.push(p);
        }
        await Promise.all(promises);
    }

    public async whisper(to: string, content: string): Promise<void>
    {
        // MUST BE NAMED
        if (this.name_ === undefined)
            throw new Error("Name is not specified yet.");
        else if (this.participants_.has(to) === false)
            throw new Error("Unable to find the matched name");

        //----
        // INFORM TO TARGET PARTICIPANTS
        //----
        let from: string = this.name_;
        let promises: Promise<void>[] = [];

        for (let printer of [ this.printer_, this.participants_.get(to) ])
        {
            let p: Promise<void> = printer.whisper(from, to, content);
            promises.push(p);
        }
        await Promise.all(promises);
    }
}
```

#### [`server.ts`](https://github.com/samchon/tgrid.projects.chat-application/blob/master/src/server.ts)
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
        let driver: Driver<IChatPrinter> = acceptor.getDriver<IChatPrinter>();
        let service: ChatService = new ChatService(participants, driver);

        await acceptor.accept(service);

        // DESTRUCTOR
        await acceptor.join();
        await service.destructor();
    });
}
main();
```

### 3.3. Client Application
#### `providers/ChatPrinter.tsx`
#### `app.tsx`