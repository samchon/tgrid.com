# Learn from Examples
## 1. Remote Function Call
Remote Function Call 이 무엇인지, 그리고 어떻게 사용하는 것인지, 예제를 통해 알아봅시다. 우리가 이번에 예제로 만들어볼 것은 원격 계산기로써, 서버는 간단한 사칙연산 계산기를 제공할 것이며 (provides), 클라이언트는 이를 사용하여 계산을 수행할 (remote function calls) 것입니다.

  - 서버: 사칙연산 제공
  - 클라이언트: 사칙연산 사용

### 1.1. Features
`ISimpleCalculator` 는 서버로부터 클라이언트에게 제공되는 함수들을 정의한 인터페이스입니다. 혹 벌써 눈치채신 분들도 계실 겁니다. 그렇습니다, `ISimpleCalculator` 는 바로 [Controller](concepts.md#23-controller) 가 될 녀석입니다. 그렇다면, `SimpleCalculator` 의 역할은 무얼까요? 맞습니다, 서버에서 사용할 [Provider](concepts.md#22-provider) 를 구현한 클래스입니다.

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
앞서 얘기하기를, 이번 예제에서 서버의 역할이란, 클라이언트에게 사칙연산 계산기를 제공한다는 것이었습니다. 그렇다면, 서버 프로그램에 작성해야 할 코드는 간단합니다. 서버를 개설하고, 해당 서버로 접속해오는 클라이언트들에게 사칙연산 계산기 `SimpleCalculator` (be [Provider](concepts.md#22-provider)) 를 제공하는 것입니다.

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
드디어 대망의 클라이언트 프로그램을 만들 차례가 다가왔습니다. 대체 그놈의 Remote Function Call 이 무엇인지, 아래 두 코드를 비교해보시면 단박에 이해하실 수 있으실 겁니다. 두 코드를 비교해보시면, 클라이언트가 서버에서 제공하는 원격 계산기를 사용하는 코드와, 단일 프로그램에서 자체 계산기 클래스를 사용하는 코드가 비슷함을 확인하실 수 있습니다.

이를 전문적인 용어로, 비지니스 로직 (Business Logic) 코드가 완전히 유사하다고 말합니다. 물론, 두 코드가 완벽하게 100 % 일치하지는 않습니다. 도메인 로직으로써 클라이언트가 서버에 접속을 해야 한다던가, 비지니스 로직 코드부에 원격 함수를 호출할 때마다 `await` 이라는 심벌이 추가로 붙는다던가 하는 등의 소소한 차이점들은 존재하기 때문입니다. 하지만, 근본적으로 두 코드의 비지니스 로직부는 완벽하게 동질의 것이며, 이로써 비지니스 로직을 네트워크 시스템으로부터 완벽하게 분리해낼 수 있었습니다. 제 주장에 동의하시는지요?

> 17 번째 라인을 보면 클라이언트가 서버로의 접속을 마친 후, 원격 함수를 호출하기 위해 [Communicator](concepts.md#21-communicator) 로부터 `connector.getDriver<ISimpleCalculator>()` 메서드를 호출함으로써 [Driver](concepts.md#23-driver)<[Controller](concepts.md#24-controller)> 객체를 구성한 것을 보실 수 있습니다. 원격 시스템이 제공하는 [Provider](concepts.md#22-provider) 에 대한 모든 원격 함수 호출은 언제나 이 [Driver](concepts.md#23-driver)<[Controller](concepts.md#24-controller)> 를 통해 이루어집니다. 
>
> 이 부분은 앞으로 모든 튜토리얼에서 계속하여 반복될 내용입니다. 꼭 숙지해주세요.

#### [`simple-calculator/client.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/simple-calculator/client.ts)
{% codegroup %}
```typescript::Remote Function Call
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
```typescript::Single Program
import { SimpleCalculator } from "../../controllers/Calculator";

function main(): void
{
    //----
    // CALL FUNCTIONS
    //----
    // CONSTRUCT CALCULATOR
    let calc: SimpleCalculator = new SimpleCalculator();

    // CALL FUNCTIONS DIRECTLY
    console.log("1 + 3 =", calc.plus(1, 3));
    console.log("7 - 4 =", calc.minus(7, 4));
    console.log("8 x 9 =", calc.multiplies(8, 9));

    // TO CATCH EXCEPTION
    try 
    {
        calc.divides(4, 0);
    }
    catch (err)
    {
        console.log("4 / 0 -> Error:", err.message);
    }
}
main();
```
{% endcodegroup %}

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