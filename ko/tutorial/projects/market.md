# Grid Market
## 1. Outline
  - 데모 사이트: http://samchon.org/market
  - 코드 저장소: https://github.com/samchon/tgrid.projects.market


## 2. Design



## 3. Implementation
### 3.1. Market
#### [`core/market/ConsumerChannel.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/market/ConsumerChannel.ts)
```typescript
import { WebAcceptor } from "tgrid/protocols/web";
import { SharedWorkerAcceptor } from "tgrid/protocols/workers";
import { HashMap } from "tstl/container/HashMap";
import { ArrayDict } from "../../utils/ArrayDict";

import { Market } from "./Market";
import { ISupplier } from "../supplier/ISupplier";
import { SupplierChannel } from "./SupplierChannel";
import { Supplier } from "../supplier/Supplier";
import { Consumer } from "../consumer/Consumer";

export class ConsumerChannel
{
    public readonly uid: number;

    private market_: Market;
    private acceptor_: Acceptor;
    private assignees_: HashMap<number, SupplierChannel>;

    /* ----------------------------------------------------------------
        CONSTRUCTORS
    ---------------------------------------------------------------- */
    public static async create
        (
            uid: number, 
            market: Market, 
            acceptor: Acceptor
        ): Promise<ConsumerChannel>
    {
        let ret: ConsumerChannel = new ConsumerChannel(uid, market, acceptor);
        await ret.acceptor_.accept(new ConsumerChannel.Provider(ret));
        
        ret._Handle_disconnection();
        return ret;
    }

    private constructor(uid: number, market: Market, acceptor: Acceptor)
    {
        this.uid = uid;
        this.market_ = market;
        this.acceptor_ = acceptor;

        this.assignees_ = new HashMap();
    }

    private async _Handle_disconnection(): Promise<void>
    {
        try { await this.acceptor_.join(); } catch {}
        for (let it of this.assignees_)
            await it.second.unlink(this);
    }

    /* ----------------------------------------------------------------
        ACCESSORS
    ---------------------------------------------------------------- */
    /**
     * @internal
     */
    public getMarket(): Market
    {
        return this.market_;
    }

    public getDriver()
    {
        return this.acceptor_.getDriver<Consumer.IController>();
    }

    /**
     * @internal
     */
    public getAssignees()
    {
        return this.assignees_;
    }

    /* ----------------------------------------------------------------
        SUPPLIERS I/O
    ---------------------------------------------------------------- */
    /**
     * @internal
     */
    public async link(supplier: SupplierChannel): Promise<boolean>
    {
        if (this.assignees_.has(supplier.uid) || // DUPLICATED
            await supplier.link(this) === false) // MONOPOLIZED
            return false;

        // CONSTR5UCT SERVANT
        await this.assignees_.emplace(supplier.uid, supplier);

        // PROVIDER FOR CONSUMER (SERVANT) := CONTROLLER OF SUPPLIER
        let provider = supplier.getDriver();
        this.acceptor_.provider!.assginees.set(supplier.uid, provider);

        // RETURN WITH ASSIGNMENT
        await provider.assign(this.uid);
        for (let entry of this.market_.getMonitors())
            entry.second.link(this.uid, supplier.uid).catch(() => {});

        return true;
    }

    /**
     * @internal
     */
    public async unlink(supplier: SupplierChannel): Promise<void>
    {
        this.assignees_.erase(supplier.uid);
        this.acceptor_.provider!.assginees.erase(supplier.uid);

        await supplier.unlink(this);
        for (let entry of this.market_.getMonitors())
            entry.second.release(supplier.uid).catch(() => {});
    }
}

export namespace ConsumerChannel
{
    /**
     * @hidden
     */
    export interface IController
    {
        assginees: ArrayLike<Supplier.IController>;
    
        getUID(): number;
        getSuppliers(): ISupplier[];
        buyResource(supplier: ISupplier): Promise<boolean>;
    }

    /**
     * @hidden
     */
    export class Provider implements IController
    {
        private consumer_: ConsumerChannel;
        private market_: Market;
        public assginees: ArrayDict<Supplier.IController>;

        public constructor(consumer: ConsumerChannel)
        {
            this.consumer_ = consumer;
            this.market_ = consumer.getMarket();
            this.assginees = new ArrayDict();
        }

        public getUID(): number
        {
            return this.consumer_.uid;
        }

        public getSuppliers(): ISupplier[]
        {
            return this.market_.getSuppliers().toJSON().map(entry => entry.second.toJSON());
        }

        public async buyResource(supplier: ISupplier): Promise<boolean>
        {
            let map = this.market_.getSuppliers();
            let it = map.find(supplier.uid);

            if (it.equals(map.end()) === true)
                return false;

            return await this.consumer_.link(it.second);
        }
    }
}

/**
 * @hidden
 */
type Acceptor = WebAcceptor<ConsumerChannel.Provider> | SharedWorkerAcceptor<ConsumerChannel.Provider>;
```

