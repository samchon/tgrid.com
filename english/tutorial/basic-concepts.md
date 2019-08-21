# Tutorial - Basic Concepts
## 1. Concepts
### 1.1. Communicator
Communicator for remote systems.

The `Communicator` is an object taking full charge of network communications and being a bridge between `Controller` and `Provider`. Sequence of the remote function call is like such below:

![Sequence Diagram](../../assets/images/diagrams/sequence.png)

### 1.2. Provider
Provider for remote system.

`Provider` is an object *providing functions* to remote system. Functions in the `Provider` object are provided to the remote system through the `Communicators`. The remote system can call those functions by using the `Driver<Controller>`.

```typescript
class Calculator // Can be a "Provider"
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
}
```

### 1.3. Controller
Controller (with Driver) for remote system.

The `Controller` is an interface who defines provided functions from the remote system. The `Driver` is an object who makes to call remote functions, defined in the `Controller` and provided by `Provider` in the remote system, possible.

In other words, calling a functions in the `Driver<Controller>`, it means to call a matched function in the remote system's `Provider` object.

  - `Controller`: Definition only
  - `Driver`: Remote Function Call

```typescript
// Can be a "Controller"
interface ICalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
}

// Driver makes remote function call possible
type Driver<ICalculator> = 
{
    plus(x: number, y: number): Promise<number>;
    minus(x: number, y: number): Promise<number>;
    multiplies(x: number, y: number): Promise<number>;
    divides(x: number, y: number): Promise<number>;
};
```




## 2. Remote Function Call
To understand how to handle remote functions, I provide an example code that is an implementation of a *Remote Calculator*. Server provides the simple (the four fundamental) arithmetic operations and clients use those operations.

  - Server: Provide operations.
  - Client: Use those operations.

