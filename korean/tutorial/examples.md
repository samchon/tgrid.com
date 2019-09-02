# Learn from Examples
## 1. Remote Function Call
### 1.1. Features
  - [`../controllers/ICalculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/controllers/ICalculator.ts#L8-L14)
  - [`../providers/Calculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/providers/Calculator.ts#L6-L28)

{% codegroup %}
```typescript::ICalculator.ts
export interface ISimpleCalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
}
```
```typescript::Calculator.ts
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

### 1.2. Server
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

### 1.3. Client
#### [`simple-calculator/client.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/simple-calculator/client.ts)
```typescript
import { WebConnector } from "tgrid/protocols/web/WebConnector";
import { Driver } from "tgrid/components/Driver";
import { ISimpleCalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // CONNECTION
    //----
    let connector: WebConnector = new WebConnector();
    await connector.connect("ws://127.0.0.1:10101");

    //----
    // CALL REMOTE FUNCTIONS
    //----
    // GET DRIVER
    let calc: Driver<ISimpleCalculator> = connector.getDriver<ISimpleCalculator>();

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

> ```python
> 1 + 3 = 4
> 7 - 4 = 3
> 8 x 9 = 72
> 4 / 0 -> Error: Divided by zero.
> ```




## 2. Remote Object Call
### 2.1. Features
  - [`../controllers/ICalculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/controllers/ICalculator.ts)
  - [`../providers/Calculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/providers/Calculator.ts)

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

### 2.2. Server
#### [`composite-calculator/server.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/composite-calculator/server.ts)
{% codegroup %}
```typescript::Remote Object Call
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
```typescript::Remote Function Call
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
{% endcodegroup %}

### 2.3. Client
#### [`composite-calculator/client.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/composite-calculator/client.ts)
{% codegroup %}
```typescript::Remote Object Call
import { WebConnector } from "tgrid/protocols/web";
import { Driver } from "tgrid/components";

import { ICompositeCalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // CONNECTION
    //----
    let connector: WebConnector = new WebConnector();
    await connector.connect("ws://127.0.0.1:10102");

    //----
    // CALL REMOTE FUNCTIONS
    //----
    // GET DRIVER
    let calc: Driver<ICompositeCalculator> = connector.getDriver<ICompositeCalculator>();

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
```typescript::Remote Function Call
import { WebConnector } from "tgrid/protocols/web/WebConnector";
import { Driver } from "tgrid/components";

import { ISimpleCalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // CONNECTION
    //----
    let connector: WebConnector = new WebConnector();
    await connector.connect("ws://127.0.0.1:10101");

    //----
    // CALL REMOTE FUNCTIONS
    //----
    // GET DRIVER
    let calc: Driver<ISimpleCalculator> = connector.getDriver<ISimpleCalculator>();

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
{% endcodegroup %}

> ```python
> 1 + 6 = 7
> 7 * 2 = 14
> 3 ^ 4 = 81
> log (2, 32) = 5
> SQRT (-4) -> Error: Negative value on sqaure.
> Mean (1, 2, 3, 4) = 2.5
> Stdev. (1, 2, 3, 4) = 1.118033988749895
> ```




## 3. Object Oriented Network
![diagram](../../assets/images/examples/composite-calculator.png) | ![diagram](../../assets/images/examples/hierarchical-calculator.png)
:-------------------:|:-----------------------:
Composite Calculator | Hierarchical Calculator

### 3.1. Features
  - [`../controllers/ICalculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/controllers/ICalculator.ts)
  - [`../providers/Calculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/providers/Calculator.ts)

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

### 3.2. Servers
#### [`hierarchical-calculator/scientific.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/hierarchical-calculator/scientific.ts)
```typescript
import { WorkerServer } from "tgrid/protocols/workers";
import { Scientific } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WorkerServer<Scientific> = new WorkerServer();
    await server.open(new Scientific());
}
main();
```

#### [`hierarchical-calculator/statistics.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/hierarchical-calculator/statistics.ts)
```typescript
import { WorkerServer } from "tgrid/protocols/workers";
import { Statistics } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WorkerServer<Statistics> = new WorkerServer();
    await server.open(new Statistics());
}
main();
```

####  [`hierarchical-calculator/calculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/hierarchical-calculator/calculator.ts)
{% codegroup %}
```typescript::Object Oriented Network
import { WorkerServer, WorkerConnector } from "tgrid/protocols/workers";
import { Driver } from "tgrid/components";

import { SimpleCalculator } from "../../providers/Calculator";
import { IScientific, IStatistics } from "../../controllers/ICalculator";

class HierarchicalCalculator extends SimpleCalculator
{
    // REMOTE CALCULATOR
    public scientific: Driver<IScientific>;
    public statistics: Driver<IStatistics>;
}

async function link<Controller extends object>
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
    let calc: HierarchicalCalculator = new HierarchicalCalculator();
    calc.scientific = await link<IScientific>("scientific.js");
    calc.statistics = await link<IStatistics>("statistics.js");

    // OPEN SERVER
    let server = new WorkerServer();
    await server.open(calc);
}
main();
```
```typescript::Remote Object Call
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
{% endcodegroup %}

### 3.3. Client
#### [`hierarchical-calculator/index.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/hierarchical-calculator/index.ts)
{% codegroup %}
```typescript::Object Oriented Network
import { WorkerConnector } from "tgrid/protocols/workers";
import { Driver } from "tgrid/components";

import { ICompositeCalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // CONNECTION
    //----
    let connector: WorkerConnector = new WorkerConnector();
    await connector.connect(__dirname + "/calculator.js");

    //----
    // CALL REMOTE FUNCTIONS
    //----
    // GET DRIVER
    let calc: Driver<ICompositeCalculator> = connector.getDriver<ICompositeCalculator>();

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
```typescript::Remote Object Call
import { WebConnector } from "tgrid/protocols/web";
import { Driver } from "tgrid/components";

import { ICompositeCalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // CONNECTION
    //----
    let connector: WebConnector = new WebConnector();
    await connector.connect("ws://127.0.0.1:10102");
    
    //----
    // CALL REMOTE FUNCTIONS
    //----
    // GET DRIVER
    let calc: Driver<ICompositeCalculator> = connector.getDriver<ICompositeCalculator>();

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
{% endcodegroup %}

> ```python
> 1 + 6 = 7
> 7 * 2 = 14
> 3 ^ 4 = 81
> log (2, 32) = 5
> SQRT (-4) -> Error: Negative value on sqaure.
> Mean (1, 2, 3, 4) = 2.5
> Stdev. (1, 2, 3, 4) = 1.118033988749895
> ```




## 4. Remote Critical Section
### 4.1. Server
#### [`thread/child.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/thread/child.ts)
```typescript
import { WorkerServer } from "tgrid/protocol/worker";
import { Driver } from "tgrid/components";

import { Mutex, sleep_for } from "tstl/thread";
import { randint } from "tstl/algorithm";

interface IController
{
    mutex: Mutex;
    print(character: string): void;
}

async function main(character: string): Promise<void>
{
    // PREPARE SERVER & DRIVER
    let server: WorkerServer = new WorkerServer();
    let driver: Driver<IController> = server.getDriver<IController>();

    // REMOTE FUNCTION CALLS
    await driver.mutex.lock();
    {
        // RANDOM SLEEP -> SEQUENCE WOULD BE SHUFFLED
        await sleep_for(randint(50, 100));

        // PRINT A LINE WITH REPEATED LETTERS
        for (let i: number = 0; i < 20; ++i)
        {
            await driver.print(character); // PRINT A LETTER
            await sleep_for(randint(50, 100)); // RANDOM SLEEP
        }
        await driver.print("\n");
    }
    await driver.mutex.unlock();

    // CLOSE THE SERVER (WORKER)
    await server.close();
}
main(randint(0, 9) + "");
```

### 4.2. Client
#### [`thread/index.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/thread/index.ts)
```typescript
import { WorkerConnector } from "tgrid/protocols/workers";

import { Vector } from "tstl/container";
import { Mutex } from "tstl/thread";

// FEATURES TO PROVIDE
namespace provider
{
    export var mutex = new Mutex();
    export function print(str: string): void
    {
        process.stdout.write(str);
    }
}

async function main(): Promise<void>
{
    let workers: Vector<WorkerConnector<typeof provider>> = new Vector();

    //----
    // CREATE WORKERS
    //----
    for (let i: number = 0; i < 4; ++i)
    {
        // CONNECT TO WORKER
        let w = new WorkerConnector(provider);
        await w.connect(__dirname + "/child.js");

        // ENROLL IT
        workers.push_back(w);
    }

    //----
    // WAIT THEM TO BE CLOSED
    //----
    await Promise.all(workers.map(w => w.join()));
}
main();
```

> ```python
> 11111111111111111111
> 88888888888888888888
> 44444444444444444444
> 33333333333333333333
> ```