#### [`core/market/SupplierChannel.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/market/SupplierChannel.ts)
```typescript
import { WebAcceptor } from "tgrid/protocols/web";
import { SharedWorkerAcceptor } from "tgrid/protocols/workers";
import { Mutex } from "tstl/thread/Mutex";

import { ISupplier } from "../supplier/ISupplier";
import { IPerformance } from "../supplier/IPerformance";
import { ConsumerChannel } from "./ConsumerChannel";
import { UniqueLock } from "tstl";
import { Driver } from "tgrid/basic";
import { Supplier } from "../supplier/Supplier";

export class SupplierChannel implements Readonly<ISupplier>
{
    /**
     * @inheritDoc
     */
    public readonly uid: number;

    /**
     * @inheritDoc
     */
    public readonly performance: IPerformance;

    /**
     * @hidden
     */
    private acceptor_: Acceptor;

    /**
     * @hidden
     */
    private consumer_: ConsumerChannel | null;

    /**
     * @hidden
     */
    private mtx_: Mutex;

    /* ----------------------------------------------------------------
        CONSTRUCTORS
    ---------------------------------------------------------------- */
    /**
     * @hidden
     */
    private constructor(uid: number, acceptor: Acceptor)
    {
        this.uid = uid;
        this.acceptor_ = acceptor;
        
        this.performance = 
        {
            mean: 1.0,
            risk: 0.0,
            credit: 0.0
        };
        this.consumer_ = null;
        this.mtx_ = new Mutex();
    }

    /**
     * @internal
     */
    public static async create(uid: number, acceptor: Acceptor): Promise<SupplierChannel>
    {
        let ret: SupplierChannel = new SupplierChannel(uid, acceptor);
        await ret.acceptor_.accept(new SupplierChannel.Provider(ret));

        ret._Handle_disconnection();
        return ret;
    }

    /**
     * @hidden
     */
    private async _Handle_disconnection(): Promise<void>
    {
        try { await this.acceptor_.join(); } catch {}
        await UniqueLock.lock(this.mtx_, async () =>
        {
            if (this.consumer_ !== null)
                this.consumer_.unlink(this);
        });
    }

    /* ----------------------------------------------------------------
        ACCESSORS
    ---------------------------------------------------------------- */
    /**
     * @inheritDoc
     */
    public get free(): boolean
    {
        return this.consumer_ === null;
    }

    public getDriver(): Driver<Supplier.IController>
    {
        return this.acceptor_.getDriver<Supplier.IController>();
    }

    public getConsumer(): ConsumerChannel | null
    {
        return this.consumer_;
    }

    public toJSON(): ISupplier
    {
        let ret: ISupplier = 
        {
            uid: this.uid,
            performance: this.performance,
            free: this.free
        };
        return ret;
    }

    /* ----------------------------------------------------------------
        ASSIGNER
    ---------------------------------------------------------------- */
    /**
     * @internal
     */
    public async link(consumer: ConsumerChannel): Promise<boolean>
    {
        let ret: boolean;
        await UniqueLock.lock(this.mtx_, () =>
        {
            if ((ret = this.free) === true)
            {
                this.consumer_ = consumer;
                this.acceptor_.provider!.provider = consumer.getDriver().servants[this.uid];
            }
        });
        return ret!;
    }

    /**
     * @internal
     */
    public async unlink(consumer: ConsumerChannel): Promise<void>
    {
        await UniqueLock.lock(this.mtx_, async () =>
        {
            if (this.consumer_ === consumer)
            {
                // ERASE CONSUMER
                this.consumer_ = null;
                this.acceptor_.provider!.provider = null;

                // TO ANTICIPATE ABUSING
                this.getDriver().close().catch(() => {});
            }
        });
    }
}

export namespace SupplierChannel
{
    export interface IController
    {
        provider: object | null;
        getUID(): number;
    }

    export class Provider implements IController
    {
        private channel_: SupplierChannel;

        // PROVIDER FOR SUPPLIER := CONTROLLER OF CONSUMER (SERVANT)
        public provider: object | null = null;

        public constructor(channel: SupplierChannel)
        {
            this.channel_ = channel;
        }
        
        public getUID(): number
        {
            return this.channel_.uid;
        }
    }
}

/**
 * @hidden
 */
type Acceptor = WebAcceptor<SupplierChannel.Provider> | SharedWorkerAcceptor<SupplierChannel.Provider>;
```