### 2.1. Interface
The interface `ISimpleCalculator` defines which operations are provided from server to client. Someone who smart already noticed what the `ISimpleCalculator` is for. Yes, it would be [Controller](#13-controller) in client system. The class `SimpleCalculator` is implementation of those operations and it would be the [Provider](#12-provider) in server system.

  - `ISimpleCalculator` -> be [Controller](#13-controller)
  - `SimpleCalculator` -> be [Provider](#12-provider)

{% codegroup %}
```typescript::Controller
export interface ISimpleCalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
}
```
```typescript::Provider
export class SimpleCalculator implements ISimpleCalculator
{
    public plus(x: number, y: number): number
    {
        return x + y;
    }
    public minus(x: number, y: number): number
    {
        return x - y;
    }
    
    public multiplies(x: number, y: number): number
    {
        return x * y;
    }
    public divides(x: number, y: number): number
    {
        if (y === 0)
            throw new Error("Divided by zero.");
        return x / y;
    }
}
```
{% endcodegroup %}

### 2.2. Server
As I've mentioned in the interface section, server provides the four arithmetic operations to client(s). Clients may request those operations and server may replies solutions of them. Thus, the server configures the `SimpleCalculator` to be [Provider](#12-provider).

#### [`simple-calculator/server.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/simple-calculator/server.ts)
```typescript
import { WebServer, WebAcceptor } from "tgrid/protocols/web";
import { SimpleCalculator } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WebServer = new WebServer();
    await server.open(10101, async (acceptor: WebAcceptor) =>
    {
        await acceptor.accept(new SimpleCalculator());
    });
}
main();
```

### 2.3. Client
To call functions in the server, client should get [Driver\<Controller>](#13-controller) instance. Following the below implementation code, you can see the program initialize a [Driver\<Controller>](#13-controller) instance by using that method; `connector.getDriver<ISimpleCalculator>()`. After that, the program calls functions in the server with the [Driver\<Controller>](#13-controller) instance and `await` statement. 

#### [`simple-calculator/client.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/simple-calculator/client.ts)
```typescript
import { WebConnector } from "tgrid/protocols/web";
import { Driver } from "tgrid/basic";
import { ISimpleCalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // PREPARES
    //----
    // DO CONNECT
    let connector: WebConnector = new WebConnector();
    await connector.connect("ws://127.0.0.1:10101");

    // GET DRIVER
    let calc: Driver<ISimpleCalculator> = connector.getDriver<ISimpleCalculator>();

    //----
    // CALL FUNCTIONS
    //----
    // CALL FUNCTIONS WITH AWAIT SYMBOL
    console.log("1 + 3 =", await calc.plus(1, 3));
    console.log("7 - 4 =", await calc.minus(7, 4));
    console.log("8 x 9 =", await calc.multiplies(8, 9));

    // TO CATCH EXCEPTION IS ALSO POSSIBLE
    try 
    {
        await calc.divides(4, 0);
    }
    catch (err)
    {
        console.log("4 / 0 -> Error:", err.message);
    }

    //----
    // TERMINATE
    //----
    await connector.close();
}
main();
```

> ```console
> 1 + 3 = 4
> 7 - 4 = 3
> 8 x 9 = 72
> 4 / 0 -> Error: Divided by zero.
> ```




## 3. Remote Object Call
Until now, we've only handled singular objects which do not have any composite structure. Functions have always defined in the top level. However, imagine a situation; you're preparing a remote system who has enormous features. Because of too many features, you should consider the composite structure.

In that case, how should you do that? Answer of **TGrid** is simple and clear. *Just Do It*. Define the interface to have the composite structure like below. That's all.

### 3.1. Interface
To demonstrate the composite call, we'll evolve the previous *Remote Calculator*. In addition to the ordinary (four arithmetic) operations, we'll add `scientific` and `statistics` operations. Of course, those operations would be placed in composite scopes. 

Look at the interface `ICompositeCalculator` and find what has been changed.

{% codegroup %}
```typescript::ICalculator.ts
export interface ICompositeCalculator 
    extends ISimpleCalculator
{
    scientific: IScientific;
    statistics: IStatistics;
}

export interface ISimpleCalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
}
export interface IScientific
{
    pow(x: number, y: number): number;
    sqrt(x: number): number;
    log(x: number, y: number): number;
}
export interface IStatistics
{
    mean(...elems: number[]): number;
    stdev(...elems: number[]): number;
}
```
```typescript::Calculator.ts
import { 
    ICompositeCalculator, 
    ISimpleCalculator, IScientific, IStatistics
} from "../controllers/ICalculator";

export class SimpleCalculator 
    implements ISimpleCalculator
{
    public plus(x: number, y: number): number
    {
        return x + y;
    }
    public minus(x: number, y: number): number
    {
        return x - y;
    }
    
    public multiplies(x: number, y: number): number
    {
        return x * y;
    }
    public divides(x: number, y: number): number
    {
        if (y === 0)
            throw new Error("Divided by zero.");
        return x / y;
    }
}

export class CompositeCalculator 
    extends SimpleCalculator 
    implements ICompositeCalculator
{
    public scientific = new Scientific();
    public statistics = new Statistics();
}

export class Scientific implements IScientific
{
    public pow(x: number, y: number): number
    {
        return Math.pow(x, y);
    }

    public log(x: number, y: number): number
    {
        if (x < 0 || y < 0)
            throw new Error("Negative value on log.");
        return Math.log(y) / Math.log(x);
    }

    public sqrt(x: number): number
    {
        if (x < 0)
            throw new Error("Negative value on sqaure.");
        return Math.sqrt(x);
    }
}

export class Statistics implements IStatistics
{
    public mean(...elems: number[]): number
    {
        let ret: number = 0;
        for (let val of elems)
            ret += val;
        return ret / elems.length;
    }

    public stdev(...elems: number[]): number
    {
        let mean: number = this.mean(...elems);
        let ret: number = 0;

        for (let val of elems)
            ret += Math.pow(val - mean, 2);

        return Math.sqrt(ret / elems.length);
    }
}
```
{% endcodegroup %}

### 3.2. Server
Nothing to be changed in the server implementation. Just keep configuring the `CompositeCalculator` to be [Provider](#12-provider).

#### [`composite-calculator/server.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/composite-calculator/server.ts)
```typescript
import { WebServer, WebAcceptor } from "tgrid/protocols/web";
import { CompositeCalculator } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WebServer = new WebServer();
    await server.open(10102, async (acceptor: WebAcceptor) =>
    {
        await acceptor.accept(new CompositeCalculator());
    });
}
main();
```

### 3.3. Client
Any special description is required? Just enjoy the code `\o/`.

#### [`composite-calculator/client.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/composite-calculator/client.ts)
```typescript
import { WebConnector } from "tgrid/protocols/web";
import { Driver } from "tgrid/basic";

import { ICompositeCalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // PREPARES
    //----
    // DO CONNECT
    let connector: WebConnector = new WebConnector();
    await connector.connect("ws://127.0.0.1:10102");

    // GET DRIVER
    let calc: Driver<ICompositeCalculator> = connector.getDriver<ICompositeCalculator>();
    
    //----
    // CALL FUNCTIONS
    //----
    // FUNCTIONS IN THE ROOT SCOPE
    console.log("1 + 6 =", await calc.plus(1, 6));
    console.log("7 * 2 =", await calc.multiplies(7, 2));

    // FUNCTIONS IN AN OBJECT (SCIENTIFIC)
    console.log("3 ^ 4 =", await calc.scientific.pow(3, 4));
    console.log("log (2, 32) =", await calc.scientific.log(2, 32));

    try
    {
        // TO CATCH EXCEPTION IS STILL POSSIBLE
        await calc.scientific.sqrt(-4);
    }
    catch (err)
    {
        console.log("SQRT (-4) -> Error:", err.message);
    }

    // FUNCTIONS IN AN OBJECT (STATISTICS)
    console.log("Mean (1, 2, 3, 4) =", await calc.statistics.mean(1, 2, 3, 4));
    console.log("Stdev. (1, 2, 3, 4) =", await calc.statistics.stdev(1, 2, 3, 4));

    //----
    // TERMINATE
    //----
    await connector.close();
}
main();
```

> ```console
> 1 + 6 = 7
> 7 * 2 = 14
> 3 ^ 4 = 81
> log (2, 32) = 5
> SQRT (-4) -> Error: Negative value on sqaure.
> Mean (1, 2, 3, 4) = 2.5
> Stdev. (1, 2, 3, 4) = 1.118033988749895
> ```



## 4. Object Oriented Network
Let's make the composite calculator again, but change it something different; *hierarchical-calculator*. The composite calculator had partial calculators (scientific & statistic) as inline objects. The new hierarchical-calculator would change the partial calculators to be independent remote systems.

Composite Calculator | Hierarchical Calculator
:-------------------:|:-----------------------:
![diagram](../../assets/images/examples/composite-calculator.png) | ![diagram](../../assets/images/examples/hierarchical-calculator.png)

### 4.1. Internal Files
{% codegroup %}
```typescript::Controller
export interface ICompositeCalculator 
    extends ISimpleCalculator
{
    scientific: IScientific;
    statistics: IStatistics;
}

export interface ISimpleCalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
}
export interface IScientific
{
    pow(x: number, y: number): number;
    sqrt(x: number): number;
    log(x: number, y: number): number;
}
export interface IStatistics
{
    mean(...elems: number[]): number;
    stdev(...elems: number[]): number;
}
```
```typescript::Controller
import { 
    ICompositeCalculator, 
    ISimpleCalculator, IScientific, IStatistics
} from "../controllers/ICalculator";

export class SimpleCalculator 
    implements ISimpleCalculator
{
    public plus(x: number, y: number): number
    {
        return x + y;
    }
    public minus(x: number, y: number): number
    {
        return x - y;
    }
    
    public multiplies(x: number, y: number): number
    {
        return x * y;
    }
    public divides(x: number, y: number): number
    {
        if (y === 0)
            throw new Error("Divided by zero.");
        return x / y;
    }
}

export class CompositeCalculator 
    extends SimpleCalculator 
    implements ICompositeCalculator
{
    public scientific = new Scientific();
    public statistics = new Statistics();
}

export class Scientific implements IScientific
{
    public pow(x: number, y: number): number
    {
        return Math.pow(x, y);
    }

    public log(x: number, y: number): number
    {
        if (x < 0 || y < 0)
            throw new Error("Negative value on log.");
        return Math.log(y) / Math.log(x);
    }

    public sqrt(x: number): number
    {
        if (x < 0)
            throw new Error("Negative value on sqaure.");
        return Math.sqrt(x);
    }
}

export class Statistics implements IStatistics
{
    public mean(...elems: number[]): number
    {
        let ret: number = 0;
        for (let val of elems)
            ret += val;
        return ret / elems.length;
    }

    public stdev(...elems: number[]): number
    {
        let mean: number = this.mean(...elems);
        let ret: number = 0;

        for (let val of elems)
            ret += Math.pow(val - mean, 2);

        return Math.sqrt(ret / elems.length);
    }
}
```
{% endcodegroup %}

### 4.2. Remote Systems
{% codegroup %}
```typescript::calculator.ts
import { WorkerServer, WorkerConnector } from "tgrid/protocols/workers";
import { Driver } from "tgrid/basic";

import { SimpleCalculator } from "../../providers/Calculator";
import { IScientific, IStatistics } from "../../controllers/ICalculator";

class HierarchicalCalculator extends SimpleCalculator
{
    // REMOTE CALCULATOR
    public scientific: Driver<IScientific>;
    public statistics: Driver<IStatistics>;
}

async function get<Controller extends object>
    (path: string): Promise<Driver<Controller>>
{
    // DO CONNECT
    let connector = new WorkerConnector();
    await connector.connect(__dirname + "/" + path);

    // RETURN DRIVER
    return connector.getDriver<Controller>();
}

async function main(): Promise<void>
{
    // PREPARE REMOTE CALCULATOR
    let calc = new HierarchicalCalculator();
    calc.scientific = await get<IScientific>("scientific.js");
    calc.statistics = await get<IStatistics>("statistics.js");

    // OPEN SERVER
    let server = new WorkerServer();
    await server.open(calc);
}
main();
```
```typescript::scientific.ts
import { WorkerServer } from "tgrid/protocols/workers";
import { Scientific } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WorkerServer<Scientific> = new WorkerServer();
    await server.open(new Scientific());
}
main();
```
```typescript::statistics.ts
import { WorkerServer } from "tgrid/protocols/workers";
import { Statistics } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WorkerServer<Statistics> = new WorkerServer();
    await server.open(new Statistics());
}
main();
```
{% endcodegroup %}

### 4.3. Index
#### [`hierarchical-calculator/index.ts`](https://github.com/samchon/tgrid.examples/tree/master/src/projects/hierarchical-calculator/index.ts)
```typescript
import { WorkerConnector } from "tgrid/protocols/workers";
import { Driver } from "tgrid/basic";

import { ICompositeCalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // PREPARATIONS
    //----
    // DO CONNECT
    let connector: WorkerConnector = new WorkerConnector();
    await connector.connect(__dirname + "/calculator.js");

    // GET DRIVER
    let calc: Driver<ICompositeCalculator> = connector.getDriver<ICompositeCalculator>();

    //----
    // CALL REMOTE FUNCTIONS
    //----
    // FUNCTIONS IN THE ROOT SCOPE
    console.log("1 + 6 =", await calc.plus(1, 6));
    console.log("7 * 2 =", await calc.multiplies(7, 2));

    // FUNCTIONS IN AN OBJECT (SCIENTIFIC)
    console.log("3 ^ 4 =", await calc.scientific.pow(3, 4));
    console.log("log (2, 32) =", await calc.scientific.log(2, 32));

    try
    {
        // TO CATCH EXCEPTION IS STILL POSSIBLE
        await calc.scientific.sqrt(-4);
    }
    catch (err)
    {
        console.log("SQRT (-4) -> Error:", err.message);
    }

    // FUNCTIONS IN AN OBJECT (STATISTICS)
    console.log("Mean (1, 2, 3, 4) =", await calc.statistics.mean(1, 2, 3, 4));
    console.log("Stdev. (1, 2, 3, 4) =", await calc.statistics.stdev(1, 2, 3, 4));

    //----
    // TERMINATE
    //----
    await connector.close();
}
main().catch(exp =>
{
    console.log(exp);
});
```

> ```bash
> 1 + 6 = 7
> 7 * 2 = 14
> 3 ^ 4 = 81
> log (2, 32) = 5
> SQRT (-4) -> Error: Negative value on sqaure.
> Mean (1, 2, 3, 4) = 2.5
> Stdev. (1, 2, 3, 4) = 1.118033988749895
> ```




## 5. Advanced Training
Do you remember? None of function in the `ICompositeCalculator` returns the `Promise` typed value. However, the program is using the `await` statement to all remote funtion calls. Can you explain why? 

Well, if you're smart to remember the `Driver`, you may answer "the reason is on the Drvier". It's right, the reason is on the `Driver`. Then let's study how the `Driver` converted return type of remote functions to be promisified.

```typescript
declare class WebConnector
{
    public getDriver<Controller extends object>(): Driver<T>;
}

declare class Driver<Controller extends object> 
    extends Proxy<Promisify<Controller>> 
{
}

declare type Promisify<Instance extends object> = 
    // IS FUNCTION?
    Instance extends Function
        ? Instance extends (...args: infer Params) => infer Ret
            ? Ret extends Promise<any>
                ? (...args: Params) => Ret
                : (...args: Params) => Promise<Ret>
            : (...args: any[]) => Promise<any>
    : 
    { // IS OBJECT?
        [P in keyof Instance]: Instance[P] extends (...args: any[]) => any
            ? Promisify<Instance[P]>
            : Instance[P] extends object
                ? Promisify<Instance[P]>
                : never;
    };
```

As you can see, the `Driver` type converts all functions to return `Promise<T>` typed value using the `Promisify` type. By the `Promisify` type, `ICompositeCalculator` is converted like such below and it's reason why the program uses `await` symbol.

```typescript
type ICompositeCalculator = 
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;

    scientific:
    {
        pow(x: number, y: number): number;
        sqrt(x: number): number;
        log(x: number, y: number): number;
    };
    statistics:
    {
        mean(...elems: number[]): number;
        stdev(...elems: number[]): number;
    };
};

type Promisify<ICompositeCalculator> = 
{
    // FUNCTIONS TO RETURN PROMISE TYPE
    plus(x: number, y: number): Promise<number>;
    minus(x: number, y: number): Promise<number>;
    multiplies(x: number, y: number): Promise<number>;
    divides(x: number, y: number): Promise<number>;

    // OBJECT TYPES ARE CONVERTED TO `Driver<Object>`
    scientific:
    {
        pow(x: number, y: number): Promise<number>;
        sqrt(x: number): Promise<number>;
        log(x: number, y: number): Promise<number>;
    };
    statistics:
    {
        mean(...elems: number[]): Promise<number>;
        stdev(...elems: number[]): Promise<number>;
    };
};
```