#### [`core/market/Market.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/market/Market.ts)
```typescript
import { HashMap } from "tstl/container/HashMap";
import { WebServer, WebAcceptor } from "tgrid/protocols/web";
import { SharedWorkerServer, SharedWorkerAcceptor } from "tgrid/protocols/workers";
import { Driver } from "tgrid/basic";

import { ConsumerChannel } from "./ConsumerChannel";
import { SupplierChannel } from "./SupplierChannel";
import { Monitor } from "../monitor/Monitor";
import { IConsumerNode } from "../monitor/IConsumerNode";
import { ISupplierNode } from "../monitor/ISupplierNode";

export class Market
{
    /**
     * @hidden
     */
    private server_: Server<Provider>;

    /**
     * @hidden
     */
    private consumers_: HashMap<number, ConsumerChannel>;

    /**
     * @hidden
     */
    private suppliers_: HashMap<number, SupplierChannel>;

    /**
     * @hidden
     */
    private monitors_: HashMap<number, Driver<Monitor.IController>>;

    /**
     * @hidden
     */
    private static sequence_: number = 0;

    /* ----------------------------------------------------------------
        CONSTRUCTORS
    ---------------------------------------------------------------- */
    /**
     * @hidden
     */
    private constructor(server: Server<Provider>)
    {
        this.server_ = server;

        this.consumers_ = new HashMap();
        this.suppliers_ = new HashMap();
        this.monitors_ = new HashMap();
    }

    public static async open(port: number): Promise<Market>
    {
        let server: WebServer<Provider> = new WebServer();
        let market: Market = new Market(server);

        await Market._Open(market, 
            server.open.bind(server, port),
            (acceptor: WebAcceptor<Provider>): Actor => 
            {
                if (acceptor.path.indexOf("/consumer") === 0)
                    return Actor.CONSUMER;
                else if (acceptor.path.indexOf("/supplier") === 0)
                    return Actor.SUPPLIER;
                else if (acceptor.path.indexOf("/monitor") === 0)
                    return Actor.MONITOR;
                else
                    return Actor.NONE;
            },
            (acceptor: WebAcceptor<Provider>) => acceptor.reject(404, "Invalid URL")
        );

        // RETURNS
        return market;
    }

    // public static async simulate(): Promise<Market>
    // {
    //     //----
    //     // NODE: IN CHILD-PROCESS, OPEN THE WEB-SERVER
    //     // WEB:  IN SHARED-WORKER, OPEN THE SHARED-WORKER-SERVER
    //     //----
    // }

    public async close(): Promise<void>
    {
        await this.server_.close();
        this.consumers_.clear();
        this.suppliers_.clear();
    }

    /* ----------------------------------------------------------------
        ACCESSORS
    ---------------------------------------------------------------- */
    public getSuppliers()
    {
        return this.suppliers_;
    }

    public getMonitors()
    {
        return this.monitors_;
    }

    /* ----------------------------------------------------------------
        PROCEDURES
    ---------------------------------------------------------------- */
    /**
     * @hidden
     */
    private static async _Open<AcceptorT extends Acceptor<Provider>>
        (
            market: Market, 
            opener: (cb: (acceptor: AcceptorT) => Promise<void>) => Promise<void>,
            predicator: (acceptor: AcceptorT) => Actor,
            rejector: (acceptor: AcceptorT) => Promise<void>
        ): Promise<void>
    {
        await opener(async acceptor =>
        {
            //----
            // PRELIMINARIES
            //----
            // DETERMINE ACTOR
            let uid: number = ++Market.sequence_;
            let actor: Actor = predicator(acceptor);

            if (actor === Actor.NONE)
            {
                await rejector(acceptor);
                return;
            }
            else if (actor === Actor.MONITOR)
            {
                market._Handle_monitor(uid, acceptor);
                return;
            }

            // PREPARE ASSETS
            let instance: Instance;
            let dictionary: HashMap<number, Instance>;
            let monitor_inserter: (drvier: Driver<Monitor.IController>)=>Promise<void>;
            let monitor_eraser: (drvier: Driver<Monitor.IController>)=>Promise<void>;
            
            //----
            // PROCEDURES
            //----
            // CONSTRUCT INSTANCE
            if (actor === Actor.CONSUMER)
            {
                instance = await ConsumerChannel.create(uid, market, acceptor as Acceptor<ConsumerChannel.Provider>);
                dictionary = market.consumers_;

                let raw: IConsumerNode = { uid: uid, servants: [] };
                monitor_inserter = driver => driver.insertConsumer(raw);
                monitor_eraser = driver => driver.eraseConsumer(uid);
            }
            else
            {
                instance = await SupplierChannel.create(uid, acceptor as Acceptor<SupplierChannel.Provider>);
                dictionary = market.suppliers_;

                let raw: ISupplierNode = { uid: uid };
                monitor_inserter = driver => driver.insertSupplier(raw);
                monitor_eraser = driver => driver.eraseSupplier(uid);
            }
            
            // ENROLL TO DICTIONARY
            dictionary.emplace(uid, instance);
            console.log("A participant has come", market.consumers_.size(), market.suppliers_.size());
            
            // INFORM TO MONITORS
            for (let entry of market.monitors_)
                monitor_inserter(entry.second).catch(() => {});

            //----
            // DISCONNECTION
            //----
            // JOIN CONNECTION
            try { await acceptor.join(); } catch {}

            // ERASE ON DICTIONARY
            dictionary.erase(uid);
            console.log("A participant has left", market.consumers_.size(), market.suppliers_.size());
            
            // INFORM TO MONITORS
            for (let entry of market.monitors_)
                monitor_eraser(entry.second).catch(() => {});
        });
    }

    private async _Handle_monitor(uid: number, acceptor: Acceptor<{}>): Promise<void>
    {
        console.log("A monitor has come", this.monitors_.size());

        // ACCEPT CONNECTION
        let driver: Driver<Monitor.IController> = acceptor.getDriver<Monitor.IController>();
        await acceptor.accept(null);

        this.monitors_.emplace(uid, driver);

        //----
        // SEND CURRENT RELATIONSHIP
        //----
        let rawConsumers: IConsumerNode[] = [];
        let rawSuppliers: ISupplierNode[] = [];

        // CONSUMERS
        for (let entry of this.consumers_)
        {
            let raw: IConsumerNode = { uid: entry.first, servants: [] };
            for (let servantEntry of entry.second.getAssignees())
                raw.servants.push(servantEntry.first);
            rawConsumers.push(raw);
        }
        
        // SUPPLIERS
        for (let entry of this.suppliers_)
        {
            let raw: ISupplierNode = { uid: entry.first };
            rawSuppliers.push(raw);
        }
        
        // DO ASSIGN
        await driver.assign(rawConsumers, rawSuppliers);

        //----
        // JOIN CONNECTION
        //----
        await acceptor.join();
        this.monitors_.erase(uid);

        console.log("A monitor has left", this.monitors_.size());
    }
}

/**
 * @hidden
 */
type Server<Provider extends object> = WebServer<Provider> | SharedWorkerServer<Provider>;

/**
 * @hidden
 */
type Instance = ConsumerChannel | SupplierChannel;

/**
 * @hidden
 */
type Acceptor<Provider extends object> = WebAcceptor<Provider> | SharedWorkerAcceptor<Provider>;

/**
 * @hidden
 */
type Provider = ConsumerChannel.Provider | SupplierChannel.Provider;

/**
 * @hidden
 */
const enum Actor
{
    NONE,
    CONSUMER,
    SUPPLIER,
    MONITOR
}
```

### 3.2. Consumer
#### [`core/consumer/Servant.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/consumer/Servant.ts)
```typescript
import { ISupplier } from "../supplier/ISupplier";
import { ICommunicator, Driver } from "tgrid/basic";
import { ConditionVariable } from "tstl/thread";

import { Supplier } from "../supplier/Supplier";
import { IPerformance } from "../supplier/IPerformance";

export class Servant implements Readonly<ISupplier>, ICommunicator<object|null|undefined>
{
    /**
     * @hidden
     */
    private base_: ISupplier;

    /**
     * @hidden
     */
    private assignee_: Driver<Supplier.IController>;

    /**
     * @hidden
     */
    private joiners_: ConditionVariable;

    /**
     * @hidden
     */
    private provider_?: object | null;

    /* ----------------------------------------------------------------
        CONSTRUCTORS
    ---------------------------------------------------------------- */
    /**
     * @hidden
     */
    private constructor(base: ISupplier, driver: Driver<Supplier.IController>)
    {
        this.base_ = base;
        this.assignee_ = driver;

        this.joiners_ = new ConditionVariable();
    }

    /**
     * @internal
     */
    public static create(base: ISupplier, driver: Driver<Supplier.IController>): Servant
    {
        return new Servant(base, driver);
    }

    public async compile(provider: object | null, script: string, ...args: string[]): Promise<void>
    {
        this.provider_ = provider;
        await this.assignee_.compile(script, ...args);
    }

    public async close(): Promise<void>
    {
        await this.assignee_.close();
        await this.joiners_.notify_all();
    }

    /* ----------------------------------------------------------------
        ACCESSORS
    ---------------------------------------------------------------- */
    public get provider(): object | null | undefined
    {
        return this.provider_;
    }

    public getDriver<Controller extends object>(): Driver<Controller>
    {
        return this.assignee_.provider as Driver<Controller>;
    }

    public join(): Promise<void>;
    public join(ms: number): Promise<boolean>;
    public join(until: Date): Promise<boolean>;

    public join(param?: number | Date): Promise<void | boolean>
    {
        if (param === undefined)
            return this.joiners_.wait();
        else if (param instanceof Date)
            return this.joiners_.wait_until(param);
        else
            return this.joiners_.wait_for(param);
    }
    
    /* ----------------------------------------------------------------
        PROPERTIES
    ---------------------------------------------------------------- */
    public get uid(): number
    {
        return this.base_.uid;
    }
    public get performance(): IPerformance
    {
        return this.base_.performance;
    }
    public get free(): boolean
    {
        return false;
    }
}

export namespace Servant
{
    /**
     * @internal
     */
    export interface IController
    {
        provider: object;

        join(): Promise<void>;
        close(): Promise<void>;
    }

    /**
     * @internal
     */
    export class Provider
    {
        private base_: Servant;

        public constructor(base: Servant)
        {
            this.base_ = base;
        }

        public get provider(): object
        {
            return this.base_.provider!;
        }

        public join(): Promise<void>
        {
            return this.base_.join();
        }

        public close(): Promise<void>
        {
            return this.base_.close();
        }
    }
}
```

#### [`core/consumer/Consumer.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/consumer/Consumer.ts)
```typescript
import { ISupplier } from "../supplier/ISupplier";
import { ICommunicator, Driver } from "tgrid/basic";
import { ConditionVariable } from "tstl/thread";

import { Supplier } from "../supplier/Supplier";
import { IPerformance } from "../supplier/IPerformance";

export class Servant implements Readonly<ISupplier>, ICommunicator<object|null|undefined>
{
    /**
     * @hidden
     */
    private base_: ISupplier;

    /**
     * @hidden
     */
    private assignee_: Driver<Supplier.IController>;

    /**
     * @hidden
     */
    private joiners_: ConditionVariable;

    /**
     * @hidden
     */
    private provider_?: object | null;

    /* ----------------------------------------------------------------
        CONSTRUCTORS
    ---------------------------------------------------------------- */
    /**
     * @hidden
     */
    private constructor(base: ISupplier, driver: Driver<Supplier.IController>)
    {
        this.base_ = base;
        this.assignee_ = driver;

        this.joiners_ = new ConditionVariable();
    }

    /**
     * @internal
     */
    public static create(base: ISupplier, driver: Driver<Supplier.IController>): Servant
    {
        return new Servant(base, driver);
    }

    public async compile(provider: object | null, script: string, ...args: string[]): Promise<void>
    {
        this.provider_ = provider;
        await this.assignee_.compile(script, ...args);
    }

    public async close(): Promise<void>
    {
        await this.assignee_.close();
        await this.joiners_.notify_all();
    }

    /* ----------------------------------------------------------------
        ACCESSORS
    ---------------------------------------------------------------- */
    public get provider(): object | null | undefined
    {
        return this.provider_;
    }

    public getDriver<Controller extends object>(): Driver<Controller>
    {
        return this.assignee_.provider as Driver<Controller>;
    }

    public join(): Promise<void>;
    public join(ms: number): Promise<boolean>;
    public join(until: Date): Promise<boolean>;

    public join(param?: number | Date): Promise<void | boolean>
    {
        if (param === undefined)
            return this.joiners_.wait();
        else if (param instanceof Date)
            return this.joiners_.wait_until(param);
        else
            return this.joiners_.wait_for(param);
    }
    
    /* ----------------------------------------------------------------
        PROPERTIES
    ---------------------------------------------------------------- */
    public get uid(): number
    {
        return this.base_.uid;
    }
    public get performance(): IPerformance
    {
        return this.base_.performance;
    }
    public get free(): boolean
    {
        return false;
    }
}

export namespace Servant
{
    /**
     * @internal
     */
    export interface IController
    {
        provider: object;

        join(): Promise<void>;
        close(): Promise<void>;
    }

    /**
     * @internal
     */
    export class Provider
    {
        private base_: Servant;

        public constructor(base: Servant)
        {
            this.base_ = base;
        }

        public get provider(): object
        {
            return this.base_.provider!;
        }

        public join(): Promise<void>
        {
            return this.base_.join();
        }

        public close(): Promise<void>
        {
            return this.base_.close();
        }
    }
}
```

#### [`apps/ConsumerApplication.tsx`]()

### 3.3. Supplier
#### [`core/supplier/ISupplier.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/supplier/ISupplier.ts)
#### [`core/supplier/Supplier.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/supplier/Supplier.ts)
```typescript
import { EventEmitter } from "events";

import { WebConnector } from "tgrid/protocols/web";
import { WorkerConnector, SharedWorkerConnector } from "tgrid/protocols/workers";
import { Driver } from "tgrid/basic";

import { IPointer } from "tstl/functional";
import { SupplierChannel } from "../market/SupplierChannel";

export class Supplier extends EventEmitter
{
    public readonly uid: number;

    /**
     * @hidden
     */
    private connector_: Connector;

    /* ----------------------------------------------------------------
        CONSTRUCTOR
    ---------------------------------------------------------------- */
    /**
     * @hidden
     */
    private constructor(uid: number, connector: Connector)
    {
        super();

        this.uid = uid;
        this.connector_ = connector;
    }

    public static async participate(url: string): Promise<Supplier>
    {
        // POINTERS - LAZY CONSTRUCTION
        let basePtr: IPointer<Supplier> = { value: null! };
        let workerPtr: IPointer<WorkerConnector> = { value: null! };

        // PREPARE ASSETS
        let provider = new Supplier.Provider(basePtr, workerPtr);
        let connector: WebConnector<Supplier.Provider> = new WebConnector(provider);
        let driver: Driver<SupplierChannel.IController> = connector.getDriver<SupplierChannel.IController>();

        // CONSTRUCT WORKER
        let worker: WorkerConnector = new WorkerConnector(driver.provider);
        workerPtr.value = worker;

        // CONNECTION & CONSTRUCTION
        await connector.connect(url);
        let ret: Supplier = new Supplier(await driver.getUID(), connector);
        basePtr.value = ret;

        // RETURNS
        return ret;
    }

    public assign(consumerUID: number): void
    {
        this.emit("assign", consumerUID);
    }

    public leave(): Promise<void>
    {
        return this.connector_.close();
    }
}

export namespace Supplier
{
    /**
     * @internal
     */
    export interface IController
    {
        provider: object;

        assign(consumerUID: number): void;
        compile(script: string, ...args: string[]): Promise<void>;
        close(): Promise<void>;
    }

    /**
     * @internal
     */
    export class Provider implements IController
    {
        private base_ptr_: IPointer<Supplier>;
        private worker_ptr_: IPointer<WorkerConnector>;

        /* ----------------------------------------------------------------
            CONSTRUCTOR
        ---------------------------------------------------------------- */
        public constructor(basePtr: IPointer<Supplier>, workerPtr: IPointer<WorkerConnector>)
        {
            this.base_ptr_ = basePtr;
            this.worker_ptr_ = workerPtr;
        }

        public assign(consumerUID: number): void
        {
            this.base_ptr_.value.assign(consumerUID);
        }

        public async compile(code: string, ...args: string[]): Promise<void>
        {
            // FOR SAFETY
            let state = this.worker_ptr_.value.state;
            if (state !== WorkerConnector.State.NONE && state !== WorkerConnector.State.CLOSED)
                await this.worker_ptr_.value.close();

            // DO COMPILE
            console.log("do compile", code.length, args.length);
            await this.worker_ptr_.value.compile(code, ...args);

            // EMIT EVENTS
            this.base_ptr_.value.emit("compile", code, ...args);
            this.worker_ptr_.value.join().then(() =>
            {
                this.base_ptr_.value.emit("close");
            });
        }

        public close(): Promise<void>
        {
            return this.worker_ptr_.value.close();
        }

        /* ----------------------------------------------------------------
            ACCESSORS
        ---------------------------------------------------------------- */
        public get provider(): Driver<object>
        {
            return this.worker_ptr_.value.getDriver<object>();
        }

        public isFree(): boolean
        {
            return this.worker_ptr_.value.state === WorkerConnector.State.NONE
                || this.worker_ptr_.value.state === WorkerConnector.State.CLOSED;
        }
    }
}

type Connector = WebConnector<Supplier.Provider> | SharedWorkerConnector<Supplier.Provider>;
```

#### [`apps/SupplierApplication.tsx`]()
```typescript
import "./polyfill";

import { Supplier } from "../core/supplier/Supplier";
import { StringUtil } from "../utils/StringUtil";

const TAB = "&nbsp;&nbsp;&nbsp;&nbsp;";
var CONSOLE_BOX!: HTMLDivElement;

function trace(...args: any[]): void
{
    let str: string = "";
    for (let elem of args)
        str += elem + " ";
    
    CONSOLE_BOX.innerHTML += str + "<br/>\n";
}

async function main(): Promise<void>
{
    let url: string = "ws://" + window.location.hostname + ":10101/supplier";
    let supp: Supplier =  await Supplier.participate(url);
    let time: number;

    CONSOLE_BOX = document.getElementById("consoleBox") as HTMLDivElement;
    
    //----
    // TRACE EVENTS
    //----
    // PRINT TITLE
    trace("Connection to market has succeded. Your uid is", supp.uid);
    trace();
    CONSOLE_BOX.innerHTML += "<hr/><br/>\n"

    // WHENEVER A CONSUMER BEING ASSIGNED
    supp.on("assign", (uid: number) =>
    {
        time = Date.now();
        trace(`Consumer #${uid} has bought your computing power.`);
        trace();
    });

    // COMPILE
    supp.on("compile", (code: string, ...args: string[]) =>
    {
        trace("The consumer requests you to compile a program");
        trace(`${TAB}- bytes of codes: #${StringUtil.numberFormat(code.length)}`);
        trace(`${TAB}- arguments: ${args.length ? args.toString() : "N/A"}`);
        trace();
    });

    // CLOSE
    supp.on("close", () => 
    {
        trace("The computation has been completed.");
        trace(`${TAB}- elapsed time: ${StringUtil.numberFormat(Date.now() - time)} ms`);
        trace();

        CONSOLE_BOX.innerHTML += "<hr/><br/>\n";
    });
}
window.onload = main;
```

### 3.4. Monitor
#### [`core/monitor/ConsumerNode.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/monitor/ConsumerNode.ts)
```typescript
import { HashMap } from "tstl/container/HashMap";
import { SupplierNode } from "./SupplierNode";

export class ConsumerNode
{
    public readonly uid: number;
    public readonly servants: HashMap<number, SupplierNode>;

    public constructor(uid: number)
    {
        this.uid = uid;
        this.servants = new HashMap();
    }
}
```

#### [`core/monitor/SupplierNode.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/monitor/SupplierNode.ts)
```typescript
import { ConsumerNode } from "./ConsumerNode";

export class SupplierNode
{
    public readonly uid: number;
    private assignee_: ConsumerNode | null;

    public constructor(uid: number)
    {
        this.uid = uid;
        this.assignee_ = null;
    }

    public get assignee(): ConsumerNode | null
    {
        return this.assignee_;
    }

    public assign(obj: ConsumerNode): void
    {
        this.assignee_ = obj;
    }
    public release(): void
    {
        this.assignee_ = null;
    }
}
```

#### [`core/monitor/Monitor.ts](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/monitor/Monitor.ts)
```typescript
import { WebConnector } from "tgrid/protocols/web";
import { SharedWorkerConnector } from "tgrid/protocols/workers";

import { EventEmitter } from "events";
import { HashMap } from "tstl/container/HashMap";
import { ConditionVariable } from "tstl/thread/ConditionVariable";
import { IPointer } from "tstl/functional/IPointer";

import { ConsumerNode } from "./ConsumerNode";
import { SupplierNode } from "./SupplierNode";
import { IConsumerNode } from "./IConsumerNode";
import { ISupplierNode } from "./ISupplierNode";

export class Monitor
{
    /**
     * @hidden
     */
    private connector_: Connector;

    /**
     * @hidden
     */
    private consumers_: HashMap<number, ConsumerNode>;

    /**
     * @hidden
     */
    private suppliers_: HashMap<number, SupplierNode>;

    /**
     * @hidden
     */
    private emitter_: EventEmitter;

    /* ----------------------------------------------------------------
        CONSTRUCTORS
    ---------------------------------------------------------------- */
    /**
     * @hidden
     */
    private constructor(connector: Connector)
    {
        this.connector_ = connector;

        this.consumers_ = new HashMap();
        this.suppliers_ = new HashMap();
        this.emitter_ = new EventEmitter();
    }

    /**
     * @internal
     */
    public static async participate(url: string): Promise<Monitor>
    {
        // PREPARE ASSETS
        let ptr: IPointer<Monitor> = { value: null! };
        let waitor: ConditionVariable = new ConditionVariable();

        let provider: Monitor.Provider = new Monitor.Provider(ptr, waitor);
        let connector: WebConnector = new WebConnector(provider);

        // LAZY CREATION
        ptr.value = new Monitor(connector);

        // CONNECT & WAIT MARKET
        await connector.connect(url);
        await waitor.wait();

        // RETURNS
        return ptr.value;
    }

    public leave(): Promise<void>
    {
        return this.connector_.close();
    }

    /* ----------------------------------------------------------------
        ACCESSORS
    ---------------------------------------------------------------- */
    public on(type: "refresh", listener: (consumers: HashMap<number, ConsumerNode>, suppliers: HashMap<number, SupplierNode>) => void): void
    {
        this.emitter_.on(type, listener);
    }

    public getConsumers(): HashMap<number, ConsumerNode>
    {
        return this.consumers_;
    }

    public getSuppliers(): HashMap<number, SupplierNode>
    {
        return this.suppliers_;
    }
    
    /**
     * @internal
     */
    public _Refresh(): void
    {
        this.emitter_.emit("refresh", this.consumers_, this.suppliers_);
    }
}

export namespace Monitor
{
    /**
     * @internal
     */
    export interface IController
    {
        assign(consumers: IConsumerNode[], suppliers: ISupplierNode[]): Promise<void>;

        insertConsumer(consumer :IConsumerNode): void;
        insertSupplier(supplier: ISupplierNode): void;
        eraseConsumer(uid: number): void;
        eraseSupplier(uid: number): void;

        link(consumer: number, supplier: number): void;
        release(uid: number): void;
    }

    /**
     * @internal
     */
    export class Provider implements IController
    {
        private ptr_: IPointer<Monitor>;
        private waitor_: ConditionVariable;

        /* ----------------------------------------------------------------
            CONSTRUCTORS
        ---------------------------------------------------------------- */
        public constructor(ptr: IPointer<Monitor>, waitor: ConditionVariable)
        {
            this.ptr_ = ptr;
            this.waitor_ = waitor;
        }

        public async assign(rawConsumers: IConsumerNode[], rawSuppliers: ISupplierNode[]): Promise<void>
        {
            let base: Monitor = this.ptr_.value;
            for (let raw of rawSuppliers)
                base.getSuppliers().emplace(raw.uid, new SupplierNode(raw.uid));
                
            for (let raw of rawConsumers)
            {
                let consumer: ConsumerNode = new ConsumerNode(raw.uid);
                for (let uid of raw.servants)
                {
                    let supplier: SupplierNode = base.getSuppliers().get(uid);
                    consumer.servants.emplace(uid, supplier);
                }
                base.getConsumers().emplace(raw.uid, consumer);
            }
            await this.waitor_.notify_all();
        }

        /* ----------------------------------------------------------------
            ELEMENTS I/O
        ---------------------------------------------------------------- */
        public insertConsumer(raw: IConsumerNode): void
        {
            let base: Monitor = this.ptr_.value;
            base.getConsumers().emplace(raw.uid, new ConsumerNode(raw.uid));
            base._Refresh();
        }

        public insertSupplier(raw: ISupplierNode): void
        {
            let base: Monitor = this.ptr_.value;
            base.getSuppliers().emplace(raw.uid, new SupplierNode(raw.uid));
            base._Refresh();
        }

        public eraseConsumer(uid: number): void
        {
            let base: Monitor = this.ptr_.value;
            
            let consumer: ConsumerNode = base.getConsumers().get(uid); 
            for (let entry of consumer.servants)
                entry.second.release();

            base.getConsumers().erase(uid);
            base._Refresh();
        }

        public eraseSupplier(uid: number): void
        {
            let base: Monitor = this.ptr_.value;

            let supplier: SupplierNode = base.getSuppliers().get(uid);
            if (supplier.assignee !== null)
                supplier.assignee.servants.erase(uid);

            supplier.release();
            base.getSuppliers().erase(uid);

            base._Refresh();
        }

        /* ----------------------------------------------------------------
            RELATIONSHIPS
        ---------------------------------------------------------------- */
        public link(customerUID: number, supplierUID: number): void
        {
            let base: Monitor = this.ptr_.value;
            let consumer: ConsumerNode = base.getConsumers().get(customerUID);
            let supplier: SupplierNode = base.getSuppliers().get(supplierUID);

            consumer.servants.emplace(supplier.uid, supplier);
            supplier.assign(consumer);

            base._Refresh();
        }

        public release(uid: number): void
        {
            let base: Monitor = this.ptr_.value;

            let supplier: SupplierNode = base.getSuppliers().get(uid);
            if (supplier.assignee !== null)
                supplier.assignee.servants.erase(uid);

            supplier.release();
            base._Refresh();
        }
    }
}

/**
 * @hidden
 */
type Connector = WebConnector | SharedWorkerConnector;
```